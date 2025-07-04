<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.sql.Connection" %>
<%@ page import="com.auction.dao.ProductDAO, com.auction.vo.ProductDTO" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>📦 최근 낙찰된 상품</title>
    <style>
        body { font-family: 'Noto Sans KR', sans-serif; background: #f5f5f5; margin: 0; }
        .container { width: 80%; max-width: 1000px; margin: 40px auto; background: #fff; padding: 20px; border-radius: 8px; }
        .title { text-align: center; font-size: 28px; margin-bottom: 30px; color: #333; }
        .win-item { display: flex; align-items: center; border-bottom: 1px solid #eee; padding: 15px 0; }
        .win-item:last-child { border-bottom: none; }
        .win-item img { width: 120px; height: 120px; object-fit: cover; border-radius: 6px; margin-right: 20px; }
        .win-info { flex: 1; }
        .win-info strong { display: block; font-size: 20px; color: #222; }
        .win-info span { display: block; margin-top: 6px; color: #555; }
        .empty-msg { text-align: center; color: #777; padding: 40px 0; }
    </style>
</head>
<body>
<jsp:include page="/layout/header/header.jsp" />
<div class="container">
    <div class="title">최근 낙찰된 상품</div>
    <%
        List<ProductDTO> winList;
        try (Connection conn = getConnection()) {
            winList = new ProductDAO().selectRecentWins(conn);
        } catch (Exception e) {
            winList = null;
            out.println("<p class='empty-msg'>데이터를 불러오는 중 오류가 발생했습니다.</p>");
        }
        if (winList != null && !winList.isEmpty()) {
            for (ProductDTO p : winList) {
    %>
    <div class="win-item">
        <img src="<%=request.getContextPath()%>/resources/product_images/<%=p.getImageRenamedName()%>" alt="<%=p.getProductName()%>">
        <div class="win-info">
            <strong><%=p.getProductName()%></strong>
            <span>작가: <%=p.getArtistName()%></span>
            <span>낙찰가: ₩ <%=String.format("%,d", p.getFinalPrice())%></span>
            <span>낙찰자: <%=p.getWinnerId()%></span>
        </div>
    </div>
    <%
            }
        } else {
    %>
    <p class="empty-msg">최근 낙찰된 상품이 없습니다.</p>
    <%
        }
    %>
</div>
<jsp:include page="/layout/footer/footer.jsp" />
</body>
</html>
