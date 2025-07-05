package com.auction.common;

import java.security.MessageDigest;

public class SHA256 {
    
    public static String encrypt(String pwd) {
        String encPwd = "";
        
        try {
            // 1. 암호화 도구 준비
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            
            // 2. 비밀번호를 바이트로 변환해서 암호화
            md.update(pwd.getBytes());
            byte[] bytes = md.digest();
            
            // 3. 바이트를 16진수 문자열로 변환
            StringBuilder sb = new StringBuilder();
            for(byte b : bytes) {
                sb.append(String.format("%02x", b));
            }
            
            encPwd = sb.toString();
            
        } catch(Exception e) {
            e.printStackTrace();
        }
        
        return encPwd;
    }
}