<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="com.auction.vo.MemberDTO" %>
<%@ page import="com.auction.vo.BidDTO" %>
<%@ page import="com.auction.dao.ProductDAO" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>

<%
    // 1. 로그인 여부 확인
    MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }

    // 2. 파라미터 받기
    int productId    = Integer.parseInt(request.getParameter("productId"));
    int bidPrice     = Integer.parseInt(request.getParameter("bidPrice"));
    int currentPrice = Integer.parseInt(request.getParameter("currentPrice"));

    // 3. 유효성 검증: 입찰가 > 현재가
    if (bidPrice <= currentPrice) {
%>
<script>
    alert("입찰가는 현재가보다 높아야 합니다.");
    history.back();
</script>
<%
        return;
    }

    // 4. Bid 객체에 정보 세팅
    BidDTO b = new BidDTO();
    b.setItemId(productId); 
    b.setBidderId(loginUser.getMemberId());           // MemberDTO의 사용자 아이디
    b.setBidPrice(bidPrice);

    // 5. 트랜잭션 처리
    Connection conn = getConnection();
    ProductDAO dao = new ProductDAO();
    int result1 = 0, result2 = 0;
    try {
        result1 = dao.insertBid(conn, b);
        result2 = dao.updateCurrentPrice(conn, productId, bidPrice);
        if (result1 > 0 && result2 > 0) {
            commit(conn);
        } else {
            rollback(conn);
        }
    } catch (Exception e) {
        rollback(conn);
        e.printStackTrace();
    } finally {
        close(conn);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>입찰 처리</title>
</head>
<body>
<script>
<% if (result1 > 0 && result2 > 0) { %>
    alert("입찰에 성공했습니다.");
    // 상품 상세페이지로 리다이렉트
    location.replace("productDetail.jsp?productId=<%= productId %>");
<% } else { %>
    alert("입찰 처리 중 오류가 발생했습니다. 다시 시도해주세요.");
    history.back();
<% } %>
</script>
</body>
</html>
