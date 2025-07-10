<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="com.auction.dto.MemberDTO" %>
<%@ page import="com.auction.dto.ProductDTO" %>
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
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>마이페이지 - M4 경매</title>

    <!-- Professional Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Lora:wght@400;500;600&display=swap" rel="stylesheet">
    
    <!-- Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    
    <!-- Global Styles -->
    <link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/luxury-global-style.css">

    <style>
        /* ===== GLOBAL RESET ===== */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #f8f9fa;
            color: #1a1a1a;
            line-height: 1.6;
            padding-top: 120px !important;
        }

        /* ===== LAYOUT SYSTEM ===== */
        .dashboard-container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 32px 24px;
        }

        .dashboard-header {
            margin-bottom: 48px;
        }

        .page-title {
            font-family: 'Lora', serif;
            font-size: 32px;
            font-weight: 600;
            color: #1a1a1a;
            margin-bottom: 8px;
        }

        .page-subtitle {
            color: #6b7280;
            font-size: 16px;
            font-weight: 400;
        }

        /* ===== GRID SYSTEM ===== */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 300px 1fr;
            gap: 32px;
            align-items: start;
        }

        /* ===== SIDEBAR (EDGY) ===== */
        .sidebar {
            background: white;
            border: 2px solid #e5e7eb;
            border-radius: 0;
            overflow: hidden;
            position: sticky;
            top: 152px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .user-profile {
            padding: 32px 24px;
            border-bottom: 1px solid #e5e7eb;
            text-align: center;
            background: white;
        }

        .user-avatar {
            width: 64px;
            height: 64px;
            background: #f3f4f6;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 16px;
            color: #6b7280;
            font-size: 24px;
            position: relative;
        }

        .user-name {
            font-size: 18px;
            font-weight: 600;
            color: #1a1a1a;
            margin-bottom: 4px;
        }

        .user-id {
            font-size: 14px;
            color: #6b7280;
            margin-bottom: 12px;
        }

        .user-badge {
            display: inline-flex;
            align-items: center;
            gap: 3px;
            background: #000;
            color: #c9961a;
            font-size: 9px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 3px 6px;
            border: 1px solid #c9961a;
            position: absolute;
            top: -8px;
            right: -8px;
        }

        /* Navigation */
        .sidebar-nav {
            padding: 0;
        }

        .nav-item {
            display: block;
            padding: 16px 24px;
            color: #6b7280;
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            border-bottom: 1px solid #f0f0f0;
            transition: all 0.2s ease;
            position: relative;
        }

        .nav-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 3px;
            background: #c9961a;
            transform: scaleY(0);
            transition: transform 0.2s ease;
        }

        .nav-item:hover,
        .nav-item.active {
            background: #e5e7eb;
            color: #1a1a1a;
        }

        .nav-item:hover::before,
        .nav-item.active::before {
            transform: scaleY(1);
        }

        .nav-item i {
            width: 18px;
            margin-right: 12px;
            font-size: 14px;
        }

        /* ===== MAIN CONTENT (EDGY) ===== */
        .main-content {
            background: #f3f4f6;
            border: 2px solid #d1d5db;
            border-radius: 0;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
        }

        .content-header {
            padding: 32px 32px 0;
            margin-bottom: 32px;
        }

        .content-title {
            font-size: 24px;
            font-weight: 600;
            color: #1a1a1a;
            margin-bottom: 8px;
        }

        .content-subtitle {
            color: #6b7280;
            font-size: 14px;
        }

        .content-body {
            padding: 0 32px 32px;
        }

        /* ===== STATS GRID (EDGY) ===== */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 24px;
            margin-bottom: 48px;
        }

        .stat-card {
            background: white;
            border: 2px solid #e5e7eb;
            border-radius: 2px;
            padding: 24px;
            transition: all 0.2s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 3px;
            background: linear-gradient(90deg, #1a1a1a, #c9961a);
            opacity: 0;
            transition: opacity 0.2s ease;
        }

        .stat-card:hover {
            border-color: #1a1a1a;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            transform: translateY(-2px);
        }

        .stat-card:hover::before {
            opacity: 1;
        }
        
        .stat-card.clickable {
            cursor: pointer;
        }
        
        .stat-card.clickable:hover {
            border-color: #c9961a;
            box-shadow: 0 6px 20px rgba(201, 150, 26, 0.25);
            transform: translateY(-3px);
        }
        
        .stat-card.clickable:active {
            transform: translateY(-1px);
            box-shadow: 0 3px 10px rgba(201, 150, 26, 0.3);
        }

        .stat-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }

        .stat-label {
            font-size: 14px;
            font-weight: 500;
            color: #6b7280;
        }

        .stat-icon {
            width: 32px;
            height: 32px;
            background: #f3f4f6;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #6b7280;
            font-size: 14px;
        }

        .stat-value {
            font-size: 28px;
            font-weight: 700;
            color: #1a1a1a;
            line-height: 1.2;
        }

        .stat-change {
            font-size: 12px;
            color: #6b7280;
            font-weight: 500;
            margin-top: 4px;
        }

        /* ===== SECTIONS ===== */
        .section {
            margin-bottom: 48px;
        }

        .section:last-child {
            margin-bottom: 0;
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            padding-bottom: 16px;
            border-bottom: 2px solid #e5e7eb;
        }

        .section-title {
            font-size: 18px;
            font-weight: 600;
            color: #1a1a1a;
        }

        .section-action {
            font-size: 14px;
            color: #6b7280;
            text-decoration: none;
            font-weight: 500;
            transition: color 0.15s ease;
        }

        .section-action:hover {
            color: #1a1a1a;
        }

        /* ===== PRODUCT TABLE (EDGY) ===== */
        .product-table {
            width: 100%;
            border-collapse: collapse;
        }

        .product-table th {
            text-align: left;
            font-size: 12px;
            font-weight: 700;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 16px 0;
            border-bottom: 2px solid #d1d5db;
        }

        .product-table td {
            padding: 16px 0;
            border-bottom: 1px solid #e5e7eb;
            vertical-align: top;
        }

        .product-table tr:last-child td {
            border-bottom: none;
        }

        .product-table tr:hover {
            background: rgba(0, 0, 0, 0.02);
        }

        .product-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .product-image {
            width: 48px;
            height: 48px;
            border-radius: 6px;
            object-fit: cover;
            background: #f3f4f6;
        }

        .product-details h4 {
            font-size: 14px;
            font-weight: 600;
            color: #1a1a1a;
            margin-bottom: 2px;
        }

        .product-details p {
            font-size: 12px;
            color: #6b7280;
        }

        .product-price {
            font-size: 14px;
            font-weight: 600;
            color: #1a1a1a;
        }

        .product-status {
            display: inline-block;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            padding: 6px 12px;
            border-radius: 0;
            border: 2px solid;
        }

        .status-active {
            background: #000;
            color: #fff;
            border-color: #000;
        }

        .status-ending {
            background: #c9961a;
            color: #fff;
            border-color: #c9961a;
        }

        .status-ended {
            background: #fff;
            color: #666;
            border-color: #666;
        }

        /* ===== EMPTY STATE (EDGY) ===== */
        .empty-state {
            text-align: center;
            padding: 64px 32px;
        }

        .empty-state i {
            font-size: 48px;
            color: #ccc;
            margin-bottom: 16px;
        }

        .empty-state h3 {
            font-size: 18px;
            font-weight: 700;
            color: #1a1a1a;
            margin-bottom: 8px;
        }

        .empty-state p {
            font-size: 14px;
            color: #6b7280;
            margin-bottom: 24px;
        }

        .empty-state .btn {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: #1a1a1a;
            color: white;
            font-size: 14px;
            font-weight: 700;
            padding: 12px 24px;
            border-radius: 0;
            text-decoration: none;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            transition: all 0.2s ease;
            border: 2px solid #1a1a1a;
        }

        .empty-state .btn:hover {
            background: #c9961a;
            border-color: #c9961a;
            transform: translateY(-1px);
        }

        /* ===== VIP SIDEBAR SECTION ===== */
        .vip-section {
            border-top: 1px solid #e5e7eb;
            padding: 20px;
            background: #f3f4f6;
        }
        
        .vip-section-header {
            margin-bottom: 16px;
        }
        
        .vip-section-header h4 {
            font-size: 14px;
            font-weight: 600;
            color: #1a1a1a;
        }
        
        .vip-form-sidebar {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        
        .vip-select-sidebar {
            padding: 8px 12px;
            border: 2px solid #e5e7eb;
            background: white;
            color: #1a1a1a;
            font-size: 13px;
            font-weight: 500;
        }
        
        .vip-select-sidebar:focus {
            outline: none;
            border-color: #c9961a;
        }
        
        .vip-submit-sidebar {
            background: #1a1a1a;
            color: white;
            border: 2px solid #1a1a1a;
            padding: 8px 16px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            cursor: pointer;
            transition: all 0.2s ease;
        }
        
        .vip-submit-sidebar:hover {
            background: #c9961a;
            border-color: #c9961a;
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 1024px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
                gap: 24px;
            }

            .sidebar {
                position: static;
                order: 2;
            }

            .main-content {
                order: 1;
            }
        }

        @media (max-width: 768px) {
            body {
                padding-top: 100px !important;
            }

            .dashboard-container {
                padding: 20px 16px;
            }

            .content-header,
            .content-body {
                padding: 24px 20px;
            }

            .stats-grid {
                grid-template-columns: 1fr;
                gap: 16px;
            }

            .vip-form {
                flex-direction: column;
                align-items: stretch;
            }

            .product-table {
                font-size: 14px;
            }

            .product-table th,
            .product-table td {
                padding: 12px 8px;
            }
        }

        /* ===== MICRO-INTERACTIONS ===== */
        .stat-card:hover .stat-icon {
            background: #e5e7eb;
        }

        .nav-item:hover i {
            transform: translateX(2px);
        }

        .section-action:hover {
            text-decoration: underline;
        }

        /* ===== ACCESSIBILITY ===== */
        .nav-item:focus,
        .section-action:focus,
        .empty-state .btn:focus {
            outline: 2px solid #3b82f6;
            outline-offset: 2px;
        }

        /* ===== UTILITY CLASSES ===== */
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .font-mono { font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace; }
    </style>
