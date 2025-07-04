<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.auction.vo.MemberDTO, com.auction.vo.ProductDTO" %>
<%@ page import="com.auction.dao.ProductDAO" %>
<%@ page import="com.auction.dao.TransactionLogDAO" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%
MemberDTO loginUser = (MemberDTO)session.getAttribute("loginUser");
if(loginUser == null){
    response.sendRedirect("../member/loginForm.jsp");
    return;
}

int productId = Integer.parseInt(request.getParameter("productId"));
long bidPrice = Long.parseLong(request.getParameter("bidPrice"));

Connection conn = getConnection();
ProductDAO dao = new ProductDAO();
ProductDTO p = dao.selectProductById(conn, productId);

// 상품 존재 여부 확인
if (p == null) {
    rollback(conn);
%>
<script>
    alert("존재하지 않는 상품입니다.");
    location.href = "productList.jsp";
</script>
<%
    close(conn);
    return;
}

// 입찰가 유효성 확인
if (bidPrice <= p.getCurrentPrice()) {
    rollback(conn);
%>
<script>
    alert("입찰가는 현재가보다 높아야 합니다.");
    history.back();
</script>
<%
    close(conn);
    return;
}

// 마일리지 보유 여부 확인
if (bidPrice > loginUser.getMileage()) {
    rollback(conn);
%>
<script>
    alert("보유 마일리지가 부족합니다.");
    history.back();
</script>
<%
    close(conn);
    return;
}

	//1) 현재가 업데이트
   int resultPrice = dao.updateCurrentPrice(conn, productId, (Long)bidPrice);
   // 2) 마일리지 차감
   int resultMileage = dao.reduceMileage(conn, loginUser.getMemberId(), bidPrice);

   if(resultPrice > 0 && resultMileage > 0) {
     commit(conn);
     
   if(resultPrice > 0) {
    	    commit(conn);
    	    session.setAttribute("alertMsg", "입찰 성공!");
    	    
    	    // --- 거래내역 기록 ---
    	    new TransactionLogDAO()
    	        .insertLog(conn,
    	                   loginUser.getMemberId(),
    	                   "B",               // 입찰
    	                   bidPrice,
    	                   productId);
    	} else {
    	    rollback(conn);
    	    session.setAttribute("alertMsg", "입찰 실패");
    	}
%>

<script>
 alert("입찰 성공");
 location.href = "productDetail.jsp?productId=<%= productId %>";
</script>
<%
       // 세션에 남은 마일리지 반영
       loginUser.setMileage(loginUser.getMileage() - bidPrice);
       session.setAttribute("loginUser", loginUser);
 } else {
     rollback(conn);
%>
<script>
    alert("입찰 실패");
    history.back();
</script>
<%
}
close(conn);
%>