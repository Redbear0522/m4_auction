<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.auction.dto.ChargeRequestDTO, com.auction.dto.MemberDTO, com.auction.dto.ProductDTO, com.auction.dao.ProductDAO, com.auction.dao.AdminDAO" %>
<%@ page import="java.util.List, java.util.ArrayList, java.sql.Connection, java.text.DecimalFormat, static com.auction.common.JDBCTemplate.*" %>
<%@ page import="java.util.stream.Collectors" %><%--// 자바 8 이상 사용 시 스트림을 활용하면 더 간결해집니다.--%>
<%
    // =================================================================================
    // 1. 데이터 처리 및 준비 (페이지 상단에서 로직 집중 처리)
    // =================================================================================

    String ctx = request.getContextPath();

    // --- 관리자 로그인 체크 ---
    MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
    if (loginUser == null || !"admin".equals(loginUser.getMemberId())) {
        session.setAttribute("alertMsg", "관리자 로그인 후 이용 가능한 서비스입니다.");
        response.sendRedirect(ctx + "/index.jsp");
        return;
    }

    String alertMsg = (String) session.getAttribute("alertMsg");
    if (alertMsg != null) {
        session.removeAttribute("alertMsg");
    }

    // --- 데이터 포맷터 ---
    DecimalFormat dfCount = new DecimalFormat("###,###");
    DecimalFormat dfAmt   = new DecimalFormat("###,###,###");

    // --- 데이터베이스 조회 ---
    Connection conn = getConnection();
    AdminDAO aDao = new AdminDAO();
    ProductDAO pDAO = new ProductDAO();

    int totalProducts   = 0;
    int pendingCount    = 0;
    int totalBids       = 0;
    long totalRevenue   = 0;
    List<ProductDTO> pendingList = null;
    List<ChargeRequestDTO> chargeList = null;
    List<ProductDTO> allList = null;
    
    // <%-- NullPointerException 방지를 위해 try-catch 블록 안에서 DB 작업 수행 --
    try {
        totalProducts = aDao.selectTotalProducts(conn);
        pendingCount = aDao.selectPendingProducts(conn);
        totalBids = aDao.selectTotalBids(conn);
        totalRevenue = aDao.selectTotalRevenue(conn);
        
        pendingList = aDao.selectPendingProductsList(conn);
        chargeList = aDao.getAllChargeRequests(conn);
        allList = pDAO.selectAllProducts(conn);
    } catch(Exception e) {
        // 실제 운영 환경에서는 로그를 남기는 것이 좋습니다.
        e.printStackTrace();
    } finally {
        close(conn);
    }
    
    // --- 마일리지 충전 요청 데이터 사전 처리 (비효율적인 반복 제거) ---
    // <%-- '대기' 상태인 충전 요청만 미리 필터링하여 새로운 리스트를 생성합니다. --
    List<ChargeRequestDTO> pendingChargeList = new ArrayList<>();
    if (chargeList != null) {
        for (ChargeRequestDTO req : chargeList) {
            if ("W".equals(req.getStatus())) {
                pendingChargeList.add(req);
            }
        }
    }
    // 자바 8 이상 스트림 사용 시: 
    // List<ChargeRequestDTO> pendingChargeList = chargeList.stream()
    //                                                     .filter(r -> "W".equals(r.getStatus()))
    //                                                     .collect(Collectors.toList());

