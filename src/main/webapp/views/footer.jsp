<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.UserDAO, model.UserDTO" %>


<footer class="footer-v2">
  <div class="footer-main">
    
    <div class="footer-col">
      <h4 class="footer-logo-v2">M4 auction</h4>
      <p>세상의 모든 경매소식을 가장 빠르고 정확하게 전달하며, 사용자의 더 나은 내일을 위한 경매 소식을 제공합니다.</p>
      <ul class="contact-list">
        <li><i class="fas fa-map-marker-alt"></i> <span>서울특별시 관악구 남부순환로, 에그옐로우</span></li>
        <li><i class="fas fa-phone"></i> <span>대표전화: 02-***-****</span></li>
        <li><i class="fas fa-envelope"></i> <span>이메일: M4_auction@naver.com</span></li>
      </ul>
    </div>
    
    <div class="footer-col">
      <h4 class="footer-title-v2">주요 뉴스</h4>
      <ul class="footer-links-v2">
        <li><a href="${pageContext.request.contextPath}/news/economy/economyList.jsp">미술품</a></li>
        <li><a href="${pageContext.request.contextPath}/news/politics/politicsList.jsp">골동품</a></li>
        <li><a href="${pageContext.request.contextPath}/news/society/societyList.jsp">자동차</a></li>
        <li><a href="${pageContext.request.contextPath}/news/entertainment/entertainmentList.jsp">명품</a></li>
        <li><a href="${pageContext.request.contextPath}/news/sports/sportsList.jsp">부동산</a></li>
      </ul>
    </div>
    
    <div class="footer-col">
      <h4 class="footer-title-v2">auction 정보</h4>
      <ul class="footer-links-v2">
        <li><a href="<%= request.getContextPath() %>/company_intro.jsp">auction 소개</a></li>
        <li><a href="#">이용약관</a></li>
        <li><a href="#">개인정보처리방침</a></li>
        <li><a href="<%= request.getContextPath() %>/news/qna/qnaWrite.jsp">문의하기</a></li>
      </ul>
    </div>

  </div>

  <div class="footer-subscribe">
    <h4>최신 auction 뉴스를 가장 먼저 받아보세요</h4>
    <form class="subscribe-form">
      <input type="email" placeholder="이메일 주소를 입력하세요">
      <button type="submit">구독하기</button>
    </form>
  </div>
  
  <div class="footer-bottom-v2">
    <p>&copy; <%= java.time.Year.now().getValue() %> M4 auction. All Rights Reserved.</p>
    <div class="social-links-v2">
      <a href="#" aria-label="Facebook"><i class="fab fa-facebook-f"></i></a>
      <a href="#" aria-label="Instagram"><i class="fab fa-instagram"></i></a>
      <a href="#" aria-label="YouTube"><i class="fab fa-youtube"></i></a>
      <a href="#" aria-label="Twitter"><i class="fab fa-twitter"></i></a>
    </div>
  </div>
</footer>


<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" integrity="sha512-SnH5WK+bZxgPHs44uWIX+LLJAJ9/2PkPKZ5QiAj6Ta86w+fsb2TkcmfRyVX3pBnMFcV7oQPJkl9QevSCWr3W6A==" crossorigin="anonymous" referrerpolicy="no-referrer" />


