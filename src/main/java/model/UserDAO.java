package model;

import java.sql.*;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class UserDAO {
    private DataSource ds;
    private Connection conn;
    private PreparedStatement pstmt;
    private ResultSet rs;

    // 1) DB 연결
    private Connection getConnection() throws ClassNotFoundException, SQLException {
        Class.forName("oracle.jdbc.driver.OracleDriver");
        String url = "jdbc:oracle:thin:@192.168.219.198:1521:orcl";
        //String url= "jdbc:oracle:thin:@192.168.219.198:1521:orcl";
        return DriverManager.getConnection(url, "team01", "1234");
    }
    
    public UserDAO() {
        try {
            Context init = new InitialContext();
            ds = (DataSource) init.lookup("java:comp/env/jdbc/OracleDB");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 회원 등록
    public boolean insertUser(UserDTO user) {
        String sql = "INSERT INTO USERS (MEMBER_ID, MEMBER_PWD, MEMBER_NAME, EMAIL, TEL, BIRTHDATE, GENDER, MOBILE_CARRIER, ENROLL_DATE, MILEAGE) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE)";
        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, user.getMemberId());
            pstmt.setString(2, user.getMemberPwd());
            pstmt.setString(3, user.getMemberName());
            pstmt.setInt(4, user.getMileage());

            int result = pstmt.executeUpdate();
            return result == 1;

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ID 중복 확인
    public boolean isDuplicateId(String memberId) {
        String sql = "SELECT 1 FROM USERS WHERE MEMBER_ID = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, memberId);
            ResultSet rs = pstmt.executeQuery();
            return rs.next(); // true: 존재함 → 중복 ID

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // 회원 상세 정보 조회
    public UserDTO getUser(String memberId) {
        String sql = "SELECT * FROM USERS WHERE MEMBER_ID = ?";
        try (Connection conn = ds.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, memberId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                UserDTO user = new UserDTO();
                user.setMemberId(rs.getString("MEMBER_ID"));
                user.setMemberPwd(rs.getString("MEMBER_PWD"));
                user.setMemberName(rs.getString("MEMBER_NAME"));
                user.setMileage(rs.getInt("MILEAGE"));
                return user;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
