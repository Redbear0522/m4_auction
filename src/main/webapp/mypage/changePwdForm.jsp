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
<title>비밀번호 변경 - M4 Auction</title>

<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=Poppins:wght@300;400;500;600;700&family=Noto+Sans+KR:wght@300;400;500;700;900&display=swap" rel="stylesheet">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/luxury-global-style.css">

<style>
    /* 헤더 겹침 해결 */
    body {
        padding-top: 120px !important;
        background: #f8f8f8;
        font-family: 'Noto Sans KR', sans-serif;
    }
    
    .pwd-container {
        max-width: 600px;
        margin: 50px auto;
        background: white;
        padding: 60px;
        box-shadow: 0 0 20px rgba(0,0,0,0.05);
    }
    
    h1 {
        font-family: 'Playfair Display', serif;
        text-align: center;
        font-size: 36px;
        color: #1a1a1a;
        margin-bottom: 50px;
    }
    
    .form-group {
        margin-bottom: 30px;
    }
    
    .form-group label {
        display: block;
        margin-bottom: 10px;
        color: #333;
        font-weight: 600;
        font-size: 14px;
        letter-spacing: 0.5px;
    }
    
    .form-group input {
        width: 100%;
        padding: 15px;
        background-color: #fafafa;
        border: 1px solid #e5e5e5;
        color: #333;
        font-size: 16px;
        transition: all 0.3s;
    }
    
    .form-group input:focus {
        outline: none;
        border-color: #c9961a;
        background: white;
    }
    
    .btn-group {
        display: flex;
        gap: 10px;
        margin-top: 50px;
    }
    
    .btn {
        flex: 1;
        padding: 18px;
        border: none;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        transition: all 0.3s;
    }
    
    .submit-btn {
        background-color: #1a1a1a;
        color: white;
    }
    
    .submit-btn:hover {
        background-color: #c9961a;
    }
    
    .cancel-btn {
        background-color: white;
        color: #1a1a1a;
        border: 2px solid #e5e5e5;
    }
    
    .cancel-btn:hover {
        border-color: #1a1a1a;
    }
    
    .info-box {
        background: #faf8f4;
        border-left: 4px solid #c9961a;
        padding: 20px;
        margin-top: 30px;
    }
    
    .info-box h4 {
        font-size: 16px;
        color: #1a1a1a;
        margin-bottom: 10px;
        font-weight: 600;
    }
    
    .info-box ul {
        list-style: none;
        padding: 0;
    }
    
    .info-box li {
        font-size: 14px;
        color: #666;
        margin-bottom: 8px;
        padding-left: 20px;
        position: relative;
    }
    
    .info-box li:before {
        content: '•';
        color: #c9961a;
        position: absolute;
        left: 0;
    }
    
    /* 비밀번호 강도 표시 */
    .password-strength {
        margin-top: 10px;
        height: 5px;
        background: #f0f0f0;
        border-radius: 3px;
        overflow: hidden;
    }
    
    .strength-bar {
        height: 100%;
        width: 0;
        transition: all 0.3s;
        border-radius: 3px;
    }
    
    .strength-weak { background: #e74c3c; width: 33%; }
    .strength-medium { background: #f39c12; width: 66%; }
    .strength-strong { background: #27ae60; width: 100%; }
    
    .strength-text {
        font-size: 12px;
        margin-top: 5px;
        color: #999;
    }
</style>
</head>
<body>
<jsp:include page="/layout/header/luxury-header.jsp" />

<div class="pwd-container">
    <h1>비밀번호 변경</h1>
    
    <form action="changePwdAction.jsp" method="post" onsubmit="return validatePwd();">
        <div class="form-group">
            <label for="currentPwd">현재 비밀번호</label>
            <input type="password" id="currentPwd" name="currentPwd" required>
        </div>
        
        <div class="form-group">
            <label for="newPwd">새 비밀번호</label>
            <input type="password" id="newPwd" name="newPwd" required onkeyup="checkPasswordStrength()">
            <div class="password-strength">
                <div class="strength-bar" id="strengthBar"></div>
            </div>
            <p class="strength-text" id="strengthText"></p>
        </div>
        
        <div class="form-group">
            <label for="newPwdCheck">새 비밀번호 확인</label>
            <input type="password" id="newPwdCheck" name="newPwdCheck" required>
        </div>
        
        <div class="info-box">
            <h4>안전한 비밀번호 만들기</h4>
            <ul>
                <li>최소 8자 이상 입력해주세요</li>
                <li>영문 대/소문자를 혼합하여 사용하세요</li>
                <li>숫자와 특수문자를 포함하세요</li>
                <li>개인정보와 관련된 단어는 피하세요</li>
            </ul>
        </div>
        
        <div class="btn-group">
            <button type="submit" class="btn submit-btn">변경하기</button>
            <button type="button" class="btn cancel-btn" onclick="location.href='myPage.jsp'">취소</button>
        </div>
    </form>
</div>

<jsp:include page="/layout/footer/luxury-footer.jsp" />

<script>
function checkPasswordStrength() {
    const password = document.getElementById('newPwd').value;
    const strengthBar = document.getElementById('strengthBar');
    const strengthText = document.getElementById('strengthText');
    
    let strength = 0;
    
    // 길이 체크
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    
    // 대소문자 체크
    if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
    
    // 숫자 체크
    if (/\d/.test(password)) strength++;
    
    // 특수문자 체크
    if (/[!@#$%^&*(),.?":{}|<>]/.test(password)) strength++;
    
    // 강도에 따른 표시
    strengthBar.className = 'strength-bar';
    if (strength <= 2) {
        strengthBar.classList.add('strength-weak');
        strengthText.textContent = '약함';
        strengthText.style.color = '#e74c3c';
    } else if (strength <= 4) {
        strengthBar.classList.add('strength-medium');
        strengthText.textContent = '보통';
        strengthText.style.color = '#f39c12';
    } else {
        strengthBar.classList.add('strength-strong');
        strengthText.textContent = '강함';
        strengthText.style.color = '#27ae60';
    }
}

function validatePwd() {
    const currentPwd = document.getElementById('currentPwd').value;
    const newPwd = document.getElementById('newPwd').value;
    const newPwdCheck = document.getElementById('newPwdCheck').value;
    
    if(newPwd.length < 8) {
        alert('새 비밀번호는 8자 이상 입력해주세요.');
        return false;
    }
    
    if(currentPwd === newPwd) {
        alert('현재 비밀번호와 새 비밀번호가 동일합니다.');
        return false;
    }
    
    if(newPwd !== newPwdCheck) {
        alert('새 비밀번호가 일치하지 않습니다.');
        document.getElementById('newPwd').value = '';
        document.getElementById('newPwdCheck').value = '';
        document.getElementById('newPwd').focus();
        return false;
    }
    
    return confirm('비밀번호를 변경하시겠습니까?');
}
</script>

</body>
</html>