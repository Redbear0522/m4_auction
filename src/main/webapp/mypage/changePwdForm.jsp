<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.auction.vo.MemberDTO" %>
<%
    MemberDTO loginUser = (MemberDTO)session.getAttribute("loginUser");
    if(loginUser == null){
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Art Auction - 비밀번호 변경</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/layout.css">
<style>
    body { background-color: #1a1a1a; }
    .pwd-container {
        width: 500px;
        margin: 50px auto;
        padding: 40px;
        background-color: #2b2b2b;
        border-radius: 10px;
        color: #e0e0e0;
    }
    h1 {
        font-family: 'Playfair Display', serif;
        text-align: center;
        font-size: 36px;
        color: #d4af37;
        margin-bottom: 40px;
    }
    .form-group {
        margin-bottom: 20px;
    }
    .form-group label {
        display: block;
        margin-bottom: 8px;
        color: #ccc;
        font-weight: bold;
    }
    .form-group input {
        width: 100%;
        padding: 12px;
        background-color: #1a1a1a;
        border: 1px solid #555;
        color: #fff;
        border-radius: 5px;
        font-size: 16px;
    }
    .btn-group {
        display: flex;
        gap: 10px;
        margin-top: 30px;
    }
    .btn {
        flex: 1;
        padding: 15px;
        border: none;
        border-radius: 5px;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
    }
    .submit-btn {
        background-color: #d4af37;
        color: #1a1a1a;
    }
    .cancel-btn {
        background-color: #555;
        color: white;
    }
    .info-text {
        font-size: 14px;
        color: #aaa;
        margin-top: 20px;
        text-align: center;
    }
</style>
</head>
<body>
<jsp:include page="/layout/header/header.jsp" />

<div class="pwd-container">
    <h1>비밀번호 변경</h1>
    
    <form action="changePwdAction.jsp" method="post" onsubmit="return validatePwd();">
        <div class="form-group">
            <label for="currentPwd">현재 비밀번호</label>
            <input type="password" id="currentPwd" name="currentPwd" required>
        </div>
        
        <div class="form-group">
            <label for="newPwd">새 비밀번호</label>
            <input type="password" id="newPwd" name="newPwd" required>
        </div>
        
        <div class="form-group">
            <label for="newPwdCheck">새 비밀번호 확인</label>
            <input type="password" id="newPwdCheck" name="newPwdCheck" required>
        </div>
        
        <div class="btn-group">
            <button type="submit" class="btn submit-btn">변경하기</button>
            <button type="button" class="btn cancel-btn" onclick="history.back();">취소</button>
        </div>
    </form>
    
    <p class="info-text">
        * 비밀번호는 8자 이상 입력해주세요<br>
        * 영문, 숫자, 특수문자를 조합하면 더 안전합니다
    </p>
</div>

<script>
function validatePwd() {
    const newPwd = document.getElementById('newPwd').value;
    const newPwdCheck = document.getElementById('newPwdCheck').value;
    
    if(newPwd.length < 8) {
        alert('새 비밀번호는 8자 이상 입력해주세요.');
        return false;
    }
    
    if(newPwd !== newPwdCheck) {
        alert('새 비밀번호가 일치하지 않습니다.');
        document.getElementById('newPwd').value = '';
        document.getElementById('newPwdCheck').value = '';
        document.getElementById('newPwd').focus();
        return false;
    }
    
    return true;
}
</script>

</body>
</html>