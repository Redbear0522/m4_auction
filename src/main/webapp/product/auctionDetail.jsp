<%-- File: WebContent/product/auctionDetail.jsp --%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.auction.dao.AuctionDAO, com.auction.vo.AuctionDTO" %>

<%-- ▼▼▼ [수정된 부분] 파라미터 값 검증 로직 추가 ▼▼▼ --%>
<div style="background-color:#fffde7; padding: 1px 15px; border-radius: 5px; margin-bottom:10px; border:1px solid #ffecb3;">
<%
	request.setCharacterEncoding("UTF-8");

	// 1. 파라미터를 일단 문자열로 받습니다.
	String id_str = request.getParameter("id");

	// 2. 파라미터가 null이거나 비어있는지 검사합니다.
	if (id_str == null || id_str.trim().isEmpty()) {
		// 만약 값이 없다면, 알림 메시지를 세션에 저장하고 목록 페이지로 돌려보냅니다.
		session.setAttribute("alertMsg", "잘못된 접근입니다. 상품 번호가 누락되었습니다.");
		response.sendRedirect("auctionList.jsp");
		return; // 이 페이지의 추가 실행을 막습니다.
	}

	int id = 0;
	AuctionDTO item = null;
	try {
		// 3. 문자열을 숫자로 변환합니다. 숫자가 아닌 값이 들어오면 catch 블록으로 이동합니다.
		id = Integer.parseInt(id_str);

		// 4. id 값이 정상일 때만 DAO를 통해 상품 정보를 조회합니다.
		AuctionDAO dao = new AuctionDAO();
		item = dao.getAuctionItemById(id);

		// 5. DB에서 해당 id의 상품을 찾지 못한 경우도 처리합니다.
		if (item == null) {
			session.setAttribute("alertMsg", "존재하지 않는 상품입니다.");
			response.sendRedirect("auctionList.jsp");
			return;
		}

	} catch (NumberFormatException e) {
		// id 파라미터가 숫자가 아닌 경우 (예: ?id=abc)
		session.setAttribute("alertMsg", "상품 번호가 올바르지 않습니다.");
		response.sendRedirect("auctionList.jsp");
		return;
	}

	String memberId = (String) session.getAttribute("memberId");
%>
</div>
<%-- ▲▲▲ [수정된 부분] 종료 ▲▲▲ --%>
<html>
<head>
    <title>상품 상세 보기</title>
    <%-- (스타일 코드는 기존과 동일) --%>
    <style>
        .detail-box { width: 60%; margin: 30px auto; padding: 20px; border: 1px solid #ccc; border-radius: 10px; }
        .detail-box h2 { margin-bottom: 20px; }
        .detail-box p { margin: 10px 0; }
        .description { white-space: pre-line; }
        .bid-box { margin-top: 30px; }
        .bid-box input[type="number"] { width: 150px; padding: 5px; }
        .bid-box input[type="submit"] { padding: 5px 10px; }
    </style>
</head>
<body>
<jsp:include page="/layout/header/header.jsp" />
	<div class="detail-box">
		<h2><%= item.getTitle() %></h2>
		<p><strong>상품 번호:</strong> <%= item.getId() %></p>
		<p><strong>시작 가격:</strong> <%= item.getStartPrice() %>원</p>
		<p><strong>현재 최고가:</strong> <%= item.getCurrentPrice() %>원</p>
		<p><strong>등록일:</strong> <%= item.getRegDate() %></p>
		<p><strong>상태:</strong> <%= item.getStatus() %></p>
	
		<hr>
		<p><strong>상품 설명:</strong></p>
		<div class="description"><%= item.getDescription() %></div>
				
		<hr>
		<!--  입찰 폼 내역 -->
		<div class="bid-box">
			<h3> 입찰하기</h3>
			<%
				if(memberId == null){
			%>
				<p style="color:red;">로그인 후 입찰이 가능합니다.</p>
			<%
				}else{
			%>	
				<form action="bidProcess.jsp" method="post">
					<input type="hidden" name="itemId" value="<%= item.getId() %>">
					<input type="number" name="bidPrice" min="<%= item.getCurrentPrice() + 1 %>" required> 원
					<input type="submit" value="입찰">
				</form>
			<%
				}
			%>		
			
		<p><a href="auctionList.jsp">←목록으로 돌아가기</a></p>
	</div>	
</body>
</html>	