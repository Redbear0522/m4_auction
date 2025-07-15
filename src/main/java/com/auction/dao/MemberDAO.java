package com.auction.dao;

import static com.auction.common.JDBCTemplate.*;
import com.auction.common.SHA256;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import com.auction.dto.MemberDTO;

public class MemberDAO {

    public MemberDAO() {}

    /**
     * 로그인 처리를 위한 회원 조회
     * @param conn    DB 연결 객체
     * @param userId  입력한 아이디
     * @param userPwd 입력한 비밀번호(암호화 전)
     * @return 일치하는 회원 정보 또는 null
     */
    public MemberDTO loginMember(Connection conn, String userId, String userPwd) {
        MemberDTO loginUser = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        String sql = "SELECT * FROM USERS WHERE MEMBER_ID = ? AND MEMBER_PWD = ?";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userId);
            // 비밀번호는 SHA256.encrypt(userPwd)로 암호화해서 비교
            //pstmt.setString(2, SHA256.encrypt(userPwd));
            pstmt.setString(2, userPwd);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                loginUser = new MemberDTO();
                loginUser.setMemberId(rs.getString("MEMBER_ID"));
                loginUser.setMemberName(rs.getString("MEMBER_NAME"));
                loginUser.setEmail(rs.getString("EMAIL"));
                loginUser.setTel(rs.getString("TEL"));
                loginUser.setEnrollDate(rs.getDate("ENROLL_DATE"));
                loginUser.setBirthdate(rs.getString("BIRTHDATE"));
                loginUser.setGender(rs.getString("GENDER"));
                loginUser.setMobileCarrier(rs.getString("MOBILE_CARRIER"));
                loginUser.setMileage(rs.getLong("MILEAGE"));
                loginUser.setZip(rs.getString("ZIP"));
                loginUser.setAddr1(rs.getString("ADDR1"));
                loginUser.setAddr2(rs.getString("ADDR2"));
                loginUser.setMemberType(rs.getInt("MEMBER_TYPE"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(rs);
            close(pstmt);
        }
        return loginUser;
    }

    /**
     * 회원가입 처리
     * @param conn DB 연결 객체
     * @param m    회원 정보 DTO
     * @return INSERT 성공 개수 (1이면 성공)
     */
    public int enrollMember(Connection conn, MemberDTO m) {
        int result = 0;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO USERS ("
                   + "  MEMBER_ID, MEMBER_PWD, MEMBER_NAME, EMAIL, TEL,"
                   + "  BIRTHDATE, GENDER, MOBILE_CARRIER, ENROLL_DATE, MILEAGE,"
                   + "  ZIP, ADDR1, ADDR2, MEMBER_TYPE"
                   + ") VALUES (?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, 0, ?, ?, ?, ?)";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, m.getMemberId());
            pstmt.setString(2, SHA256.encrypt(m.getMemberPwd()));
            pstmt.setString(3, m.getMemberName());
            pstmt.setString(4, m.getEmail());
            pstmt.setString(5, m.getTel());
            pstmt.setString(6, m.getBirthdate());
            pstmt.setString(7, m.getGender());
            pstmt.setString(8, m.getMobileCarrier());
            pstmt.setString(9, m.getZip());
            pstmt.setString(10, m.getAddr1());
            pstmt.setString(11, m.getAddr2());
            pstmt.setInt(12, m.getMemberType());
            result = pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(pstmt);
        }
        return result;
    }

    /**
     * 회원 정보 수정(이름, 이메일, 전화, 주소)
     * @param conn DB 연결 객체
     * @param m    수정할 회원 정보 DTO
     * @return UPDATE 성공 개수
     */
    public int updateMember(Connection conn, MemberDTO m) {
        int result = 0;
        PreparedStatement pstmt = null;
        String sql = "UPDATE USERS SET "
                   + " MEMBER_NAME = ?, EMAIL = ?, TEL = ?, ZIP = ?, ADDR1 = ?, ADDR2 = ? "
                   + "WHERE MEMBER_ID = ?";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, m.getMemberName());
            pstmt.setString(2, m.getEmail());
            pstmt.setString(3, m.getTel());
            pstmt.setString(4, m.getZip());
            pstmt.setString(5, m.getAddr1());
            pstmt.setString(6, m.getAddr2());
            pstmt.setString(7, m.getMemberId());
            result = pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(pstmt);
        }
        return result;
    }

    /**
     * 비밀번호 변경
     * @param conn       DB 연결 객체
     * @param memberId   대상 회원 아이디
     * @param currentPwd 현재 비밀번호(평문)
     * @param newPwd     새 비밀번호(평문)
     * @return UPDATE 성공 개수
     */
    public int updatePassword(Connection conn, String memberId, String currentPwd, String newPwd) {
        int result = 0;
        PreparedStatement pstmt = null;
        String sql = "UPDATE USERS SET MEMBER_PWD = ? "
                   + "WHERE MEMBER_ID = ? AND MEMBER_PWD = ?";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, SHA256.encrypt(newPwd));
            pstmt.setString(2, memberId);
            pstmt.setString(3, SHA256.encrypt(currentPwd));
            result = pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(pstmt);
        }
        return result;
    }

    /**
     * 마일리지 증감 처리
     * @param conn     DB 연결 객체
     * @param memberId 대상 회원 아이디
     * @param delta    증감할 마일리지 (+ 또는 –)
     * @return UPDATE 성공 개수
     */
    public int updateMileage(Connection conn, String memberId, int delta) throws SQLException {
        String sql = "UPDATE USERS SET MILEAGE = MILEAGE + ? WHERE MEMBER_ID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, delta);
            pstmt.setString(2, memberId);
            return pstmt.executeUpdate();
        }
    }

    /**
     * VIP 정보 저장
     * @param conn DB 연결 객체
     * @param m    회원 DTO (VIP 정보 포함)
     * @return INSERT 성공 개수
     */
    public int insertVipInfo(Connection conn, MemberDTO m) {
        int result = 0;
        PreparedStatement pstmt = null;
        String sql = "INSERT INTO VIP_INFO (MEMBER_ID, PREFERRED_CATEGORY, ANNUAL_BUDGET, VIP_NOTE)"
                   + " VALUES (?, ?, ?, ?)";

        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, m.getMemberId());
            pstmt.setString(2, m.getPreferredCategory());
            pstmt.setString(3, m.getAnnualBudget());
            pstmt.setString(4, m.getVipNote());
            result = pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            close(pstmt);
        }
        return result;
    }

}