%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지 - M4 Auction</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Noto+Sans+KR:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=ctx%>/resources/css/luxury-global-style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
        /* (기존 스타일 코드는 변경 없음) */
        body { margin:0; padding:0; font-family: 'Noto Sans KR', sans-serif; background:#f8f8f8; padding-top: 120px !important;}
        .admin-layout { display: flex; max-width: 1400px; margin: 0 auto; gap: 30px; padding: 40px 20px; }
        .admin-sidebar { width: 280px; background: white; border-radius: 12px; box-shadow: 0 4px 16px rgba(0,0,0,0.08); padding: 0; position: sticky; top: 140px; height: fit-content; }
        .sidebar-header { background: linear-gradient(135deg, #1a1a1a 0%, #c9961a 100%); color: white; padding: 24px; border-radius: 12px 12px 0 0; text-align: center; }
        .sidebar-title { font-family: 'Playfair Display', serif; font-size: 20px; font-weight: 700; margin: 0; }
        .sidebar-subtitle { font-size: 13px; opacity: 0.9; margin-top: 4px; }
        .sidebar-menu { padding: 0; margin: 0; list-style: none; }
        .sidebar-menu li { border-bottom: 1px solid #f0f0f0; }
        .sidebar-menu li:last-child { border-bottom: none; }
        .sidebar-menu a { display: flex; align-items: center; gap: 12px; padding: 16px 24px; color: #333; text-decoration: none; transition: all 0.3s; font-size: 14px; font-weight: 500; }
        .sidebar-menu a:hover { background: #f8f9fa; color: #c9961a; }
        .sidebar-menu a.active { background: #c9961a; color: white; }
        .sidebar-menu i { width: 18px; text-align: center; }
        .admin-content { flex: 1; }
        .admin-wrapper { max-width: 100%; margin: 0; padding: 0; }
        .dashboard-cards { display:grid; grid-template-columns:repeat(auto-fit, minmax(250px,1fr)); gap:30px; margin-bottom:40px; }
        .dashboard-card { background:#fff; border-radius:10px; box-shadow:0 4px 16px rgba(0,0,0,0.04); text-align:center; padding:38px 10px 32px 10px; min-width:0; transition: box-shadow 0.2s; }
        .dashboard-card:hover { box-shadow:0 8px 32px rgba(201,150,26,0.13);}
        .card-icon { width:54px; height:54px; border-radius:50%; background:#c9961a; color:#fff; display:flex; align-items:center; justify-content:center; margin:0 auto 18px auto; font-size:28px;}
        .card-label { color:#999; font-size:15px; margin-bottom:7px; }
        .card-value { color:#1a1a1a; font-size:27px; font-weight:700; }
        .card-link { display:block; margin-top:10px; color:#c9961a; font-size:14px; text-decoration:none; font-weight:500;}
        .card-link:hover { color:#ad870e; }
        .admin-section { background:#fff; margin-bottom:40px; padding:35px 32px; border-radius:10px; box-shadow:0 4px 16px rgba(0,0,0,0.04);}
        .admin-section-title { font-size:22px; font-family:'Playfair Display',serif; color:#1a1a1a; margin-bottom:25px; }
        .product-grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(250px,1fr)); gap:28px;}
        .product-card, .charge-card { background:#faf8f4; border:1px solid #e5dfc8; border-radius:9px; overflow:hidden; box-shadow:0 2px 10px rgba(201,150,26,0.04); transition:box-shadow 0.2s; min-width:0; }
        .product-card:hover { box-shadow:0 6px 32px rgba(201,150,26,0.10);}
        .product-image { width:100%; height:160px; object-fit:cover; background:#eee;}
        .product-info, .charge-info { padding:18px 16px 16px 16px;}
        .product-title { font-size:17px; font-weight:700; color:#333; margin-bottom:9px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;}
        .product-meta { color:#888; font-size:14px; margin-bottom:3px;}
        .product-price { color:#c9961a; font-size:15px; margin-bottom:7px;}
        .product-meta2 { color:#888; font-size:13px; margin-bottom:2px;}
        .actions { display:flex; gap:8px; margin-top:11px;}
        .approve-btn, .reject-btn { padding:7px 16px; border-radius:6px; border:none; font-size:14px; font-weight:600; cursor:pointer; text-decoration:none; display:inline-block; transition: background 0.2s; }
        .approve-btn { background:#c9961a; color:#fff;}
        .approve-btn:hover { background:#ad870e;}
        .reject-btn { background:#ddd; color:#555;}
        .reject-btn:hover { background:#b2b2b2; color:#222;}
        .empty-state { text-align:center; color:#aaa; padding:50px 0;}
        .empty-state i { font-size:40px; opacity:0.4; margin-bottom:10px;}
        .charge-card { padding:18px 16px 14px 16px; display:flex; flex-direction:column; align-items:flex-start; justify-content:center;}
        .charge-info { padding:0 0 12px 0;}
        .charge-label { font-size:15px; color:#888; margin-bottom:2px;}
        .charge-value { font-size:16px; font-weight:600; color:#333;}
        .charge-actions { display:flex; gap:8px;}
        .charge-btn { padding:6px 17px; border-radius:6px; font-size:14px; border:none; font-weight:600; cursor:pointer; }
        .charge-btn.approve-btn { background:#c9961a; color:#fff;}
        .charge-btn.approve-btn:hover { background:#ad870e;}
        .charge-btn.reject-btn { background:#ddd; color:#555;}
        .charge-btn.reject-btn:hover { background:#b2b2b2; color:#222;}
        .vip-link { display:inline-block; margin:24px 0 0 4px; color:#c9961a; font-weight:600; text-decoration:none;}
        .vip-link:hover { color:#ad870e; text-decoration:underline;}
        @media (max-width:1000px) {
            .dashboard-cards, .product-grid { grid-template-columns:1fr 1fr; }
            .admin-layout { flex-direction: column; }
            .admin-sidebar { width: 100%; position: relative; top: auto; }
        }
        @media (max-width:700px) {
            .dashboard-cards, .product-grid { grid-template-columns:1fr; }
            .admin-layout { padding: 20px 10px; }
            .admin-section { padding:15px 7px;}
        }
    </style>
</head>
<body>
<jsp:include page="/layout/header/luxury-header.jsp" />

<div class="admin-layout">
    <div class="admin-sidebar">
        <div class="sidebar-header">
            <div class="sidebar-title">관리자 패널</div>
            <div class="sidebar-subtitle">Admin Panel</div>
        </div>
        <ul class="sidebar-menu">
            <li><a href="<%=ctx%>/admin/adminPage.jsp"><i class="fas fa-tachometer-alt"></i> 대시보드</a></li>
            <li><a href="<%=ctx%>/admin/waittingProduct.jsp"><i class="fas fa-clock"></i> 상품 승인 관리</a></li>
            <li><a href="<%=ctx%>/admin/allProduct.jsp"><i class="fas fa-box"></i> 전체 상품 관리</a></li>
            <li><a href="<%=ctx%>/admin/auctionManage.jsp"><i class="fas fa-gavel"></i> 경매 관리</a></li>
            <li><a href="<%=ctx%>/admin/chargeRequestList.jsp"><i class="fas fa-coins"></i> 마일리지 충전 관리</a></li>
            <li><a href="<%=ctx%>/admin/vipRequestList.jsp"><i class="fas fa-crown"></i> VIP 신청 관리</a></li>
            <li><a href="<%=ctx%>/admin/memberManage.jsp"><i class="fas fa-users"></i> 회원 관리</a></li>
            <li><a href="<%=ctx%>/admin/bidHistory.jsp"><i class="fas fa-list"></i> 입찰 내역 관리</a></li>
            <li><a href="<%=ctx%>/admin/siteStatistics.jsp"><i class="fas fa-chart-bar"></i> 사이트 통계</a></li>
            <li><a href="<%=ctx%>/admin/systemSettings.jsp"><i class="fas fa-cog"></i> 시스템 설정</a></li>
            <li><a href="<%=ctx%>/luxury-main.jsp"><i class="fas fa-home"></i> 메인 페이지로</a></li>
        </ul>
    </div>
    
    <div class="admin-content">
        <div class="admin-wrapper">

            <div class="dashboard-cards">
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-box"></i></div>
                    <div class="card-label">전체 상품</div>
                    <div class="card-value"><%= dfCount.format(totalProducts) %> 건</div>
                    <a class="card-link" href="<%=ctx%>/admin/allProduct.jsp">전체 상품 보기</a>
                </div>
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-clock"></i></div>
                    <div class="card-label">승인 대기 상품</div>
                    <div class="card-value"><%= dfCount.format(pendingCount) %> 건</div>
                    <a class="card-link" href="<%=ctx%>/admin/waittingProduct.jsp">대기 목록 보기</a>
                </div>
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-gavel"></i></div>
                    <div class="card-label">전체 입찰 건수</div>
                    <div class="card-value"><%= dfCount.format(totalBids) %> 건</div>
                    <a class="card-link" href="<%=ctx%>/admin/bidHistory.jsp">입찰 내역</a>
                </div>
                <div class="dashboard-card">
                    <div class="card-icon"><i class="fas fa-coins"></i></div>
                    <div class="card-label">총 낙찰 금액</div>
                    <div class="card-value">₩ <%= dfAmt.format(totalRevenue) %></div>
                </div>
            </div>

            <div class="admin-section">
                <div class="admin-section-title">승인 대기 상품 목록</div>
                <% if (pendingList == null || pendingList.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-box-open"></i><br>
                        승인 대기 중인 상품이 없습니다.
                    </div>
                <% } else { %>
                    <div class="product-grid">
                        <% for (int i = 0; i < pendingList.size() && i < 6; i++) {
                           ProductDTO p = pendingList.get(i); %>
                        <div class="product-card">
                            <a href="<%= ctx %>/product/productDetail.jsp?productId=<%= p.getProductId() %>">
                                <img src="<%= ctx %>/resources/product_images/<%= p.getImageRenamedName() %>" alt="<%= p.getProductName() %>" class="product-image">
                            </a>
                            <div class="product-info">
                                <div class="product-title"><%= p.getProductName() %></div>
                                <div class="product-meta">등록자: <%= p.getSellerId() %></div>
                                <div class="product-price">시작가 ₩ <%= dfAmt.format(p.getStartPrice()) %></div>
                                <div class="actions">
                                    <a class="approve-btn" href="<%= ctx %>/admin/approveProduct.jsp?productId=<%= p.getProductId() %>">승인</a>
                                    <a class="reject-btn" href="<%= ctx %>/admin/rejectProduct.jsp?productId=<%= p.getProductId() %>">거부</a>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% if (pendingList.size() > 6) { %>
                    <div style="text-align:right;margin-top:10px;">
                        <a class="card-link" href="<%=ctx%>/admin/waittingProduct.jsp">더보기</a>
                    </div>
                    <% } %>
                <% } %>
            </div>

            <div class="admin-section">
                <div class="admin-section-title">전체 상품 목록</div>
                <% if (allList == null || allList.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-cube"></i><br>
                        상품이 없습니다.
                    </div>
                <% } else { %>
                    <div class="product-grid">
                        <% for (int i = 0; i < allList.size() && i < 6; i++) {
                           ProductDTO p = allList.get(i); %>
                        <div class="product-card">
                            <a href="<%= ctx %>/product/productDetail.jsp?productId=<%= p.getProductId() %>">
                                <img src="<%= ctx %>/resources/product_images/<%= p.getImageRenamedName() %>" alt="<%= p.getProductName() %>" class="product-image">
                            </a>
                            <div class="product-info">
                                <div class="product-title"><%= p.getProductName() %></div>
                                <div class="product-meta">등록자: <%= p.getSellerId() %></div>
                                <div class="product-price">시작가 <%= dfAmt.format(p.getStartPrice()) %></div>
                                <div class="product-price">현재가 <%= dfAmt.format(p.getCurrentPrice()) %></div>
                                <div class="product-meta2">
                                    상태
                                    <%
                                        String statusText = "기타";
                                        switch (p.getStatus()) {
                                            case "A": statusText = "진행중"; break;
                                            case "E": statusText = "마감"; break;
                                            case "P": statusText = "보류"; break;
                                            case "C": statusText = "취소"; break;
                                            case "F": statusText = "종료(낙찰)"; break;
                                        }
                                    %>
                                    <%= statusText %>
                                </div>
                                <div class="product-meta2">
                                    낙찰일: 
                                    <%= (p.getEndTime() != null) ? p.getEndTime() : "-" %>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% if (allList.size() > 6) { %>
                    <div style="text-align:right;margin-top:10px;">
                        <a class="card-link" href="<%=ctx%>/admin/allProduct.jsp">더보기</a>
                    </div>
                    <% } %>
                <% } %>
            </div>

            <div class="admin-section">
                <div class="admin-section-title">마일리지 충전 요청 대기 목록</div>
                <% if (pendingChargeList.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-coins"></i><br>
                        현재 충전 대기 요청이 없습니다.
                    </div>
                <% } else { %>
                    <div class="product-grid">
                        <% for (int i = 0; i < pendingChargeList.size() && i < 6; i++) {
                           ChargeRequestDTO req = pendingChargeList.get(i); %>
                        <div class="charge-card">
                            <div class="charge-info">
                                <div class="charge-label">회원 ID</div>
                                <div class="charge-value"><%= req.getMemberId() %></div>
                                <div class="charge-label">충전 요청 금액</div>
                                <div class="charge-value">₩ <%= dfAmt.format(req.getAmount()) %></div>
                                <div class="charge-label">요청일</div>
                                <div class="charge-value"><%= req.getRequestDate() %></div>
                            </div>
                            <div class="charge-actions">
                                <a class="charge-btn approve-btn" href="<%= ctx %>/admin/chargeAction?reqId=<%= req.getReqId() %>&action=approve">승인</a>
                                <a class="charge-btn reject-btn" href="<%= ctx %>/admin/chargeAction?reqId=<%= req.getReqId() %>&action=reject">거부</a>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% if (pendingChargeList.size() > 6) { %>
                    <div style="text-align:right;margin-top:10px;">
                        <a class="card-link" href="<%=ctx%>/admin/chargeRequestList.jsp">더보기</a>
                    </div>
                    <% } %>
                <% } %>
                <a class="vip-link" href="<%= ctx %>/admin/vipRequestList.jsp"><i class="fas fa-crown"></i> VIP 신청 관리</a>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/layout/footer/luxury-footer.jsp" />
<% if(alertMsg != null) { %>
<script>
    alert("<%= alertMsg.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") %>");
</script>
<% } %>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // 현재 URL 경로를 가져옵니다.
    const currentPath = window.location.pathname;
    const menuItems = document.querySelectorAll('.sidebar-menu a');
    
    let isMatched = false;
    
    // 모든 메뉴 아이템을 순회하며 현재 경로와 일치하는 항목을 찾습니다.
    menuItems.forEach(item => {
        item.classList.remove('active');
        const itemPath = item.getAttribute('href');
        
        // <%-- 'href' 속성 값이 현재 경로를 포함하는지 확인하여 더 정확하게 활성화 --%>
        if (currentPath.includes(itemPath.split('/').pop())) {
            item.classList.add('active');
            isMatched = true;
        }
    });

    // <%-- 만약 일치하는 메뉴가 없다면(예: URL이 adminPage.jsp로 끝날 때), 대시보드를 활성화합니다. --%>
    if (!isMatched && currentPath.includes('adminPage.jsp')) {
        const dashboardMenu = document.querySelector('.sidebar-menu a[href*="adminPage.jsp"]');
        if (dashboardMenu) {
            dashboardMenu.classList.add('active');
        }
    }
});
</script>
</body>
</html>