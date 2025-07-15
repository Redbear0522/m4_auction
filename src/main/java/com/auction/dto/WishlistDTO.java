package com.auction.dto;

import java.sql.Timestamp;

public class WishlistDTO {
    private int wishlistId;
    private String memberId;
    private int productId;
    private Timestamp createdAt;
    
    // Product 관련 정보 (조인용)
    private String productName;
    private String artistName;
    private String category;
    private int currentPrice;
    private int startPrice;
    private String imageRenamedName;
    private String status;
    
    // 기본 생성자
    public WishlistDTO() {}
    
    // 전체 생성자
    public WishlistDTO(int wishlistId, String memberId, int productId, Timestamp createdAt) {
        this.wishlistId = wishlistId;
        this.memberId = memberId;
        this.productId = productId;
        this.createdAt = createdAt;
    }
    
    // Getter & Setter
    public int getWishlistId() {
        return wishlistId;
    }
    
    public void setWishlistId(int wishlistId) {
        this.wishlistId = wishlistId;
    }
    
    public String getMemberId() {
        return memberId;
    }
    
    public void setMemberId(String memberId) {
        this.memberId = memberId;
    }
    
    public int getProductId() {
        return productId;
    }
    
    public void setProductId(int productId) {
        this.productId = productId;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    // Product 관련 Getter & Setter
    public String getProductName() {
        return productName;
    }
    
    public void setProductName(String productName) {
        this.productName = productName;
    }
    
    public String getArtistName() {
        return artistName;
    }
    
    public void setArtistName(String artistName) {
        this.artistName = artistName;
    }
    
    public String getCategory() {
        return category;
    }
    
    public void setCategory(String category) {
        this.category = category;
    }
    
    public int getCurrentPrice() {
        return currentPrice;
    }
    
    public void setCurrentPrice(int currentPrice) {
        this.currentPrice = currentPrice;
    }
    
    public int getStartPrice() {
        return startPrice;
    }
    
    public void setStartPrice(int startPrice) {
        this.startPrice = startPrice;
    }
    
    public String getImageRenamedName() {
        return imageRenamedName;
    }
    
    public void setImageRenamedName(String imageRenamedName) {
        this.imageRenamedName = imageRenamedName;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    @Override
    public String toString() {
        return "WishlistDTO{" +
                "wishlistId=" + wishlistId +
                ", memberId='" + memberId + '\'' +
                ", productId=" + productId +
                ", createdAt=" + createdAt +
                ", productName='" + productName + '\'' +
                ", artistName='" + artistName + '\'' +
                ", category='" + category + '\'' +
                ", currentPrice=" + currentPrice +
                ", startPrice=" + startPrice +
                ", imageRenamedName='" + imageRenamedName + '\'' +
                ", status='" + status + '\'' +
                '}';
    }
}