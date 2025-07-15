-- WISHLIST 테이블 존재 확인
SELECT table_name FROM user_tables WHERE table_name = 'WISHLIST';

-- 모든 테이블 확인
SELECT table_name FROM user_tables ORDER BY table_name;

-- WISHLIST 테이블 구조 확인 (테이블이 있다면)
DESC WISHLIST;

-- 시퀀스 확인
SELECT sequence_name FROM user_sequences WHERE sequence_name = 'SEQ_WISHLIST_ID';

-- 현재 사용자 확인
SELECT USER FROM dual;

-- 권한 확인
SELECT * FROM user_tab_privs WHERE table_name = 'WISHLIST';