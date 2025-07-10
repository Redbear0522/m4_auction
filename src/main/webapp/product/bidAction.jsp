<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.auction.dao.ProductDAO" %>
<%@ page import="com.auction.dao.BidDAO" %>
<%@ page import="com.auction.dto.MemberDTO" %>
<%@ page import="com.auction.dto.ProductDTO" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    
    // 로그인 체크
    MemberDTO loginUser = (MemberDTO) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/member/loginForm.jsp");
        return;
    }

    // 파라미터 받기
    String productIdStr = request.getParameter("productId");
    String bidPriceStr = request.getParameter("bidPrice");
    String memberId = loginUser.getMemberId();
    
    // 파라미터 검증
    if (productIdStr == null || bidPriceStr == null) {
        session.setAttribute("alertMsg", "잘못된 요청입니다.");
        response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp");
        return;
    }

    int productId = 0;
    int bidPrice = 0;
    
    try {
        productId = Integer.parseInt(productIdStr);
        bidPrice = Integer.parseInt(bidPriceStr);
    } catch (NumberFormatException e) {
        session.setAttribute("alertMsg", "잘못된 입찰 금액입니다.");
        response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productIdStr);
        return;
    }

    Connection conn = null;
    try {
        conn = getConnection();
        conn.setAutoCommit(false); // 트랜잭션 시작
        
        // 1. 상품 정보 확인
        ProductDAO productDao = new ProductDAO();
        ProductDTO product = productDao.selectProductById(conn, productId);
        
        if (product == null) {
            session.setAttribute("alertMsg", "상품 정보가 없습니다.");
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
            return;
        }
        
        // 2. 경매 진행 상태 확인
        if (!"A".equals(product.getStatus())) {
            session.setAttribute("alertMsg", "종료된 경매입니다.");
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
            return;
        }
        
        // 3. 경매 종료 시간 확인
        if (new java.util.Date().after(product.getEndTime())) {
            session.setAttribute("alertMsg", "경매가 종료되었습니다.");
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
            return;
        }
        
        // 4. 본인 상품 입찰 방지
        if (memberId.equals(product.getSellerId())) {
            session.setAttribute("alertMsg", "본인의 상품에는 입찰할 수 없습니다.");
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
            return;
        }
        
        // 5. 현재가보다 높은지 확인
        int currentPrice = product.getCurrentPrice();
        if (currentPrice == 0) currentPrice = product.getStartPrice();
        
        if (bidPrice <= currentPrice) {
            session.setAttribute("alertMsg", "입찰가는 현재가(" + String.format("%,d", currentPrice) + "원)보다 높아야 합니다.");
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
            return;
        }
        
        // 6. 사용자 마일리지 확인
        if (loginUser.getMileage() < bidPrice) {
            session.setAttribute("alertMsg", "마일리지가 부족합니다. (보유: " + String.format("%,d", loginUser.getMileage()) + "P)");
            response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
            return;
        }
        
        // 7. 입찰 처리 (BidDAO의 placeBid 메서드 사용)
        BidDAO bidDao = new BidDAO();
        boolean bidSuccess = bidDao.placeBid(conn, memberId, productId, bidPrice);
        
        if (bidSuccess) {
            // 8. 입찰 성공 (마일리지는 경매 종료 시에 차감)
            commit(conn);
            session.setAttribute("alertMsg", "입찰 성공! 입찰가: " + String.format("%,d", bidPrice) + "원 (경매 종료 시 마일리지 차감)");
            
            System.out.println("[입찰성공] 사용자: " + memberId + ", 상품: " + productId + ", 금액: " + bidPrice);
        } else {
            rollback(conn);
            session.setAttribute("alertMsg", "입찰 처리 중 오류가 발생했습니다.");
        }
        
    } catch (SQLException e) {
        if (conn != null) rollback(conn);
        e.printStackTrace();
        session.setAttribute("alertMsg", "입찰 처리 중 오류가 발생했습니다.");
    } catch (Exception e) {
        if (conn != null) rollback(conn);
        e.printStackTrace();
        session.setAttribute("alertMsg", "시스템 오류가 발생했습니다.");
    } finally {
        if (conn != null) close(conn);
    }

    // 상품 상세 페이지로 리다이렉트
    response.sendRedirect(request.getContextPath() + "/product/productDetail.jsp?productId=" + productId);
%>