// File: src/main/java/com/auction/dto/ProductDTO.java
package com.auction.dto;

import java.sql.Date;
import java.sql.Timestamp;

public class ProductDTO {

    private int productId;
    private String productName;
    private String artistName;
    private String productDesc;
    private int startPrice;
    private int buyNowPrice; // 즉시 구매가
    private int currentPrice;
    private Timestamp startTime;
    private Timestamp endTime;
    private String imageOriginalName;
    private String imageRenamedName;
    private String category;
    private String sellerId;
    private Date regDate;
    private String status;
    private String winnerId;
    private int finalPrice;
    private ScheduleDTO schedule;
    private Integer bidCount;
    private Integer viewCount;

    public ScheduleDTO getSchedule() {
		return schedule;
	}

	public void setSchedule(ScheduleDTO schedule) {
		this.schedule = schedule;
	}

	public ProductDTO() {}
    
    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }
    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }
    public String getArtistName() { return artistName; }
    public void setArtistName(String artistName) { this.artistName = artistName; }
    public String getProductDesc() { return productDesc; }
    public void setProductDesc(String productDesc) { this.productDesc = productDesc; }
    public int getStartPrice() { return startPrice; }
    public void setStartPrice(int startPrice) { this.startPrice = startPrice; }
    public int getBuyNowPrice() { return buyNowPrice; }
    public void setBuyNowPrice(int buyNowPrice) { this.buyNowPrice = buyNowPrice; }
    public int getCurrentPrice() { return currentPrice; }
    public void setCurrentPrice(int currentPrice) { this.currentPrice = currentPrice; }
    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }
    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }
    public String getImageOriginalName() { return imageOriginalName; }
    public void setImageOriginalName(String imageOriginalName) { this.imageOriginalName = imageOriginalName; }
    public String getImageRenamedName() { return imageRenamedName; }
    public void setImageRenamedName(String imageRenamedName) { this.imageRenamedName = imageRenamedName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getSellerId() { return sellerId; }
    public void setSellerId(String sellerId) { this.sellerId = sellerId; }
    public Date getRegDate() { return regDate; }
    public void setRegDate(Date regDate) { this.regDate = regDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getWinnerId() { return winnerId; }
    public void setWinnerId(String winnerId) { this.winnerId = winnerId; }
    public int getFinalPrice() { return finalPrice; }
    public void setFinalPrice(int finalPrice) { this.finalPrice = finalPrice; }
    public Integer getBidCount() { return bidCount; }
    public void setBidCount(Integer bidCount) { this.bidCount = bidCount; }
    public Integer getViewCount() { return viewCount; }
    public void setViewCount(Integer viewCount) { this.viewCount = viewCount; }
}