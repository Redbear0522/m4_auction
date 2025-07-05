<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="com.auction.dao.MemberDAO,com.auction.vo.MemberDTO" %>
<%  
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
    String sid = (String) session.getAttribute("sid");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>로그인 - M4 Auction</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Poppins:wght@300;400;500;600;700&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    
    <link rel="stylesheet" href="<%=ctx%>/resources/css/luxury-global-style.css">
    
    <link rel="stylesheet" href="<%=ctx%>/resources/css/login-style.css">
    
</head>
<body class="login-page">
    <jsp:include page="<%=request.getContextPath() %>/layout/header/luxury-header.jsp" />
    
    <div class="login-container">
        <div class="login-wrapper">
            <div class="login-image">
                <div class="login-image-overlay">
                    <h2>Welcome Back</h2>
                    <p>세계적인 예술 작품과 함께하는 특별한 경험</p>
                </div>
            </div>
            
            <div class="login-form-wrapper">
                <div class="login-header">
                    <h3>Member Login</h3>
                    <p>M4 Auction에 오신 것을 환영합니다</p>
                </div>
                
                <form action="<%=ctx%>/member/loginAction.jsp" method="post">
                    <div class="form-group">
                        <label for="userid">아이디</label>
                        <input type="text" id="userid" name="userid" class="form-control" placeholder="아이디를 입력하세요" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="passwd">비밀번호</label>
                        <input type="password" id="passwd" name="passwd" class="form-control" placeholder="비밀번호를 입력하세요" required>
                    </div>
                    
                    <div class="form-options">
                        <label class="remember-me">
                            <input type="checkbox" name="remember">
                            <span>아이디 저장</span>
                        </label>
                        <a href="#" class="forgot-link">아이디/비밀번호 찾기</a>
                    </div>
                    
                    <button type="submit" class="login-btn">로그인</button>
                </form>
                
                <div class="divider">
                    <span>간편 로그인</span>
                </div>
                
                <div class="social-login">
                    <button class="social-btn">
                        <i class="fab fa-google"></i>
                        <span>Google</span>
                    </button>
                    <button class="social-btn">
                        <i class="fab fa-apple"></i>
                        <span>Apple</span>
                    </button>
                    <button class="social-btn">
                        <img src="https://developers.kakao.com/assets/img/about/logos/kakaolink/kakaolink_btn_small.png" alt="Kakao">
                        <span>Kakao</span>
                    </button>
                </div>
                
                <div class="signup-link">
                    아직 회원이 아니신가요?<a href="<%=ctx%>/views/register.jsp">회원가입</a>
                </div>
            </div>
        </div>
    </div>
    
    <jsp:include page="<%=request.getContextPath() %>/layout/footer/luxury-footer.jsp" />
</body>
</html>