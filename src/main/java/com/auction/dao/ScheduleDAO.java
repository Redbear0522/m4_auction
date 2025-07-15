package com.auction.dao;

import com.auction.dto.ScheduleDTO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static com.auction.common.JDBCTemplate.*;

public class ScheduleDAO {

    /** 스케줄 등록 */
    public int insertSchedule(Connection conn, ScheduleDTO dto) throws SQLException {
        String sql = "INSERT INTO SCHEDULE (SCHEDULE_ID, PRODUCT_ID, START_TIME, END_TIME, STATUS, CREATED_AT, UPDATED_AT) " +
                     "VALUES (SCHEDULE_SEQ.NEXTVAL, ?, ?, ?, ?, SYSDATE, SYSDATE)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getProductId());
            if (dto.getStartTime() != null)
                pstmt.setTimestamp(2, new Timestamp(dto.getStartTime().getTime()));
            else
                pstmt.setNull(2, java.sql.Types.TIMESTAMP);
            if (dto.getEndTime() != null)
                pstmt.setTimestamp(3, new Timestamp(dto.getEndTime().getTime()));
            else
                pstmt.setNull(3, java.sql.Types.TIMESTAMP);
            pstmt.setString(4, dto.getStatus());

            return pstmt.executeUpdate();
        }
    }

    /** 스케줄 수정 */
    public int updateSchedule(Connection conn, ScheduleDTO dto) throws SQLException {
        String sql = "UPDATE SCHEDULE SET PRODUCT_ID = ?, START_TIME = ?, END_TIME = ?, STATUS = ?, UPDATED_AT = SYSDATE " +
                     "WHERE SCHEDULE_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, dto.getProductId());
            if (dto.getStartTime() != null)
                pstmt.setTimestamp(2, new Timestamp(dto.getStartTime().getTime()));
            else
                pstmt.setNull(2, java.sql.Types.TIMESTAMP);
            if (dto.getEndTime() != null)
                pstmt.setTimestamp(3, new Timestamp(dto.getEndTime().getTime()));
            else
                pstmt.setNull(3, java.sql.Types.TIMESTAMP);
            pstmt.setString(4, dto.getStatus());
            pstmt.setInt(5, dto.getScheduleId());

            return pstmt.executeUpdate();
        }
    }

    /** 스케줄 삭제 */
    public int deleteSchedule(Connection conn, int scheduleId) throws SQLException {
        String sql = "DELETE FROM SCHEDULE WHERE SCHEDULE_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, scheduleId);
            return pstmt.executeUpdate();
        }
    }

    /** 스케줄 단건 조회 */
    public ScheduleDTO selectScheduleById(Connection conn, int scheduleId) throws SQLException {
        String sql = "SELECT SCHEDULE_ID, PRODUCT_ID, START_TIME, END_TIME, STATUS, CREATED_AT, UPDATED_AT " +
                     "FROM SCHEDULE WHERE SCHEDULE_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, scheduleId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ScheduleDTO dto = new ScheduleDTO();
                    dto.setScheduleId(rs.getInt("SCHEDULE_ID"));
                    dto.setProductId(rs.getInt("PRODUCT_ID"));
                    dto.setStartTime(rs.getTimestamp("START_TIME"));
                    dto.setEndTime(rs.getTimestamp("END_TIME"));
                    dto.setStatus(rs.getString("STATUS"));
                    dto.setCreatedAt(rs.getTimestamp("CREATED_AT"));
                    dto.setUpdatedAt(rs.getTimestamp("UPDATED_AT"));
                    return dto;
                }
            }
        }
        return null;
    }

    /** 특정 상품의 모든 스케줄 조회 */
    public List<ScheduleDTO> selectSchedulesByProductId(Connection conn, int productId) throws SQLException {
        String sql = "SELECT SCHEDULE_ID, PRODUCT_ID, START_TIME, END_TIME, STATUS, CREATED_AT, UPDATED_AT " +
                     "FROM SCHEDULE WHERE PRODUCT_ID = ? ORDER BY START_TIME ASC";
        List<ScheduleDTO> list = new ArrayList<>();
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, productId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ScheduleDTO dto = new ScheduleDTO();
                    dto.setScheduleId(rs.getInt("SCHEDULE_ID"));
                    dto.setProductId(rs.getInt("PRODUCT_ID"));
                    dto.setStartTime(rs.getTimestamp("START_TIME"));
                    dto.setEndTime(rs.getTimestamp("END_TIME"));
                    dto.setStatus(rs.getString("STATUS"));
                    dto.setCreatedAt(rs.getTimestamp("CREATED_AT"));
                    dto.setUpdatedAt(rs.getTimestamp("UPDATED_AT"));
                    list.add(dto);
                }
            }
        }
        return list;
    }

    /** 전체 스케줄 조회 */
    public List<ScheduleDTO> selectAllSchedules(Connection conn) throws SQLException {
        String sql = "SELECT SCHEDULE_ID, PRODUCT_ID, START_TIME, END_TIME, STATUS, CREATED_AT, UPDATED_AT " +
                     "FROM SCHEDULE ORDER BY START_TIME ASC";
        List<ScheduleDTO> list = new ArrayList<>();
        try (PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                ScheduleDTO dto = new ScheduleDTO();
                dto.setScheduleId(rs.getInt("SCHEDULE_ID"));
                dto.setProductId(rs.getInt("PRODUCT_ID"));
                dto.setStartTime(rs.getTimestamp("START_TIME"));
                dto.setEndTime(rs.getTimestamp("END_TIME"));
                dto.setStatus(rs.getString("STATUS"));
                dto.setCreatedAt(rs.getTimestamp("CREATED_AT"));
                dto.setUpdatedAt(rs.getTimestamp("UPDATED_AT"));
                list.add(dto);
            }
        }
        return list;
    }

    /** 스케줄 상태 반환 (대기중/진행중/종료됨) */
    public String getScheduleStatus(Date startTime, Date endTime) {
        Date now = new Date();
        if (now.before(startTime))      return "대기중";
        else if (now.after(endTime))    return "종료됨";
        else                            return "진행중";
    }
}
