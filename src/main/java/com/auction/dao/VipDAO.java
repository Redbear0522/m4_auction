// File: src/main/java/com/auction/dao/VipDAO.java
package com.auction.dao;

import com.auction.dto.VipBenefitDTO;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import static com.auction.common.JDBCTemplate.*;

public class VipDAO {

    public List<VipBenefitDTO> selectUserVipBenefits(Connection conn, String memberId) throws SQLException {
        List<VipBenefitDTO> list = new ArrayList<>();
        String sql = "SELECT BENEFIT_ID, OPTION_NAME, START_DATE, END_DATE, STATUS " +
                     "FROM VIP_BENEFIT WHERE MEMBER_ID = ? ORDER BY START_DATE DESC";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, memberId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    VipBenefitDTO dto = new VipBenefitDTO();
                    dto.setBenefitId(rs.getInt("BENEFIT_ID"));
                    dto.setOptionName(rs.getString("OPTION_NAME"));
                    dto.setStartDate(rs.getDate("START_DATE"));
                    dto.setEndDate(rs.getDate("END_DATE"));
                    dto.setStatus(rs.getString("STATUS"));
                    list.add(dto);
                }
            }
        }

        return list;
    }

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