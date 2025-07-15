<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection" %>
<%@ page import="com.auction.dao.WishlistDAO" %>
<%@ page import="com.auction.dto.MemberDTO" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    Map<String, Object> responseData = new HashMap<>();

    try {
        MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
        if (loginUser == null) {
            responseData.put("success", false);
            responseData.put("message", "로그인이 필요합니다.");
            out.print(new Gson().toJson(responseData));
            return;
        }

        String action = request.getParameter("action");
        String productIdParam = request.getParameter("productId");

        if (action == null || action.trim().isEmpty() ||
            productIdParam == null || productIdParam.trim().isEmpty()) {
            responseData.put("success", false);
            responseData.put("message", "잘못된 요청입니다.");
            out.print(new Gson().toJson(responseData));
            return;
        }

        int productId = Integer.parseInt(productIdParam.trim());
        String memberId = loginUser.getMemberId();

        Connection conn = getConnection();
        WishlistDAO wishlistDAO = new WishlistDAO();

        int result = 0;
        boolean isWishlisted = false;

        if ("add".equals(action)) {
            result = wishlistDAO.insertWishlist(conn, memberId, productId);
            isWishlisted = true;
        } else if ("remove".equals(action)) {
            result = wishlistDAO.deleteWishlist(conn, memberId, productId);
            isWishlisted = false;
        }

        if (result > 0) {
            commit(conn);
            int wishlistCount = wishlistDAO.selectWishlistCount(conn, memberId);
            responseData.put("success", true);
            responseData.put("message", isWishlisted ? "찜 목록에 추가되었습니다." : "찜 목록에서 제거되었습니다.");
            responseData.put("isWishlisted", isWishlisted);
            responseData.put("wishlistCount", wishlistCount);
        } else {
            rollback(conn);
            responseData.put("success", false);
            responseData.put("message", "처리 중 오류가 발생했습니다.");
        }

        close(conn);

    } catch (Exception e) {
        e.printStackTrace();
        responseData.put("success", false);
        responseData.put("message", "서버 오류가 발생했습니다.");
    }
    out.print(new Gson().toJson(responseData));
%>
