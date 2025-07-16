<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.auction.dto.ChargeRequestDTO" %>
<%@ page import="com.auction.dto.MemberDTO" %>
<%@ page import="com.auction.dto.ProductDTO" %>
<%@ page import="com.auction.dao.ProductDAO" %>
<%@ page import="com.auction.dao.AdminDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%
    // 관리자 로그인 체크
    MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(loginUser.getMemberId())) {
        session.setAttribute("alertMsg", "관리자 로그인 후 이용 가능한 서비스입니다.");
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    String alertMsg = (String) session.getAttribute("alertMsg");
    session.removeAttribute("alertMsg");

    // 데이터 조회
    Connection conn = getConnection();
    AdminDAO aDao = new AdminDAO();
    ProductDAO pDAO = new ProductDAO();

    int totalProducts   = aDao.selectTotalProducts(conn);
    int pendingCount    = aDao.selectPendingProducts(conn);
    int totalBids       = aDao.selectTotalBids(conn);
    long totalRevenue   = aDao.selectTotalRevenue(conn);

    List<ProductDTO> pendingList = aDao.selectPendingProductsList(conn);
    List<ChargeRequestDTO> chargeList = aDao.getAllChargeRequests(conn);
    List<ProductDTO> allList = pDAO.selectAllProducts(conn);

    close(conn);

    DecimalFormat dfCount = new DecimalFormat("###,###");
    DecimalFormat dfAmt   = new DecimalFormat("###,###,###");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>관리자 페이지 - M4 Auction</title>
    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <!-- Global Styles -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/luxury-global-style.css">
    <style>
        body {
            font-family: 'Inter', 'Noto Sans KR', sans-serif;
            background: #f8f9fa;
            padding-top: 120px !important;
            line-height: 1.6;
        }
        .admin-layout { display: flex; max-width: 1400px; margin: 0 auto; gap: 30px; padding: 40px 20px; }
        .admin-sidebar {
            width: 280px; background: #fff; border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08); padding: 0;
            position: sticky; top: 140px; height: fit-content;
        }
        .sidebar-header { background: linear-gradient(135deg, #1a1a1a 0%, #c9961a 100%); color: white; padding: 24px; border-radius: 12px 12px 0 0; text-align: center; }
        .sidebar-title { font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; margin: 0; }
        .sidebar-subtitle { font-size: 13px; opacity: 0.9; margin-top: 4px; }
        .sidebar-menu { padding: 0; margin: 0; list-style: none; }
        .sidebar-menu li { border-bottom: 1px solid #f0f0f0; }
        .sidebar-menu li:last-child { border-bottom: none; }
        .sidebar-menu a {
            display: flex; align-items: center; gap: 12px; padding: 16px 24px;
            color: #333; text-decoration: none; transition: all 0.3s;
            font-size: 14px; font-weight: 500;
        }
        .sidebar-menu a:hover { background: #f8f9fa; color: #c9961a; }
        .sidebar-menu a.active { background: #c9961a; color: white; }
        .sidebar-menu i { width: 18px; text-align: center; }

        .admin-content { flex: 1; }
        .page-header { background: white; border-radius: 12px; padding: 32px; margin-bottom: 32px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .page-title { font-family: 'Playfair Display', serif; font-size: 28px; font-weight: 700; color: #1a1a1a; margin: 0 0 8px 0; }
        .page-subtitle { color: #666; font-size: 14px; margin: 0; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 24px; margin-bottom: 32px; }
        .stat-card {
            background: white; border-radius: 12px; padding: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);
            border-left: 4px solid #c9961a; transition: all 0.3s; cursor: pointer;
            text-decoration: none; color: inherit;
        }
        .stat-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,0.1); transform: translateY(-2px); border-left-color: #b8860b; }
        .stat-number { font-size: 24px; font-weight: 700; color: #c9961a; margin-bottom: 4px; }
        .stat-label { color: #666; font-size: 14px; margin-bottom: 8px; }
        .stat-detail { color: #999; font-size: 12px; }

        .content-section { background: white; border-radius: 12px; padding: 24px; margin-bottom: 24px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);}
        .section-title { font-size: 18px; font-weight: 600; color: #1a1a1a; margin: 0 0 20px 0; padding-bottom: 12px; border-bottom: 2px solid #f0f0f0; }

        .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 20px; }
        .product-card { border: 1px solid #eee; border-radius: 8px; overflow: hidden; transition: all 0.3s; background: #fff; }
        .product-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.1); transform: translateY(-2px); }
        .product-image { width: 100%; height: 120px; object-fit: cover; background: #f3f3f3; }
        .product-info { padding: 12px; }
        .product-name { font-size: 13px; font-weight: 600; color: #333; margin-bottom: 4px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .product-price { font-size: 12px; color: #c9961a; font-weight: 600; }
        .product-seller { font-size: 11px; color: #666; margin-top: 4px; }
        .empty-state { text-align: center; padding: 40px; color: #999; }
        .empty-state i { font-size: 48px; margin-bottom: 16px; display: block; }
        .more-btn {
            display: inline-block; background: #c9961a; color: white;
            padding: 12px 24px; border-radius: 6px; text-decoration: none;
            font-size: 14px; font-weight: 500; margin-top: 20px; transition: all 0.3s;
        }
        .more-btn:hover { background: #b8860b; color: white; }
        @media (max-width: 900px) { .product-grid { grid-template-columns: 1fr 1fr; } }
        @media (max-width: 600px) { .product-grid { grid-template-columns: 1fr; } .admin-layout{flex-direction:column;} }
    </style>
</head>
<body>
<jsp:include page="/layout/header/luxury-header.jsp" />

<div class="admin-layout">
    <!-- 사이드바 -->
    <div class="admin-sidebar">
        <div class="sidebar-header">
            <h2 class="sidebar-title">관리자 패널</h2>
            <p class="sidebar-subtitle">Admin Panel</p>
        </div>
        <ul class="sidebar-menu">
            <li><a href="<%=request.getContextPath()%>/admin/adminPage.jsp" class="active"><i class="fas fa-tachometer-alt"></i> 대시보드</a></li>
            <li><a href="<%=request.getContextPath()%>/admin/waittingProduct.jsp"><i class="fas fa-clock"></i> 상품 승인 관리</a></li>
            <li><a href="<%=request.getContextPath()%>/admin/allProduct.jsp"><i class="fas fa-box"></i> 전체 상품 관리</a></li>
            <li><a href="<%=request.getContextPath()%>/admin/auctionManage.jsp"><i class="fas fa-gavel"></i> 경매 관리</a></li>
            <li><a href="<%=request.getContextPath()%>/admin/chargeRequestList.jsp"><i class="fas fa-coins"></i> 마일리지 충전 관리</a></li>
            <li><a href="<%=request.getContextPath()%>/admin/memberManage.jsp"><i class="fas fa-users"></i> 회원 관리</a></li>
            <li><a href="<%=request.getContextPath()%>/admin/bidHistory.jsp"><i class="fas fa-list"></i> 입찰 내역 관리</a></li>
            <li><a href="<%=request.getContextPath()%>/admin/siteStatistics.jsp"><i class="fas fa-chart-bar"></i> 사이트 통계</a></li>
            <li><a href="<%=request.getContextPath()%>/admin/systemSettings.jsp"><i class="fas fa-cog"></i> 시스템 설정</a></li>
            <li><a href="<%=request.getContextPath()%>/index.jsp"><i class="fas fa-home"></i> 메인 페이지로</a></li>
        </ul>
    </div>
    
    <!-- 메인 컨텐츠 -->
    <div class="admin-content">
        <!-- 페이지 헤더 -->
        <div class="page-header">
            <h1 class="page-title">관리자 대시보드</h1>
            <p class="page-subtitle">시스템 전반의 통계와 주요 관리 업무를 확인하세요</p>
        </div>

        <!-- 통계 카드 -->
        <div class="stats-grid">
            <a href="<%=request.getContextPath()%>/admin/allProduct.jsp" class="stat-card">
                <div class="stat-number"><%= dfCount.format(totalProducts) %></div>
                <div class="stat-label">전체 상품</div>
                <div class="stat-detail">전체 상품 보기</div>
            </a>
            <a href="<%=request.getContextPath()%>/admin/waittingProduct.jsp" class="stat-card">
                <div class="stat-number"><%= dfCount.format(pendingCount) %></div>
                <div class="stat-label">승인 대기</div>
                <div class="stat-detail">대기 목록 보기</div>
            </a>
            <a href="<%=request.getContextPath()%>/admin/bidHistory.jsp" class="stat-card">
                <div class="stat-number"><%= dfCount.format(totalBids) %></div>
                <div class="stat-label">전체 입찰 건수</div>
                <div class="stat-detail">입찰 내역</div>
            </a>
            <a href="<%=request.getContextPath()%>/admin/siteStatistics.jsp" class="stat-card">
                <div class="stat-number">₩ <%= dfAmt.format(totalRevenue) %></div>
                <div class="stat-label">총 낙찰 금액</div>
                <div class="stat-detail">누적 금액</div>
            </a>
        </div>

        <!-- 승인 대기 상품 목록 -->
        <div class="content-section">
            <h2 class="section-title">승인 대기 상품 목록</h2>
            <% if (pendingList.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-clock"></i>
                    승인 대기 중인 상품이 없습니다.
                </div>
            <% } else { %>
                <div class="product-grid">
                    <% 
                    int pendingDisplayCount = 0;
                    for (ProductDTO p : pendingList) { 
                        if (pendingDisplayCount >= 6) break;
                        pendingDisplayCount++;
                    %>
                    <div class="product-card">
                        <a href="<%= request.getContextPath() %>/product/productDetail.jsp?productId=<%= p.getProductId() %>">
                            <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" alt="<%= p.getProductName() %>" class="product-image">
                        </a>
                        <div class="product-info">
                            <div class="product-name"><%= p.getProductName() %></div>
                            <div class="product-price">시작가 ₩ <%= dfAmt.format(p.getStartPrice()) %></div>
                            <div class="product-seller">등록자: <%= p.getSellerId() %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% if (pendingList.size() > 6) { %>
                    <a href="<%= request.getContextPath() %>/admin/waittingProduct.jsp" class="more-btn">
                        + 더보기 (<%= pendingList.size() - 6 %>개 더)
                    </a>
                <% } %>
            <% } %>
        </div>

        <!-- 전체 상품 목록 -->
        <div class="content-section">
            <h2 class="section-title">전체 상품 목록</h2>
            <% if (allList.isEmpty()) { %>
                <div class="empty-state">
                    <i class="fas fa-cube"></i>
                    등록된 상품이 없습니다.
                </div>
            <% } else { %>
                <div class="product-grid">
                    <% 
                    int allDisplayCount = 0;
                    for (ProductDTO p : allList) { 
                        if (allDisplayCount >= 6) break;
                        allDisplayCount++;
                    %>
                    <div class="product-card">
                        <a href="<%= request.getContextPath() %>/product/productDetail.jsp?productId=<%= p.getProductId() %>">
                            <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" alt="<%= p.getProductName() %>" class="product-image">
                        </a>
                        <div class="product-info">
                            <div class="product-name"><%= p.getProductName() %></div>
                            <div class="product-price">현재가 ₩ <%= dfAmt.format(p.getCurrentPrice()) %></div>
                            <div class="product-seller">등록자: <%= p.getSellerId() %></div>
                        </div>
                    </div>
                    <% } %>
                </div>
                <% if (allList.size() > 6) { %>
                    <a href="<%= request.getContextPath() %>/admin/allProduct.jsp" class="more-btn">
                        + 더보기 (<%= allList.size() - 6 %>개 더)
                    </a>
                <% } %>
            <% } %>
        </div>

        <!-- 마일리지 충전 요청 목록 -->
        <div class="content-section">
            <h2 class="section-title">마일리지 충전 요청 대기 목록</h2>
            <% boolean hasCharge = false;
               for (ChargeRequestDTO req : chargeList) {
                   if ("W".equals(req.getStatus())) { hasCharge=true; break;}
               }
               if (!hasCharge) { %>
                <div class="empty-state">
                    <i class="fas fa-coins"></i>
                    현재 충전 대기 요청이 없습니다.
                </div>
            <% } else { %>
                <div class="product-grid">
                    <% for (ChargeRequestDTO req : chargeList) {
                        if ("W".equals(req.getStatus())) { %>
                        <div class="product-card">
                            <div class="product-info">
                                <div class="product-name">회원 ID: <%= req.getMemberId() %></div>
                                <div class="product-price">충전 요청 ₩ <%= dfAmt.format(req.getAmount()) %></div>
                                <div class="product-seller">요청일: <%= req.getRequestDate() %></div>
                                <div style="margin-top:10px;">
                                    <a class="more-btn" style="background:#29b158;margin-right:8px;" href="<%= request.getContextPath() %>/admin/chargeAction.jsp?reqId=<%= req.getReqId() %>&action=approve">승인</a>
                                    <a class="more-btn" style="background:#db4a39;" href="<%= request.getContextPath() %>/admin/chargeAction.jsp?reqId=<%= req.getReqId() %>&action=reject">거부</a>
                                </div>
                            </div>
                        </div>
                    <% }} %>
                </div>
            <% } %>
        </div>
    </div>
</div>

<jsp:include page="/layout/footer/luxury-footer.jsp" />

<% if(alertMsg != null) { %>
<script>
    alert("<%= alertMsg %>");
</script>
<% } %>
<script>
// 현재 페이지에 맞는 사이드바 메뉴 활성화
document.addEventListener('DOMContentLoaded', function() {
    const currentPath = window.location.pathname;
    const menuItems = document.querySelectorAll('.sidebar-menu a');
    menuItems.forEach(item => {
        item.classList.remove('active');
        if (item.getAttribute('href').includes(currentPath.split('/').pop())) {
            item.classList.add('active');
        }
    });
    if (currentPath.includes('adminPage.jsp')) {
        document.querySelector('.sidebar-menu a[href*="adminPage.jsp"]').classList.add('active');
    }
});
</script>
</body>
</html>
