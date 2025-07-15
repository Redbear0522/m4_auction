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
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 페이지 - M4 Auction</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=Noto+Sans+KR:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/luxury-global-style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
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
        .dashboard-card {
            background:#fff; border-radius:10px; box-shadow:0 4px 16px rgba(0,0,0,0.04);
            text-align:center; padding:38px 10px 32px 10px; min-width:0;
            transition: box-shadow 0.2s;
        }
        .dashboard-card:hover { box-shadow:0 8px 32px rgba(201,150,26,0.13);}
        .card-icon { width:54px; height:54px; border-radius:50%; background:#c9961a; color:#fff; display:flex; align-items:center; justify-content:center; margin:0 auto 18px auto; font-size:28px;}
        .card-label { color:#999; font-size:15px; margin-bottom:7px; }
        .card-value { color:#1a1a1a; font-size:27px; font-weight:700; }
        .card-link { display:block; margin-top:10px; color:#c9961a; font-size:14px; text-decoration:none; font-weight:500;}
        .card-link:hover { color:#ad870e; }
        .admin-section { background:#fff; margin-bottom:40px; padding:35px 32px; border-radius:10px; box-shadow:0 4px 16px rgba(0,0,0,0.04);}
        .admin-section-title { font-size:22px; font-family:'Playfair Display',serif; color:#1a1a1a; margin-bottom:25px; }
        .product-grid { display:grid; grid-template-columns:repeat(auto-fit, minmax(250px,1fr)); gap:28px;}
        .product-card, .charge-card {
            background:#faf8f4; border:1px solid #e5dfc8; border-radius:9px; overflow:hidden;
            box-shadow:0 2px 10px rgba(201,150,26,0.04); transition:box-shadow 0.2s; min-width:0;
        }
        .product-card:hover { box-shadow:0 6px 32px rgba(201,150,26,0.10);}
        .product-image { width:100%; height:160px; object-fit:cover; background:#eee;}
        .product-info, .charge-info { padding:18px 16px 16px 16px;}
        .product-title { font-size:17px; font-weight:700; color:#333; margin-bottom:9px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;}
        .product-meta { color:#888; font-size:14px; margin-bottom:3px;}
        .product-price { color:#c9961a; font-size:15px; margin-bottom:7px;}
        .product-meta2 { color:#888; font-size:13px; margin-bottom:2px;}
        .actions { display:flex; gap:8px; margin-top:11px;}
        .approve-btn, .reject-btn {
            padding:7px 16px; border-radius:6px; border:none; font-size:14px; font-weight:600; cursor:pointer; text-decoration:none; display:inline-block;
            transition: background 0.2s;
        }
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
    <!-- 사이드바 -->
    <div class="admin-sidebar">
        <div class="sidebar-header">
            <div class="sidebar-title">관리자 패널</div>
            <div class="sidebar-subtitle">Admin Panel</div>
        </div>
        <ul class="sidebar-menu">
            <li><a href="<%=request.getContextPath()%>/admin/adminPage.jsp" class="active">
                <i class="fas fa-tachometer-alt"></i>
                대시보드
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/waittingProduct.jsp">
                <i class="fas fa-clock"></i>
                상품 승인 관리
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/allProduct.jsp">
                <i class="fas fa-box"></i>
                전체 상품 관리
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/auctionManage.jsp">
                <i class="fas fa-gavel"></i>
                경매 관리
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/chargeRequestList.jsp">
                <i class="fas fa-coins"></i>
                마일리지 충전 관리
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/vipRequestList.jsp">
                <i class="fas fa-crown"></i>
                VIP 신청 관리
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/memberManage.jsp">
                <i class="fas fa-users"></i>
                회원 관리
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/bidHistory.jsp">
                <i class="fas fa-list"></i>
                입찰 내역 관리
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/siteStatistics.jsp">
                <i class="fas fa-chart-bar"></i>
                사이트 통계
            </a></li>
            <li><a href="<%=request.getContextPath()%>/admin/systemSettings.jsp">
                <i class="fas fa-cog"></i>
                시스템 설정
            </a></li>
            <li><a href="<%=request.getContextPath()%>/index.jsp">
                <i class="fas fa-home"></i>
                메인 페이지로
            </a></li>
        </ul>
    </div>
    
    <!-- 메인 컨텐츠 -->
    <div class="admin-content">
        <div class="admin-wrapper">

    <!-- 대시보드 카드 -->
    <div class="dashboard-cards">
        <div class="dashboard-card">
            <div class="card-icon"><i class="fas fa-box"></i></div>
            <div class="card-label">전체 상품</div>
            <div class="card-value"><%= dfCount.format(totalProducts) %> 건</div>
            <a class="card-link" href="<%=request.getContextPath()%>/admin/allProduct.jsp">전체 상품 보기</a>
        </div>
        <div class="dashboard-card">
            <div class="card-icon"><i class="fas fa-clock"></i></div>
            <div class="card-label">승인 대기 상품</div>
            <div class="card-value"><%= dfCount.format(pendingCount) %> 건</div>
            <a class="card-link" href="<%=request.getContextPath()%>/admin/waittingProduct.jsp">대기 목록 보기</a>
        </div>
        <div class="dashboard-card">
            <div class="card-icon"><i class="fas fa-gavel"></i></div>
            <div class="card-label">전체 입찰 건수</div>
            <div class="card-value"><%= dfCount.format(totalBids) %> 건</div>
            <a class="card-link" href="<%=request.getContextPath()%>/admin/bidHistory.jsp">입찰 내역</a>
        </div>
        <div class="dashboard-card">
            <div class="card-icon"><i class="fas fa-coins"></i></div>
            <div class="card-label">총 낙찰 금액</div>
            <div class="card-value">₩ <%= dfAmt.format(totalRevenue) %></div>
        </div>
    </div>

    <!-- 승인 대기 상품 목록 -->
    <div class="admin-section">
        <div class="admin-section-title">승인 대기 상품 목록</div>
        <% if (pendingList.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-box-open"></i><br>
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
                        <div class="product-title"><%= p.getProductName() %></div>
                        <div class="product-meta">등록자: <%= p.getSellerId() %></div>
                        <div class="product-price">시작가 ₩ <%= dfAmt.format(p.getStartPrice()) %></div>
                        <div class="actions">
                            <a class="approve-btn" href="<%= request.getContextPath() %>/admin/approveProduct.jsp?productId=<%= p.getProductId() %>">승인</a>
                            <a class="reject-btn" href="<%= request.getContextPath() %>/admin/rejectProduct.jsp?productId=<%= p.getProductId() %>">거부</a>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% if (pendingList.size() > 6) { %>
            <div style="text-align: center; margin-top: 20px;">
                <a href="<%= request.getContextPath() %>/admin/waittingProduct.jsp" class="approve-btn" style="display: inline-block; padding: 12px 24px;">
                    <i class="fas fa-plus"></i> 더보기 (<%= pendingList.size() - 6 %>개 더)
                </a>
            </div>
            <% } %>
        <% } %>
    </div>

    <!-- 전체 상품 목록 -->
    <div class="admin-section">
        <div class="admin-section-title">전체 상품 목록</div>
        <% if (allList.isEmpty()) { %>
            <div class="empty-state">
                <i class="fas fa-cube"></i><br>
                상품이 없습니다.
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
                        <div class="product-title"><%= p.getProductName() %></div>
                        <div class="product-meta">등록자: <%= p.getSellerId() %></div>
                        <div class="product-price">시작가 <%= dfAmt.format(p.getStartPrice()) %></div>
                        <div class="product-price">현재가 <%= dfAmt.format(p.getCurrentPrice()) %></div>
                        <div class="product-meta2">
                            상태
                            <%
                                String status = p.getStatus();
                                String statusText = "기타";
                                if ("A".equals(status)) statusText = "진행중";
                                else if ("E".equals(status)) statusText = "마감";
                                else if ("P".equals(status)) statusText = "보류";
                                else if ("C".equals(status)) statusText = "취소";
                                else if ("F".equals(status)) statusText = "종료(낙찰)";
                            %>
                            <%= statusText %>
                        </div>
                        <div class="product-meta2">
                            낙찰일
                            <% if (p.getEndTime() != null) { %>
                                <%= p.getEndTime() %>
                            <% } else { %>
                                -
                            <% } %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
            <% if (allList.size() > 6) { %>
            <div style="text-align: center; margin-top: 20px;">
                <a href="<%= request.getContextPath() %>/admin/allProduct.jsp" class="approve-btn" style="display: inline-block; padding: 12px 24px;">
                    <i class="fas fa-plus"></i> 더보기 (<%= allList.size() - 6 %>개 더)
                </a>
            </div>
            <% } %>
        <% } %>
    </div>

    <!-- 마일리지 충전 요청 목록 -->
    <div class="admin-section">
        <div class="admin-section-title">마일리지 충전 요청 대기 목록</div>
        <% boolean hasCharge = false;
           for (ChargeRequestDTO req : chargeList) {
               if ("W".equals(req.getStatus())) { hasCharge=true; break;}
           }
           if (!hasCharge) { %>
            <div class="empty-state">
                <i class="fas fa-coins"></i><br>
                현재 충전 대기 요청이 없습니다.
            </div>
        <% } else { %>
            <div class="product-grid">
                <% for (ChargeRequestDTO req : chargeList) {
                    if ("W".equals(req.getStatus())) { %>
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
                            <a class="charge-btn approve-btn" href="<%= request.getContextPath() %>/admin/chargeAction.jsp?reqId=<%= req.getReqId() %>&action=approve">승인</a>
                            <a class="charge-btn reject-btn" href="<%= request.getContextPath() %>/admin/chargeAction.jsp?reqId=<%= req.getReqId() %>&action=reject">거부</a>
                        </div>
                    </div>
                <% }} %>
            </div>
        <% } %>
        <a class="vip-link" href="<%= request.getContextPath() %>/admin/vipRequestList.jsp"><i class="fas fa-crown"></i> VIP 신청 관리</a>
    </div>
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
    
    // 대시보드가 기본 활성화
    if (currentPath.includes('adminPage.jsp')) {
        document.querySelector('.sidebar-menu a[href*="adminPage.jsp"]').classList.add('active');
    }
});
</script>
</body>
</html>
