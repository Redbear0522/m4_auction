<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%@ page import="com.auction.dto.MemberDTO" %>
<%
    // 관리자 로그인 체크 필요 (간단히 로그인 유무만 체크 예시)
    // 실제론 관리자 권한 체크도 필요
     MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(loginUser.getMemberId())) {
        session.setAttribute("alertMsg", "관리자 로그인 후 이용 가능한 서비스입니다.");
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }
    

    class VipRequest {
        public int requestId;
        public String memberId;
        public String optionName;
        public Date requestDate;
        public String status;
    }

    List<VipRequest> list = new ArrayList<>();

    Connection conn = getConnection();
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String sql = "SELECT REQUEST_ID, MEMBER_ID, OPTION_NAME, REQUEST_DATE, STATUS FROM VIP_OPTION_REQUEST ORDER BY REQUEST_DATE DESC";
        pstmt = conn.prepareStatement(sql);
        rs = pstmt.executeQuery();

        while(rs.next()) {
            VipRequest vr = new VipRequest();
            vr.requestId = rs.getInt("REQUEST_ID");
            vr.memberId = rs.getString("MEMBER_ID");
            vr.optionName = rs.getString("OPTION_NAME");
            vr.requestDate = rs.getDate("REQUEST_DATE");
            vr.status = rs.getString("STATUS");
            list.add(vr);
        }

    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        close(rs);
        close(pstmt);
        close(conn);
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - VIP 혜택 신청 목록</title>
<style>
    body { font-family: Arial, sans-serif; background: #f5f5f5; padding: 20px; }
    table { border-collapse: collapse; width: 100%; background: #fff; }
    th, td { border: 1px solid #ccc; padding: 10px; text-align: center; }
    th { background-color: #d4af37; color: black; }
    .btn-approve { background-color: #28a745; color: white; border: none; padding: 6px 12px; cursor: pointer; border-radius: 4px; }
    .btn-reject { background-color: #dc3545; color: white; border: none; padding: 6px 12px; cursor: pointer; border-radius: 4px; }
</style>
<script>
    function processRequest(requestId, action) {
        if(confirm(action + " 처리하시겠습니까?")) {
            location.href = "vipRequestProcess.jsp?requestId=" + requestId + "&action=" + action;
        }
    }
</script>
</head>
<body>
    <h1>VIP 혜택 신청 목록</h1>
    <table>
        <thead>
            <tr>
                <th>요청 ID</th>
                <th>회원 ID</th>
                <th>옵션명</th>
                <th>신청일</th>
                <th>상태</th>
                <th>처리</th>
            </tr>
        </thead>
        <tbody>
            <% if(list.isEmpty()) { %>
                <tr><td colspan="6">신청 내역이 없습니다.</td></tr>
            <% } else { 
                for(VipRequest vr : list) { %>
                <tr>
                    <td><%= vr.requestId %></td>
                    <td><%= vr.memberId %></td>
                    <td><%= vr.optionName %></td>
                    <td><%= vr.requestDate %></td>
                    <td><%= vr.status %></td>
                    <td>
                        <% if("대기중".equals(vr.status)) { %>
                            <button class="btn-approve" onclick="processRequest(<%= vr.requestId %>, '승인')">승인</button>
                            <button class="btn-reject" onclick="processRequest(<%= vr.requestId %>, '거절')">거절</button>
                        <% } else { %>
                            처리완료
                        <% } %>
                    </td>
                </tr>
            <% } } %>
        </tbody>
    </table>
    	<div style="margin-top:20px;">
  <a href="<%= request.getContextPath() %>/admin/adminPage.jsp">관리자 대시보드로 돌아가기</a>
		</div>
</body>
</html>
