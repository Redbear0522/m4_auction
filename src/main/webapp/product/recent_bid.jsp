<%-- 
  File: WebContent/recent_bid.jsp
  역할: 최근 낙찰된 상품을 목록으로 출력
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, com.auction.dao.ProductDAO, com.auction.vo.ProductDTO" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>

<html>
<head>
    <title>최근 낙찰된 상품</title>
    <style>
        body {
            font-family: Arial, sans-serif;
        }
        .container {
            width: 80%;
            margin: 30px auto;
        }
        .title {
            text-align: center;
            font-size: 24px;
            margin-bottom: 30px;
        }
        .win-item {
            display: flex;
            align-items: center;
            border-bottom: 1px solid #ddd;
            padding: 10px 0;
        }
        .win-item img {
            width: 100px;
            height: 100px;
            margin-right: 20px;
            object-fit: cover;
            border-radius: 8px;
        }
        .win-info {
            flex-grow: 1;
        }
        .win-info strong {
            font-size: 18px;
        }
        .win-info span {
            display: block;
            margin-top: 5px;
            color: #555;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="title">📦 최근 낙찰된 상품 목록</div>
        <%
            Connection conn = getConnection();
            ProductDAO dao = new ProductDAO();
            List<ProductDTO> winList = dao.selectRecentWins(conn);
            close(conn);

            if (winList != null && !winList.isEmpty()) {
                for (ProductDTO p : winList) {
        %>
        <div class="win-item">
            <img src="upload/<%= p.getImageRenamedName() %>" alt="썸네일">
            <div class="win-info">
                <strong><%= p.getProductName() %></strong>
                <span>작가: <%= p.getArtistName() %></span>
                <span>낙찰가: <%= p.getFinalPrice() %>원</span>
                <span>낙찰자: <%= p.getWinnerId() %></span>
            </div>
        </div>
        <%
                }
            } else {
        %>
        <p style="text-align:center;">최근 낙찰된 상품이 없습니다.</p>
        <% } %>
    </div>
</body>
</html>
