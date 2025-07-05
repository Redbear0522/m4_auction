<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="model.UserDAO, model.UserDTO" %>
<%  
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>회원가입 - Auction M4</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

  <link rel="stylesheet" href="<%=ctx%>/views/style.css">
  
  
  <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  
  <script>
    function execDaumPostcode() {
      new daum.Postcode({
        oncomplete: function(data) {
          document.getElementById('zip').value   = data.zonecode;
          document.getElementById('addr1').value = data.address;
          document.getElementById('addr2').focus();
        }
      }).open();
    }
    function checkId() {
      var id = document.getElementById('id').value.trim();
      if (!id) { alert('아이디를 입력해주세요.'); return; }
      window.open(
        '<%=ctx%>/member/checkId.jsp?id=' + encodeURIComponent(id),
        'chk','width=400,height=200,scrollbars=no'
      );
    }
    function validate() {
      var pw  = document.getElementById('pw').value;
      var pw2 = document.getElementById('pw2').value;
      if (pw.length < 4) {
        alert('비밀번호를 4자 이상 입력하세요.'); return false;
      }
      if (pw !== pw2) {
        alert('비밀번호가 일치하지 않습니다.'); return false;
      }
      return true;
    }
  </script>
</head>
<body class="d-flex flex-column min-vh-100">

  <jsp:include page="/views/header.jsp" />

  <main class="flex-grow-1 d-flex justify-content-center align-items-center main-content">
    <div class="join-container">
      <h3 class="join-title">Create Your Account</h3>
      
      <form name="joinForm" action="<%=ctx%>/member/inputPro.jsp" method="post" onsubmit="return validate();">
        <input type="hidden" name="job" value="1">
        <input type="hidden" name="company" value="null">

        <div class="input-group mb-3">
          <div class="form-floating flex-grow-1">
            <input type="text" id="id" name="id" class="form-control" placeholder="아이디" maxlength="100" required>
            <label for="id">아이디</label>
          </div>
          <div class="input-group-append">
            <button type="button" class="btn btn-outline-secondary" onclick="checkId()">중복확인</button>
          </div>
        </div>

        <div class="form-floating mb-3">
          <input type="password" id="pw" name="pw" class="form-control" placeholder="비밀번호" maxlength="100" required>
          <label for="pw">비밀번호</label>
        </div>

        <div class="form-floating mb-3">
          <input type="password" id="pw2" name="pw2" class="form-control" placeholder="비밀번호 확인" maxlength="100" required>
          <label for="pw2">비밀번호 확인</label>
        </div>
        
        <div class="form-floating mb-3">
          <input type="text" id="name" name="name" class="form-control" placeholder="이름" maxlength="100" required>
          <label for="name">이름</label>
        </div>

        <div class="form-floating mb-3">
          <input type="date" id="birth" name="birth" class="form-control">
          <label for="birth">생년월일</label>
        </div>

        <div class="mb-3">
          <div class="btn-group w-100 gender-toggle" role="group" aria-label="Gender toggle">
            <input type="radio" class="btn-check" name="gender" id="gender1" value="1" autocomplete="off" checked>
            <label class="btn btn-outline-primary" for="gender1">남자</label>
          
            <input type="radio" class="btn-check" name="gender" id="gender2" value="2" autocomplete="off">
            <label class="btn btn-outline-primary" for="gender2">여자</label>
          </div>
        </div>
        
        <div class="input-group mb-3">
          <select name="phone1" class="form-select" style="max-width: 120px;">
            <option value="1">SKT</option>
            <option value="2">KT</option>
            <option value="3">LGU+</option>
          </select>
          <div class="form-floating flex-grow-1">
            <input type="text" name="phone2" id="phone2" class="form-control" placeholder="전화번호" required>
            <label for="phone2">전화번호 ('-' 없이 입력)</label>
          </div>
        </div>
        
        <div class="input-group mb-2">
          <div class="form-floating flex-grow-1">
            <input type="text" id="zip" name="zip" class="form-control" placeholder="우편번호" readonly>
            <label for="zip">우편번호</label>
          </div>
          <button type="button" class="btn btn-outline-secondary" onclick="execDaumPostcode()">주소찾기</button>
        </div>
        <div class="form-floating mb-2">
          <input type="text" id="addr1" name="addr1" class="form-control" placeholder="주소" readonly>
          <label for="addr1">주소</label>
        </div>
        <div class="form-floating mb-4">
          <input type="text" id="addr2" name="addr2" class="form-control" placeholder="상세주소">
          <label for="addr2">상세주소</label>
        </div>

        <div class="d-grid gap-2">
          <button type="submit" class="btn btn-primary btn-lg">가입하기</button>
          <button type="reset"  class="btn btn-outline-secondary">다시작성</button>
          <button type="button" class="btn btn-link text-muted" onclick="history.back()">돌아가기</button>
        </div>
      </form>
    </div>
  </main>

  <jsp:include page="/views/footer.jsp" />

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>