<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>M4 Auction - VIP 회원가입</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;700&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">

<!-- ⭐ CSS 변경 -->
<link rel="stylesheet" href="<%=request.getContextPath()%>/resources/css/luxury-global-style.css">
<style>
    body { 
        margin: 0; 
        background-color: #f8f8f8; 
        color: #333; 
        font-family: 'Noto Sans KR', sans-serif; 
    }
    .container {
        width: 700px;
        margin: 50px auto;
        padding: 60px;
        background-color: #fff;
        box-shadow: 0 0 20px rgba(0,0,0,0.1);
    }
    h1 {
        font-family: 'Playfair Display', serif;
        text-align: center;
        font-size: 36px;
        color: #1a1a1a;
        margin-bottom: 50px;
    }
    .form-group {
        margin-bottom: 25px;
    }
    .form-group label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        margin-bottom: 8px;
        color: #333;
        letter-spacing: 0.5px;
    }
    .form-group input[type="text"],
    .form-group input[type="password"],
    .form-group input[type="email"],
    .form-group input[type="tel"],
    .form-group select,
    .form-group textarea {
        width: 100%;
        padding: 15px;
        font-size: 16px;
        border: 1px solid #e5e5e5;
        border-radius: 0;
        box-sizing: border-box;
        transition: all 0.3s;
        font-family: 'Noto Sans KR', sans-serif;
    }
    .form-group input:focus,
    .form-group select:focus,
    .form-group textarea:focus {
        outline: none;
        border-color: #c9961a;
    }
    .input-with-button {
        display: flex;
        gap: 10px;
    }
    .input-with-button input {
        flex-grow: 1;
    }
    .input-with-button button {
        padding: 0 30px;
        border: 2px solid #1a1a1a;
        background: #1a1a1a;
        color: white;
        cursor: pointer;
        white-space: nowrap;
        transition: all 0.3s;
        font-weight: 600;
        letter-spacing: 0.5px;
    }
    .input-with-button button:hover {
        background: #c9961a;
        border-color: #c9961a;
    }
    .gender-group label {
        margin-right: 30px;
        font-weight: normal;
    }
    .submit-btn {
        display: block;
        width: 100%;
        padding: 18px;
        font-size: 18px;
        font-weight: 600;
        color: #fff;
        background-color: #1a1a1a;
        border: none;
        cursor: pointer;
        transition: all 0.3s;
        margin-top: 50px;
        letter-spacing: 1px;
        text-transform: uppercase;
    }
    .submit-btn:hover {
        background-color: #c9961a;
    }
    /* VIP 섹션 스타일 */
    .vip-section {
        background-color: #faf8f4;
        border: 2px solid #c9961a;
        padding: 30px;
        border-radius: 0;
        margin-top: 40px;
        position: relative;
    }
    .vip-section::before {
        content: 'VIP';
        position: absolute;
        top: -15px;
        left: 30px;
        background: #c9961a;
        color: white;
        padding: 5px 20px;
        font-weight: 700;
        letter-spacing: 2px;
    }
    .vip-section h3 {
        color: #1a1a1a;
        margin-bottom: 25px;
        font-family: 'Playfair Display', serif;
        font-size: 24px;
    }
    button[onclick="execDaumPostcode()"] {
        padding: 15px 30px;
        background: #1a1a1a;
        color: white;
        border: none;
        cursor: pointer;
        font-weight: 600;
        transition: all 0.3s;
    }
    button[onclick="execDaumPostcode()"]:hover {
        background: #c9961a;
    }
