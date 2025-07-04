package com.auction.dao;

import static com.auction.common.JDBCTemplate.*;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.auction.vo.AuctionDTO;

public class AuctionDAO {
 	
        // 상품 등록
        public int insertAuctionItem(String title, String description, int startPrice) throws SQLException {
                String sql = "INSERT INTO AUCTION_ITEM (ID, TITLE, DESCRIPTION, START_PRICE, CURRENT_PRICE) "
                               + "VALUES (AUCTION_ITEM_SEQ.NEXTVAL, ?, ?, ?, ?)";

                Connection conn = getConnection();
                int result = 0;
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        pstmt.setString(1, title);
                        pstmt.setString(2, description);
                        pstmt.setInt(3, startPrice);
                        pstmt.setInt(4, startPrice); // 현재가 = 시작가로 초기화
                        result = pstmt.executeUpdate();
                        commit(conn);
                } catch (SQLException e) {
                        rollback(conn);
                        throw e;
                } finally {
                        close(conn);
                }
                return result;
        }
 	
        //상품 전체 조회 메서드 추가
        public List<AuctionDTO> getAllAuctionItems() throws SQLException {
                List<AuctionDTO> itemList = new ArrayList<>();
                String sql = "SELECT * FROM AUCTION_ITEM ORDER BY ID DESC";

                Connection conn = getConnection();
                try (PreparedStatement pstmt = conn.prepareStatement(sql);
                     ResultSet rs = pstmt.executeQuery()) {
                        while (rs.next()) {
                                AuctionDTO dto = new AuctionDTO();
                                dto.setId(rs.getInt("ID"));
                                dto.setTitle(rs.getString("TITLE"));
                                dto.setStartPrice(rs.getInt("START_PRICE"));
                                dto.setCurrentPrice(rs.getInt("CURRENT_PRICE"));
                                dto.setStatus(rs.getString("STATUS"));
                                dto.setRegDate(rs.getDate("REG_DATE"));
                                itemList.add(dto);
                        }
                } finally {
                        close(conn);
                }
                return itemList;
        }
 	
        //상품상세 정보 보기
        public AuctionDTO getAuctionItemById(int id) throws SQLException {
                AuctionDTO dto = null;
                String sql = "SELECT * FROM AUCTION_ITEM WHERE ID = ?";
                Connection conn = getConnection();
                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        pstmt.setInt(1, id);
                        try (ResultSet rs = pstmt.executeQuery()) {
                                if (rs.next()) {
                                        dto = new AuctionDTO();
                                        dto.setId(rs.getInt("ID"));
                                        dto.setTitle(rs.getString("TITLE"));
                                        dto.setStartPrice(rs.getInt("START_PRICE"));
                                        dto.setCurrentPrice(rs.getInt("CURRENT_PRICE"));
                                        dto.setStatus(rs.getString("STATUS"));
                                        dto.setRegDate(rs.getDate("REG_DATE"));
                                        dto.setDescription(rs.getString("DESCRIPTION"));
                                }
                        }
                } finally {
                        close(conn);
                }
                return dto;
        }
 	
 	
 }
