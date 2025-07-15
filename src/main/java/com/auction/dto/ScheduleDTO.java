package com.auction.dto;

import java.util.Date;
import java.sql.Timestamp;

public class ScheduleDTO {
    private int scheduleId;    // 스케줄 고유번호 (PK)
    private int productId;     // 상품 ID (FK)
    private Timestamp startTime;    // 경매 시작 시간
    private Timestamp endTime;      // 경매 종료 시간
    private String status;     // 상태 ('대기', '진행중', '종료')
    private Date createdAt;    // 등록일
    private Date updatedAt;    // 수정일

    public ScheduleDTO() {}

    // Getter / Setter
    public int getScheduleId() {
        return scheduleId;
    }
    public void setScheduleId(int scheduleId) {
        this.scheduleId = scheduleId;
    }
    public int getProductId() {
        return productId;
    }
    public void setProductId(int productId) {
        this.productId = productId;
    }
    public Timestamp getStartTime() {
        return startTime;
    }
    public void setStartTime(Timestamp startTime) {
        this.startTime = startTime;
    }
    public Timestamp getEndTime() {
        return endTime;
    }
    public void setEndTime(Timestamp endTime) {
        this.endTime = endTime;
    }
    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public Date getCreatedAt() {
        return createdAt;
    }
    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }
    public Date getUpdatedAt() {
        return updatedAt;
    }
    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }
}