</head>
<body>
    <!-- Header -->
    <jsp:include page="/layout/header/luxury-header.jsp" />

    <div class="dashboard-container">
        <!-- Dashboard Header -->
        <div class="dashboard-header">
            <h1 class="page-title">마이페이지</h1>
            <p class="page-subtitle">경매, 입찰, 계정 설정을 관리하세요</p>
        </div>

        <!-- Dashboard Grid -->
        <div class="dashboard-grid">
            <!-- Sidebar -->
            <aside class="sidebar">
                <!-- User Profile -->
                <div class="user-profile">
                    <div class="user-avatar">
                        <i class="fas fa-user"></i>
                        <% if(isVip) { %>
                            <span class="user-badge">
                                <i class="fas fa-crown" style="font-size: 9px;"></i>
                                VIP
                            </span>
                        <% } %>
                    </div>
                    <h3 class="user-name"><%= loginUser.getMemberName() %></h3>
                    <p class="user-id">@<%= loginUser.getMemberId() %></p>
                </div>
                
                <!-- Navigation -->
                <nav class="sidebar-nav">
                    <a href="#overview" class="nav-item active" onclick="showSection('overview', event)">
                        <i class="fas fa-chart-line"></i>개요
                    </a>
                    <a href="#my-items" class="nav-item" onclick="showSection('my-items', event)">
                        <i class="fas fa-tag"></i>내 상품
                    </a>
                    <a href="#bids" class="nav-item" onclick="showSection('bids', event)">
                        <i class="fas fa-gavel"></i>입찰 현황
                    </a>
                    <a href="#won" class="nav-item" onclick="showSection('won', event)">
                        <i class="fas fa-trophy"></i>낙찰 상품
                    </a>
                    <a href="updateMemberForm.jsp" class="nav-item">
                        <i class="fas fa-user-edit"></i>프로필 설정
                    </a>
                    <a href="changePwdForm.jsp" class="nav-item">
                        <i class="fas fa-lock"></i>보안 설정
                    </a>
                    <a href="chargeForm.jsp" class="nav-item">
                        <i class="fas fa-coins"></i>마일리지 충전
                    </a>
                    <% if(isVip) { %>
                    <a href="#vip-benefits" class="nav-item" onclick="showVipOptions(event)">
                        <i class="fas fa-crown"></i>VIP 혜택
                    </a>
                    <% } %>
                </nav>
                
                <!-- VIP Benefits Section (VIP만 표시) -->
                <% if(isVip) { %>
                <div class="vip-section" id="vip-section" style="display: none;">
                    <div class="vip-section-header">
                        <h4>VIP 혜택 선택</h4>
                    </div>
                    <form action="<%= request.getContextPath() %>/mypage/vipOptionRequest.jsp" method="post" class="vip-form-sidebar">
                        <select name="option" class="vip-select-sidebar" required>
                            <option value="">등급 선택</option>
                            <option value="골드">골드 (5% 보너스)</option>
                            <option value="다이아">다이아 (10% 보너스)</option>
                        </select>
                        <button type="submit" class="vip-submit-sidebar">적용</button>
                    </form>
                </div>
                <% } %>
            </aside>

            <!-- Main Content -->
            <main class="main-content">
                <!-- Overview Section -->
                <div id="overview-section" class="content-section">
                    <div class="content-header">
                        <h2 class="content-title">계정 개요</h2>
                        <p class="content-subtitle">경매 활동을 한눈에 확인하세요</p>
                    </div>

                    <div class="content-body">
                        <!-- Stats Grid -->
                        <div class="stats-grid">
                            <div class="stat-card clickable" onclick="window.location.href='chargeForm.jsp'">
                                <div class="stat-header">
                                    <span class="stat-label">보유 마일리지</span>
                                    <div class="stat-icon">
                                        <i class="fas fa-coins"></i>
                                    </div>
                                </div>
                                <div class="stat-value"><%= df.format(loginUser.getMileage()) %><span style="font-size: 16px; color: #6b7280; margin-left: 4px;">P</span></div>
                                <div class="stat-change">입찰 준비 완료 • 클릭하여 충전</div>
                            </div>
                            
                            <div class="stat-card clickable" onclick="showSection('bids')">
                                <div class="stat-header">
                                    <span class="stat-label">활성 입찰</span>
                                    <div class="stat-icon">
                                        <i class="fas fa-gavel"></i>
                                    </div>
                                </div>
                                <div class="stat-value"><%= myBids.size() %></div>
                                <div class="stat-change">참여 중 • 클릭하여 보기</div>
                            </div>
                            
                            <div class="stat-card clickable" onclick="showSection('won')">
                                <div class="stat-header">
                                    <span class="stat-label">낙찰 성공</span>
                                    <div class="stat-icon">
                                        <i class="fas fa-trophy"></i>
                                    </div>
                                </div>
                                <div class="stat-value"><%= myWonProducts.size() %></div>
                                <div class="stat-change">성공적으로 획득 • 클릭하여 보기</div>
                            </div>
                            
                            <div class="stat-card clickable" onclick="showSection('my-items')">
                                <div class="stat-header">
                                    <span class="stat-label">등록 상품</span>
                                    <div class="stat-icon">
                                        <i class="fas fa-tag"></i>
                                    </div>
                                </div>
                                <div class="stat-value"><%= myProducts.size() %></div>
                                <div class="stat-change">판매 중 • 클릭하여 관리</div>
                            </div>
                        </div>


                        <!-- Recent Activity -->
                        <div class="section">
                            <div class="section-header">
                                <h3 class="section-title">최근 활동</h3>
                                <a href="#bids" class="section-action" onclick="showSection('bids')">모든 입찰 보기 →</a>
                            </div>
                            
                            <% if(!myBids.isEmpty()) { %>
                                <table class="product-table">
                                    <thead>
                                        <tr>
                                            <th style="width: 40%;">상품</th>
                                            <th style="width: 20%;">현재 입찰가</th>
                                            <th style="width: 20%;">상태</th>
                                            <th style="width: 20%;">남은 시간</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% 
                                        int count = 0;
                                        for(ProductDTO p : myBids) { 
                                            if(count >= 5) break; // 최대 5개만 미리보기
                                        %>
                                        <tr>
                                            <td>
                                                <div class="product-info">
                                                    <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" 
                                                         alt="<%= p.getProductName() %>" class="product-image">
                                                    <div class="product-details">
                                                        <h4><%= p.getProductName() %></h4>
                                                        <p><%= p.getArtistName() %></p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="product-price">₩<%= df.format(p.getCurrentPrice()) %></div>
                                            </td>
                                            <td>
                                                <span class="product-status status-active">진행중</span>
                                            </td>
                                            <td>
                                                <div class="auction-timer" data-endtime="<%= p.getEndTime() %>">
                                                    <span class="time-remaining font-mono">로딩중...</span>
                                                </div>
                                            </td>
                                        </tr>
                                        <% 
                                            count++;
                                        } %>
                                    </tbody>
                                </table>
                            <% } else { %>
                                <div class="empty-state">
                                    <i class="fas fa-gavel"></i>
                                    <h3>활성 입찰 없음</h3>
                                    <p>아직 입찰에 참여하지 않았습니다. 경매를 둘러보고 시작해보세요.</p>
                                    <a href="<%= request.getContextPath() %>/index.jsp" class="btn">
                                        <i class="fas fa-search"></i>경매 둘러보기
                                    </a>
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- My Items Section -->
                <div id="my-items-section" class="content-section" style="display: none;">
                    <div class="content-header">
                        <h2 class="content-title">내 등록 상품</h2>
                        <p class="content-subtitle">경매에 등록한 상품들</p>
                    </div>

                    <div class="content-body">
                        <!-- 상품 등록 버튼 (항상 표시) -->
                        <div style="margin-bottom: 24px; text-align: right;">
                            <a href="<%= request.getContextPath() %>/product/productEnrollForm.jsp" class="btn" style="display: inline-flex;">
                                <i class="fas fa-plus"></i>새 상품 등록하기
                            </a>
                        </div>
                        
                        <% if(!myProducts.isEmpty()) { %>
                            <table class="product-table">
                                <thead>
                                    <tr>
                                        <th style="width: 40%;">상품</th>
                                        <th style="width: 20%;">현재 입찰가</th>
                                        <th style="width: 20%;">상태</th>
                                        <th style="width: 20%;">마감</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for(ProductDTO p : myProducts) { %>
                                    <tr>
                                        <td>
                                            <div class="product-info">
                                                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" 
                                                     alt="<%= p.getProductName() %>" class="product-image">
                                                <div class="product-details">
                                                    <h4><%= p.getProductName() %></h4>
                                                    <p><%= p.getArtistName() %></p>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="product-price">₩<%= df.format(p.getCurrentPrice()) %></div>
                                        </td>
                                        <td>
                                            <span class="product-status status-active">등록됨</span>
                                        </td>
                                        <td>
                                            <div class="auction-timer" data-endtime="<%= p.getEndTime() %>">
                                                <span class="time-remaining font-mono">Loading...</span>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <div class="empty-state">
                                <i class="fas fa-tag"></i>
                                <h3>등록된 상품 없음</h3>
                                <p>아직 경매에 등록한 상품이 없습니다. 위의 버튼을 클릭하여 첫 상품을 등록해보세요!</p>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Active Bids Section -->
                <div id="bids-section" class="content-section" style="display: none;">
                    <div class="content-header">
                        <h2 class="content-title">활성 입찰</h2>
                        <p class="content-subtitle">현재 참여하고 있는 경매</p>
                    </div>

                    <div class="content-body">
                        <% if(!myBids.isEmpty()) { %>
                            <table class="product-table">
                                <thead>
                                    <tr>
                                        <th style="width: 40%;">상품</th>
                                        <th style="width: 20%;">현재 입찰가</th>
                                        <th style="width: 20%;">상태</th>
                                        <th style="width: 20%;">남은 시간</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for(ProductDTO p : myBids) { %>
                                    <tr>
                                        <td>
                                            <div class="product-info">
                                                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" 
                                                     alt="<%= p.getProductName() %>" class="product-image">
                                                <div class="product-details">
                                                    <h4><%= p.getProductName() %></h4>
                                                    <p><%= p.getArtistName() %></p>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="product-price">₩<%= df.format(p.getCurrentPrice()) %></div>
                                        </td>
                                        <td>
                                            <span class="product-status status-active">입찰중</span>
                                        </td>
                                        <td>
                                            <div class="auction-timer" data-endtime="<%= p.getEndTime() %>">
                                                <span class="time-remaining font-mono">Loading...</span>
                                            </div>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <div class="empty-state">
                                <i class="fas fa-gavel"></i>
                                <h3>활성 입찰 없음</h3>
                                <p>아직 입찰에 참여하지 않았습니다. 경매를 둘러보고 시작해보세요.</p>
                                <a href="<%= request.getContextPath() %>/index.jsp" class="btn">
                                    <i class="fas fa-search"></i>경매 둘러보기
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>

                <!-- Won Items Section -->
                <div id="won-section" class="content-section" style="display: none;">
                    <div class="content-header">
                        <h2 class="content-title">낙찰 상품</h2>
                        <p class="content-subtitle">성공적으로 획득한 상품들</p>
                    </div>

                    <div class="content-body">
                        <% if(!myWonProducts.isEmpty()) { %>
                            <table class="product-table">
                                <thead>
                                    <tr>
                                        <th style="width: 40%;">상품</th>
                                        <th style="width: 20%;">최종 가격</th>
                                        <th style="width: 20%;">상태</th>
                                        <th style="width: 20%;">낙찰일</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for(ProductDTO p : myWonProducts) { %>
                                    <tr>
                                        <td>
                                            <div class="product-info">
                                                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" 
                                                     alt="<%= p.getProductName() %>" class="product-image">
                                                <div class="product-details">
                                                    <h4><%= p.getProductName() %></h4>
                                                    <p><%= p.getArtistName() %></p>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="product-price">₩<%= df.format(p.getFinalPrice()) %></div>
                                        </td>
                                        <td>
                                            <span class="product-status status-ended">낙찰</span>
                                        </td>
                                        <td>
                                            <span class="font-mono">최근</span>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        <% } else { %>
                            <div class="empty-state">
                                <i class="fas fa-trophy"></i>
                                <h3>낙찰 상품 없음</h3>
                                <p>아직 낙찰받은 상품이 없습니다. 계속 입찰하여 원하는 상품을 획득하세요!</p>
                                <a href="<%= request.getContextPath() %>/index.jsp" class="btn">
                                    <i class="fas fa-gavel"></i>경매 참여하기
                                </a>
                            </div>
                        <% } %>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <!-- Footer -->
    <jsp:include page="/layout/footer/luxury-footer.jsp" />
    
    <% if(alertMsg != null) { 
        session.removeAttribute("alertMsg");
    %>
    <script>
        alert("<%= alertMsg %>");
    </script>
    <% } %>
    
    <script>
        // VIP Options Toggle
        function showVipOptions(event) {
            event.preventDefault();
            const vipSection = document.getElementById('vip-section');
            if (vipSection.style.display === 'none') {
                vipSection.style.display = 'block';
            } else {
                vipSection.style.display = 'none';
            }
        }
        
        // Section Navigation
        function showSection(sectionName, event) {
            // Prevent default action if event exists
            if (event) {
                event.preventDefault();
            }
            
            // Hide all sections
            document.querySelectorAll('.content-section').forEach(section => {
                section.style.display = 'none';
            });
            
            // Remove active class from all nav items
            document.querySelectorAll('.nav-item').forEach(item => {
                item.classList.remove('active');
            });
            
            // Show selected section
            const targetSection = document.getElementById(sectionName + '-section');
            if (targetSection) {
                targetSection.style.display = 'block';
            }
            
            // Add active class to corresponding nav item
            const navItems = document.querySelectorAll('.nav-item');
            navItems.forEach(item => {
                const href = item.getAttribute('href');
                if (href && href.includes('#' + sectionName)) {
                    item.classList.add('active');
                }
            });
        }

        // Real-time Auction Timer
        function updateAuctionTimers() {
            const timers = document.querySelectorAll('.auction-timer');
            
            timers.forEach(timer => {
                const endTime = new Date(timer.dataset.endtime);
                const now = new Date();
                const diff = endTime - now;
                
                const timeSpan = timer.querySelector('.time-remaining');
                
                if (diff > 0) {
                    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
                    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                    
                    let timeText = '';
                    if (days > 0) {
                        timeText = `${days}d ${hours}h`;
                    } else if (hours > 0) {
                        timeText = `${hours}h ${minutes}m`;
                    } else {
                        timeText = `${minutes}m`;
                    }
                    
                    timeSpan.textContent = timeText;
                    
                    // Change status based on time remaining
                    const statusElement = timer.closest('tr')?.querySelector('.product-status');
                    if (statusElement && hours < 1) {
                        statusElement.className = 'product-status status-ending';
                        statusElement.textContent = '곧 마감';
                    }
                } else {
                    timeSpan.textContent = '종료';
                    timer.style.color = '#6b7280';
                    
                    // Update status
                    const statusElement = timer.closest('tr')?.querySelector('.product-status');
                    if (statusElement) {
                        statusElement.className = 'product-status status-ended';
                        statusElement.textContent = '종료';
                    }
                }
            });
        }

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            // Start timers
            updateAuctionTimers();
            setInterval(updateAuctionTimers, 60000); // Update every minute
            
            // Handle navigation
            document.querySelectorAll('.nav-item[onclick]').forEach(item => {
                item.addEventListener('click', function(e) {
                    e.preventDefault();
                });
            });
        });
    </script>
</body>
</html>