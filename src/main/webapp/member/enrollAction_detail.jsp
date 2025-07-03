<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
%><%@ page import="com.auction.vo.MemberDTO"
%><%@ page import="com.auction.dao.MemberDAO"
%><%@ page import="java.sql.Connection"
%><%@ page import="static com.auction.common.JDBCTemplate.*" %><%
    request.setCharacterEncoding("UTF-8");

    // 기본 정보 받기
    String userId = request.getParameter("userId");
    String userPwd = request.getParameter("userPwd");
    String userName = request.getParameter("userName");
    String birthdate = request.getParameter("birthdate");
    String gender = request.getParameter("gender");
    String email = request.getParameter("email");
    String mobileCarrier = request.getParameter("mobileCarrier");
    String tel = request.getParameter("tel");
    
    // 주소 정보
    String zip = request.getParameter("zip");
    String addr1 = request.getParameter("addr1");
    String addr2 = request.getParameter("addr2");
    String memberType = request.getParameter("memberType");
    
    // VIP 전용 정보 초기화
    String preferredCategory = "";
    String annualBudget = "";
    String vipNote = "";
    
    // VIP 회원일 때만 추가 정보 받기
    if("2".equals(memberType)) {
        preferredCategory = request.getParameter("preferredCategory");
        annualBudget = request.getParameter("annualBudget");
        vipNote = request.getParameter("vipNote");
    }
    
    // MemberDTO 생성
    MemberDTO m = new MemberDTO(userId, userPwd, userName, email, tel, birthdate, gender, mobileCarrier);
    m.setZip(zip);
    m.setAddr1(addr1);
    m.setAddr2(addr2);
    m.setMemberType(Integer.parseInt(memberType));
    
    // VIP 정보 설정
    if("2".equals(memberType)) {
        m.setPreferredCategory(preferredCategory);
        m.setAnnualBudget(annualBudget);
        m.setVipNote(vipNote);
    }
    
    // DB 처리
    Connection conn = getConnection();
    MemberDAO dao = new MemberDAO();
    
    // 1. USERS 테이블에 저장
    int result = dao.enrollMember(conn, m);
    
    // 2. VIP 회원이면 VIP_INFO 테이블에도 저장
    int vipResult = 1; // 기본값 (일반회원은 VIP 저장 안 함)
    if(result > 0 && "2".equals(memberType)) {
        vipResult = dao.insertVipInfo(conn, m);
        
        if(vipResult > 0) {
            System.out.println("VIP 정보 저장 성공!");
        } else {
            System.out.println("VIP 정보 저장 실패!");
        }
    }
    
    // 3. 모두 성공했을 때만 commit
    if (result > 0 && vipResult > 0) {
        commit(conn);
    } else {
        rollback(conn);
        result = 0; // 실패 처리
    }
    
    close(conn);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 처리</title>
</head>
<body>
    <script>
        <% if(result > 0) { %>
            alert("회원가입이 완료되었습니다. 로그인 페이지로 이동합니다.");
            location.href = "loginForm.jsp";
        <% } else { %>
            alert("회원가입에 실패했습니다. 다시 시도해주세요.");
            location.href = "enroll_step1.jsp";
        <% } %>
    </script>
</body>
</html>