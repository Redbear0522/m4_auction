package com.auction.dto;

import java.sql.Date;

public class VipBenefitDTO {
    private int benefitId;
    private String memberId;
    private String optionName;
    private Date startDate;
    private Date endDate;
    private String status;

    // Getters and Setters
    public int getBenefitId() { return benefitId; }
    public void setBenefitId(int benefitId) { this.benefitId = benefitId; }

    public String getMemberId() { return memberId; }
    public void setMemberId(String memberId) { this.memberId = memberId; }

    public String getOptionName() { return optionName; }
    public void setOptionName(String optionName) { this.optionName = optionName; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}