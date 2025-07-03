<%--
  File: WebContent/mypage/myPage.jsp
  역할: 내가 등록/입찰/낙찰받은 상품 목록과 VIP 혜택 신청 기능까지 포함된 마이페이지 최종 버전입니다.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.auction.vo.MemberDTO" %>
<%@ page import="com.auction.vo.ProductDTO" %>
<%@ page import="com.auction.dao.ProductDAO" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%
    MemberDTO loginUser = (MemberDTO)session.getAttribute("loginUser");
    if(loginUser == null){
        session.setAttribute("alertMsg", "로그인 후 이용 가능한 서비스입니다.");
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String alertMsg = (String)session.getAttribute("alertMsg");

    Connection conn = getConnection();
    ProductDAO pDao = new ProductDAO();
    List<ProductDTO> myProducts = pDao.selectProductsBySeller(conn, loginUser.getMemberId());
    List<ProductDTO> myBids = pDao.selectProductsByBidder(conn, loginUser.getMemberId());
    List<ProductDTO> myWonProducts = pDao.selectWonProducts(conn, loginUser.getMemberId());
    close(conn);

    boolean isVip = false;
    try (Connection conn2 = getConnection()) {
        String sql = "SELECT 1 FROM VIP_INFO WHERE MEMBER_ID = ?";
        PreparedStatement ps = conn2.prepareStatement(sql);
        ps.setString(1, loginUser.getMemberId());
        ResultSet rs = ps.executeQuery();
        if(rs.next()) isVip = true;
        rs.close(); ps.close();
    } catch(Exception e) { e.printStackTrace(); }

    DecimalFormat df = new DecimalFormat("###,###,###");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>My Page - Art Auction</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&display=swap">
<style>
    body { background: #1a1a1a; color: #e0e0e0; font-family: 'Noto Sans KR', sans-serif; margin: 0; }
    a { color: inherit; text-decoration: none; }
    .header, .footer { background: #000; padding: 20px 50px; text-align: center; }
    .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid #333; }
    .header .logo { font-size: 28px; color: #d4af37; }
    .nav a { margin-left: 20px; }
    .mypage-container { max-width: 1200px; margin: 40px auto; padding: 30px; }
    .section-title { font-size: 24px; border-left: 5px solid #d4af37; padding-left: 10px; margin-bottom: 20px; }
    .info-group { margin-bottom: 10px; display: flex; justify-content: space-between; }
    .info-label { font-weight: bold; width: 130px; color: #aaa; }
    .product-list { display: grid; grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); gap: 20px; }
    .product-card { background: #2b2b2b; padding: 15px; border-radius: 8px; }
    .product-card img { width: 100%; height: 180px; object-fit: cover; border-radius: 4px; }
    .product-title { font-size: 16px; margin: 10px 0 5px; color: #fff; }
    .product-price { font-weight: bold; color: #d4af37; }
    .vip-section { background: #2b2b2b; padding: 20px; margin-top: 30px; border-radius: 8px; }
</style>
</head>
<body>
    <header class="header">
        <div class="logo"><a href="<%= request.getContextPath() %>/index.jsp">Art Auction</a></div>
        <div class="nav">
            <span><%= loginUser.getMemberName() %>님</span>
            <a href="<%= request.getContextPath() %>/product/productEnrollForm.jsp">상품등록</a>
            <a href="<%= request.getContextPath() %>/mypage/myPage.jsp">마이페이지</a>
            <a href="<%= request.getContextPath() %>/member/logout.jsp">로그아웃</a>
        </div>
    </header>

    <div class="mypage-container">
        <h2 class="section-title">내 정보</h2>
        <div class="info-group"><span class="info-label">아이디</span><span><%= loginUser.getMemberId() %></span></div>
        <div class="info-group"><span class="info-label">이름</span><span><%= loginUser.getMemberName() %></span></div>
        <div class="info-group"><span class="info-label">이메일</span><span><%= loginUser.getEmail() %></span></div>
        <div class="info-group"><span class="info-label">전화번호</span><span><%= loginUser.getTel() != null ? loginUser.getTel() : "미입력" %></span></div>
        <div class="info-group"><span class="info-label">보유 마일리지</span><span><%= df.format(loginUser.getMileage()) %> P</span></div>

        <% if(isVip) { %>
        <div class="vip-section">
            <div class="info-group">
                <span class="info-label">VIP 혜택 신청</span>
                <form action="<%= request.getContextPath() %>/mypage/vipOptionRequest.jsp" method="post">
                    <select name="option" required>
                        <option value="">선택</option>
                        <option value="골드">골드</option>
                        <option value="다이아">다이아</option>
                    </select>
                    <input type="submit" value="신청하기">
                </form>
            </div>
        </div>
        <% } %>

        <h2 class="section-title">내가 등록한 상품</h2>
        <div class="product-list">
            <% if(myProducts.isEmpty()) { %><p>등록한 상품이 없습니다.</p><% } 
               else { for(ProductDTO p : myProducts) { %>
            <div class="product-card">
                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" alt="<%= p.getProductName() %>">
                <div class="product-title"><%= p.getProductName() %></div>
                <div class="product-price">₩ <%= df.format(p.getCurrentPrice()) %></div>
            </div>
            <% } } %>
        </div>

        <h2 class="section-title">내가 입찰한 상품</h2>
        <div class="product-list">
            <% if(myBids.isEmpty()) { %><p>입찰한 상품이 없습니다.</p><% } 
               else { for(ProductDTO p : myBids) { %>
            <div class="product-card">
                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" alt="<%= p.getProductName() %>">
                <div class="product-title"><%= p.getProductName() %></div>
                <div class="product-price">₩ <%= df.format(p.getCurrentPrice()) %></div>
            </div>
            <% } } %>
        </div>

        <h2 class="section-title">내가 낙찰받은 상품</h2>
        <div class="product-list">
            <% if(myWonProducts.isEmpty()) { %><p>낙찰받은 상품이 없습니다.</p><% } 
               else { for(ProductDTO p : myWonProducts) { %>
            <div class="product-card">
                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" alt="<%= p.getProductName() %>">
                <div class="product-title"><%= p.getProductName() %></div>
                <div class="product-price">낙찰가 ₩ <%= df.format(p.getFinalPrice()) %></div>
            </div>
            <% } } %>
        </div>
    </div>

    <footer class="footer">
        <p>&copy; 2025 Art Auction. All rights reserved.</p>
    </footer>
</body>
</html>
