// File: src/main/java/com/auction/dao/VipDAO.java
package com.auction.dao;

import com.auction.vo.VipBenefitDTO;
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
}