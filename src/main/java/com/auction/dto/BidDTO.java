package com.auction.dto;

import java.util.Date;

public class BidDTO {
	private int bidId;          // 입찰 고유 번호
	private int productId;      // 입찰한 상품 번호
	private String memberId;    // 입찰자 아이디
	private int bidPrice;       // 입찰 가격
	private Date bidTime;       // 입찰 시간
	private int isSuccessful;   // 낙찰 여부 (0: 실패, 1: 낙찰)
	
	// 상품 정보 추가 필드들
	private String productName;      // 상품명
	private String imageRenamedName; // 이미지 파일명
	private int currentPrice;        // 현재가
	private String productStatus;    // 상품 상태

	public int getBidId() {
		return bidId;
	}
	public void setBidId(int bidId) {
		this.bidId = bidId;
	}
	public int getBidPrice() {
		return bidPrice;
	}
	public void setBidPrice(int bidPrice) {
		this.bidPrice = bidPrice;
	}
	public Date getBidTime() {
		return bidTime;
	}
	public void setBidTime(Date bidTime) {
		this.bidTime = bidTime;
	}
	public int getIsSuccessful() {
		return isSuccessful;
	}
	public void setIsSuccessful(int isSuccessful) {
		this.isSuccessful = isSuccessful;
	}
	
	// 새로 추가된 필드들의 getter/setter
	public int getProductId() {
		return productId;
	}
	public void setProductId(int productId) {
		this.productId = productId;
	}
	public String getMemberId() {
		return memberId;
	}
	public void setMemberId(String memberId) {
		this.memberId = memberId;
	}
	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}
	public String getImageRenamedName() {
		return imageRenamedName;
	}
	public void setImageRenamedName(String imageRenamedName) {
		this.imageRenamedName = imageRenamedName;
	}
	public int getCurrentPrice() {
		return currentPrice;
	}
	public void setCurrentPrice(int currentPrice) {
		this.currentPrice = currentPrice;
	}
	public String getProductStatus() {
		return productStatus;
	}
	public void setProductStatus(String productStatus) {
		this.productStatus = productStatus;
	}
}