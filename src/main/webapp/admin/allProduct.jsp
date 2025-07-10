<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.sql.Connection" %>
<%@ page import="com.auction.common.PageInfo" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.auction.dao.ProductDAO, com.auction.dto.ProductDTO" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%
    String ctx = request.getContextPath();

    int currentPage = 1, pageLimit = 5, boardLimit = 100;
    if (request.getParameter("page") != null) {
        currentPage = Integer.parseInt(request.getParameter("page"));
    }

    List<ProductDTO> productList = null;
    PageInfo pi = null;
    try (Connection conn = getConnection()) {
        int listCount = new ProductDAO().selectProductCount(conn);
        pi = new PageInfo(listCount, currentPage, pageLimit, boardLimit);
        productList = new ProductDAO().selectAllProducts(conn);
    } catch (Exception e) { e.printStackTrace(); }
    DecimalFormat df = new DecimalFormat("###,###");
    
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>전체 상품 목록</title>
    <link rel="stylesheet" href="<%=ctx%>/resources/css/luxury-global-style.css">
    <link rel="stylesheet" href="<%=ctx%>/resources/css/layout.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
        body { background: #f8f8f8; padding-top: 120px !important; }
        .admin-layout {
            display: flex;
            max-width: 1400px;
            margin: 0 auto;
            gap: 30px;
            padding: 40px 20px;
        }
        .admin-sidebar {
            width: 280px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            padding: 0;
            position: sticky;
            top: 140px;
            height: fit-content;
        }
        .sidebar-header {
            background: linear-gradient(135deg, #1a1a1a 0%, #c9961a 100%);
            color: white;
            padding: 24px;
            border-radius: 12px 12px 0 0;
            text-align: center;
        }
        .sidebar-title {
            font-family: 'Playfair Display', serif;
            font-size: 20px;
            font-weight: 700;
            margin: 0;
        }
        .sidebar-subtitle {
            font-size: 13px;
            opacity: 0.9;
            margin-top: 4px;
        }
        .sidebar-menu {
            padding: 0;
            margin: 0;
            list-style: none;
        }
        .sidebar-menu li {
            border-bottom: 1px solid #f0f0f0;
        }
        .sidebar-menu li:last-child {
            border-bottom: none;
        }
        .sidebar-menu a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 24px;
            color: #333;
            text-decoration: none;
            transition: all 0.3s;
            font-size: 14px;
            font-weight: 500;
        }
        .sidebar-menu a:hover {
            background: #f8f9fa;
            color: #c9961a;
        }
        .sidebar-menu a.active {
            background: #c9961a;
            color: white;
        }
        .sidebar-menu i {
            width: 18px;
            text-align: center;
        }
        .admin-content {
            flex: 1;
        }
        .main-header {
            margin-bottom: 28px;
        }
        .main-title {
            font-size: 28px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 4px;
        }
        .main-desc {
            color: #6b7280;
            font-size: 15px;
            margin: 0;
        }
        .product-list-container {
            width: 100%;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(270px,1fr));
            gap: 28px;
        }
        .product-card {
            background: #fff;
            border: 1px solid #e5dfc8;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(201,150,26,0.04);
            display: flex;
            flex-direction: column;
            transition: box-shadow 0.2s;
        }
        .product-card:hover { box-shadow:0 6px 32px rgba(201,150,26,0.10);}
        .product-image {
            width: 100%;
            height: 180px;
            object-fit: cover;
            background: #eee;
        }
        .product-info {
            padding: 18px 16px 16px 16px;
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .product-title {
            font-size: 17px;
            font-weight: 700;
            color: #333;
            margin-bottom: 2px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .product-meta, .product-meta2 {
            color: #888;
            font-size: 13px;
        }
        .product-curruntprice {
            color: #c9961a;
            font-size: 16px;
            font-weight: 600;
        }
        .details-btn {
            margin-top: 13px;
            padding: 9px 0;
            background: #c9961a;
            color: #fff;
            border-radius: 8px;
            text-align: center;
            text-decoration: none;
            font-weight: 700;
            transition: background 0.2s;
            display: block;
        }
        .details-btn:hover { background: #ad870e; }
        .pagination {
            display: flex;
            justify-content: center;
            margin: 40px 0 30px 0;
            gap: 7px;
        }
        .pagination a {
            color: #888;
            padding: 6px 15px;
            border-radius: 6px;
            background: #fff;
            text-decoration: none;
            font-size: 15px;
            transition: background 0.2s, color 0.2s;
        }
        .pagination a.active,
        .pagination a:hover {
            color: #fff;
            background: #c9961a;
        }
        .empty-state {
            text-align: center;
            color: #aaa;
            padding: 60px 0 30px 0;
            grid-column: 1 / -1;
        }
        .empty-state i { font-size: 48px; opacity: 0.45; margin-bottom: 18px; display: block;}
        @media (max-width: 1100px) {
            .admin-layout { flex-direction: column; }
            .admin-sidebar { width: 100%; position: static; }
        }
        @media (max-width: 900px) {
            .product-list-container { grid-template-columns: repeat(2,1fr);}
        }
        @media (max-width: 600px) {
            .product-list-container { grid-template-columns: 1fr;}
        }
    </style>
</head>
<body>
<jsp:include page="/layout/header/luxury-header.jsp" flush="true"/>
<div class="admin-layout">
    <!-- 사이드바 -->
    <div class="admin-sidebar">
        <div class="sidebar-header">
            <div class="sidebar-title">관리자 패널</div>
            <div class="sidebar-subtitle">Admin Panel</div>
        </div>
        <ul class="sidebar-menu">
            <li><a href="<%=ctx%>/admin/adminPage.jsp"><i class="fas fa-tachometer-alt"></i>대시보드</a></li>
            <li><a href="<%=ctx%>/admin/waittingProduct.jsp"><i class="fas fa-clock"></i>상품 승인 관리</a></li>
            <li><a href="<%=ctx%>/admin/allProduct.jsp" class="active"><i class="fas fa-box"></i>전체 상품 관리</a></li>
            <li><a href="<%=ctx%>/admin/auctionManage.jsp"><i class="fas fa-gavel"></i>경매 관리</a></li>
            <li><a href="<%=ctx%>/admin/chargeRequestList.jsp"><i class="fas fa-coins"></i>마일리지 충전 관리</a></li>
            <li><a href="<%=ctx%>/admin/vipRequestList.jsp"><i class="fas fa-crown"></i>VIP 신청 관리</a></li>
            <li><a href="<%=ctx%>/admin/memberManage.jsp"><i class="fas fa-users"></i>회원 관리</a></li>
            <li><a href="<%=ctx%>/admin/bidHistory.jsp"><i class="fas fa-list"></i>입찰 내역 관리</a></li>
            <li><a href="<%=ctx%>/admin/siteStatistics.jsp"><i class="fas fa-chart-bar"></i>사이트 통계</a></li>
            <li><a href="<%=ctx%>/admin/systemSettings.jsp"><i class="fas fa-cog"></i>시스템 설정</a></li>
            <li><a href="<%=ctx%>/luxury-main.jsp"><i class="fas fa-home"></i>메인 페이지로</a></li>
        </ul>
    </div>
    <!-- 메인 컨텐츠 -->
    <div class="admin-content">
        <div class="main-header">
            <div class="main-title">전체 상품 목록</div>
            <div class="main-desc">현재 등록된 전체 상품을 확인할 수 있습니다.</div>
        </div>
        <!-- 정렬 옵션 -->
        <div style="text-align:right; margin-bottom:20px;">
            <select id="sortSelect" style="padding:6px 14px;border-radius:6px;font-size:15px;">
                <option value="">— 정렬 선택 —</option>
                <option value="regdate-asc">등록일 ↑</option>
                <option value="regdate-desc">등록일 ↓</option>
                <option value="endTime-asc">마감일 ↑</option>
                <option value="endTime-desc">마감일 ↓</option>
                <option value="price-asc">현재가 ↑</option>
                <option value="price-desc">현재가 ↓</option>
            </select>
        </div>
        <div class="product-list-container">
            <% if (productList != null && !productList.isEmpty()) {
                for (ProductDTO p : productList) {
                int priceToShow = (p.getCurrentPrice() == 0) ? p.getStartPrice() : p.getCurrentPrice();
            %>
            <div class="product-card">
                <img class="product-image"
                    src="<%= ctx %>/resources/product_images/<%= p.getImageRenamedName() %>"
                    alt="<%= p.getProductName() %>">
                <div class="product-info">
                    <div class="product-title"><%= p.getProductName() %></div>
                    <div class="product-meta">등록자: <%= p.getSellerId() %></div>
                    <div class="product-curruntprice">현재가 <%= df.format(priceToShow) %> 원</div>
                    <div class="product-meta2 timer"
                         data-endtime="<%= p.getEndTime() != null ? p.getEndTime() : "" %>">
                        마감일
                        <% if (p.getEndTime() != null) { %>
                            <%= p.getEndTime() %>
                        <% } else { %> - <% } %>
                    </div>
                    <a href="<%=ctx%>/product/productDetail.jsp?productId=<%=p.getProductId()%>" class="details-btn">상세 보기</a>
                </div>
            </div>
            <% }
            } else { %>
            <div class="empty-state">
                <i class="fas fa-box-open"></i>
                등록된 상품이 없습니다.
            </div>
            <% } %>
        </div>
        <!-- 페이징 -->
        <% if (pi != null && pi.getMaxPage() > 1) { %>
        <div class="pagination">
            <% for(int i=1; i<=pi.getMaxPage(); i++) { %>
                <a href="?page=<%=i%>"
                   class="<%= (i==pi.getCurrentPage() ? "active" : "") %>"><%=i%></a>
            <% } %>
        </div>
        <% } %>
    </div>
</div>
<jsp:include page="/layout/footer/luxury-footer.jsp" flush="true"/>
<script>
document.getElementById('sortSelect').addEventListener('change', function() {
    const val = this.value;
    if (!val) return;
    const [criteria, order] = val.split('-');
    sortProducts(criteria, order);
});
function sortProducts(criteria, order) {
    const grid = document.querySelector('.product-list-container');
    const cards = Array.from(grid.querySelectorAll('.product-card'));
    cards.sort((a, b) => {
      let aVal, bVal;
      if (criteria === 'endTime') {
        aVal = new Date(a.querySelector('.timer').dataset.endtime).getTime();
        bVal = new Date(b.querySelector('.timer').dataset.endtime).getTime();
      } else if (criteria === 'price') {
        const getPrice = card => {
          const txt = card.querySelector('.product-curruntprice').textContent;
          return parseInt(txt.replace(/[^0-9]/g, '')) || 0;
        };
        aVal = getPrice(a);
        bVal = getPrice(b);
      }
      return (order === 'asc') ? (aVal - bVal) : (bVal - aVal);
    });
    cards.forEach(card => grid.appendChild(card));
}
</script>
</body>
</html>
