<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Art Auction - 아이디/비밀번호 찾기</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/layout.css">
<style>
    body { background-color: #1a1a1a; }
    .find-container {
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
    .tab-buttons {
        display: flex;
        margin-bottom: 30px;
        border-bottom: 2px solid #444;
    }
    .tab-button {
        flex: 1;
        padding: 15px;
        background: none;
        border: none;
        color: #aaa;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.3s;
    }
    .tab-button.active {
        color: #d4af37;
        border-bottom: 3px solid #d4af37;
    }
    .tab-content {
        display: none;
    }
    .tab-content.active {
        display: block;
    }
    .form-group {
        margin-bottom: 20px;
    }
    .form-group label {
        display: block;
        margin-bottom: 8px;
        color: #ccc;
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
    .submit-btn {
        width: 100%;
        padding: 15px;
        background-color: #d4af37;
        color: #1a1a1a;
        border: none;
        border-radius: 5px;
        font-size: 18px;
        font-weight: bold;
        cursor: pointer;
        margin-top: 20px;
    }
    .submit-btn:hover {
        background-color: #e6c567;
    }
    .back-link {
        display: block;
        text-align: center;
        margin-top: 20px;
        color: #aaa;
    }
    .result-box {
        margin-top: 20px;
        padding: 20px;
        background-color: #1a1a1a;
        border-radius: 5px;
        text-align: center;
        display: none;
    }
    .result-box.success {
        border: 2px solid #28a745;
        color: #28a745;
    }
    .result-box.error {
        border: 2px solid #dc3545;
        color: #dc3545;
    }
</style>
</head>
<body>
<jsp:include page="/layout/header/header.jsp" />

<div class="find-container">
    <h1>아이디/비밀번호 찾기</h1>
    
    <div class="tab-buttons">
        <button class="tab-button active" onclick="showTab('findId')">아이디 찾기</button>
        <button class="tab-button" onclick="showTab('findPw')">비밀번호 찾기</button>
    </div>
    
    <!-- 아이디 찾기 -->
    <div id="findId" class="tab-content active">
        <form onsubmit="findId(event)">
            <div class="form-group">
                <label for="nameForId">이름</label>
                <input type="text" id="nameForId" required>
            </div>
            <div class="form-group">
                <label for="emailForId">이메일</label>
                <input type="email" id="emailForId" required>
            </div>
            <button type="submit" class="submit-btn">아이디 찾기</button>
        </form>
        <div id="idResult" class="result-box"></div>
    </div>
    
    <!-- 비밀번호 찾기 -->
    <div id="findPw" class="tab-content">
        <form onsubmit="findPw(event)">
            <div class="form-group">
                <label for="idForPw">아이디</label>
                <input type="text" id="idForPw" required>
            </div>
            <div class="form-group">
                <label for="nameForPw">이름</label>
                <input type="text" id="nameForPw" required>
            </div>
            <div class="form-group">
                <label for="emailForPw">이메일</label>
                <input type="email" id="emailForPw" required>
            </div>
            <button type="submit" class="submit-btn">비밀번호 재설정</button>
        </form>
        <div id="pwResult" class="result-box"></div>
    </div>
    
    <a href="loginForm.jsp" class="back-link">로그인 페이지로 돌아가기</a>
</div>

<script>
function showTab(tabName) {
    // 모든 탭 숨기기
    document.querySelectorAll('.tab-content').forEach(tab => {
        tab.classList.remove('active');
    });
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // 선택한 탭 보이기
    document.getElementById(tabName).classList.add('active');
    event.target.classList.add('active');
}

function findId(event) {
    event.preventDefault();
    
    const name = document.getElementById('nameForId').value;
    const email = document.getElementById('emailForId').value;
    
    // AJAX로 아이디 찾기
    const xhr = new XMLHttpRequest();
    xhr.open('POST', 'findIdAction.jsp', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    xhr.onreadystatechange = function() {
        if(xhr.readyState == 4 && xhr.status == 200) {
            const result = xhr.responseText.trim();
            const resultBox = document.getElementById('idResult');
            
            if(result !== 'N') {
                resultBox.className = 'result-box success';
                resultBox.innerHTML = '찾은 아이디: <strong>' + result + '</strong>';
            } else {
                resultBox.className = 'result-box error';
                resultBox.innerHTML = '일치하는 회원 정보를 찾을 수 없습니다.';
            }
            resultBox.style.display = 'block';
        }
    };
    
    xhr.send('name=' + encodeURIComponent(name) + '&email=' + encodeURIComponent(email));
}

function findPw(event) {
    event.preventDefault();
    
    const id = document.getElementById('idForPw').value;
    const name = document.getElementById('nameForPw').value;
    const email = document.getElementById('emailForPw').value;
    
    // AJAX로 비밀번호 찾기
    const xhr = new XMLHttpRequest();
    xhr.open('POST', 'findPwAction.jsp', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    
    xhr.onreadystatechange = function() {
        if(xhr.readyState == 4 && xhr.status == 200) {
            const result = xhr.responseText.trim();
            const resultBox = document.getElementById('pwResult');
            
            if(result === 'Y') {
                resultBox.className = 'result-box success';
                resultBox.innerHTML = '임시 비밀번호가 이메일로 발송되었습니다.<br>로그인 후 비밀번호를 변경해주세요.';
            } else {
                resultBox.className = 'result-box error';
                resultBox.innerHTML = '일치하는 회원 정보를 찾을 수 없습니다.';
            }
            resultBox.style.display = 'block';
        }
    };
    
    xhr.send('id=' + encodeURIComponent(id) + '&name=' + encodeURIComponent(name) + '&email=' + encodeURIComponent(email));
}
</script>

</body>
</html>