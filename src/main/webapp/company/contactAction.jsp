<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.mail.*, javax.mail.internet.*, java.util.Properties" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 폼 데이터
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String phone = request.getParameter("phone");
    String category = request.getParameter("category");
    String subject = request.getParameter("subject");
    String message = request.getParameter("message");

    // 필수항목 체크
    if(name == null || name.trim().isEmpty() ||
       email == null || email.trim().isEmpty() ||
       category == null || category.trim().isEmpty() ||
       subject == null || subject.trim().isEmpty() ||
       message == null || message.trim().isEmpty()) {
%>
    <script>
        alert("필수 입력값이 누락되었습니다. 다시 확인해주세요.");
        history.back();
    </script>
<%
        return;
    }

    // Gmail SMTP 설정 (앱 비밀번호 필수)
    final String username = "jjhansol2196@gmail.com"; // 본인 gmail
    final String password = "zyjq jhed lbfn yfbq";    // 앱 비밀번호 (16자리)
    String toEmail = "jjhansol4158@gmail.com";        // 실제 받을 관리자 이메일

    Properties props = new Properties();
    props.put("mail.smtp.host", "smtp.gmail.com");
    props.put("mail.smtp.port", "587");
    props.put("mail.smtp.auth", "true");
    props.put("mail.smtp.starttls.enable", "true");
    props.put("mail.smtp.ssl.protocols", "TLSv1.2"); // 최신 자바환경에서 필요

    Session mailSession = Session.getInstance(props, new javax.mail.Authenticator() {
        protected PasswordAuthentication getPasswordAuthentication() {
            return new PasswordAuthentication(username, password);
        }
    });

    boolean sendOk = false;
    String mailMsg =
        "<b>문의 분류:</b> " + category + "<br>"
        + "<b>이름:</b> " + name + "<br>"
        + "<b>이메일:</b> " + email + "<br>"
        + "<b>연락처:</b> " + (phone == null ? "" : phone) + "<br>"
        + "<b>제목:</b> " + subject + "<br>"
        + "<b>문의 내용:</b><br>" + message.replaceAll("\n", "<br>");

    try {
        MimeMessage mimeMsg = new MimeMessage(mailSession); // ← mailSession으로 수정
        mimeMsg.setFrom(new InternetAddress(username, "M4 Auction 문의폼", "UTF-8"));
        mimeMsg.addRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
        mimeMsg.setSubject("[M4 Auction 문의] " + subject, "UTF-8");
        mimeMsg.setContent(mailMsg, "text/html; charset=UTF-8");
        Transport.send(mimeMsg);
        sendOk = true;
    } catch(Exception e) {
        e.printStackTrace();
    }

    if(sendOk) {
%>
    <script>
        alert("문의가 정상적으로 접수되었습니다.\n빠른 시일 내에 답변드리겠습니다.");
        location.href = "<%=ctx%>/company/contact.jsp";
    </script>
<%
    } else {
%>
    <script>
        alert("메일 전송 중 오류가 발생했습니다. 다시 시도해주세요.");
        history.back();
    </script>
<%
    }
%>
