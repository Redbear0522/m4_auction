package com.auction.scheduler;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.util.Timer;
import java.util.TimerTask;
import java.sql.*;
import static com.auction.common.JDBCTemplate.*;
import com.auction.dao.TransactionLogDAO;

/**
 * 경매 자동 종료를 위한 스케줄러
 * 1분마다 실행되어 종료 시간이 지난 경매를 자동으로 마감합니다.
 */
@WebListener
public class AuctionScheduler implements ServletContextListener {
    
    private Timer timer;
    
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AuctionScheduler] 경매 스케줄러 시작...");
        
        timer = new Timer("AuctionSchedulerTimer");
        
        // 1분마다 실행 (60000ms = 60초)
        timer.scheduleAtFixedRate(new AuctionCloseTask(), 10000, 60000); // 시작 10초 후, 1분마다
    }
    
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AuctionScheduler] 경매 스케줄러 종료...");
        if (timer != null) {
            timer.cancel();
        }
    }
    
    /**
     * 경매 종료 작업
     */
    private class AuctionCloseTask extends TimerTask {
        @Override
        public void run() {
            System.out.println("[AuctionScheduler] 경매 종료 체크 시작: " + new java.util.Date());
            
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;
            
            try {
                conn = getConnection();
                conn.setAutoCommit(false); // 트랜잭션 시작
                
                // 1. 종료 시간이 지났지만 아직 상태가 'A'(진행중)인 경매 조회
                String selectSql = 
                    "SELECT P.PRODUCT_ID, P.PRODUCT_NAME, P.SELLER_ID, P.CURRENT_PRICE, P.START_PRICE, " +
                    "       B.BIDDER_ID AS FINAL_BIDDER " +
                    "FROM PRODUCT P " +
                    "LEFT JOIN ( " +
                    "    SELECT PRODUCT_ID, BIDDER_ID " +
                    "    FROM BID " +
                    "    WHERE (PRODUCT_ID, BID_PRICE) IN ( " +
                    "        SELECT PRODUCT_ID, MAX(BID_PRICE) " +
                    "        FROM BID " +
                    "        GROUP BY PRODUCT_ID " +
                    "    ) " +
                    ") B ON P.PRODUCT_ID = B.PRODUCT_ID " +
                    "WHERE P.END_TIME <= SYSDATE " +
                    "AND P.STATUS = 'A'";
                
                pstmt = conn.prepareStatement(selectSql);
                rs = pstmt.executeQuery();
                
                int closedCount = 0;
                
                while (rs.next()) {
                    int productId = rs.getInt("PRODUCT_ID");
                    String productName = rs.getString("PRODUCT_NAME");
                    String sellerId = rs.getString("SELLER_ID");
                    long currentPrice = rs.getLong("CURRENT_PRICE");
                    long startPrice = rs.getLong("START_PRICE");
                    String finalBidder = rs.getString("FINAL_BIDDER");
                    
                    // 최종 가격 결정 (입찰이 있으면 현재가, 없으면 시작가)
                    long finalPrice = (currentPrice > 0) ? currentPrice : startPrice;
                    
                    // 2. 경매 상태 업데이트
                    String updateSql = 
                        "UPDATE PRODUCT SET STATUS = 'E', " +
                        "FINAL_PRICE = ?, " +
                        "WINNER_ID = ? " +
                        "WHERE PRODUCT_ID = ?";
                    
                    PreparedStatement updatePstmt = conn.prepareStatement(updateSql);
                    updatePstmt.setLong(1, finalPrice);
                    updatePstmt.setString(2, finalBidder);
                    updatePstmt.setInt(3, productId);
                    updatePstmt.executeUpdate();
                    updatePstmt.close();
                    
                    // 3. 낙찰자가 있는 경우 처리
                    if (finalBidder != null) {
                        // 3-1. 낙찰자 마일리지 차감 확인
                        String checkSql = "SELECT MILEAGE FROM USERS WHERE MEMBER_ID = ?";
                        PreparedStatement checkPstmt = conn.prepareStatement(checkSql);
                        checkPstmt.setString(1, finalBidder);
                        ResultSet checkRs = checkPstmt.executeQuery();
                        
                        long bidderMileage = 0;
                        if (checkRs.next()) {
                            bidderMileage = checkRs.getLong("MILEAGE");
                        }
                        checkRs.close();
                        checkPstmt.close();
                        
                        if (bidderMileage >= finalPrice) {
                            // 3-2. 낙찰자 마일리지 차감
                            String deductSql = "UPDATE USERS SET MILEAGE = MILEAGE - ? WHERE MEMBER_ID = ?";
                            PreparedStatement deductPstmt = conn.prepareStatement(deductSql);
                            deductPstmt.setLong(1, finalPrice);
                            deductPstmt.setString(2, finalBidder);
                            deductPstmt.executeUpdate();
                            deductPstmt.close();
                            
                            // 3-3. 판매자에게 마일리지 지급 (수수료 5% 제외)
                            long sellerAmount = (long)(finalPrice * 0.95);
                            String addSql = "UPDATE USERS SET MILEAGE = MILEAGE + ? WHERE MEMBER_ID = ?";
                            PreparedStatement addPstmt = conn.prepareStatement(addSql);
                            addPstmt.setLong(1, sellerAmount);
                            addPstmt.setString(2, sellerId);
                            addPstmt.executeUpdate();
                            addPstmt.close();
                            
                            // 3-4. 거래 로그 기록
                            TransactionLogDAO logDao = new TransactionLogDAO();
                            logDao.insertLog(conn, finalBidder, "W", -finalPrice, productId);
                            logDao.insertLog(conn, sellerId, "S", sellerAmount, productId);
                            
                            System.out.println("[경매종료] " + productName + " - 낙찰자: " + finalBidder + ", 금액: " + finalPrice + ", 판매자 수령: " + sellerAmount);
                        } else {
                            // 마일리지 부족으로 유찰
                            System.out.println("[경매종료] " + productName + " - 낙찰자 마일리지 부족으로 유찰 (보유: " + bidderMileage + ", 필요: " + finalPrice + ")");
                            
                            String failSql = "UPDATE PRODUCT SET STATUS = 'F', WINNER_ID = NULL WHERE PRODUCT_ID = ?";
                            PreparedStatement failPstmt = conn.prepareStatement(failSql);
                            failPstmt.setInt(1, productId);
                            failPstmt.executeUpdate();
                            failPstmt.close();
                        }
                    } else {
                        // 입찰자가 없어서 유찰
                        System.out.println("[경매종료] " + productName + " - 입찰자 없음으로 유찰");
                    }
                    
                    closedCount++;
                }
                
                conn.commit(); // 트랜잭션 커밋
                
                if (closedCount > 0) {
                    System.out.println("[AuctionScheduler] 총 " + closedCount + "개의 경매가 종료되었습니다.");
                }
                
            } catch (Exception e) {
                System.err.println("[AuctionScheduler] 경매 종료 처리 중 오류 발생");
                e.printStackTrace();
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
            } finally {
                close(rs);
                close(pstmt);
                close(conn);
            }
        }
    }
}