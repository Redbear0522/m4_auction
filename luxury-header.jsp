<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String sid = (String) session.getAttribute("sid");
    String ctx = request.getContextPath();
%>

<header class="luxury-header">
    <!-- Top Bar -->
    <div class="header-top">
        <div class="container">
            <div class="top-left">
                <span class="welcome-text">Welcome to M4 Auction</span>
            </div>
            <div class="top-right">
                <% if (sid != null) { %>
                    <a href="<%=ctx%>/member/mypage.jsp" class="user-link">
                        <i class="fas fa-user"></i> <%= sid %>님
                    </a>
                    <span class="divider">|</span>
                    <a href="<%=ctx%>/member/logout.jsp">로그아웃</a>
                <% } else { %>
                    <a href="<%=ctx%>/views/luxury-login.jsp">LOGIN</a>
                    <span class="divider">|</span>
                    <a href="<%=ctx%>/views/register.jsp">JOIN</a>
                <% } %>
                <span class="divider">|</span>
                <div class="language-select">
                    <button class="lang-btn active">KOR</button>
                    <button class="lang-btn">ENG</button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Main Header -->
    <div class="header-main">
        <div class="container">
            <div class="header-wrapper">
                <!-- Logo -->
                <div class="logo">
                    <a href="<%=ctx%>/luxury-main.jsp">
                        <span class="logo-text">M4 Auction</span>
                        <span class="logo-tagline">Premium Art & Luxury</span>
                    </a>
                </div>
                
                <!-- Navigation -->
                <nav class="main-nav">
                    <ul>
                        <li class="has-mega-menu">
                            <a href="#">Live Auction</a>
                            <div class="mega-menu">
                                <div class="mega-menu-inner">
                                    <div class="menu-column">
                                        <h4>경매 일정</h4>
                                        <ul>
                                            <li><a href="#">이번 달 경매</a></li>
                                            <li><a href="#">예정 경매</a></li>
                                            <li><a href="#">지난 경매</a></li>
                                        </ul>
                                    </div>
                                    <div class="menu-column">
                                        <h4>카테고리별</h4>
                                        <ul>
                                            <li><a href="#">근현대미술</a></li>
                                            <li><a href="#">고미술</a></li>
                                            <li><a href="#">해외미술</a></li>
                                        </ul>
                                    </div>
                                    <div class="menu-column">
                                        <h4>경매 안내</h4>
                                        <ul>
                                            <li><a href="#">응찰 방법</a></li>
                                            <li><a href="#">경매 약관</a></li>
                                            <li><a href="#">FAQ</a></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </li>
                        <li class="has-mega-menu">
                            <a href="#">Online Auction</a>
                            <div class="mega-menu">
                                <div class="mega-menu-inner">
                                    <div class="menu-column">
                                        <h4>진행중인 경매</h4>
                                        <ul>
                                            <li><a href="#">프리미엄 온라인</a></li>
                                            <li><a href="#">위클리 온라인</a></li>
                                            <li><a href="#">제로베이스</a></li>
                                        </ul>
                                    </div>
                                    <div class="menu-column">
                                        <h4>카테고리</h4>
                                        <ul>
                                            <li><a href="<%=ctx%>/news/economy/economyList.jsp">미술품</a></li>
                                            <li><a href="<%=ctx%>/news/politics/politicsList.jsp">골동품</a></li>
                                            <li><a href="<%=ctx%>/news/society/societyList.jsp">명품</a></li>
                                            <li><a href="<%=ctx%>/news/entertainment/entertainmentList.jsp">주얼리</a></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </li>
                        <li><a href="#">How To</a></li>
                        <li class="has-mega-menu">
                            <a href="#">Services</a>
                            <div class="mega-menu">
                                <div class="mega-menu-inner">
                                    <div class="menu-column">
                                        <h4>위탁 안내</h4>
                                        <ul>
                                            <li><a href="#">위탁 절차</a></li>
                                            <li><a href="#">위탁 신청</a></li>
                                            <li><a href="#">수수료 안내</a></li>
                                        </ul>
                                    </div>
                                    <div class="menu-column">
                                        <h4>기타 서비스</h4>
                                        <ul>
                                            <li><a href="#">작품 감정</a></li>
                                            <li><a href="#">프라이빗 세일</a></li>
                                            <li><a href="#">아트 컨설팅</a></li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </li>
                        <li><a href="<%=ctx%>/company_intro.jsp">About</a></li>
                        <li><a href="<%=ctx%>/news/qna/qnaList.jsp">Contact</a></li>
                    </ul>
                </nav>
                
                <!-- Header Actions -->
                <div class="header-actions">
                    <button class="search-toggle">
                        <i class="fas fa-search"></i>
                    </button>
                    <a href="#" class="wishlist-link">
                        <i class="far fa-heart"></i>
                        <span class="count">0</span>
                    </a>
                    <button class="mobile-menu-toggle">
                        <span></span>
                        <span></span>
                        <span></span>
                    </button>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Search Bar (Hidden by default) -->
    <div class="search-bar">
        <div class="container">
            <form class="search-form" action="<%=ctx%>/search.jsp" method="get">
                <input type="text" name="keyword" placeholder="작가명, 작품명, 경매번호를 입력하세요" autocomplete="off">
                <button type="submit"><i class="fas fa-search"></i></button>
                <button type="button" class="search-close"><i class="fas fa-times"></i></button>
            </form>
            <div class="search-suggestions">
                <h4>인기 검색어</h4>
                <div class="tag-list">
                    <a href="#" class="tag">김환기</a>
                    <a href="#" class="tag">이우환</a>
                    <a href="#" class="tag">박수근</a>
                    <a href="#" class="tag">이중섭</a>
                    <a href="#" class="tag">천경자</a>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
    // Search toggle
    document.querySelector('.search-toggle').addEventListener('click', function() {
        document.querySelector('.search-bar').classList.add('active');
        document.querySelector('.search-form input').focus();
    });
    
    document.querySelector('.search-close').addEventListener('click', function() {
        document.querySelector('.search-bar').classList.remove('active');
    });
    
    // Mobile menu toggle
    document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
        this.classList.toggle('active');
        document.querySelector('.main-nav').classList.toggle('active');
    });
    
    // Language toggle
    document.querySelectorAll('.lang-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelectorAll('.lang-btn').forEach(b => b.classList.remove('active'));
            this.classList.add('active');
        });
    });
</script>