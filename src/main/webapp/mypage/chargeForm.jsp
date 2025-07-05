<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.auction.vo.MemberDTO" %>
<%
    MemberDTO loginUser = (MemberDTO)session.getAttribute("loginUser");
    if(loginUser == null){
        response.sendRedirect(request.getContextPath() + "/member/luxury-login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>마일리지 충전 - M4 Auction</title>

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
    
    .charge-container {
        max-width: 600px;
        margin: 50px auto;
        padding: 60px;
        background-color: white;
        box-shadow: 0 0 20px rgba(0,0,0,0.05);
    }
    
    h1 {
        font-family: 'Playfair Display', serif;
        font-size: 36px;
        color: #1a1a1a;
        text-align: center;
        margin-bottom: 20px;
    }
    
    .current-mileage {
        text-align: center;
        margin-bottom: 50px;
        padding: 30px;
        background: #faf8f4;
        border-radius: 8px;
    }
    
    .current-mileage-label {
        font-size: 14px;
        color: #999;
        margin-bottom: 10px;
    }
    
    .current-mileage-value {
        font-size: 32px;
        font-weight: 700;
        color: #c9961a;
    }
    
    .charge-form {
        margin-top: 40px;
    }
    
    .form-group {
        margin-bottom: 30px;
    }
    
    .form-group label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: #333;
        margin-bottom: 15px;
        letter-spacing: 0.5px;
    }
    
    .amount-buttons {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 15px;
        margin-bottom: 30px;
    }
    
    .amount-btn {
        padding: 20px;
        background: white;
        border: 2px solid #e5e5e5;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        transition: all 0.3s;
        color: #333;
    }
    
    .amount-btn:hover {
        border-color: #c9961a;
        color: #c9961a;
    }
    
    .amount-btn.active {
        background: #c9961a;
        border-color: #c9961a;
        color: white;
    }
    
    .custom-amount {
        position: relative;
    }
    
    .custom-amount input {
        width: 100%;
        padding: 15px 50px 15px 15px;
        font-size: 18px;
        text-align: right;
        border: 2px solid #e5e5e5;
        background: #fafafa;
        transition: all 0.3s;
    }
    
    .custom-amount input:focus {
        outline: none;
        border-color: #c9961a;
        background: white;
    }
    
    .custom-amount .currency {
        position: absolute;
        right: 15px;
        top: 50%;
        transform: translateY(-50%);
        color: #999;
        font-weight: 600;
    }
    
    .charge-btn {
        width: 100%;
        padding: 20px;
        font-size: 18px;
        font-weight: 600;
        color: white;
        background-color: #1a1a1a;
        border: none;
        cursor: pointer;
        transition: all 0.3s;
        text-transform: uppercase;
        letter-spacing: 1px;
        margin-top: 40px;
    }
    
    .charge-btn:hover {
        background-color: #c9961a;
    }
    
    .info-box {
        background: #f8f8f8;
        padding: 25px;
        border-radius: 8px;
        margin-top: 40px;
    }
    
    .info-box h4 {
        font-size: 16px;
        color: #1a1a1a;
        margin-bottom: 15px;
        font-weight: 600;
    }
    
    .info-box ul {
        list-style: none;
        padding: 0;
    }
    
    .info-box li {
        font-size: 14px;
        color: #666;
        margin-bottom: 10px;
        padding-left: 20px;
        position: relative;
    }
    
    .info-box li:before {
        content: '•';
        color: #c9961a;
        position: absolute;
        left: 0;
    }
    
    .back-link {
        display: block;
        text-align: center;
        margin-top: 30px;
        color: #999;
        font-size: 14px;
        text-decoration: none;
        transition: all 0.3s;
    }
    
    .back-link:hover {
        color: #c9961a;
    }
</style>
</head>
<body>
    <jsp:include page="/layout/header/luxury-header.jsp" />
    
    <div class="charge-container">
        <h1>마일리지 충전</h1>
        
        <div class="current-mileage">
            <p class="current-mileage-label">현재 보유 마일리지</p>
            <p class="current-mileage-value">
                <%= String.format("%,d", loginUser.getMileage()) %> P
            </p>
        </div>
        
        <form action="chargeMileage.jsp" method="post" class="charge-form" onsubmit="return validateForm();">
            <div class="form-group">
                <label>충전 금액 선택</label>
                <div class="amount-buttons">
                    <button type="button" class="amount-btn" onclick="setAmount(10000)">1만원</button>
                    <button type="button" class="amount-btn" onclick="setAmount(30000)">3만원</button>
                    <button type="button" class="amount-btn" onclick="setAmount(50000)">5만원</button>
                    <button type="button" class="amount-btn" onclick="setAmount(100000)">10만원</button>
                    <button type="button" class="amount-btn" onclick="setAmount(200000)">20만원</button>
                    <button type="button" class="amount-btn" onclick="setAmount(500000)">50만원</button>
                </div>
            </div>
            
            <div class="form-group">
                <label for="amount">직접 입력</label>
                <div class="custom-amount">
                    <input type="number" id="amount" name="amount" min="1000" step="1000" 
                           placeholder="충전할 금액" required>
                    <span class="currency">원</span>
                </div>
            </div>
            
            <button type="submit" class="charge-btn">
                <i class="fas fa-coins"></i> 충전하기
            </button>
        </form>
        
        <div class="info-box">
            <h4><i class="fas fa-info-circle" style="color: #c9961a;"></i> 충전 안내</h4>
            <ul>
                <li>최소 충전 금액은 1,000원입니다</li>
                <li>충전된 마일리지는 경매 입찰에 사용됩니다</li>
                <li>충전 요청 후 관리자 승인이 필요합니다</li>
                <li>충전 완료까지 1-2일 소요될 수 있습니다</li>
            </ul>
        </div>
        
        <a href="myPage.jsp" class="back-link">
            <i class="fas fa-arrow-left"></i> 마이페이지로 돌아가기
        </a>
    </div>
    
    <jsp:include page="/layout/footer/luxury-footer.jsp" />
    
    <script>
    function setAmount(value) {
        document.getElementById('amount').value = value;
        
        // 모든 버튼에서 active 클래스 제거
        document.querySelectorAll('.amount-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        // 클릭한 버튼에 active 클래스 추가
        event.target.classList.add('active');
    }
    
    function validateForm() {
        const amount = document.getElementById('amount').value;
        
        if(amount < 1000) {
            alert('최소 충전 금액은 1,000원입니다.');
            return false;
        }
        
        if(amount % 1000 !== 0) {
            alert('1,000원 단위로 입력해주세요.');
            return false;
        }
        
        return confirm(new Intl.NumberFormat('ko-KR').format(amount) + '원을 충전하시겠습니까?');
    }
    
    // 직접 입력 시 버튼 선택 해제
    document.getElementById('amount').addEventListener('input', function() {
        document.querySelectorAll('.amount-btn').forEach(btn => {
            btn.classList.remove('active');
        });
    });
    </script>
</body>
</html>