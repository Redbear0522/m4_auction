<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.UserDAO, model.UserDTO" %>
<%@ include file="/views/header.jsp" %> <%-- 헤더 공통 부분 분리 시 --%>

<%  
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 - M4 auction</title>
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background-color: #f7f8fa;
            margin: 0;
            padding: 0;
        }

        .login-container {
            max-width: 400px;
            margin: 80px auto;
            background-color: #ffffff;
            padding: 30px 40px;
            border-radius: 12px;
            box-shadow: 0 8px 16px rgba(0,0,0,0.1);
        }

        .login-container h2 {
            text-align: center;
            margin-bottom: 30px;
            font-weight: 600;
            color: #333;
        }

        .login-container input[type="text"],
        .login-container input[type="password"] {
            width: 100%;
            padding: 12px 15px;
            margin: 10px 0 20px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 15px;
        }

        .login-container button {
            width: 100%;
            background-color: #4A90E2;
            color: white;
            padding: 12px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
        }

        .login-container button:hover {
            background-color: #357ABD;
        }

        .login-container .link-group {
            margin-top: 20px;
            text-align: center;
        }

        .login-container .link-group a {
            color: #4A90E2;
            text-decoration: none;
            margin: 0 8px;
        }

        .login-container .link-group a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<link rel="stylesheet" href="<%=ctx%>/views/style.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/views/style.css">
<body>

<div class="login-container">
    <h2>로그인</h2>
    <form action="<%=request.getContextPath()%>/member/loginPro.jsp" method="post">
        <input type="text" name="userid" placeholder="아이디" required>
        <input type="password" name="passwd" placeholder="비밀번호" required>
        <button type="submit">로그인</button>
    </form>

    <div class="link-group">
        <a href="<%=request.getContextPath()%>/views/register.jsp">회원가입</a> |
        <a href="#">아이디/비밀번호 찾기</a>
    </div>
</div>

<%@ include file="/views/footer.jsp" %> <%-- 푸터 공통 부분 분리 시 --%>
</body>
</html>
