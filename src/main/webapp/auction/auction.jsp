<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%@ page import="com.auction.common.PageInfo" %>
<%-- MemberDTO는 사용되지 않으므로 import 제거 --%>
<%-- <%@ page import="com.auction.vo.MemberDTO" %> --%>
<%@ page import="com.auction.vo.ProductDTO" %>
<%@ page import="com.auction.vo.ScheduleDTO" %>
<%@ page import="com.auction.dao.ProductDAO" %>
<%@ page import="com.auction.dao.ScheduleDAO" %>

<%
    // 검색 키워드와 카테고리 초기화
    String keyword = request.getParameter("keyword");
    String category = request.getParameter("category");
    if (keyword == null)  keyword="";
    if (category == null) category="all";

    // 페이징 관련 초기화
    int listCount;
    int currentPage = 1;
    int pageLimit   = 5;
    int boardLimit  = 8;

    // DAO 호출
    Connection conn = getConnection();
    ProductDAO pDao   = new ProductDAO();
    ScheduleDAO sDAO  = new ScheduleDAO();

    if (!keyword.isEmpty()) listCount = pDao.searchProductCount(conn, keyword);
    else if (!"all".equals(category)) listCount = pDao.selectProductCountByCategory(conn, category);
    else listCount = pDao.selectProductCount(conn);

    if (request.getParameter("page") != null) {
        currentPage = Integer.parseInt(request.getParameter("page"));
    }
    PageInfo pi = new PageInfo(listCount, currentPage, pageLimit, boardLimit);

    List<ProductDTO> productList;
    if (!keyword.isEmpty()) productList = pDao.searchProductList(conn, keyword, pi);
    else if (!"all".equals(category)) productList = pDao.selectProductListByCategory(conn, category, pi);
    else productList = pDao.selectProductList(conn, pi);

    List<ScheduleDTO> scheduleList = sDAO.selectAllSchedules(conn);
    close(conn);
    
    // sdf 변수 선언이 다시 필요하므로 복구
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    SimpleDateFormat sdf2 = new SimpleDateFormat("MM/dd HH:mm");
    DecimalFormat df     = new DecimalFormat("###,###,###");
    java.util.Date now   = new java.util.Date();
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title> 경매장 </title>
    <style>
      /* (스타일 코드는 변경사항 없음) */
      body { background-color: #f4f4f4; margin:0; font-family:'Noto Sans KR',sans-serif; }
      .page-container { display:flex; max-width:1400px; margin:20px auto; gap:20px; }
      aside.sidebar { width:260px; background:#2b2b2b; padding:20px; border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.3); flex-shrink:0; color:#fff; }
      aside.sidebar h3.sidebar-title { margin:0 0 12px; padding-bottom:6px; border-bottom:2px solid #d4af37; font-size:1.2rem; }
      ul.category-list, ul.schedule-list { list-style:none; margin:0; padding:0; }
      ul.category-list li { margin-bottom:8px; }
      ul.category-list li a { display:block; padding:8px 12px; color:#ccc; border-radius:4px; transition:0.3s; }
      ul.category-list li a.active, ul.category-list li a:hover { background:rgba(212,175,55,0.15); color:#d4af37; font-weight:bold; }
      ul.schedule-list li { margin-bottom:18px; display:flex; justify-content:space-between; align-items: center; }
      span.status { font-weight:bold; padding:2px 6px; border-radius:4px; color: #fff; }
      .status.waiting { background:#4a90e2; }
      .status.ongoing { background:#7ed321; }
      .status.finished{ background:#d0021b; }
      ul.schedule-list li.empty { text-align:center; color:#4a90e2; }
      .search-form { display: flex; margin-bottom: 20px; }
      .search-form input { flex: 1; border: 1px solid #555; background: #333; color: #fff; padding: 8px; border-radius: 4px 0 0 4px; }
      .search-form button { background: #d4af37; border: none; color: #2b2b2b; padding: 8px 12px; cursor: pointer; border-radius: 0 4px 4px 0; }

      main.main-container { flex:1; background:#fff; padding:20px; border-radius:8px; box-shadow:0 4px 12px rgba(0,0,0,0.1); }
      .section-title { margin:0 0 20px; font-size:1.6rem; color:#333; }
      .product-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:20px; }
      .product-card a { text-decoration: none; color: inherit; }
      .product-card { background:#fff; border-radius:8px; overflow:hidden; box-shadow:0 4px 12px rgba(0,0,0,0.1); transition:transform .2s; }
      .product-card:hover { transform:translateY(-5px); }
      .product-card img { width:100%; height:200px; object-fit:cover; display: block; }
      .product-info { padding:16px; }
      .product-info h3 { margin:0 0 8px; font-size:1.1rem; color:#333; }
      .product-info .artist { margin:0 0 12px; font-size:0.9rem; color:#666; }
      .price-label { font-size: 0.8rem; color: #888; }
      .product-info .price { font-size:1.2rem; font-weight:700; color:#333; margin: 2px 0 8px; }
      .timer { font-size: 0.9rem; color: #d0021b; }
    </style>
</head>
<body>
<jsp:include page="/layout/header/header.jsp" />
<div class="page-container">
  <aside class="sidebar">
          <form action="auction.jsp" method="get" class="search-form">
            <input type="text" name="keyword" placeholder="작품/작가명 검색" value="<%= keyword %>">
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

        String status;
        String cls; // CSS 클래스 적용을 위한 변수
        if (now.before(sched.getStartTime())) {
            status = "대기중";
            cls = "waiting";
        } else if (!now.before(sched.getStartTime()) && !now.after(sched.getEndTime())) {
            status = "진행중";
            cls = "ongoing";
        } else {
            status = "종료";
            cls = "finished";
        }
%>
      <%-- status에 맞는 CSS 클래스(cls)를 적용하여 색상이 표시되도록 수정 --%>
      <li><span class="status <%=cls%>"><%=status%></span>
          <span><%=sdf2.format(sched.getStartTime())%> ~ <%=sdf2.format(sched.getEndTime())%></span></li>
    <%
      }
      if(count==0){
    %>
      <li class="empty">등록된 일정 없음</li>
    <%
      }
    %>
    </ul>
  </aside>

  <main class="main-container">
  <h2 class="section-title">Now Bidding</h2>
  <div class="product-grid">
    <%-- 상품 리스트가 비어 있으면 메시지 출력 --%>
    <% if (productList.isEmpty()) { %>
      <p>조회된 상품이 없습니다.</p>
    <% } else { %>
      <%-- 리스트를 순회하면서 STATUS='A' 이고 아직 종료되지 않은 상품만 렌더링 --%>
      <% for (ProductDTO p : productList) { 
           if (!"A".equals(p.getStatus()))       continue;
           if (p.getEndTime().before(now))       continue;
      %>
        <div class="product-card">
          <a href="<%=request.getContextPath()%>/product/productDetail.jsp?productId=<%=p.getProductId()%>">
            <% boolean hasImg = p.getImageRenamedName() != null; %>
            <img src="<%= hasImg 
                        ? request.getContextPath()+"/resources/product_images/"+p.getImageRenamedName()
                        : "https://placehold.co/600x400/ddd/333?text="+URLEncoder.encode(p.getProductName(),"UTF-8")
                     %>"
                 alt="<%=p.getProductName()%>">
            <div class="product-info">
              <h3><%=p.getProductName()%></h3>
              <p class="artist"><%=p.getArtistName()%></p>
              <span class="price-label">현재가</span>
              <p class="price">₩ <%= df.format(p.getCurrentPrice() == 0 ? p.getStartPrice() : p.getCurrentPrice()) %></p>
              <div class="timer" data-endtime="<%= sdf.format(p.getEndTime()) %>"></div>
            </div>
          </a>
        </div>
      <% } %>
    <% } %>
  </div>
</main>
</div>
</body>
<script>
document.addEventListener('DOMContentLoaded', function() {
  const timers = document.querySelectorAll('.timer');
  timers.forEach(timer => {
    const endTimeString = timer.dataset.endtime; // 여기에 JSP가 찍어낸 "2025-07-04T15:00:00" 같은 문자열이 담겨야 합니다
    if (!endTimeString) return;                 // 비어 있다면 건너뛰고
    const endTime = new Date(endTimeString).getTime();
    const interval = setInterval(() => {
      const now = Date.now();
      const diff = endTime - now;
      if (diff <= 0) {
        clearInterval(interval);
        timer.textContent = '경매 마감';
        return;
      }
      const d = Math.floor(diff / 86400000);
      const h = String(Math.floor((diff % 86400000) / 3600000)).padStart(2,'0');
      const m = String(Math.floor((diff % 3600000) / 60000)).padStart(2,'0');
      const s = String(Math.floor((diff % 60000) / 1000)).padStart(2,'0');
      timer.textContent = (d>0? d+'일 ':'') + h+':'+m+':'+s;
    }, 1000);
  });
});
</script>
</html>