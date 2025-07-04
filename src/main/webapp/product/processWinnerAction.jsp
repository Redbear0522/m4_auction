<%--
  File: WebContent/product/processWinnerAction.jsp
  역할: 경매가 마감된 상품의 최종 낙찰자를 결정하고, 상품 상태를 변경합니다.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<%@ page import="com.auction.vo.MemberDTO"%>
<%@ page import="com.auction.vo.ProductDTO"%>
<%@ page import="com.auction.vo.BidDTO"%>
<%@ page import="com.auction.dao.ProductDAO"%>
<%@ page import="com.auction.dao.BidDAO"%>
<%@ page import="com.auction.dao.TransactionLogDAO"%>
<%@ page import="com.auction.dao.MemberDAO"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.util.List"%>
<%@ page import="static com.auction.common.JDBCTemplate.*"%>

<%
// 1. 판매자 본인이 맞는지 확인 (로그인 정보 & 상품의 판매자 정보 비교)
MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
int productId = Integer.parseInt(request.getParameter("productId"));

if (loginUser == null) {
	session.setAttribute("alertMsg", "로그인 후 이용해주세요.");
	response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
	return;
}

Connection conn = getConnection();
ProductDAO pDao = new ProductDAO();

ProductDTO p = pDao.selectProductById(conn, productId);

if (!"admin".equals(loginUser.getMemberId())) {
    session.setAttribute("alertMsg", "권한이 없습니다. 관리자만 접근할 수 있습니다.");
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

// 2. 최고 입찰자 정보 조회
BidDTO winner = pDao.findWinner(conn, productId);

if (winner != null) { // 3. 입찰자가 있는 경우 (정상적인 낙찰 처리)

	// 3-1. PRODUCT 테이블에 최종 낙찰자, 최종 낙찰가 정보 업데이트
	int result1 = pDao.updateProductWinner(conn, productId, winner.getBidderId(), winner.getBidPrice());

	// 3-2. PRODUCT 테이블의 상태를 'E'(End)로 변경
	int result2 = pDao.updateProductStatus(conn, productId, "E");

	if (result1 > 0 && result2 > 0) {
		commit(conn);
		session.setAttribute("alertMsg", "낙찰 처리가 완료되었습니다.");
	} else {
		rollback(conn);
		session.setAttribute("alertMsg", "낙찰 처리 중 오류가 발생했습니다.");
	}
	// 3-3) 낙찰자를 제외한 모든 입찰자에 대해 환급 처리
	// 3-1,3-2 결과와 3-3 환급 모두 성공해야 최종 커밋
	boolean ok = (result1 > 0 && result2 > 0);

	// 3-3) 낙찰자를 제외한 환급 처리
	BidDAO bidDao = new BidDAO();
	TransactionLogDAO tDao = new TransactionLogDAO();
	List<BidDTO> allBids = bidDao.getBidsByProductId(productId);

	for (BidDTO b : allBids) {
		if (!b.getBidderId().equals(winner.getBidderId())) {
	int upd = new MemberDAO().reduceMileage(conn, b.getBidderId(), -b.getBidPrice());
	int logR = tDao.insertLog(conn, b.getBidderId(), "D", b.getBidPrice(), productId);
	int refd = bidDao.markRefunded(b.getBidId());
	if (upd <= 0 || logR <= 0 || refd <= 0)
		ok = false;
		}
	}

	if (ok) {
		commit(conn);
		session.setAttribute("alertMsg", "낙찰 처리 및 환급이 완료되었습니다.");
	} else {
		rollback(conn);
		session.setAttribute("alertMsg", "낙찰/환급 처리 중 오류가 발생했습니다.");
	}
} else { // 4. 입찰자가 아무도 없는 경우 (유찰 처리)

	// 4-1. PRODUCT 테이블의 상태만 'E'(End)로 변경
	int result = pDao.updateProductStatus(conn, productId, "E");

	if (result > 0) {
		commit(conn);
		session.setAttribute("alertMsg", "입찰자가 없어 경매가 종료되었습니다.");
	} else {
		rollback(conn);
		session.setAttribute("alertMsg", "경매 종료 처리 중 오류가 발생했습니다.");
	}
}

// 5. 모든 처리가 끝나면 다시 상품 상세 페이지로 돌아갑니다.
close(conn);
response.sendRedirect("productDetail.jsp?productId=" + productId);
%>
