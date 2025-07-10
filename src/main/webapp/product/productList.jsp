<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.auction.dto.ProductDTO" %>
<%@ page import="com.auction.dao.ProductDAO" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%@ page import="com.auction.dto.MemberDTO" %>

<%
    String ctx = request.getContextPath();
    MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
    
    // 검색 및 필터 파라미터
    String searchKeyword = request.getParameter("keyword");
    String categoryFilter = request.getParameter("category");
    String statusFilter = request.getParameter("status");
    String sortBy = request.getParameter("sort");
    
    if(searchKeyword == null) searchKeyword = "";
    if(categoryFilter == null) categoryFilter = "";
    if(statusFilter == null) statusFilter = "";
    if(sortBy == null) sortBy = "newest";
    
    // 데이터베이스에서 상품 목록 조회
    List<ProductDTO> productList = new ArrayList<>();
    Connection conn = null;
    try {
        conn = getConnection();
        ProductDAO productDao = new ProductDAO();
        productList = productDao.selectAllProducts(conn);
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) close(conn);
    }
    
    // 포맷터
    DecimalFormat df = new DecimalFormat("###,###,###");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy.MM.dd");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>전체 상품 목록 - M4 Auction</title>
    
    <!-- Fonts & Icons -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    
    <!-- Global Styles -->
    <link rel="stylesheet" href="<%=ctx%>/resources/css/luxury-global-style.css">
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: #f8f9fa;
            padding-top: 120px;
        }
        
        .page-header {
            background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
            color: white;
            padding: 60px 0;
            text-align: center;
        }
        
        .page-header h1 {
            font-family: 'Playfair Display', serif;
            font-size: 42px;
            font-weight: 700;
            margin-bottom: 15px;
        }
        
        .page-header p {
            font-size: 18px;
            opacity: 0.9;
            max-width: 600px;
            margin: 0 auto;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            padding: 0 20px;
        }
        
        .content-wrapper {
            padding: 40px 0;
        }
        
        .filter-section {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            margin-bottom: 30px;
        }
        
        .filter-row {
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1fr auto;
            gap: 20px;
            align-items: end;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            font-weight: 600;
            margin-bottom: 8px;
            color: #1a1a1a;
        }
        
        .form-group input,
        .form-group select {
            padding: 12px;
            border: 1px solid #e5e5e5;
            border-radius: 8px;
            font-size: 15px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #c9961a;
        }
        
        .search-btn {
            background: linear-gradient(135deg, #c9961a 0%, #d4af37 100%);
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            height: fit-content;
        }
        
        .search-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(201, 150, 26, 0.3);
        }
        
        .results-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .results-count {
            color: #666;
            font-size: 16px;
        }
        
        .view-toggle {
            display: flex;
            gap: 10px;
        }
        
        .view-btn {
            padding: 8px 12px;
            border: 1px solid #e5e5e5;
            background: white;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .view-btn.active {
            background: #c9961a;
            color: white;
            border-color: #c9961a;
        }
        
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 30px;
        }
        
        .product-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 16px rgba(0,0,0,0.08);
            transition: all 0.3s;
        }
        
        .product-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        
        .product-image {
            position: relative;
            height: 240px;
            overflow: hidden;
        }
        
        .product-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s;
        }
        
        .product-card:hover .product-image img {
            transform: scale(1.05);
        }
        
        .product-status {
            position: absolute;
            top: 15px;
            right: 15px;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
        }
        
        .status-active {
            background: #28a745;
            color: white;
        }
        
        .status-pending {
            background: #ffc107;
            color: #333;
        }
        
        .status-ended {
            background: #6c757d;
            color: white;
        }
        
        .product-info {
            padding: 25px;
        }
        
        .product-title {
            font-size: 18px;
            font-weight: 600;
            color: #1a1a1a;
            margin-bottom: 8px;
            line-height: 1.4;
        }
        
        .product-artist {
            color: #666;
            font-size: 14px;
            margin-bottom: 15px;
        }
        
        .product-prices {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .price-info {
            text-align: center;
        }
        
        .price-label {
            font-size: 12px;
            color: #999;
            margin-bottom: 5px;
        }
        
        .price-value {
            font-size: 16px;
            font-weight: 600;
            color: #1a1a1a;
        }
        
        .current-price {
            color: #c9961a;
            font-size: 18px;
        }
        
        .product-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 12px;
            color: #999;
            margin-bottom: 20px;
        }
        
        .product-actions {
            display: flex;
            gap: 10px;
        }
        
        .btn {
            padding: 10px 20px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            text-decoration: none;
            text-align: center;
            transition: all 0.3s;
            flex: 1;
        }
        
        .btn-primary {
            background: #c9961a;
            color: white;
            border: 1px solid #c9961a;
        }
        
        .btn-primary:hover {
            background: #b8851a;
        }
        
        .btn-outline {
            background: transparent;
            color: #c9961a;
            border: 1px solid #c9961a;
        }
        
        .btn-outline:hover {
            background: #c9961a;
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 80px 20px;
            color: #666;
        }
        
        .empty-state i {
            font-size: 48px;
            color: #ddd;
            margin-bottom: 20px;
        }
        
        @media (max-width: 768px) {
            .filter-row {
                grid-template-columns: 1fr;
                gap: 15px;
            }
            
            .results-header {
                flex-direction: column;
                gap: 15px;
                align-items: stretch;
            }
            
            .products-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }
    </style>
