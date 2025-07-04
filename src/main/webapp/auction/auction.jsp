<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat, java.text.DecimalFormat" %>
<%@ page import="java.util.List, java.util.Date" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%@ page import="com.auction.common.PageInfo" %>
<%@ page import="com.auction.vo.ProductDTO, com.auction.vo.ScheduleDTO" %>
<%@ page import="com.auction.dao.ProductDAO, com.auction.dao.ScheduleDAO" %>

<%
    // 파라미터
    String keyword  = request.getParameter("keyword");
    String category = request.getParameter("category");
    if (keyword  == null) keyword  = "";
    if (category == null) category = "all";

    // 페이징 설정
    int currentPage = 1, pageLimit = 5, boardLimit = 8, listCount;
    if (!keyword.isEmpty()) {
        listCount = new ProductDAO().searchProductCount(getConnection(), keyword);
    } else if (!"all".equals(category)) {
        listCount = new ProductDAO().selectProductCountByCategory(getConnection(), category);
    } else {
        listCount = new ProductDAO().selectProductCount(getConnection());
    }
    if (request.getParameter("page") != null) {
        currentPage = Integer.parseInt(request.getParameter("page"));
    }
    PageInfo pi = new PageInfo(listCount, currentPage, pageLimit, boardLimit);

    // DAO 호출
    Connection conn = getConnection();
    List<ProductDTO> productList;
    if (!keyword.isEmpty()) {
        productList = new ProductDAO().searchProductList(conn, keyword, pi);
    } else if (!"all".equals(category)) {
        productList = new ProductDAO().selectProductListByCategory(conn, category, pi);
    } else {
        productList = new ProductDAO().selectProductList(conn, pi);
    }
    List<ScheduleDTO> scheduleList = new ScheduleDAO().selectAllSchedules(conn);
    close(conn);

    // 포맷터
    SimpleDateFormat sdf  = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    SimpleDateFormat sdf2 = new SimpleDateFormat("MM/dd HH:mm");
    DecimalFormat df      = new DecimalFormat("###,###,###");
    Date now              = new Date();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>경매장</title>
    <style>
        body { background:#f4f4f4; margin:0; font-family:'Noto Sans KR',sans-serif; }
        .page-container { display:flex; max-width:1400px; margin:20px auto; gap:20px; }
        aside.sidebar { width:260px; background:#2b2b2b; padding:20px; border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.3); color:#fff; }
        .sidebar-title { margin:0 0 12px; padding-bottom:6px; border-bottom:2px solid #d4af37; font-size:1.2rem; }
        ul.category-list, ul.schedule-list { list-style:none; padding:0; margin:0; }
        ul.category-list li { margin-bottom:8px; }
        ul.category-list li a { display:block; padding:8px 12px; color:#ccc; border-radius:4px; transition:0.3s; }
        ul.category-list li a.active, ul.category-list li a:hover { background:rgba(212,175,55,0.15); color:#d4af37; font-weight:bold; }
        ul.schedule-list li { display:flex; justify-content:space-between; margin-bottom:18px; }
        span.status { font-weight:bold; padding:2px 6px; border-radius:4px; color:#fff; }
        .status.waiting { background:#4a90e2; }
        .status.ongoing { background:#7ed321; }
        .status.finished{ background:#d0021b; }
        .empty { text-align:center; color:#4a90e2; }
        .search-form { display:flex; margin-bottom:20px; }
        .search-form input { flex:1; border:1px solid #555; background:#333; color:#fff; padding:8px; border-radius:4px 0 0 4px; }
        .search-form button { background:#d4af37; border:none; color:#2b2b2b; padding:8px 12px; cursor:pointer; border-radius:0 4px 4px 0; }
        main { flex:1; background:#fff; padding:20px; border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.1); }
        .section-title { font-size:1.6rem; color:#333; margin-bottom:20px; }
        .product-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:20px; }
        .product-card { background:#fff; border-radius:8px; overflow:hidden; box-shadow:0 4px 12px rgba(0,0,0,0.1); transition:transform .2s; }
        .product-card:hover { transform:translateY(-5px); }
        .product-card img { width:100%; height:200px; object-fit:cover; display:block; }
        .product-info { padding:16px; }
        .product-info h3 { margin:0 0 8px; font-size:1.1rem; color:#333; }
        .artist { font-size:0.9rem; color:#666; margin-bottom:12px; }
        .price-label { font-size:0.8rem; color:#888; }
        .price { font-size:1.2rem; font-weight:700; color:#333; margin:2px 0 8px; }
        .timer { font-size:0.9rem; color:#d0021b; }
    </style>
</head>
<body>
<jsp:include page="/layout/header/header.jsp" />

<div class="page-container">
  <!-- 사이드바 -->
  <aside class="sidebar">
    <form action="auction.jsp" method="get" class="search-form">
      <input type="text" name="keyword" placeholder="작품/작가명 검색" value="<%=keyword%>">
      <button type="submit">&#128269;</button>
    </form>
    <h3 class="sidebar-title">Category</h3>
    <ul class="category-list">
      <li><a href="auction.jsp?category=all"      class="<%= category.equals("all")   ? "active":"" %>">전체보기</a></li>
      <li><a href="auction.jsp?category=서양화"   class="<%= category.equals("서양화") ? "active":"" %>">서양화</a></li>
      <li><a href="auction.jsp?category=동양화"   class="<%= category.equals("동양화") ? "active":"" %>">동양화</a></li>
      <li><a href="auction.jsp?category=조각"     class="<%= category.equals("조각")   ? "active":"" %>">조각</a></li>
      <li><a href="auction.jsp?category=판화"     class="<%= category.equals("판화")   ? "active":"" %>">판화</a></li>
      <li><a href="auction.jsp?category=사진"     class="<%= category.equals("사진")   ? "active":"" %>">사진</a></li>
      <li><a href="auction.jsp?category=고미술"   class="<%= category.equals("고미술") ? "active":"" %>">고미술</a></li>
    </ul>

    <h3 class="sidebar-title" style="margin-top:20px;">경매 일정</h3>
    <ul class="schedule-list">
      <%
        int count = 0;
        for (ScheduleDTO sched : scheduleList) {
          if (count++ >= 5) break;
          String cls, status;
          if (now.before(sched.getStartTime())) {
            status = "대기중"; cls = "waiting";
          } else if (now.before(sched.getEndTime())) {
            status = "진행중"; cls = "ongoing";
          } else {
            status = "종료";   cls = "finished";
          }
      %>
        <li>
          <span class="status <%=cls%>"><%=status%></span>
          <span><%=sdf2.format(sched.getStartTime())%> ~ <%=sdf2.format(sched.getEndTime())%></span>
        </li>
      <%
        }
        if (count == 0) {
      %>
        <li class="empty">등록된 일정 없음</li>
      <%
        }
      %>
    </ul>
  </aside>

  <!-- 메인 콘텐츠 -->
  <main>
    <h2 class="section-title">Now Bidding</h2>
    
     <!-- ★ 정렬 옵션 버튼 ★ -->
  <div class="sort-options">
    <div class="sort-options">
	  <select id="sortSelect">
	    <option value="">— 정렬 선택 —</option>
	    <option value="endTime-asc">마감일 ↑</option>
	    <option value="endTime-desc">마감일 ↓</option>
	    <option value="price-asc">현재가 ↑</option>
	    <option value="price-desc">현재가 ↓</option>
	  </select>
	</div>
  </div>
  
  
    <div class="product-grid">
      <%
        if (productList.isEmpty()) {
      %>
        <p>조회된 상품이 없습니다.</p>
      <%
        } else {
          for (ProductDTO p : productList) {
            boolean isActive   = "A".equals(p.getStatus());
            boolean notExpired = p.getEndTime() != null && now.before(p.getEndTime());
            if (!(isActive && notExpired)) continue;
      %>
        <div class="product-card">
          <a href="<%=request.getContextPath()%>/product/productDetail.jsp?productId=<%=p.getProductId()%>">
            <%
              String imgUrl = (p.getImageRenamedName() != null)
                ? request.getContextPath()+"/resources/product_images/"+p.getImageRenamedName()
                : "https://placehold.co/600x400/ddd/333?text="+URLEncoder.encode(p.getProductName(),"UTF-8");
            %>
            <img src="<%=imgUrl%>" alt="<%=p.getProductName()%>">
            <div class="product-info">
              <h3><%=p.getProductName()%></h3>
              <p class="artist"><%=p.getArtistName()%></p>
              <span class="price-label">현재가</span>
              <p class="price">₩ <%=df.format(p.getCurrentPrice()==0 ? p.getStartPrice() : p.getCurrentPrice())%></p>
              <div class="timer" data-endtime="<%=sdf.format(p.getEndTime())%>"></div>
            </div>
          </a>
        </div>
      <%
          }
        }
      %>
    </div>
  </main>
</div>

<script>
  document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.timer').forEach(timer => {
      const end = timer.dataset.endtime;
      if (!end) return;
      const target = new Date(end).getTime();
      const id = setInterval(() => {
        const diff = target - Date.now();
        if (diff <= 0) {
          clearInterval(id);
          timer.textContent = '경매 마감';
          return;
        }
        const d = Math.floor(diff/86400000),
              h = String(Math.floor((diff%86400000)/3600000)).padStart(2,'0'),
              m = String(Math.floor((diff%3600000)/60000)).padStart(2,'0'),
              s = String(Math.floor((diff%60000)/1000)).padStart(2,'0');
        timer.textContent = (d>0? d+'일 ':'') + h+':'+m+':'+s;
      }, 1000);
    });
  });
  document.getElementById('sortSelect').addEventListener('change', function() {
	    const val = this.value;
	    if (!val) return;          // “— 정렬 선택 —” 선택 시 무시
	    const [criteria, order] = val.split('-');
	    sortProducts(criteria, order);
	  });
  
  function sortProducts(criteria, order) {
	    const grid = document.querySelector('.product-grid');
	    // .product-card 요소만 골라서 배열로
	    const cards = Array.from(grid.querySelectorAll('.product-card'));

	    cards.sort((a, b) => {
	      let aVal, bVal;

	      if (criteria === 'endTime') {
	        aVal = new Date(a.querySelector('.timer').dataset.endtime).getTime();
	        bVal = new Date(b.querySelector('.timer').dataset.endtime).getTime();
	      } else if (criteria === 'price') {
	        // "₩ 1,234" 형태 -> 숫자만 파싱
	        const getPrice = card => {
	          const txt = card.querySelector('.price').textContent;
	          return parseInt(txt.replace(/[₩,\s]/g, '')) || 0;
	        };
	        aVal = getPrice(a);
	        bVal = getPrice(b);
	      }

	      return (order === 'asc') ? (aVal - bVal) : (bVal - aVal);
	    });

	    // 정렬된 순서로 DOM 다시 배치
	    cards.forEach(card => grid.appendChild(card));
	  }
</script>
</body>
</html>
