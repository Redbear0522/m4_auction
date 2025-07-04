package com.auction.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import static com.auction.common.JDBCTemplate.*;

public class TransactionLogDAO {
    /** 거래내역 INSERT & BID 테이블 기록 */
    public int insertLog(Connection conn, String memberId, String type, long amount, int relatedItemId) throws SQLException {
        // 1) TRANSACTION_LOG 기록
        String sql =
          "INSERT INTO TRANSACTION_LOG (LOG_ID, MEMBER_ID, TRANSACTION_TYPE, AMOUNT, TRANSACTION_TIME, RELATED_ITEM_ID)" +
          " VALUES (TRANSACTION_LOG_SEQ.NEXTVAL, ?, ?, ?, SYSDATE, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            pstmt.setString(2, type);        // 'B': 입찰, 'C': 낙찰, 'D': 환급 등
            pstmt.setLong(3, amount);
            pstmt.setInt(4, relatedItemId);
            int logResult = pstmt.executeUpdate();

            // 2) BID 테이블에도 기록
            String bidSql =
              "INSERT INTO BID (BID_ID, PRODUCT_ID, BIDDER_ID, BID_PRICE, BID_TIME)" +
              " VALUES (SEQ_BID_ID.NEXTVAL, ?, ?, ?, SYSDATE)";
            try (PreparedStatement bidPstmt = conn.prepareStatement(bidSql)) {
                bidPstmt.setInt(1, relatedItemId);
                bidPstmt.setString(2, memberId);
                bidPstmt.setLong(3, amount);
                bidPstmt.executeUpdate();
            }

            return logResult;
        }
    }
}
