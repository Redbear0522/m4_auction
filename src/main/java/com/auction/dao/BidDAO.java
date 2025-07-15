package com.auction.dao;

import com.auction.dto.BidDTO;
import com.auction.dao.MemberDAO;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BidDAO {

	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;

	// 기존과 동일한 JDBC 연결 획득
	private Connection getConnection() throws ClassNotFoundException, SQLException {
		Class.forName("oracle.jdbc.driver.OracleDriver");
		return DriverManager.getConnection("jdbc:oracle:thin:@192.168.219.198:1521:orcl", "team01", "1234");
	}

	// 리소스 정리
	private void close() {
		try {
			if (rs != null)
				rs.close();
		} catch (Exception e) {
		}
		try {
			if (pstmt != null)
				pstmt.close();
		} catch (Exception e) {
		}
		try {
			if (conn != null)
				conn.close();
		} catch (Exception e) {
		}
	}

	public boolean placeBid(Connection conn, String memberId, int productId, int bidAmount) throws SQLException {
		// 1) BID 테이블에 기록 (마일리지는 경매 종료 시에만 차감)
		String insertSql = "INSERT INTO BID " + " (BID_ID, PRODUCT_ID, BIDDER_ID, BID_PRICE, BID_TIME, IS_SUCCESSFUL) "
				+ "VALUES (BID_SEQ.NEXTVAL, ?, ?, ?, SYSDATE, 0)";
		try (PreparedStatement p = conn.prepareStatement(insertSql)) {
			p.setInt(1, productId);
			p.setString(2, memberId);
			p.setInt(3, bidAmount);
			if (p.executeUpdate() != 1)
				return false;
		}

		// 2) Product 테이블의 최고가·최고입찰자 동시 업데이트
		String updSql = "UPDATE PRODUCT SET CURRENT_PRICE = ?, WINNER_ID = ? WHERE PRODUCT_ID = ?";
		try (PreparedStatement p = conn.prepareStatement(updSql)) {
			p.setInt(1, bidAmount);
			p.setString(2, memberId);
			p.setInt(3, productId);
			if (p.executeUpdate() != 1)
				return false;
		}

		return true;
	}

	/** 4) 특정 상품의 모든 입찰 내역 조회 (가격 높은 순) */
	public List<BidDTO> getBidsByProductId(int productId) throws ClassNotFoundException, SQLException {
		List<BidDTO> list = new ArrayList<>();
		String sql = "SELECT BID_ID, PRODUCT_ID, BIDDER_ID, BID_PRICE, BID_TIME, IS_SUCCESSFUL " + 
		             "FROM BID " +
				     "WHERE PRODUCT_ID = ? " + 
				     "ORDER BY BID_PRICE DESC, BID_TIME ASC";
		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, productId);
			rs = pstmt.executeQuery();
			while (rs.next()) {
				BidDTO b = new BidDTO();
				b.setBidId(rs.getInt("BID_ID"));
				b.setProductId(rs.getInt("PRODUCT_ID"));
				b.setMemberId(rs.getString("BIDDER_ID"));
				b.setBidPrice(rs.getInt("BID_PRICE"));
				b.setBidTime(rs.getTimestamp("BID_TIME"));
				b.setIsSuccessful(rs.getInt("IS_SUCCESSFUL"));
				list.add(b);
			}
		} finally {
			close();
		}
		return list;
	}

	/** 5) 이 상품의 최고 입찰 1건 조회 (낙찰 대상) */
	public BidDTO selectHighestBid(Connection conn, int productId) throws SQLException {
		String sql = "SELECT BID_ID, PRODUCT_ID, BIDDER_ID, BID_PRICE, BID_TIME, IS_SUCCESSFUL " + "FROM ( "
				+ "  SELECT * FROM BID WHERE PRODUCT_ID = ? ORDER BY BID_PRICE DESC, BID_TIME ASC "
				+ ") WHERE ROWNUM = 1";
		try (PreparedStatement p = conn.prepareStatement(sql)) {
			p.setInt(1, productId);
			try (ResultSet rs = p.executeQuery()) {
				if (rs.next()) {
					BidDTO b = new BidDTO();
					b.setBidId(rs.getInt("BID_ID"));
					b.setProductId(rs.getInt("PRODUCT_ID"));
					b.setMemberId(rs.getString("BIDDER_ID"));
					b.setBidPrice(rs.getInt("BID_PRICE"));
					b.setBidTime(rs.getTimestamp("BID_TIME"));
					b.setIsSuccessful(rs.getInt("IS_SUCCESSFUL"));
					return b;
				}
			}
		}
		return null;
	}

	/** 6) 낙찰 처리: IS_SUCCESSFUL=1, END_TIME=SYSDATE */
	public int markSuccessful(int bidId) throws ClassNotFoundException, SQLException {
		String sql = "UPDATE BID SET IS_SUCCESSFUL = 1, END_TIME = SYSDATE WHERE BID_ID = ?";
		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, bidId);
			return pstmt.executeUpdate();
		} finally {
			close();
		}
	}

	/** 7) 환불 처리: IS_SUCCESSFUL=2 (낙찰되지 않은 나머지들) */
	public int markRefunded(int bidId) throws ClassNotFoundException, SQLException {
		String sql = "UPDATE BID SET IS_SUCCESSFUL = 2 WHERE BID_ID = ?";
		try {
			conn = getConnection();
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, bidId);
			return pstmt.executeUpdate();
		} finally {
			close();
		}
	}

	// 즉시 입찰 처리
	public int insertSuccessfulBid(Connection conn, String bidderId, int productId, int bidPrice) throws SQLException {
		String sql = "INSERT INTO BID (BID_ID, PRODUCT_ID, BIDDER_ID, BID_PRICE, IS_SUCCESSFUL, BID_TIME) "
				+ "VALUES (BID_SEQ.NEXTVAL, ?, ?, ?, 1, SYSDATE)";
		try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
			pstmt.setInt(1, productId);
			pstmt.setString(2, bidderId);
			pstmt.setInt(3, bidPrice);
			return pstmt.executeUpdate();
		}
	}

	/**
	 * 입찰 처리 + 마일리지 즉시 차감
	 */
	public boolean placeBidWithMileageDeduction(Connection conn, String memberId, int productId, int bidPrice) throws SQLException {
		// 1. 해당 상품에 이전 입찰이 있는지 확인하고, 있다면 이전 입찰자에게 환불
		String prevBidderSql = "SELECT BIDDER_ID, BID_PRICE FROM BID WHERE PRODUCT_ID = ? AND IS_SUCCESSFUL = 0 ORDER BY BID_PRICE DESC, BID_TIME ASC";
		try (PreparedStatement pstmt = conn.prepareStatement(prevBidderSql)) {
			pstmt.setInt(1, productId);
			try (ResultSet rs = pstmt.executeQuery()) {
				while (rs.next()) {
					String prevBidder = rs.getString("BIDDER_ID");
					int prevBidPrice = rs.getInt("BID_PRICE");
					
					// 이전 입찰자들에게 마일리지 환불
					String refundSql = "UPDATE USERS SET MILEAGE = MILEAGE + ? WHERE MEMBER_ID = ?";
					try (PreparedStatement refundPstmt = conn.prepareStatement(refundSql)) {
						refundPstmt.setInt(1, prevBidPrice);
						refundPstmt.setString(2, prevBidder);
						refundPstmt.executeUpdate();
					}
					
					// 거래 내역 기록 (환불)
					String logSql = "INSERT INTO TRANSACTION_LOG (LOG_ID, MEMBER_ID, TRANSACTION_TYPE, AMOUNT, TRANSACTION_TIME, RELATED_ITEM_ID) VALUES (TRANSACTION_LOG_SEQ.NEXTVAL, ?, 'R', ?, SYSDATE, ?)";
					try (PreparedStatement logPstmt = conn.prepareStatement(logSql)) {
						logPstmt.setString(1, prevBidder);
						logPstmt.setInt(2, prevBidPrice);
						logPstmt.setInt(3, productId);
						logPstmt.executeUpdate();
					}
				}
			}
		}
		
		// 2. 이전 입찰들을 환불 상태로 변경
		String updatePrevBidsSql = "UPDATE BID SET IS_SUCCESSFUL = 2 WHERE PRODUCT_ID = ? AND IS_SUCCESSFUL = 0";
		try (PreparedStatement pstmt = conn.prepareStatement(updatePrevBidsSql)) {
			pstmt.setInt(1, productId);
			pstmt.executeUpdate();
		}
		
		// 3. 새로운 입찰자의 마일리지 차감
		System.out.println("[DEBUG] 마일리지 차감 전 - 회원: " + memberId + ", 차감할 금액: " + bidPrice);
		
		// 3-1. 현재 마일리지 확인
		String checkMileageSql = "SELECT MILEAGE FROM USERS WHERE MEMBER_ID = ?";
		long currentMileage = 0;
		try (PreparedStatement checkPstmt = conn.prepareStatement(checkMileageSql)) {
			checkPstmt.setString(1, memberId);
			try (ResultSet checkRs = checkPstmt.executeQuery()) {
				if (checkRs.next()) {
					currentMileage = checkRs.getLong("MILEAGE");
					System.out.println("[DEBUG] 현재 마일리지: " + currentMileage);
				} else {
					System.err.println("[ERROR] 회원 정보를 찾을 수 없습니다: " + memberId);
					return false;
				}
			}
		}
		
		// 3-2. 마일리지 부족 체크
		if (currentMileage < bidPrice) {
			System.err.println("[ERROR] 마일리지 부족 - 보유: " + currentMileage + ", 필요: " + bidPrice);
			return false;
		}
		
		// 3-3. 마일리지 차감 실행
		String deductSql = "UPDATE USERS SET MILEAGE = MILEAGE - ? WHERE MEMBER_ID = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(deductSql)) {
			pstmt.setInt(1, bidPrice);
			pstmt.setString(2, memberId);
			int updateCount = pstmt.executeUpdate();
			System.out.println("[DEBUG] 마일리지 차감 결과 - 업데이트된 행 수: " + updateCount);
			if (updateCount != 1) {
				System.err.println("[ERROR] 마일리지 차감 실패 - 업데이트된 행 수: " + updateCount);
				return false;
			}
		}
		
		// 3-4. 차감 후 마일리지 확인
		try (PreparedStatement checkPstmt = conn.prepareStatement(checkMileageSql)) {
			checkPstmt.setString(1, memberId);
			try (ResultSet checkRs = checkPstmt.executeQuery()) {
				if (checkRs.next()) {
					long afterMileage = checkRs.getLong("MILEAGE");
					System.out.println("[DEBUG] 차감 후 마일리지: " + afterMileage + " (차감된 금액: " + (currentMileage - afterMileage) + ")");
				}
			}
		}
		
		// 4. 거래 내역 기록 (입찰 차감)
		String logSql = "INSERT INTO TRANSACTION_LOG (LOG_ID, MEMBER_ID, TRANSACTION_TYPE, AMOUNT, TRANSACTION_TIME, RELATED_ITEM_ID) VALUES (TRANSACTION_LOG_SEQ.NEXTVAL, ?, 'B', ?, SYSDATE, ?)";
		try (PreparedStatement pstmt = conn.prepareStatement(logSql)) {
			pstmt.setString(1, memberId);
			pstmt.setInt(2, -bidPrice); // 음수로 차감 표시
			pstmt.setInt(3, productId);
			pstmt.executeUpdate();
		}
		
		// 5. BID 테이블에 새로운 입찰 기록
		String insertSql = "INSERT INTO BID (BID_ID, PRODUCT_ID, BIDDER_ID, BID_PRICE, BID_TIME, IS_SUCCESSFUL) VALUES (BID_SEQ.NEXTVAL, ?, ?, ?, SYSDATE, 0)";
		try (PreparedStatement pstmt = conn.prepareStatement(insertSql)) {
			pstmt.setInt(1, productId);
			pstmt.setString(2, memberId);
			pstmt.setInt(3, bidPrice);
			if (pstmt.executeUpdate() != 1) {
				return false;
			}
		}
		
		// 6. PRODUCT 테이블의 최고가·최고입찰자 업데이트
		String updateProductSql = "UPDATE PRODUCT SET CURRENT_PRICE = ?, WINNER_ID = ? WHERE PRODUCT_ID = ?";
		try (PreparedStatement pstmt = conn.prepareStatement(updateProductSql)) {
			pstmt.setInt(1, bidPrice);
			pstmt.setString(2, memberId);
			pstmt.setInt(3, productId);
			if (pstmt.executeUpdate() != 1) {
				return false;
			}
		}
		
		return true;
	}
}