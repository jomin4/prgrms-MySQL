-- ============================================================
-- [실습 기록] 인덱스 1 — 기초 (2026-07-23)
-- 노트: docs/notes/index1_인덱스기초.md
-- 실습 테이블: member (약 104만 건, loginId/loginPw/name)
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- 실습 준비: 대량 데이터 (인덱스 효과 체감용)
-- ------------------------------------------------------------
-- CREATE TABLE member (
--     id INT UNSIGNED NOT NULL AUTO_INCREMENT,
--     loginId VARCHAR(100) NOT NULL, loginPw VARCHAR(100) NOT NULL, name VARCHAR(100) NOT NULL,
--     PRIMARY KEY (id));
-- INSERT INTO member (loginId,loginPw,name) VALUES ('user1','user1','홍길동'),('user2','user2','홍길순');
-- 아래를 반복 실행해 2배씩 증식 (UUID로 loginId 중복 회피)
-- INSERT INTO member (loginId,loginPw,name) SELECT UUID(),'pw','아무개' FROM member;

-- ------------------------------------------------------------
-- Before: 인덱스 없이 검색 (Full Table Scan)
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM member WHERE loginId = 'user1';   -- type: ALL, key: NULL (느림)
SELECT * FROM member WHERE loginId = 'user1';

-- ------------------------------------------------------------
-- 인덱스 생성 / 조회 / 삭제
-- ------------------------------------------------------------
CREATE INDEX idx_loginId ON member (loginId);   -- 값 정렬해 B-Tree 구성 (생성 느림)
SHOW INDEX FROM member;
-- ALTER TABLE member DROP INDEX idx_loginId;    -- 또는 DROP INDEX idx_loginId ON member;

-- After: 같은 검색 (type: ALL→ref, key: idx_loginId, 시간 극적 감소)
EXPLAIN SELECT * FROM member WHERE loginId = 'user1';
SELECT * FROM member WHERE loginId = 'user1';

-- ------------------------------------------------------------
-- 인덱스가 "먹는" 조건
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM member WHERE loginId = 'user1';           -- ref (동등)
EXPLAIN SELECT * FROM member WHERE id BETWEEN 100 AND 200;      -- range (범위)
EXPLAIN SELECT * FROM member WHERE id > 1000000;               -- range
EXPLAIN SELECT * FROM member WHERE loginId IN ('user1','user2');-- range (동등 여러개)

-- ------------------------------------------------------------
-- 인덱스가 "안 먹는" 조건 ★핵심
-- 철칙: 인덱스 칼럼은 조건절에서 "맨몸"으로! 함수·연산으로 감싸면 죽는다
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM member WHERE SUBSTRING(loginId,1,5) = 'user1';  -- ALL (함수 씌움)
EXPLAIN SELECT * FROM member WHERE id + 1 = 101;                      -- ALL (연산)

-- ------------------------------------------------------------
-- LIKE: 앞부분 고정일 때만 인덱스 사용
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM member WHERE loginId LIKE 'user%';  -- range (앞 고정 → 먹힘)
EXPLAIN SELECT * FROM member WHERE loginId LIKE '%user';  -- ALL (앞 %→ 무효). 필요시 Full-Text

-- ------------------------------------------------------------
-- 정렬: 인덱스 = 이미 정렬된 결과 → filesort 회피
-- ------------------------------------------------------------
EXPLAIN SELECT id FROM member ORDER BY loginId LIMIT 10;  -- Extra: filesort 없음 (인덱스 순서 이용)
EXPLAIN SELECT * FROM member ORDER BY name LIMIT 10;      -- Extra: Using filesort (별도 정렬)
