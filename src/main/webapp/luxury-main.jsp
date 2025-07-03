<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    String sid = (String) session.getAttribute("sid");
    String ctx = request.getContextPath();
    
    // 날짜 포맷터
    SimpleDateFormat dateFormat = new SimpleDateFormat("MM.dd");
    SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");
    Date now = new Date();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>M4 Auction - Premium Art & Luxury Auction House</title>
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Poppins:wght@300;400;500;600;700&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    
    <!-- Swiper CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="<%=ctx%>/resources/css/luxury-global-style.css">
</head>
<body>
    <!-- Header -->
    <jsp:include page="/layout/header/luxury-header.jsp" />
    
    <!-- Main Hero Section -->
    <section class="main-hero">
        <div class="hero-slider swiper">
            <div class="swiper-wrapper">
                <!-- Slide 1 -->
                <div class="swiper-slide">
                    <div class="hero-slide" style="background-image: url('https://images.unsplash.com/photo-1578321272176-b7bbc0679853?q=80&w=2000');">
                        <div class="hero-overlay"></div>
                        <div class="hero-content">
                            <span class="hero-category">JULY ONLINE AUCTION</span>
                            <h1 class="hero-title">현대미술 특별 경매</h1>
                            <p class="hero-desc">김환기, 이우환 등 한국 현대미술의 거장들</p>
                            <div class="hero-info">
                                <div class="info-item">
                                    <span class="label">프리뷰</span>
                                    <span class="value">07.12 ~ 07.23</span>
                                </div>
                                <div class="info-item">
                                    <span class="label">경매</span>
                                    <span class="value">07.23 TUE 4pm</span>
                                </div>
                            </div>
                            <div class="hero-actions">
                                <a href="#" class="btn btn-primary">도록 보기</a>
                                <a href="#" class="btn btn-outline">라이브 경매 참여</a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Slide 2 -->
                <div class="swiper-slide">
                    <div class="hero-slide" style="background-image: url('https://images.unsplash.com/photo-1549887534-1541e9326642?q=80&w=2000');">
                        <div class="hero-overlay"></div>
                        <div class="hero-content">
                            <span class="hero-category">PREMIUM COLLECTION</span>
                            <h1 class="hero-title">프리미엄 온라인 경매</h1>
                            <p class="hero-desc">엄선된 근현대 미술품과 골동품 컬렉션</p>
                            <div class="hero-info">
                                <div class="info-item">
                                    <span class="label">프리뷰</span>
                                    <span class="value">07.12 ~ 07.22</span>
                                </div>
                                <div class="info-item">
                                    <span class="label">경매</span>
                                    <span class="value">07.22 MON 4pm</span>
                                </div>
                            </div>
                            <div class="hero-actions">
                                <a href="#" class="btn btn-primary">도록 보기</a>
                                <a href="#" class="btn btn-outline">온라인 응찰</a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Slide 3 -->
                <div class="swiper-slide">
                    <div class="hero-slide" style="background-image: url('https://images.unsplash.com/photo-1561214115-f2f134cc4912?q=80&w=2000');">
                        <div class="hero-overlay"></div>
                        <div class="hero-content">
                            <span class="hero-category">WEEKLY AUCTION</span>
                            <h1 class="hero-title">위클리 온라인 경매</h1>
                            <p class="hero-desc">매주 새로운 작품을 만나보세요</p>
                            <div class="hero-info">
                                <div class="info-item">
                                    <span class="label">프리뷰</span>
                                    <span class="value">07.12 ~ 07.24</span>
                                </div>
                                <div class="info-item">
                                    <span class="label">경매</span>
                                    <span class="value">순차 마감</span>
                                </div>
                            </div>
                            <div class="hero-actions">
                                <a href="#" class="btn btn-primary">작품 보기</a>
                                <a href="#" class="btn btn-outline">응찰 가이드</a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="swiper-pagination"></div>
            <div class="swiper-button-prev"></div>
            <div class="swiper-button-next"></div>
        </div>
    </section>
    
    <!-- Quick Links -->
    <section class="quick-links">
        <div class="container">
            <div class="links-grid">
                <a href="#" class="link-item">
                    <i class="fas fa-gavel"></i>
                    <span>Live Auction</span>
                </a>
                <a href="#" class="link-item">
                    <i class="fas fa-laptop"></i>
                    <span>Online Auction</span>
                </a>
                <a href="#" class="link-item">
                    <i class="fas fa-calendar-alt"></i>
                    <span>Auction Schedule</span>
                </a>
                <a href="#" class="link-item">
                    <i class="fas fa-user-circle"></i>
                    <span>My Page</span>
                </a>
            </div>
        </div>
    </section>
    
    <!-- Upcoming Auctions -->
    <section class="upcoming-auctions">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Upcoming Auctions</h2>
                <a href="#" class="view-all">전체보기 <i class="fas fa-arrow-right"></i></a>
            </div>
            
            <div class="auction-tabs">
                <button class="tab-btn active" data-tab="major">Major</button>
                <button class="tab-btn" data-tab="premium">Premium</button>
                <button class="tab-btn" data-tab="weekly">Weekly</button>
            </div>
            
            <div class="auction-content">
                <!-- Major Auctions -->
                <div class="tab-content active" id="major">
                    <div class="auction-grid">
                        <div class="auction-card">
                            <div class="auction-image">
                                <img src="https://images.unsplash.com/photo-1578321272176-b7bbc0679853?q=80&w=600" alt="경매">
                                <div class="auction-badge live">Live</div>
                            </div>
                            <div class="auction-info">
                                <span class="auction-date">7월 23일 화요일</span>
                                <h3 class="auction-title">메이저 경매</h3>
                                <p class="auction-desc">프리뷰 시작 D-8</p>
                                <div class="auction-meta">
                                    <span class="time"><i class="far fa-clock"></i> 16:00</span>
                                    <span class="lots"><i class="fas fa-list"></i> 156 Lots</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="auction-card">
                            <div class="auction-image">
                                <img src="https://images.unsplash.com/photo-1561214115-f2f134cc4912?q=80&w=600" alt="경매">
                                <div class="auction-badge online">Online</div>
                            </div>
                            <div class="auction-info">
                                <span class="auction-date">8월 2일 금요일</span>
                                <h3 class="auction-title">근현대미술 경매</h3>
                                <p class="auction-desc">위탁 접수중</p>
                                <div class="auction-meta">
                                    <span class="time"><i class="far fa-clock"></i> 15:00</span>
                                    <span class="lots"><i class="fas fa-list"></i> 203 Lots</span>
                                </div>
                            </div>
                        </div>
                        
                        <div class="auction-card">
                            <div class="auction-image">
                                <img src="https://images.unsplash.com/photo-1569096651661-820d0de9b8ab?q=80&w=600" alt="경매">
                                <div class="auction-badge live">Live</div>
                            </div>
                            <div class="auction-info">
                                <span class="auction-date">8월 15일 목요일</span>
                                <h3 class="auction-title">고미술 특별경매</h3>
                                <p class="auction-desc">도록 제작중</p>
                                <div class="auction-meta">
                                    <span class="time"><i class="far fa-clock"></i> 14:00</span>
                                    <span class="lots"><i class="fas fa-list"></i> 87 Lots</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Premium Auctions -->
                <div class="tab-content" id="premium">
                    <div class="auction-grid">
                        <div class="auction-card">
                            <div class="auction-image">
                                <img src="https://images.unsplash.com/photo-1549887534-1541e9326642?q=80&w=600" alt="경매">
                                <div class="auction-badge online">Online</div>
                            </div>
                            <div class="auction-info">
                                <span class="auction-date">7월 22일 월요일</span>
                                <h3 class="auction-title">프리미엄 온라인경매</h3>
                                <p class="auction-desc">프리뷰 시작 D-7</p>
                                <div class="auction-meta">
                                    <span class="time"><i class="far fa-clock"></i> 16:00</span>
                                    <span class="lots"><i class="fas fa-list"></i> 89 Lots</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Weekly Auctions -->
                <div class="tab-content" id="weekly">
                    <div class="auction-grid">
                        <div class="auction-card">
                            <div class="auction-image">
                                <img src="https://images.unsplash.com/photo-1576086477369-b5ee4eec20d6?q=80&w=600" alt="경매">
                                <div class="auction-badge online">Online</div>
                            </div>
                            <div class="auction-info">
                                <span class="auction-date">7월 17일 수요일</span>
                                <h3 class="auction-title">위클리 온라인경매</h3>
                                <p class="auction-desc">프리뷰 시작 D-8</p>
                                <div class="auction-meta">
                                    <span class="time"><i class="far fa-clock"></i> 순차마감</span>
                                    <span class="lots"><i class="fas fa-list"></i> 120 Lots</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <!-- Featured Artworks -->
    <section class="featured-artworks">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Featured Artworks</h2>
                <a href="#" class="view-all">전체보기 <i class="fas fa-arrow-right"></i></a>
            </div>
            
            <div class="artworks-slider swiper">
                <div class="swiper-wrapper">
                    <div class="swiper-slide">
                        <div class="artwork-card">
                            <div class="artwork-image">
                                <img src="https://images.unsplash.com/photo-1578321272176-b7bbc0679853?q=80&w=400" alt="작품">
                                <div class="artwork-overlay">
                                    <button class="btn-wish"><i class="far fa-heart"></i></button>
                                    <a href="#" class="btn-view">상세보기</a>
                                </div>
                            </div>
                            <div class="artwork-info">
                                <span class="lot-number">LOT 001</span>
                                <h4 class="artist-name">김환기 KIM Whanki</h4>
                                <p class="artwork-title">무제 Untitled</p>
                                <p class="artwork-details">Oil on canvas, 162.2×130.3cm, 1970</p>
                                <div class="artwork-estimate">
                                    <span class="label">추정가</span>
                                    <span class="price">KRW 3,000,000,000 - 5,000,000,000</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="swiper-slide">
                        <div class="artwork-card">
                            <div class="artwork-image">
                                <img src="https://images.unsplash.com/photo-1561214115-f2f134cc4912?q=80&w=400" alt="작품">
                                <div class="artwork-overlay">
                                    <button class="btn-wish"><i class="far fa-heart"></i></button>
                                    <a href="#" class="btn-view">상세보기</a>
                                </div>
                            </div>
                            <div class="artwork-info">
                                <span class="lot-number">LOT 002</span>
                                <h4 class="artist-name">이우환 LEE Ufan</h4>
                                <p class="artwork-title">From Point</p>
                                <p class="artwork-details">Oil on canvas, 182×227cm, 1978</p>
                                <div class="artwork-estimate">
                                    <span class="label">추정가</span>
                                    <span class="price">KRW 1,500,000,000 - 2,500,000,000</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="swiper-slide">
                        <div class="artwork-card">
                            <div class="artwork-image">
                                <img src="https://images.unsplash.com/photo-1549887534-1541e9326642?q=80&w=400" alt="작품">
                                <div class="artwork-overlay">
                                    <button class="btn-wish"><i class="far fa-heart"></i></button>
                                    <a href="#" class="btn-view">상세보기</a>
                                </div>
                            </div>
                            <div class="artwork-info">
                                <span class="lot-number">LOT 003</span>
                                <h4 class="artist-name">박수근 PARK Sookeun</h4>
                                <p class="artwork-title">빨래터</p>
                                <p class="artwork-details">Oil on canvas, 45.5×53cm, 1960</p>
                                <div class="artwork-estimate">
                                    <span class="label">추정가</span>
                                    <span class="price">KRW 2,000,000,000 - 3,000,000,000</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="swiper-slide">
                        <div class="artwork-card">
                            <div class="artwork-image">
                                <img src="https://images.unsplash.com/photo-1576086477369-b5ee4eec20d6?q=80&w=400" alt="작품">
                                <div class="artwork-overlay">
                                    <button class="btn-wish"><i class="far fa-heart"></i></button>
                                    <a href="#" class="btn-view">상세보기</a>
                                </div>
                            </div>
                            <div class="artwork-info">
                                <span class="lot-number">LOT 004</span>
                                <h4 class="artist-name">이중섭 LEE Jungseob</h4>
                                <p class="artwork-title">황소</p>
                                <p class="artwork-details">Oil on paper, 35.5×52cm, 1953</p>
                                <div class="artwork-estimate">
                                    <span class="label">추정가</span>
                                    <span class="price">KRW 800,000,000 - 1,200,000,000</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="swiper-button-prev"></div>
                <div class="swiper-button-next"></div>
            </div>
        </div>
    </section>
    
    <!-- Categories -->
    <section class="categories">
        <div class="container">
            <div class="section-header">
                <h2 class="section-title">Categories</h2>
            </div>
            
            <div class="category-grid">
                <a href="<%=ctx%>/news/economy/economyList.jsp" class="category-item">
                    <div class="category-image">
                        <img src="https://images.unsplash.com/photo-1578321272176-b7bbc0679853?q=80&w=400" alt="현대미술">
                        <div class="category-overlay">
                            <h3>현대미술</h3>
                            <span>Modern Art</span>
                        </div>
                    </div>
                </a>
                
                <a href="<%=ctx%>/news/politics/politicsList.jsp" class="category-item">
                    <div class="category-image">
                        <img src="https://images.unsplash.com/photo-1569096651661-820d0de9b8ab?q=80&w=400" alt="고미술">
                        <div class="category-overlay">
                            <h3>고미술</h3>
                            <span>Ancient Art</span>
                        </div>
                    </div>
                </a>
                
                <a href="#" class="category-item">
                    <div class="category-image">
                        <img src="https://images.unsplash.com/photo-1561214115-f2f134cc4912?q=80&w=400" alt="서양화">
                        <div class="category-overlay">
                            <h3>서양화</h3>
                            <span>Western Painting</span>
                        </div>
                    </div>
                </a>
                
                <a href="#" class="category-item">
                    <div class="category-image">
                        <img src="https://images.unsplash.com/photo-1549887534-1541e9326642?q=80&w=400" alt="조각">
                        <div class="category-overlay">
                            <h3>조각</h3>
                            <span>Sculpture</span>
                        </div>
                    </div>
                </a>
                
                <a href="<%=ctx%>/news/entertainment/entertainmentList.jsp" class="category-item">
                    <div class="category-image">
                        <img src="https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?q=80&w=400" alt="주얼리">
                        <div class="category-overlay">
                            <h3>주얼리 & 시계</h3>
                            <span>Jewelry & Watches</span>
                        </div>
                    </div>
                </a>
                
                <a href="<%=ctx%>/news/society/societyList.jsp" class="category-item">
                    <div class="category-image">
                        <img src="https://images.unsplash.com/photo-1552519507-da3b142c6e3d?q=80&w=400" alt="명품">
                        <div class="category-overlay">
                            <h3>명품 컬렉션</h3>
                            <span>Luxury Collection</span>
                        </div>
                    </div>
                </a>
            </div>
        </div>
    </section>
    
    <!-- Services -->
    <section class="services">
        <div class="container">
            <div class="service-grid">
                <div class="service-item">
                    <div class="service-icon">
                        <i class="fas fa-certificate"></i>
                    </div>
                    <h3>전문가 감정</h3>
                    <p>40년 경력의 전문가들이 작품의 진위와 가치를 정확하게 평가합니다</p>
                </div>
                
                <div class="service-item">
                    <div class="service-icon">
                        <i class="fas fa-shipping-fast"></i>
                    </div>
                    <h3>안전한 배송</h3>
                    <p>전문 미술품 운송 시스템으로 작품을 안전하게 배송해드립니다</p>
                </div>
                
                <div class="service-item">
                    <div class="service-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <h3>작품 보증</h3>
                    <p>모든 경매 작품에 대해 진품 보증서를 발급해드립니다</p>
                </div>
                
                <div class="service-item">
                    <div class="service-icon">
                        <i class="fas fa-headset"></i>
                    </div>
                    <h3>전문 상담</h3>
                    <p>컬렉션 구성부터 투자 상담까지 맞춤형 서비스를 제공합니다</p>
                </div>
            </div>
        </div>
    </section>
    
    <!-- News & Events -->
    <section class="news-events">
        <div class="container">
            <div class="news-grid">
                <div class="news-main">
                    <h2 class="section-title">News & Events</h2>
                    <div class="news-list">
                        <article class="news-item">
                            <span class="news-date">2025.01.03</span>
                            <h3><a href="#">2025년 상반기 경매 일정 안내</a></h3>
                            <p>M4 Auction의 2025년 상반기 주요 경매 일정을 안내드립니다.</p>
                        </article>
                        
                        <article class="news-item">
                            <span class="news-date">2024.12.28</span>
                            <h3><a href="#">김환기 작품 최고가 경신</a></h3>
                            <p>12월 메이저 경매에서 김환기 화백의 작품이 52억원에 낙찰되었습니다.</p>
                        </article>
                        
                        <article class="news-item">
                            <span class="news-date">2024.12.20</span>
                            <h3><a href="#">신규 VIP 멤버십 혜택 안내</a></h3>
                            <p>2025년부터 적용되는 새로운 VIP 멤버십 프로그램을 소개합니다.</p>
                        </article>
                    </div>
                    <a href="#" class="btn-more">더보기 <i class="fas fa-arrow-right"></i></a>
                </div>
                
                <div class="event-banner">
                    <h3>Special Exhibition</h3>
                    <div class="event-image">
                        <img src="https://images.unsplash.com/photo-1561214115-f2f134cc4912?q=80&w=600" alt="전시">
                    </div>
                    <div class="event-info">
                        <h4>한국 단색화의 거장들</h4>
                        <p>2025.01.15 - 02.28</p>
                        <p>M4 Gallery</p>
                        <a href="#" class="btn btn-outline-white">자세히 보기</a>
                    </div>
                </div>
            </div>
        </div>
    </section>
    
    <!-- Newsletter -->
    <section class="newsletter">
        <div class="container">
            <div class="newsletter-content">
                <div class="newsletter-text">
                    <h2>Newsletter</h2>
                    <p>M4 Auction의 최신 경매 소식과 전시 정보를 받아보세요</p>
                </div>
                <form class="newsletter-form">
                    <input type="email" placeholder="이메일 주소를 입력하세요" required>
                    <button type="submit">구독하기</button>
                </form>
            </div>
        </div>
    </section>
    
    <!-- Footer -->
    <jsp:include page="/layout/footer/luxury-footer.jsp" />
    
    <!-- Swiper JS -->
    <script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>
    
    <!-- Custom JS -->
    <script>
        // Hero Slider
        const heroSlider = new Swiper('.hero-slider', {
            loop: true,
            autoplay: {
                delay: 5000,
                disableOnInteraction: false,
            },
            pagination: {
                el: '.swiper-pagination',
                clickable: true,
            },
            navigation: {
                nextEl: '.swiper-button-next',
                prevEl: '.swiper-button-prev',
            },
            effect: 'fade',
            fadeEffect: {
                crossFade: true
            }
        });
        
        // Artworks Slider
        const artworksSlider = new Swiper('.artworks-slider', {
            slidesPerView: 1,
            spaceBetween: 20,
            loop: true,
            navigation: {
                nextEl: '.artworks-slider .swiper-button-next',
                prevEl: '.artworks-slider .swiper-button-prev',
            },
            breakpoints: {
                640: {
                    slidesPerView: 2,
                },
                768: {
                    slidesPerView: 3,
                },
                1024: {
                    slidesPerView: 4,
                }
            }
        });
        
        // Tab functionality
        const tabBtns = document.querySelectorAll('.tab-btn');
        const tabContents = document.querySelectorAll('.tab-content');
        
        tabBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const tabId = btn.getAttribute('data-tab');
                
                // Remove active class from all
                tabBtns.forEach(b => b.classList.remove('active'));
                tabContents.forEach(c => c.classList.remove('active'));
                
                // Add active class to clicked
                btn.classList.add('active');
                document.getElementById(tabId).classList.add('active');
            });
        });
        
        // Smooth scroll
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function (e) {
                e.preventDefault();
                const target = document.querySelector(this.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });
        
        // Wish button toggle
        document.querySelectorAll('.btn-wish').forEach(btn => {
            btn.addEventListener('click', function() {
                const icon = this.querySelector('i');
                icon.classList.toggle('far');
                icon.classList.toggle('fas');
                this.classList.toggle('active');
            });
        });
    </script>
</body>
</html>