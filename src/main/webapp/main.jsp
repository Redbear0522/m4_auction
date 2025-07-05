<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String sid = (String) session.getAttribute("sid");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>메인 페이지 - M4 Auction</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- 통합 스타일 -->
  <link rel="stylesheet" href="<%=ctx%>/resources/css/auction-style.css">

  <!-- 외부 라이브러리 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" crossorigin="anonymous">
  <link rel="stylesheet" href="<%=ctx%>/views/style.css">
  
</head>

<!-- 로그인 여부에 따라 body 클래스 설정 -->
<body class="<%= (sid != null ? "logged-in" : "guest") %> d-flex flex-column min-vh-100">

  <!-- ✅ 헤더 포함 -->
  <jsp:include page="/views/header.jsp" />

  <!-- ✅ 메인 콘텐츠만 아래에서 새로 구성 -->
  <main class="flex-grow-1">
    <!-- 히어로 섹션 -->
    <section class="hero-banner text-white text-center position-relative"
             style="background: url('<%=ctx%>/resources/images/ocean_banner.jpg') center/cover no-repeat; height: 60vh;">
      <div class="overlay position-absolute top-0 start-0 w-100 h-100" style="background: rgba(0,0,0,0.5);"></div>
      <div class="position-relative d-flex justify-content-center align-items-center h-100 flex-column">
        <h1 class="display-4 fw-bold">M4 Auction에 오신 것을 환영합니다</h1>
        <p class="lead">세상의 모든 명품, 골동품, 클래식/슈퍼카를 경매로 즐겨보세요.</p>
        <a href="<%=ctx%>/exhibitions.jsp" class="btn btn-warning btn-lg mt-3">경매 둘러보기</a>
      </div>
    </section>

    <!-- 주요 항목 섹션 -->
    <section class="container py-5">
      <h2 class="text-center mb-5">카테고리별 추천 경매</h2>
      <div class="row g-4">
        <div class="col-md-4">
          <div class="card shadow-sm h-100">
            <img src="<%=ctx%>/resources/images/art.jpg" class="card-img-top" alt="미술품">
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">미술품</h5>
              <p class="card-text flex-grow-1">현대 미술부터 고전 회화까지 최고의 작품을 경매로 만나보세요.</p>
              <a href="<%=ctx%>/news/economy/economyList.jsp" class="btn btn-outline-primary mt-auto">자세히 보기</a>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="card shadow-sm h-100">
            <img src="<%=ctx%>/resources/images/car.jpg" class="card-img-top" alt="자동차">
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">클래식/슈퍼카</h5>
              <p class="card-text flex-grow-1">희소한 클래식카부터 최신 슈퍼카까지 경매 진행 중입니다.</p>
              <a href="<%=ctx%>/news/society/societyList.jsp" class="btn btn-outline-primary mt-auto">자세히 보기</a>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="card shadow-sm h-100">
            <img src="<%=ctx%>/resources/images/luxury.jpg" class="card-img-top" alt="명품">
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">명품</h5>
              <p class="card-text flex-grow-1">가방, 시계, 액세서리 등 럭셔리 아이템의 경매가 진행 중입니다.</p>
              <a href="<%=ctx%>/news/entertainment/entertainmentList.jsp" class="btn btn-outline-primary mt-auto">자세히 보기</a>
            </div>
          </div>
        </div>
      </div>
    </section>
    <section class="container py-5">
      <h2 class="text-center mb-5">카테고리별 추천 경매</h2>
      <div class="row g-4">
        <div class="col-md-4">
          <div class="card shadow-sm h-100">
            <img src="<%=ctx%>/resources/images/art.jpg" class="card-img-top" alt="미술품">
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">미술품</h5>
              <p class="card-text flex-grow-1">현대 미술부터 고전 회화까지 최고의 작품을 경매로 만나보세요.</p>
              <a href="<%=ctx%>/news/economy/economyList.jsp" class="btn btn-outline-primary mt-auto">자세히 보기</a>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="card shadow-sm h-100">
            <img src="<%=ctx%>/resources/images/car.jpg" class="card-img-top" alt="자동차">
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">자동차</h5>
              <p class="card-text flex-grow-1">희소한 클래식카부터 최신 슈퍼카까지 경매 진행 중입니다.</p>
              <a href="<%=ctx%>/news/society/societyList.jsp" class="btn btn-outline-primary mt-auto">자세히 보기</a>
            </div>
          </div>
        </div>

        <div class="col-md-4">
          <div class="card shadow-sm h-100">
            <img src="<%=ctx%>/resources/images/luxury.jpg" class="card-img-top" alt="명품">
            <div class="card-body d-flex flex-column">
              <h5 class="card-title">명품</h5>
              <p class="card-text flex-grow-1">가방, 시계, 액세서리 등 럭셔리 아이템의 경매가 진행 중입니다.</p>
              <a href="<%=ctx%>/news/entertainment/entertainmentList.jsp" class="btn btn-outline-primary mt-auto">자세히 보기</a>
            </div>
          </div>
        </div>
      </div>
    </section>
  </main>

  <!-- ✅ 푸터 포함 -->
  <jsp:include page="/views/footer.jsp" />

  <!-- 부트스트랩 JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
