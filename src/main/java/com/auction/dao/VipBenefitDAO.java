package com.auction.dao;

import java.sql.*;
import static com.auction.common.JDBCTemplate.*;

public class VipBenefitDAO {

    // 혜택 신청
    public static int requestBenefit(String memberId, String option) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int result = 0;

        try {
            conn = getConnection();

            // 이미 신청 중인지 확인
            String checkSql = "SELECT COUNT(*) FROM VIP_OPTION_REQUEST WHERE MEMBER_ID = ? AND STATUS = '대기중'";
            pstmt = conn.prepareStatement(checkSql);
            pstmt.setString(1, memberId);
            rs = pstmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                return 0; // 이미 신청 중
            }
            rs.close();
            pstmt.close();

            // 신청 등록
            String insertSql = "INSERT INTO VIP_OPTION_REQUEST VALUES (VIP_OPTION_REQ_SEQ.NEXTVAL, ?, ?, SYSDATE, '대기중')";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, memberId);
            pstmt.setString(2, option);

            result = pstmt.executeUpdate();
            commit(conn);
        } catch (Exception e) {
            e.printStackTrace();
            rollback(conn);
        } finally {
            close(rs);
            close(pstmt);
            close(conn);
        }
        return result;
    }
}