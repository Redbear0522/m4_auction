package com.auction.dao;

import com.auction.dto.ChargeRequestDTO;
import com.auction.dto.ProductDTO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import static com.auction.common.JDBCTemplate.*;

public class AdminDAO {

    /** 전체 상품 수 조회 */
    public int selectTotalProducts(Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) FROM product";
        try (
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    /** 승인 대기 상품 수 조회 (status = 'P') */
    public int selectPendingProducts(Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) FROM product WHERE status = 'P'";
        try (
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    /** 전체 입찰 건수 조회 */
    public int selectTotalBids(Connection conn) throws SQLException {
        String sql = "SELECT COUNT(*) FROM bid";
        try (
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    /** 총 낙찰 금액 합계 조회 (status = 'F') */
    public long selectTotalRevenue(Connection conn) throws SQLException {
        String sql = "SELECT NVL(SUM(final_price), 0) FROM product WHERE status = 'F'";
        try (
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery()
        ) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        return 0L;
    }

    /** 승인 대기 중인 상품 목록 조회 (status = 'P') */
    public List<ProductDTO> selectPendingProductsList(Connection conn) throws SQLException {
        String sql = "SELECT product_id, product_name, start_price, image_renamed_name, seller_id "
                   + "FROM product WHERE status = 'P' ORDER BY product_id DESC";
        List<ProductDTO> list = new ArrayList<>();
        try (
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery()
        ) {
            while (rs.next()) {
                ProductDTO dto = new ProductDTO();
                dto.setProductId(rs.getInt("product_id"));
                dto.setProductName(rs.getString("product_name"));
                dto.setStartPrice(rs.getInt("start_price"));
                dto.setImageRenamedName(rs.getString("image_renamed_name"));
                dto.setSellerId(rs.getString("seller_id"));
                list.add(dto);
            }
        }
        return list;
    }
    public int approveMileage(Connection conn, int reqId) {
        int result = 0;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        ResultSet rs = null;

        try {
            // 1. 충전 요청 정보 조회
            String sql1 = "SELECT MEMBER_ID, AMOUNT FROM CHARGE_REQUEST WHERE REQ_ID = ?";
            pstmt1 = conn.prepareStatement(sql1);
            pstmt1.setInt(1, reqId);
            rs = pstmt1.executeQuery();

            if(rs.next()) {
                String memberId = rs.getString("MEMBER_ID");
                long amount = rs.getLong("AMOUNT");

                // 2. 마일리지 업데이트
                // Mileage information resides in the USERS table. Using the
                // legacy MEMBER table name results in failures when this
                // method is invoked.
                String sql2 = "UPDATE USERS SET MILEAGE = MILEAGE + ? WHERE MEMBER_ID = ?";
                pstmt2 = conn.prepareStatement(sql2);
                pstmt2.setLong(1, amount);
                pstmt2.setString(2, memberId);
                int updateResult = pstmt2.executeUpdate();

                // 3. 승인 처리
                if(updateResult > 0) {
                    String sql3 = "UPDATE CHARGE_REQUEST SET STATUS = '승인', APPROVE_DATE = SYSDATE WHERE REQ_ID = ?";
                    PreparedStatement pstmt3 = conn.prepareStatement(sql3);
                    pstmt3.setInt(1, reqId);
                    result = pstmt3.executeUpdate();
                    pstmt3.close();
                }
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            close(rs);
            close(pstmt1);
            close(pstmt2);
        }

        return result;
    }
    
    
    public List<ChargeRequestDTO> getAllChargeRequests(Connection conn) {
        List<ChargeRequestDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM CHARGE_REQUEST ORDER BY REQUEST_DATE DESC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                ChargeRequestDTO dto = new ChargeRequestDTO();
                dto.setReqId(rs.getInt("REQ_ID"));
                dto.setMemberId(rs.getString("MEMBER_ID"));
                dto.setAmount(rs.getLong("AMOUNT"));
                dto.setStatus(rs.getString("STATUS"));
                dto.setRequestDate(rs.getDate("REQUEST_DATE"));
                dto.setApproveDate(rs.getDate("APPROVE_DATE"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    //충전 승인
    public int approveCharge(Connection conn, int reqId) {
        int result = 0;
        try (PreparedStatement ps1 = conn.prepareStatement(
                 "SELECT MEMBER_ID, AMOUNT FROM CHARGE_REQUEST WHERE REQ_ID = ? AND STATUS = 'W'");
             PreparedStatement ps2 = conn.prepareStatement(
                 "UPDATE USERS SET MILEAGE = MILEAGE + ? WHERE MEMBER_ID = ?");
             PreparedStatement ps3 = conn.prepareStatement(
                 "UPDATE CHARGE_REQUEST SET STATUS = 'A', APPROVE_DATE = SYSDATE WHERE REQ_ID = ?")) {
            
            ps1.setInt(1, reqId);
            ResultSet rs = ps1.executeQuery();
            if(rs.next()) {
                String memberId = rs.getString("MEMBER_ID");
                long amount = rs.getLong("AMOUNT");

                ps2.setLong(1, amount);
                ps2.setString(2, memberId);
                int r1 = ps2.executeUpdate();

                ps3.setInt(1, reqId);
                int r2 = ps3.executeUpdate();

                result = r1 * r2; // 둘 다 성공해야 1
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    
    //충전 거부
    public int rejectCharge(Connection conn, int reqId) {
        int result = 0;
        String sql = "UPDATE CHARGE_REQUEST SET STATUS = 'R', APPROVE_DATE = SYSDATE WHERE REQ_ID = ? AND STATUS = 'W'";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, reqId);
            result = pstmt.executeUpdate();
        } catch(Exception e) {
            e.printStackTrace();
        }
        return result;
    }
    
    /** 모든 입찰 내역 조회 */
    public List<com.auction.dto.BidDTO> getAllBids(Connection conn) {
        List<com.auction.dto.BidDTO> list = new ArrayList<>();
        String sql = "SELECT b.BID_ID, b.BIDDER_ID, b.PRODUCT_ID, b.BID_PRICE, b.BID_TIME, " +
                     "p.PRODUCT_NAME, p.IMAGE_RENAMED_NAME, p.CURRENT_PRICE, p.STATUS " +
                     "FROM BID b JOIN PRODUCT p ON b.PRODUCT_ID = p.PRODUCT_ID " +
                     "ORDER BY b.BID_TIME DESC";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                com.auction.dto.BidDTO bid = new com.auction.dto.BidDTO();
                bid.setBidId(rs.getInt("BID_ID"));
                bid.setMemberId(rs.getString("BIDDER_ID"));
                bid.setProductId(rs.getInt("PRODUCT_ID"));
                bid.setBidPrice(rs.getInt("BID_PRICE"));
                bid.setBidTime(rs.getTimestamp("BID_TIME"));
                
                // 상품 정보도 함께 저장 (BidDTO에 추가 필드 필요)
                bid.setProductName(rs.getString("PRODUCT_NAME"));
                bid.setImageRenamedName(rs.getString("IMAGE_RENAMED_NAME"));
                bid.setCurrentPrice(rs.getInt("CURRENT_PRICE"));
                bid.setProductStatus(rs.getString("STATUS"));
                
                list.add(bid);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /** 오늘 입찰 건수 조회 */
    public int getTodayBidCount(Connection conn) {
        String sql = "SELECT COUNT(*) FROM BID WHERE TRUNC(BID_TIME) = TRUNC(SYSDATE)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /** 낙찰 완료 건수 조회 */
    public int getCompletedAuctionCount(Connection conn) {
        String sql = "SELECT COUNT(*) FROM PRODUCT WHERE STATUS IN ('E', 'F') AND WINNER_ID IS NOT NULL";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /** 총 입찰 금액 조회 */
    public long getTotalBidAmount(Connection conn) {
        String sql = "SELECT NVL(SUM(BID_PRICE), 0) FROM BID";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0L;
    }
    
    /** 전체 회원 수 조회 */
    public int getTotalMemberCount(Connection conn) {
        String sql = "SELECT COUNT(*) FROM USERS";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /** 오늘 가입한 회원 수 조회 */
    public int getTodayJoinCount(Connection conn) {
        String sql = "SELECT COUNT(*) FROM USERS WHERE TRUNC(ENROLL_DATE) = TRUNC(SYSDATE)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /** VIP 회원 수 조회 */
    public int getVipMemberCount(Connection conn) {
        String sql = "SELECT COUNT(DISTINCT MEMBER_ID) FROM VIP_INFO";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    /** 전체 회원 목록 조회 */
    public List<com.auction.dto.MemberDTO> getAllMembers(Connection conn) {
        List<com.auction.dto.MemberDTO> list = new ArrayList<>();
        String sql = "SELECT MEMBER_ID, MEMBER_NAME, EMAIL, TEL, MILEAGE, ENROLL_DATE, " +
                     "(SELECT COUNT(*) FROM VIP_INFO WHERE MEMBER_ID = u.MEMBER_ID) AS IS_VIP " +
                     "FROM USERS u ORDER BY ENROLL_DATE DESC";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                com.auction.dto.MemberDTO member = new com.auction.dto.MemberDTO();
                member.setMemberId(rs.getString("MEMBER_ID"));
                member.setMemberName(rs.getString("MEMBER_NAME"));
                member.setEmail(rs.getString("EMAIL"));
                member.setTel(rs.getString("TEL"));
                member.setMileage(rs.getLong("MILEAGE"));
                member.setEnrollDate(rs.getDate("ENROLL_DATE"));
                member.setVip(rs.getInt("IS_VIP") > 0);
                
                list.add(member);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /** 회원 검색 (ID, 이름, 이메일로 검색) */
    public List<com.auction.dto.MemberDTO> searchMembers(Connection conn, String keyword) {
        List<com.auction.dto.MemberDTO> list = new ArrayList<>();
        String sql = "SELECT MEMBER_ID, MEMBER_NAME, EMAIL, TEL, MILEAGE, ENROLL_DATE " +
                     "FROM USERS WHERE MEMBER_ID LIKE ? OR MEMBER_NAME LIKE ? OR EMAIL LIKE ? " +
                     "ORDER BY ENROLL_DATE DESC";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String searchKeyword = "%" + keyword + "%";
            pstmt.setString(1, searchKeyword);
            pstmt.setString(2, searchKeyword);
            pstmt.setString(3, searchKeyword);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    com.auction.dto.MemberDTO member = new com.auction.dto.MemberDTO();
                    member.setMemberId(rs.getString("MEMBER_ID"));
                    member.setMemberName(rs.getString("MEMBER_NAME"));
                    member.setEmail(rs.getString("EMAIL"));
                    member.setTel(rs.getString("TEL"));
                    member.setMileage(rs.getLong("MILEAGE"));
                    member.setEnrollDate(rs.getDate("ENROLL_DATE"));
                    
                    list.add(member);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
    /** VIP 회원만 조회 */
    public List<com.auction.dto.MemberDTO> getVipMembers(Connection conn) {
        List<com.auction.dto.MemberDTO> list = new ArrayList<>();
        String sql = "SELECT u.MEMBER_ID, u.MEMBER_NAME, u.EMAIL, u.TEL, u.MILEAGE, u.ENROLL_DATE " +
                     "FROM USERS u JOIN VIP_INFO v ON u.MEMBER_ID = v.MEMBER_ID " +
                     "ORDER BY u.ENROLL_DATE DESC";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                com.auction.dto.MemberDTO member = new com.auction.dto.MemberDTO();
                member.setMemberId(rs.getString("MEMBER_ID"));
                member.setMemberName(rs.getString("MEMBER_NAME"));
                member.setEmail(rs.getString("EMAIL"));
                member.setTel(rs.getString("TEL"));
                member.setMileage(rs.getLong("MILEAGE"));
                member.setEnrollDate(rs.getDate("ENROLL_DATE"));
                member.setVip(true);  // VIP 테이블에 조인했으므로 모두 VIP
                
                list.add(member);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    public List<ProductDTO> selectAllProducts(Connection conn) {
        List<ProductDTO> list = new ArrayList<>();
        String sql = "SELECT PRODUCT_ID, PRODUCT_NAME, START_PRICE, CURRENT_PRICE, IMAGE_RENAMED_NAME, SELLER_ID, STATUS, REG_DATE, END_TIME FROM PRODUCT ORDER BY PRODUCT_ID DESC";
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                ProductDTO p = new ProductDTO();
                p.setProductId(rs.getInt("PRODUCT_ID"));
                p.setProductName(rs.getString("PRODUCT_NAME"));
                p.setStartPrice(rs.getInt("START_PRICE"));
                p.setCurrentPrice(rs.getInt("CURRENT_PRICE"));
                p.setImageRenamedName(rs.getString("IMAGE_RENAMED_NAME"));
                p.setSellerId(rs.getString("SELLER_ID"));
                p.setStatus(rs.getString("STATUS"));
                p.setRegDate(rs.getDate("REG_DATE"));
                p.setEndTime(rs.getTimestamp("END_TIME"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    
}