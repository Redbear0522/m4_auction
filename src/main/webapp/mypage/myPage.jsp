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
<title>My Page - M4 Auction</title>

<!-- Luxury 폰트 및 CSS -->
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Poppins:wght@300;400;500;600;700&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/luxury-global-style.css">

<style>
    /* ⭐⭐⭐ 헤더 겹침 해결 - 가장 먼저! ⭐⭐⭐ */
    html, body {
        margin: 0;
        padding: 0;
    }
    
    body {
        padding-top: 120px !important; /* 헤더 높이만큼 여백 */
        font-family: 'Noto Sans KR', sans-serif;
        background: #f8f8f8;
    }
    
    /* 마이페이지 전용 스타일 */
    .mypage-wrapper {
        min-height: calc(100vh - 320px); /* 헤더 120px + 푸터 200px */
        background: #f8f8f8;
        padding: 40px 0 80px 0; /* 상단 패딩 줄임 */
    }
    
    .mypage-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 20px;
        display: grid;
        grid-template-columns: 280px 1fr;
        gap: 40px;
    }
    
    /* 사이드바 스타일 */
    .sidebar {
        background: white;
        height: fit-content;
        box-shadow: 0 0 20px rgba(0,0,0,0.05);
        position: sticky;
        top: 140px; /* 헤더 높이 + 20px 여백 */
    }
    
    .user-info-box {
        padding: 40px 30px;
        text-align: center;
        border-bottom: 1px solid #eee;
    }
    
    .user-avatar {
        width: 80px;
        height: 80px;
        background: #c9961a;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 20px;
        font-size: 36px;
        color: white;
    }
    
    .user-name {
        font-size: 24px;
        font-weight: 700;
        color: #1a1a1a;
        margin-bottom: 5px;
    }
    
    .user-id {
        color: #999;
        font-size: 14px;
    }
    
    .vip-badge {
        display: inline-block;
        background: #c9961a;
        color: white;
        padding: 4px 12px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 600;
        margin-top: 10px;
    }
    
    .sidebar-menu {
        padding: 20px 0;
    }
    
    .menu-item {
        display: block;
        padding: 15px 30px;
        color: #666;
        font-size: 15px;
        transition: all 0.3s;
        position: relative;
        text-decoration: none;
    }
    
    .menu-item:hover,
    .menu-item.active {
        color: #c9961a;
        background: #faf8f4;
    }
    
    .menu-item.active::before {
        content: '';
        position: absolute;
        left: 0;
        top: 0;
        bottom: 0;
        width: 3px;
        background: #c9961a;
    }
    
    /* 메인 컨텐츠 */
    .main-content {
        background: white;
        padding: 40px;
        box-shadow: 0 0 20px rgba(0,0,0,0.05);
        min-height: 600px;
    }
    
    .page-title {
        font-family: 'Playfair Display', serif;
        font-size: 32px;
        color: #1a1a1a;
        margin-bottom: 40px;
        padding-bottom: 20px;
        border-bottom: 2px solid #f0f0f0;
    }
    
    /* 정보 카드 */
    .info-cards {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 20px;
        margin-bottom: 50px;
    }
    
    .info-card {
        background: #fafafa;
        padding: 30px;
        border-radius: 8px;
        text-align: center;
        transition: all 0.3s;
    }
    
    .info-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 5px 20px rgba(0,0,0,0.1);
    }
    
    .info-card-icon {
        width: 50px;
        height: 50px;
        background: #c9961a;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 15px;
        color: white;
        font-size: 20px;
    }
    
    .info-card-label {
        font-size: 14px;
        color: #999;
        margin-bottom: 10px;
    }
    
    .info-card-value {
        font-size: 24px;
        font-weight: 700;
        color: #1a1a1a;
    }
    
    /* 섹션 스타일 */
    .section {
        margin-bottom: 50px;
    }
    
    .section-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 30px;
    }
    
    .section-title {
        font-size: 24px;
        font-weight: 700;
        color: #1a1a1a;
    }
    
    .btn-more {
        color: #c9961a;
        font-size: 14px;
        font-weight: 500;
        text-decoration: none;
        transition: all 0.3s;
    }
    
    .btn-more:hover {
        color: #b08515;
    }
    
    /* 상품 그리드 */
    .product-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 30px;
    }
    
    .product-card {
        background: white;
        border: 1px solid #eee;
        overflow: hidden;
        transition: all 0.3s;
        cursor: pointer;
    }
    
    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 30px rgba(0,0,0,0.1);
        border-color: #c9961a;
    }
    
    .product-image {
        width: 100%;
        height: 200px;
        object-fit: cover;
        transition: all 0.3s;
    }
    
    .product-card:hover .product-image {
        transform: scale(1.05);
    }
    
    .product-info {
        padding: 20px;
    }
    
    .product-title {
        font-size: 16px;
        font-weight: 600;
        color: #1a1a1a;
        margin-bottom: 10px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    
    .product-price {
        font-size: 18px;
        font-weight: 700;
        color: #c9961a;
    }
    
    /* 경매 타이머 스타일 추가 */
    .auction-timer {
        margin-top: 10px;
        font-size: 13px;
        color: #e74c3c;
        display: flex;
        align-items: center;
        gap: 5px;
    }

    .auction-timer i {
        color: #e74c3c;
    }

    .time-remaining {
        font-weight: 600;
    }

    .time-remaining.ending-soon {
        color: #e74c3c;
        animation: blink 1s infinite;
    }

    @keyframes blink {
        0%, 50% { opacity: 1; }
        51%, 100% { opacity: 0.5; }
    }
    
    .empty-state {
        text-align: center;
        padding: 60px 0;
        color: #999;
    }
    
    .empty-state i {
        font-size: 48px;
        margin-bottom: 20px;
        opacity: 0.5;
    }
    
    /* 버튼 스타일 */
    .btn-group {
        display: flex;
        gap: 10px;
        margin-top: 30px;
    }
    
    .btn {
        padding: 12px 30px;
        font-size: 14px;
        font-weight: 600;
        letter-spacing: 0.5px;
        text-transform: uppercase;
        border: none;
        cursor: pointer;
        transition: all 0.3s;
        text-decoration: none;
        display: inline-block;
        text-align: center;
    }
    
    .btn-primary {
        background: #1a1a1a;
        color: white;
    }
    
    .btn-primary:hover {
        background: #c9961a;
    }
    
    .btn-outline {
        background: white;
        color: #1a1a1a;
        border: 2px solid #1a1a1a;
    }
    
    .btn-outline:hover {
        background: #1a1a1a;
        color: white;
    }
    
    /* VIP 옵션 폼 */
    .vip-option-form {
        background: #faf8f4;
        border: 2px solid #c9961a;
        padding: 30px;
        margin-top: 30px;
        border-radius: 8px;
    }
    
    .vip-option-form h3 {
        font-family: 'Playfair Display', serif;
        font-size: 24px;
        margin-bottom: 20px;
        color: #1a1a1a;
    }
    
    .vip-option-form select {
        padding: 10px 15px;
        border: 1px solid #ddd;
        margin-right: 10px;
        font-size: 14px;
        background: white;
    }
    
    .vip-option-form input[type="submit"] {
        padding: 10px 30px;
        background: #c9961a;
        color: white;
        border: none;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s;
        font-size: 14px;
        text-transform: uppercase;
    }
    
    .vip-option-form input[type="submit"]:hover {
        background: #b08515;
    }
    
    /* 반응형 */
    @media (max-width: 1024px) {
        .mypage-container {
            grid-template-columns: 1fr;
        }
        
        .sidebar {
            position: static;
            margin-bottom: 30px;
        }
        
        .info-cards {
            grid-template-columns: repeat(2, 1fr);
        }
    }
    
    @media (max-width: 768px) {
        body {
            padding-top: 100px !important; /* 모바일 헤더 높이 */
        }
        
        .mypage-wrapper {
            padding: 20px 0 40px 0;
        }
        
        .main-content {
            padding: 20px;
        }
        
        .info-cards {
            grid-template-columns: 1fr;
        }
        
        .product-grid {
            grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
            gap: 15px;
        }
        
        .btn-group {
            flex-direction: column;
        }
        
        .btn {
            width: 100%;
        }
    }
</style>
</head>
<body>
    <!-- Luxury 헤더 -->
    <jsp:include page="/layout/header/luxury-header.jsp" />

    <div class="mypage-wrapper">
        <div class="mypage-container">
            <!-- 사이드바 -->
            <aside class="sidebar">
                <div class="user-info-box">
                    <div class="user-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <h3 class="user-name"><%= loginUser.getMemberName() %></h3>
                    <p class="user-id">@<%= loginUser.getMemberId() %></p>
                    <% if(isVip) { %>
                        <span class="vip-badge">VIP MEMBER</span>
                    <% } %>
                </div>
                
                <nav class="sidebar-menu">
                    <a href="#" class="menu-item active">
                        <i class="fas fa-home" style="margin-right: 10px;"></i>대시보드
                    </a>
                    <a href="updateMemberForm.jsp" class="menu-item">
                        <i class="fas fa-user-edit" style="margin-right: 10px;"></i>회원정보 수정
                    </a>
                    <a href="changePwdForm.jsp" class="menu-item">
                        <i class="fas fa-lock" style="margin-right: 10px;"></i>비밀번호 변경
                    </a>
                    <a href="#" class="menu-item">
                        <i class="fas fa-gavel" style="margin-right: 10px;"></i>입찰 내역
                    </a>
                    <a href="#" class="menu-item">
                        <i class="fas fa-trophy" style="margin-right: 10px;"></i>낙찰 내역
                    </a>
                    <a href="#" class="menu-item">
                        <i class="fas fa-heart" style="margin-right: 10px;"></i>관심 상품
                    </a>
                    <a href="chargeForm.jsp" class="menu-item">
                        <i class="fas fa-coins" style="margin-right: 10px;"></i>마일리지 충전
                    </a>
                </nav>
            </aside>
            
            <!-- 메인 컨텐츠 -->
            <main class="main-content">
                <h1 class="page-title">My Dashboard</h1>
                
                <!-- 정보 카드 -->
                <div class="info-cards">
                    <div class="info-card">
                        <div class="info-card-icon">
                            <i class="fas fa-coins"></i>
                        </div>
                        <p class="info-card-label">보유 마일리지</p>
                        <p class="info-card-value"><%= df.format(loginUser.getMileage()) %> P</p>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-card-icon">
                            <i class="fas fa-gavel"></i>
                        </div>
                        <p class="info-card-label">진행중인 입찰</p>
                        <p class="info-card-value"><%= myBids.size() %>건</p>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-card-icon">
                            <i class="fas fa-trophy"></i>
                        </div>
                        <p class="info-card-label">낙찰 성공</p>
                        <p class="info-card-value"><%= myWonProducts.size() %>건</p>
                    </div>
                    
                    <div class="info-card">
                        <div class="info-card-icon">
                            <i class="fas fa-tag"></i>
                        </div>
                        <p class="info-card-label">등록 상품</p>
                        <p class="info-card-value"><%= myProducts.size() %>건</p>
                    </div>
                </div>
                
                <!-- VIP 혜택 신청 (VIP만 표시) -->
                <% if(isVip) { %>
                <div class="vip-option-form">
                    <h3>VIP 혜택 신청</h3>
                    <form action="<%= request.getContextPath() %>/mypage/vipOptionRequest.jsp" method="post">
                        <select name="option" required>
                            <option value="">혜택 선택</option>
                            <option value="골드">골드 혜택</option>
                            <option value="다이아">다이아 혜택</option>
                        </select>
                        <input type="submit" value="신청하기">
                    </form>
                </div>
                <% } %>
                
                <!-- 내가 등록한 상품 -->
                <div class="section">
                    <div class="section-header">
                        <h2 class="section-title">내가 등록한 상품</h2>
                        <a href="#" class="btn-more">전체보기 <i class="fas fa-arrow-right"></i></a>
                    </div>
                    
                    <% if(myProducts.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-box-open"></i>
                            <p>등록한 상품이 없습니다.</p>
                        </div>
                    <% } else { %>
                        <div class="product-grid">
                            <% for(ProductDTO p : myProducts) { %>
                            <div class="product-card">
                                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" 
                                     alt="<%= p.getProductName() %>" class="product-image">
                                <div class="product-info">
                                    <h4 class="product-title"><%= p.getProductName() %></h4>
                                    <p class="product-price">₩ <%= df.format(p.getCurrentPrice()) %></p>
                                    <!-- 경매 종료 시간 추가 -->
                                    <div class="auction-timer" data-endtime="<%= p.getEndTime() %>">
                                        <i class="far fa-clock"></i>
                                        <span class="time-remaining">계산중...</span>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
                
                <!-- 내가 입찰한 상품 -->
                <div class="section">
                    <div class="section-header">
                        <h2 class="section-title">내가 입찰한 상품</h2>
                        <a href="#" class="btn-more">전체보기 <i class="fas fa-arrow-right"></i></a>
                    </div>
                    
                    <% if(myBids.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-gavel"></i>
                            <p>입찰한 상품이 없습니다.</p>
                        </div>
                    <% } else { %>
                        <div class="product-grid">
                            <% for(ProductDTO p : myBids) { %>
                            <div class="product-card">
                                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" 
                                     alt="<%= p.getProductName() %>" class="product-image">
                                <div class="product-info">
                                    <h4 class="product-title"><%= p.getProductName() %></h4>
                                    <p class="product-price">₩ <%= df.format(p.getCurrentPrice()) %></p>
                                    <!-- 경매 종료 시간 추가 -->
                                    <div class="auction-timer" data-endtime="<%= p.getEndTime() %>">
                                        <i class="far fa-clock"></i>
                                        <span class="time-remaining">계산중...</span>
                                    </div>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
                
                <!-- 내가 낙찰받은 상품 -->
                <div class="section">
                    <div class="section-header">
                        <h2 class="section-title">내가 낙찰받은 상품</h2>
                        <a href="#" class="btn-more">전체보기 <i class="fas fa-arrow-right"></i></a>
                    </div>
                    
                    <% if(myWonProducts.isEmpty()) { %>
                        <div class="empty-state">
                            <i class="fas fa-trophy"></i>
                            <p>낙찰받은 상품이 없습니다.</p>
                        </div>
                    <% } else { %>
                        <div class="product-grid">
                            <% for(ProductDTO p : myWonProducts) { %>
                            <div class="product-card">
                                <img src="<%= request.getContextPath() %>/resources/product_images/<%= p.getImageRenamedName() %>" 
                                     alt="<%= p.getProductName() %>" class="product-image">
                                <div class="product-info">
                                    <h4 class="product-title"><%= p.getProductName() %></h4>
                                    <p class="product-price">낙찰가 ₩ <%= df.format(p.getFinalPrice()) %></p>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
                
                <!-- 버튼 그룹 -->
                <div class="btn-group">
                    <a href="updateMemberForm.jsp" class="btn btn-primary">회원정보 수정</a>
                    <a href="changePwdForm.jsp" class="btn btn-outline">비밀번호 변경</a>
                </div>
            </main>
        </div>
    </div>

    <!-- Luxury 푸터 -->
    <jsp:include page="/layout/footer/luxury-footer.jsp" />
    
    <% if(alertMsg != null) { 
        session.removeAttribute("alertMsg");
    %>
    <script>
        alert("<%= alertMsg %>");
    </script>
    <% } %>
    
    <!-- 실시간 경매 타이머 스크립트 추가 -->
    <script>
    // 실시간 경매 시간 업데이트
    function updateAuctionTimers() {
        const timers = document.querySelectorAll('.auction-timer');
        
        timers.forEach(timer => {
            const endTime = new Date(timer.dataset.endtime);
            const now = new Date();
            const diff = endTime - now;
            
            if (diff > 0) {
                // 시간 계산
                const days = Math.floor(diff / (1000 * 60 * 60 * 24));
                const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((diff % (1000 * 60)) / 1000);
                
                let timeText = '';
                const timeSpan = timer.querySelector('.time-remaining');
                
                // 시간 표시 형식
                if (days > 0) {
                    timeText = `${days}일 ${hours}시간 남음`;
                } else if (hours > 0) {
                    timeText = `${hours}시간 ${minutes}분 남음`;
                    if (hours < 1) {
                        timeSpan.classList.add('ending-soon');
                    }
                } else if (minutes > 0) {
                    timeText = `${minutes}분 ${seconds}초 남음`;
                    timeSpan.classList.add('ending-soon');
                } else {
                    timeText = `${seconds}초 남음`;
                    timeSpan.classList.add('ending-soon');
                }
                
                timeSpan.textContent = timeText;
            } else {
                // 경매 종료
                timer.innerHTML = '<i class="fas fa-check-circle"></i> <span style="color: #999;">경매 종료</span>';
            }
        });
    }

    // 페이지 로드 시 실행
    updateAuctionTimers();

    // 1초마다 업데이트
    setInterval(updateAuctionTimers, 1000);
    </script>
</body>
</html>