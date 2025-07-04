<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.UserDAO, model.UserDTO" %>
<%
    // 세션 속성은 EL로도 접근 가능하므로, 스크립틀릿은 간단하게 유지합니다.
    String sid = (String) session.getAttribute("sid");
%>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Gowun+Dodum&family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

<%-- 모든 페이지를 감싸는 컨테이너 시작 --%>
<div class="page-container">

    <header class="new-site-header">
        <div class="header-content">
            
            <div class="logo-area">
                <a href="<%=request.getContextPath()%>/main.jsp">M4 auction</a>
            </div>

            <nav class="main-navigation">
                <ul>
                    <li><a href="${pageContext.request.contextPath}/company_intro.jsp">auction 소개</a></li>
                    <li><a href="${pageContext.request.contextPath}/news/economy/economyList.jsp">미술품</a></li>
                    <li><a href="${pageContext.request.contextPath}/news/politics/politicsList.jsp">골동품</a></li>
                    <li><a href="${pageContext.request.contextPath}/news/society/societyList.jsp">자동차</a></li>
                    <li><a href="${pageContext.request.contextPath}/news/entertainment/entertainmentList.jsp">명품</a></li>
                    <li><a href="${pageContext.request.contextPath}/news/sports/sportsList.jsp">부동산</a></li>
                    <li><a href="${pageContext.request.contextPath}/news/qna/qnaList.jsp">건의 사항</a></li>
                    <li><a href="${pageContext.request.contextPath}/news/qna/qnaList.jsp">사이트맵</a></li>
                </ul>
            </nav>

            <div class="header-actions">
                <div class="search-container">
                    <form action="#">
                        <input type="text" placeholder="검색" name="query" class="search-input">
                        <button type="submit" class="search-button">
                            <i class="material-icons">search</i>
                        </button>
                    </form>
                </div>

                <div class="user-menu-area">
                    <% if (sid != null) { %>
                        <div class="user-profile-menu">
                            <button class="profile-trigger">
                                <i class="material-icons">person</i>
                                <span><%= sid %>님</span>
                                <i class="material-icons dropdown-icon">arrow_drop_down</i>
                            </button>
                            <div class="dropdown-content">
                                <a href="${pageContext.request.contextPath}/member/info.jsp">마이페이지</a>
                                <a href="${pageContext.request.contextPath}/member/logout.jsp">로그아웃</a>
                            </div>
                        </div>
                    <% } else { %>
                        <div class="guest-menu">
                            <a href="${pageContext.request.contextPath}/member/login.jsp" class="btn-login">
                                <i class="material-icons">login</i>
                                <span>로그인</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/views/register.jsp" class="btn-join">회원가입</a>
                        </div>
                    <% } %>
                </div>
            </div>
        </div>
    </header>
</div>