<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="com.auction.dto.MemberDTO" %>
<%@ page import="static com.auction.common.JDBCTemplate.*" %>
<%
    // 관리자 권한 체크
    MemberDTO loginUser = (MemberDTO)session.getAttribute("loginUser");
    if(loginUser == null || !"admin".equals(loginUser.getMemberId())) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }
    String ctx = request.getContextPath();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    DecimalFormat df = new DecimalFormat("###,###,###");
    String action = request.getParameter("action");

    // 커넥션 및 통계 변수 선언 (중복 방지)
    Connection conn = null;
    int activeCount = 0, endedCount = 0, soonCount = 0;

    // 경매 수동 종료
    if("close".equals(action)) {
        int productId = Integer.parseInt(request.getParameter("productId"));
        conn = getConnection();
        try {
            String sql = "UPDATE PRODUCT SET END_TIME = SYSDATE WHERE PRODUCT_ID = ? AND STATUS = 'A'";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productId);
            int result = pstmt.executeUpdate();
            pstmt.close();
            if(result > 0) {
                session.setAttribute("alertMsg", "경매가 수동으로 종료 처리되었습니다. 스케줄러가 곧 처리합니다.");
            }
        } catch(Exception e) {
            e.printStackTrace();
        } finally {
            close(conn);
        }
        response.sendRedirect("auctionManage.jsp");
        return;
    }

    // 통계 조회
    try {
        conn = getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT " +
              "(SELECT COUNT(*) FROM PRODUCT WHERE STATUS = 'A') AS ACTIVE, " +
              "(SELECT COUNT(*) FROM PRODUCT WHERE STATUS = 'E') AS ENDED, " +
              "(SELECT COUNT(*) FROM PRODUCT WHERE STATUS = 'A' AND END_TIME <= SYSDATE + 1/24) AS SOON " +
              "FROM DUAL"
        );
        ResultSet rs = ps.executeQuery();
        if(rs.next()) {
            activeCount = rs.getInt("ACTIVE");
            endedCount = rs.getInt("ENDED");
            soonCount = rs.getInt("SOON");
        }
        rs.close(); ps.close();
    } catch(Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>경매 관리 - 관리자</title>
    <link rel="stylesheet" href="<%=ctx%>/resources/css/luxury-global-style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <style>
        body { background:#f6f6f6; margin:0; padding-top:120px!important; font-family:'Noto Sans KR','Inter',sans-serif;}
        .admin-layout { display:flex; max-width:1440px; margin:0 auto; gap:28px; padding:36px 12px;}
        .admin-sidebar {
            min-width:240px; max-width:290px; background:#fff; border-radius:14px;
            box-shadow:0 2px 16px rgba(0,0,0,0.06); height:fit-content; position:sticky; top:140px; padding-bottom:24px;
        }
        .sidebar-header {background: linear-gradient(120deg,#1a1a1a 0%,#c9961a 100%);
            color:#fff; padding:26px 12px 16px 12px; border-radius:14px 14px 0 0; text-align:center;}
        .sidebar-title {font-size:22px; font-family:'Playfair Display',serif; font-weight:700;}
        .sidebar-subtitle {font-size:13px; opacity:.9; margin-top:4px;}
        .sidebar-menu {padding:0; margin:0; list-style:none;}
        .sidebar-menu li {border-bottom:1px solid #f0f0f0;}
        .sidebar-menu li:last-child {border-bottom:none;}
        .sidebar-menu a {display:flex; align-items:center; gap:12px; padding:15px 24px; color:#333; text-decoration:none; transition:.2s; font-size:15px;}
        .sidebar-menu a.active, .sidebar-menu a:hover {background:#c9961a; color:#fff;}
        .sidebar-menu i {width:18px; text-align:center;}
        .admin-content {flex:1;}
        .admin-header {margin-bottom:32px;}
        .admin-title {font-size:32px; font-weight:800; color:#1a1a1a;}
        .admin-subtitle {font-size:16px; color:#757575;}
        /* 통계 카드 */
        .stats-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(220px,1fr)); gap:20px; margin-bottom:36px;}
        .stat-card {background:#fff; border-radius:12px; box-shadow:0 1px 8px rgba(0,0,0,.04); padding:24px;}
        .stat-label {font-size:14px; color:#888; margin-bottom:8px;}
        .stat-value {font-size:30px; font-weight:700; color:#c9961a;}
        /* 테이블 */
        .table-section {background:#fff; border-radius:14px; box-shadow:0 1px 8px rgba(0,0,0,.06);}
        .table-header {padding:20px 28px; border-bottom:1.5px solid #eee;}
        .table-title {font-size:20px; font-weight:700;}
        .auction-table {width:100%; border-collapse:collapse;}
        .auction-table th, .auction-table td {padding:16px 20px; text-align:left;}
        .auction-table th {background:#faf8f4; color:#777; font-size:13px; border-bottom:1.5px solid #eee;}
        .auction-table td {font-size:15px; border-bottom:1px solid #f4f3ee;}
        .auction-table tr:hover {background:#fafaf6;}
        .product-info {display:flex; align-items:center; gap:14px;}
        .product-image {width:54px; height:54px; object-fit:cover; border-radius:6px; background:#eee;}
        .product-details h4 {font-size:16px; font-weight:700; color:#1a1a1a; margin:0;}
        .product-details p {font-size:13px; color:#888; margin:2px 0 0 0;}
        .status-badge {display:inline-block; padding:5px 12px; border-radius:7px; font-size:12px; font-weight:700;}
        .status-active {background:#c9961a; color:#fff;}
        .status-ended {background:#f2f2f2; color:#888;}
        .status-failed {background:#fee; color:#c00;}
        .action-btn {
            padding:7px 14px; font-size:13px; font-weight:600; border-radius:8px;
            border:none; background:#1a1a1a; color:#fff; cursor:pointer; transition:.2s;
        }
        .action-btn:hover {background:#c9961a; color:#fff;}
        .action-btn:disabled {background:#eee; color:#aaa;}
        .time-remaining {font-family:monospace; font-size:14px; color:#c9961a;}
        .alert {padding:14px 20px; margin-bottom:24px; background:#fcf7e6; border:1.5px solid #f7d087; color:#b48e16; font-weight:600; border-radius:7px;}
        @media (max-width:1024px){
            .admin-layout{flex-direction:column; padding:22px 2vw;}
            .admin-sidebar{position:static; top:auto;}
        }
        @media (max-width:700px){
            .admin-header{margin-bottom:18px;}
            .admin-title{font-size:22px;}
            .table-header{padding:12px;}
            .auction-table th, .auction-table td{padding:9px 6px;}
        }
    </style>
</head>
<body>
<jsp:include page="/layout/header/luxury-header.jsp" flush="true"/>
<div class="admin-layout">
    <!-- 사이드바 -->
        <div class="admin-sidebar">
            <div class="sidebar-header">
                <div class="sidebar-title">관리자 패널</div>
                <div class="sidebar-subtitle">Admin Panel</div>
            </div>
            <ul class="sidebar-menu">
                <li><a href="<%=request.getContextPath()%>/admin/adminPage.jsp">
                    <i class="fas fa-tachometer-alt"></i>
                    대시보드
                </a></li>
                <li><a href="<%=request.getContextPath()%>/admin/waittingProduct.jsp">
                    <i class="fas fa-clock"></i>
                    상품 승인 관리
                </a></li>
                <li><a href="<%=request.getContextPath()%>/admin/allProduct.jsp" >
                    <i class="fas fa-box"></i>
                    전체 상품 관리
                </a></li>
                <li><a href="<%=request.getContextPath()%>/admin/auctionManage.jsp" class="active">
                    <i class="fas fa-gavel"></i>
                    경매 관리
                </a></li>
                <li><a href="<%=request.getContextPath()%>/admin/chargeRequestList.jsp">
                    <i class="fas fa-coins"></i>
                    마일리지 충전 관리
                </a></li>
                <li><a href="<%=request.getContextPath()%>/admin/memberManage.jsp">
                    <i class="fas fa-users"></i>
                    회원 관리
                </a></li>
                <li><a href="<%=request.getContextPath()%>/admin/bidHistory.jsp">
                    <i class="fas fa-list"></i>
                    입찰 내역 관리
                </a></li>
                <li><a href="<%=request.getContextPath()%>/admin/siteStatistics.jsp">
                    <i class="fas fa-chart-bar"></i>
                    사이트 통계
                </a></li>
                <li><a href="<%=request.getContextPath()%>/admin/systemSettings.jsp">
                    <i class="fas fa-cog"></i>
                    시스템 설정
                </a></li>
                <li><a href="<%=request.getContextPath()%>/index.jsp">
                    <i class="fas fa-home"></i>
                    메인 페이지로
                </a></li>
            </ul>
        </div>
    <!-- 메인 컨텐츠 -->
    <div class="admin-content">
        <div class="admin-header">
            <h1 class="admin-title">경매 관리</h1>
            <p class="admin-subtitle">진행 중인 경매를 모니터링하고 관리할 수 있습니다.</p>
        </div>
        <% if(session.getAttribute("alertMsg") != null) { %>
        <div class="alert"><%= session.getAttribute("alertMsg") %>
            <% session.removeAttribute("alertMsg"); %>
        </div>
        <% } %>
        <!-- 통계 카드 -->
        <div class="stats-grid">
            <div class="stat-card"><div class="stat-label">진행 중인 경매</div><div class="stat-value"><%=activeCount%></div></div>
            <div class="stat-card"><div class="stat-label">종료된 경매</div><div class="stat-value"><%=endedCount%></div></div>
            <div class="stat-card"><div class="stat-label">마감 임박(1시간)</div><div class="stat-value"><%=soonCount%></div></div>
        </div>
        <!-- 경매 목록 테이블 -->
        <div class="table-section">
            <div class="table-header">
                <h2 class="table-title"><i class="fas fa-gavel" style="color:#c9961a"></i> 진행 중인 경매 목록</h2>
            </div>
            <table class="auction-table">
                <thead>
                <tr>
                    <th>상품정보</th>
                    <th>현재가</th>
                    <th>입찰수</th>
                    <th>남은시간</th>
                    <th>상태</th>
                    <th>관리</th>
                </tr>
                </thead>
                <tbody>
                <%
                    try {
                        String sql = "SELECT P.*, (SELECT COUNT(*) FROM BID WHERE PRODUCT_ID = P.PRODUCT_ID) AS BID_COUNT " +
                                     "FROM PRODUCT P WHERE P.STATUS = 'A' ORDER BY P.END_TIME ASC";
                        PreparedStatement pstmt = conn.prepareStatement(sql);
                        ResultSet rs = pstmt.executeQuery();
                        while(rs.next()) {
                            int productId = rs.getInt("PRODUCT_ID");
                            String productName = rs.getString("PRODUCT_NAME");
                            String artistName = rs.getString("ARTIST_NAME");
                            int currentPrice = rs.getInt("CURRENT_PRICE");
                            if(currentPrice == 0) currentPrice = rs.getInt("START_PRICE");
                            Timestamp endTime = rs.getTimestamp("END_TIME");
                            int bidCount = rs.getInt("BID_COUNT");
                            String imageRenamedName = rs.getString("IMAGE_RENAMED_NAME");
                            long remainingMs = endTime.getTime() - System.currentTimeMillis();
                            boolean isExpired = remainingMs <= 0;
                %>
                <tr>
                    <td>
                        <div class="product-info">
                            <img src="<%=ctx%>/resources/product_images/<%=imageRenamedName%>"
                                 alt="<%=productName%>" class="product-image">
                            <div class="product-details">
                                <h4><%=productName%></h4>
                                <p><%=artistName%></p>
                            </div>
                        </div>
                    </td>
                    <td>₩<%=df.format(currentPrice)%></td>
                    <td><%=bidCount%>회</td>
                    <td>
                        <% if(isExpired) { %>
                            <span class="time-remaining" style="color: #ef4444;">종료 대기중</span>
                        <% } else { %>
                            <span class="time-remaining" data-endtime="<%=endTime%>">계산중...</span>
                        <% } %>
                    </td>
                    <td>
                        <span class="status-badge status-active">진행중</span>
                    </td>
                    <td>
                        <a href="?action=close&productId=<%=productId%>"
                           class="action-btn"
                           onclick="return confirm('이 경매를 수동으로 종료하시겠습니까?');">
                            수동 종료
                        </a>
                    </td>
                </tr>
                <%
                        }
                        rs.close(); pstmt.close();
                    } catch(Exception e) { e.printStackTrace(); }
                    finally { close(conn); }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<jsp:include page="/layout/footer/luxury-footer.jsp" flush="true"/>
<script>
function updateRemainingTimes() {
    document.querySelectorAll('.time-remaining[data-endtime]').forEach(el => {
        // 데이터베이스 timestamp를 JS Date로 변환
        const endTime = new Date(el.dataset.endtime.replace(' ', 'T'));
        const now = new Date();
        const diff = endTime - now;
        if(diff > 0) {
            const hours = Math.floor(diff / (1000 * 60 * 60));
            const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((diff % (1000 * 60)) / 1000);
            if(hours >= 24) {
                const days = Math.floor(hours / 24);
                el.textContent = `${days}일 ${hours % 24}시간`;
            } else if(hours > 0) {
                el.textContent = `${hours}시간 ${minutes}분`;
            } else if(minutes > 0) {
                el.textContent = `${minutes}분 ${seconds}초`;
            } else {
                el.textContent = `${seconds}초`;
            }
            if(diff < 3600000) { el.style.color = '#ef4444'; }
        } else {
            el.textContent = '종료 대기중';
            el.style.color = '#ef4444';
        }
    });
}
updateRemainingTimes();
setInterval(updateRemainingTimes, 1000);
</script>
</body>
</html>