</style>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
</head>
<body>
<!-- ⭐ 헤더 변경 -->
<jsp:include page="/layout/header/luxury-header.jsp" />

    <div class="container">
        <h1>VIP 회원가입</h1>
        
        <form action="enrollAction_detail.jsp" method="post" onsubmit="return validateForm();">
        <input type="hidden" id="memberType" name="memberType" value="<%= request.getParameter("memberType") %>">
            
            <!-- 기본 정보 (일반 회원과 동일) -->
            <div class="form-group">
                <label for="userId">아이디 *</label>
                <div class="input-with-button">
                    <input type="text" id="userId" name="userId" required>
                    <button type="button" onclick="checkId()">중복확인</button>
                </div>
            </div>
            
            <div class="form-group">
                <label for="userPwd">비밀번호 *</label>
                <input type="password" id="userPwd" name="userPwd" required>
            </div>
            
            <div class="form-group">
                <label for="userPwdCheck">비밀번호 확인 *</label>
                <input type="password" id="userPwdCheck" required>
            </div>
            
            <div class="form-group">
                <label for="userName">이름 *</label>
                <input type="text" id="userName" name="userName" required>
            </div>
            
            <div class="form-group">
                <label for="birthdate">생년월일 *</label>
                <input type="text" id="birthdate" name="birthdate" placeholder="8자리 숫자로 입력 (예: 19920508)" maxlength="8" required>
            </div>
            
            <div class="form-group gender-group">
                <label>성별 *</label>
                <label><input type="radio" id="gender_m" name="gender" value="M" checked> 남자</label>
                <label><input type="radio" id="gender_f" name="gender" value="F"> 여자</label>
            </div>
            
            <div class="form-group">
                <label for="email">이메일 *</label>
                <input type="email" id="email" name="email" required>
            </div>
            
            <div class="form-group">
                <label for="mobileCarrier">통신사</label>
                <select id="mobileCarrier" name="mobileCarrier">
                    <option value="SKT">SKT</option>
                    <option value="KT">KT</option>
                    <option value="LG U+">LG U+</option>
                    <option value="SKT 알뜰폰">SKT 알뜰폰</option>
                    <option value="KT 알뜰폰">KT 알뜰폰</option>
                    <option value="LG U+ 알뜰폰">LG U+ 알뜰폰</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="tel">휴대전화 *</label>
                <input type="tel" id="tel" name="tel" placeholder="'-' 없이 숫자만 입력" required>
            </div>
            
            <!-- 주소 -->
            <div class="form-group">
                <label>주소 *</label>
                <div class="input-with-button" style="margin-bottom: 10px;">
                    <input type="text" id="zip" name="zip" placeholder="우편번호" readonly required>
                    <button type="button" onclick="execDaumPostcode()">주소 검색</button>
                </div>
                <input type="text" id="addr1" name="addr1" placeholder="기본 주소" readonly required style="margin-bottom: 10px;">
                <input type="text" id="addr2" name="addr2" placeholder="상세 주소 입력" required maxlength="50">
            </div>
            
            <!-- ⭐ VIP 전용 섹션 -->
            <div class="vip-section">
                <h3>VIP 회원 전용 정보</h3>
                
                <div class="form-group">
                    <label for="preferredCategory">관심 작품 분야</label>
                    <select id="preferredCategory" name="preferredCategory">
                        <option value="painting">회화</option>
                        <option value="sculpture">조각</option>
                        <option value="photography">사진</option>
                        <option value="jewelry">보석/시계</option>
                        <option value="antique">골동품</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="annualBudget">연간 구매 예산</label>
                    <select id="annualBudget" name="annualBudget">
                        <option value="10000000">1천만원 이하</option>
                        <option value="50000000">5천만원 이하</option>
                        <option value="100000000">1억원 이하</option>
                        <option value="over">1억원 이상</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label for="vipNote">특별 요청사항</label>
                    <textarea id="vipNote" name="vipNote" 
                              style="height: 100px; resize: none;"
                              placeholder="VIP 서비스에 대한 특별한 요청사항을 입력해주세요."></textarea>
                </div>
            </div>
            
            <button type="submit" class="submit-btn">VIP 가입하기</button>
        </form>
    </div>

<!-- ⭐ 푸터 추가 -->
<jsp:include page="/layout/footer/luxury-footer.jsp" />

    <script>
        // 중복확인 했는지 체크하는 변수
        var isIdChecked = false;
        
        // 아이디 중복확인 함수
        function checkId(){
            const userId = document.getElementById('userId').value;
            
            if(userId.length < 4){
                alert('아이디는 4자 이상 입력해주세요.');
                return;
            }
            
            // AJAX로 중복 확인
            const xhr = new XMLHttpRequest();
            xhr.open('GET', 'checkId.jsp?userId=' + userId, true);
            
            xhr.onreadystatechange = function() {
                if(xhr.readyState == 4 && xhr.status == 200) {
                    if(xhr.responseText.trim() === 'Y') {
                        alert('사용 가능한 아이디입니다!');
                        isIdChecked = true;
                    } else {
                        alert('이미 사용중인 아이디입니다.');
                        isIdChecked = false;
                        document.getElementById('userId').value = '';
                        document.getElementById('userId').focus();
                    }
                }
            };
            
            xhr.send();
        }
        
        // 아이디 입력칸이 바뀌면 다시 체크하도록
        document.getElementById('userId').addEventListener('change', function() {
            isIdChecked = false;
        });

        // 폼 제출 전 유효성 검사
        function validateForm(){
            // 아이디 중복확인 했는지 체크
            if(!isIdChecked) {
                alert('아이디 중복확인을 해주세요!');
                return false;
            }
            
            const pwd = document.getElementById('userPwd').value;
            const pwdCheck = document.getElementById('userPwdCheck').value;

            if(pwd !== pwdCheck){
                alert('비밀번호가 일치하지 않습니다.');
                document.getElementById('userPwd').value = '';
                document.getElementById('userPwdCheck').value = '';
                document.getElementById('userPwd').focus();
                return false;
            }
            
            // 생년월일이 8자리 숫자인지 확인
            const birthdate = document.getElementById('birthdate').value;
            if(birthdate.length !== 8 || isNaN(birthdate)){
                alert('생년월일을 8자리 숫자로 정확히 입력해주세요.');
                return false;
            }

            return true;
        }
        
        // 다음 주소검색
        function execDaumPostcode() {
            new daum.Postcode({
                oncomplete: function(data) {
                    document.getElementById('zip').value = data.zonecode;
                    document.getElementById('addr1').value = data.roadAddress;
                    document.getElementById('addr2').focus();
                }
            }).open();
        }
    </script>
</body>
</html>