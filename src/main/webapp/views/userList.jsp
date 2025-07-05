<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.util.*" %>
<%@ page import="model.UserDAO, model.UserDTO" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>사용자 관리</title>
  <!-- Bootstrap CSS -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
        rel="stylesheet"/>
</head>
<body class="p-4">

  <h2 class="mb-4">사용자 목록</h2>

  <!-- 1) 검색 폼 -->
  <form class="row g-2 mb-4" method="get" action="">
    <div class="col-auto">
      <input type="text"
             name="q"
             value="${fn:escapeXml(searchQuery)}"
             class="form-control"
             placeholder="이름 또는 이메일 검색"/>
    </div>
    <div class="col-auto">
      <button type="submit" class="btn btn-primary">검색</button>
    </div>
    <div class="col-auto">
      <a href="userList.jsp" class="btn btn-outline-secondary">초기화</a>
    </div>
  </form>

  <!-- 2) 정렬·페이징 공통 파라미터 -->
  <c:set var="baseParams"
         value="q=${fn:escapeXml(searchQuery)}&amp;sort=${sortField}&amp;order=${sortOrder}"/>

  <!-- 3) 사용자 테이블 -->
  <table class="table table-striped table-hover align-middle">
    <thead class="table-dark">
      <tr>
        <th>
          <a href="?${baseParams}&amp;page=1&amp;sort=memberId&amp;order=${(sortField=='memberId' && sortOrder=='ASC')?'DESC':'ASC'}">
            ID
            <c:if test="${sortField=='memberId'}">
              <span class="badge bg-secondary">${sortOrder}</span>
            </c:if>
          </a>
        </th>
        <th>
          <a href="?${baseParams}&amp;page=1&amp;sort=nickname&amp;order=${(sortField=='nickname' && sortOrder=='ASC')?'DESC':'ASC'}">
            이름
            <c:if test="${sortField=='memberName'}">
              <span class="badge bg-secondary">${sortOrder}</span>
            </c:if>
          </a>
        </th>
        <th>이메일</th>
        <th>
          <a href="?${baseParams}&amp;page=1&amp;sort=regDate&amp;order=${(sortField=='regDate' && sortOrder=='ASC')?'DESC':'ASC'}">
            가입일
            <c:if test="${sortField=='regDate'}">
              <span class="badge bg-secondary">${sortOrder}</span>
            </c:if>
          </a>
        </th>
        <th>마일리지</th>
      </tr>
    </thead>
    <tbody>
      <c:forEach var="user" items="${userList}">
        <tr>
          <td>${user.memberId}</td>
          <td>${user.memberName}</td>
          <td>${user.email}</td>
          <td>
            <fmt:formatDate value="${user.regDate}" pattern="yyyy-MM-dd"/>
          </td>
          <td>
            <a href="userDetail.jsp?id=${user.memberId}"
               class="btn btn-sm btn-info">보기</a>
            <a href="userEdit.jsp?id=${user.memberId}"
               class="btn btn-sm btn-warning">수정</a>
            <a href="userDelete?id=${user.memberId}"
               class="btn btn-sm btn-danger"
               onclick="return confirm('정말 삭제하시겠습니까?');">
              삭제
            </a>
          </td>
        </tr>
      </c:forEach>

      <c:if test="${empty userList}">
        <tr>
          <td colspan="5" class="text-center text-muted">
            조회된 사용자가 없습니다.
          </td>
        </tr>
      </c:if>
    </tbody>
  </table>

  <!-- 4) 서버 사이드 페이징 네비게이션 -->
  <nav aria-label="페이지 네비게이션">
    <ul class="pagination justify-content-center">
      <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
        <a class="page-link"
           href="?${baseParams}&amp;page=${currentPage-1}">이전</a>
      </li>
      <c:forEach begin="1" end="${totalPages}" var="p">
        <li class="page-item ${p == currentPage ? 'active' : ''}">
          <a class="page-link"
             href="?${baseParams}&amp;page=${p}">${p}</a>
        </li>
      </c:forEach>
      <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
        <a class="page-link"
           href="?${baseParams}&amp;page=${currentPage+1}">다음</a>
      </li>
    </ul>
  </nav>

  <!-- Bootstrap JS (선택) -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