</head>
<body>
    <jsp:include page="/layout/header/luxury-header.jsp" />
    
    <!-- Page Header -->
    <section class="page-header">
        <div class="container">
            <h1>전체 상품 목록</h1>
            <p>M4 Auction의 모든 경매 상품을 한 눈에 확인하세요</p>
        </div>
    </section>
    
    <!-- Content -->
    <section class="content-wrapper">
        <div class="container">
            <!-- Filter Section -->
            <div class="filter-section">
                <form method="get" action="">
                    <div class="filter-row">
                        <div class="form-group">
                            <label for="keyword">검색어</label>
                            <input type="text" id="keyword" name="keyword" 
                                   placeholder="작품명, 작가명으로 검색" value="<%=searchKeyword%>">
                        </div>
                        <div class="form-group">
                            <label for="category">카테고리</label>
                            <select id="category" name="category">
                                <option value="">전체</option>
                                <option value="회화" <%="회화".equals(categoryFilter) ? "selected" : ""%>>회화</option>
                                <option value="조각" <%="조각".equals(categoryFilter) ? "selected" : ""%>>조각</option>
                                <option value="판화" <%="판화".equals(categoryFilter) ? "selected" : ""%>>판화</option>
                                <option value="사진" <%="사진".equals(categoryFilter) ? "selected" : ""%>>사진</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="status">상태</label>
                            <select id="status" name="status">
                                <option value="">전체</option>
                                <option value="A" <%="A".equals(statusFilter) ? "selected" : ""%>>진행중</option>
                                <option value="P" <%="P".equals(statusFilter) ? "selected" : ""%>>예정</option>
                                <option value="E" <%="E".equals(statusFilter) ? "selected" : ""%>>종료</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="sort">정렬</label>
                            <select id="sort" name="sort">
                                <option value="newest" <%="newest".equals(sortBy) ? "selected" : ""%>>최신순</option>
                                <option value="price_low" <%="price_low".equals(sortBy) ? "selected" : ""%>>낮은가격순</option>
                                <option value="price_high" <%="price_high".equals(sortBy) ? "selected" : ""%>>높은가격순</option>
                                <option value="ending" <%="ending".equals(sortBy) ? "selected" : ""%>>마감임박순</option>
                            </select>
                        </div>
                        <button type="submit" class="search-btn">
                            <i class="fas fa-search"></i> 검색
                        </button>
                    </div>
                </form>
            </div>
            
            <!-- Results Header -->
            <div class="results-header">
                <div class="results-count">
                    총 <strong><%=productList.size()%></strong>개의 상품이 등록되어 있습니다.
                </div>
                <div class="view-toggle">
                    <button class="view-btn active" onclick="toggleView('grid')">
                        <i class="fas fa-th"></i>
                    </button>
                    <button class="view-btn" onclick="toggleView('list')">
                        <i class="fas fa-list"></i>
                    </button>
                </div>
            </div>
            
            <!-- Products Grid -->
            <div class="products-grid" id="productsContainer">
                <% if (productList.isEmpty()) { %>
                    <div class="empty-state">
                        <i class="fas fa-palette"></i>
                        <h3>등록된 상품이 없습니다</h3>
                        <p>새로운 경매 상품이 등록되면 여기에 표시됩니다.</p>
                    </div>
                <% } else { %>
                    <% for (ProductDTO product : productList) { %>
                        <div class="product-card">
                            <div class="product-image">
                                <% if (product.getImageRenamedName() != null) { %>
                                    <img src="<%=ctx%>/resources/images/<%=product.getImageRenamedName()%>" 
                                         alt="<%=product.getProductName()%>" 
                                         onerror="this.src='<%=ctx%>/resources/images/no-image.jpg'">
                                <% } else { %>
                                    <img src="<%=ctx%>/resources/images/no-image.jpg" alt="No Image">
                                <% } %>
                                
                                <div class="product-status 
                                    <% if ("A".equals(product.getStatus())) { %>status-active
                                    <% } else if ("P".equals(product.getStatus())) { %>status-pending
                                    <% } else { %>status-ended<% } %>">
                                    <% if ("A".equals(product.getStatus())) { %>진행중
                                    <% } else if ("P".equals(product.getStatus())) { %>예정
                                    <% } else { %>종료<% } %>
                                </div>
                            </div>
                            
                            <div class="product-info">
                                <h3 class="product-title"><%=product.getProductName()%></h3>
                                <p class="product-artist"><%=product.getSellerId()%></p>
                                
                                <div class="product-prices">
                                    <div class="price-info">
                                        <div class="price-label">시작가</div>
                                        <div class="price-value"><%=df.format(product.getStartPrice())%>원</div>
                                    </div>
                                    <div class="price-info">
                                        <div class="price-label">현재가</div>
                                        <div class="price-value current-price"><%=df.format(product.getCurrentPrice())%>원</div>
                                    </div>
                                </div>
                                
                                <div class="product-meta">
                                    <span>상품 #<%=product.getProductId()%></span>
                                    <span><%=product.getStatus()%></span>
                                </div>
                                
                                <div class="product-actions">
                                    <a href="<%=ctx%>/product/productDetail.jsp?id=<%=product.getProductId()%>" 
                                       class="btn btn-primary">상세보기</a>
                                    <% if ("A".equals(product.getStatus()) && loginUser != null) { %>
                                        <a href="<%=ctx%>/auction/auction.jsp?id=<%=product.getProductId()%>" 
                                           class="btn btn-outline">입찰하기</a>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>
    </section>
    
    <jsp:include page="/layout/footer/luxury-footer.jsp" />
    
    <script>
        function toggleView(viewType) {
            const buttons = document.querySelectorAll('.view-btn');
            const container = document.getElementById('productsContainer');
            
            buttons.forEach(btn => btn.classList.remove('active'));
            event.target.closest('.view-btn').classList.add('active');
            
            if (viewType === 'list') {
                container.style.gridTemplateColumns = '1fr';
            } else {
                container.style.gridTemplateColumns = 'repeat(auto-fill, minmax(300px, 1fr))';
            }
        }
    </script>
</body>
</html>