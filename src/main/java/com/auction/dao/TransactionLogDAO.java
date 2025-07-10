package com.auction.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import static com.auction.common.JDBCTemplate.*;

public class TransactionLogDAO {
    /** 거래내역 INSERT */
    public int insertLog(Connection conn, String memberId, String type, long amount, int relatedItemId) throws SQLException {
        // TRANSACTION_LOG 기록
        String sql =
          "INSERT INTO TRANSACTION_LOG (LOG_ID, MEMBER_ID, TRANSACTION_TYPE, AMOUNT, TRANSACTION_TIME, RELATED_ITEM_ID)" +
          " VALUES (TRANSACTION_LOG_SEQ.NEXTVAL, ?, ?, ?, SYSDATE, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            pstmt.setString(2, type);        // 'B': 입찰, 'C': 낙찰(구매), 'S': 판매, 'D': 환급 등
            pstmt.setLong(3, amount);
            pstmt.setInt(4, relatedItemId);
            return pstmt.executeUpdate();
        }
    }
}
