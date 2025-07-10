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
}