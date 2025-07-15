package com.auction.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import static com.auction.common.JDBCTemplate.*;

public class TransactionLogDAO {
    /** 거래내역 INSERT */
    public int insertLog(Connection conn, String memberId, String type, long amount, int relatedItemId) throws SQLException {
        return insertLog(conn, memberId, type, amount, relatedItemId, null);
    }
    
    /** 거래내역 INSERT (설명 포함) */
    public int insertLog(Connection conn, String memberId, String type, long amount, int relatedItemId, String description) throws SQLException {
        // TRANSACTION_LOG 기록
        String sql =
          "INSERT INTO TRANSACTION_LOG (LOG_ID, MEMBER_ID, TRANSACTION_TYPE, AMOUNT, TRANSACTION_TIME, RELATED_ITEM_ID, DESCRIPTION)" +
          " VALUES (TRANSACTION_LOG_SEQ.NEXTVAL, ?, ?, ?, SYSDATE, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            pstmt.setString(2, type);        // 'B': 입찰, 'R': 환불, 'S': 판매, 'C': 충전, 'W': 낙찰 등
            pstmt.setLong(3, amount);
            if (relatedItemId > 0) {
                pstmt.setInt(4, relatedItemId);
            } else {
                pstmt.setNull(4, java.sql.Types.INTEGER);
            }
            pstmt.setString(5, description);
            return pstmt.executeUpdate();
        }
    }
}
