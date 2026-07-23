-- ============================================================
-- [복습] 섹션 4. SQL - 데이터 관리 (DDL / DML / 제약조건)
-- 환경: minwon DB (민원 시스템)
-- 방법: 각 문제 아래에 직접 타이핑해서 실행해보세요.
--       정답은 파일 맨 아래 [정답] 섹션에 있습니다.
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- Q1. (DDL-조회) minwon DB의 모든 테이블을 확인하고,
--     complaint 테이블의 구조(칼럼/타입/제약)를 확인하세요.



-- Q2. (DDL-생성) 민원 처리 중 참고할 '공지사항' 테이블 notice를 생성하세요.
--     칼럼: id (INT UNSIGNED, PK, AUTO_INCREMENT)
--           title (VARCHAR(200), NOT NULL)
--           content (TEXT, NOT NULL)
--           created_at (DATETIME, NOT NULL, 기본값 현재시각)



-- Q3. (DDL-변경) notice 테이블에 조회수 칼럼 view_count(INT UNSIGNED, NOT NULL, 기본값 0)를 추가하세요.



-- Q4. (DDL-변경) view_count 칼럼명을 hit_count로 변경하세요. (타입/제약 유지)



-- Q5. (DML-등록) notice에 공지 2건을 등록하세요.
--     (1) '민원 처리 기간 안내' / '일반 민원은 접수일로부터 14일 이내 처리됩니다.'
--     (2) '시스템 점검 안내'   / '7월 25일 02시~04시 시스템 점검이 예정되어 있습니다.'



-- Q6. (DML-수정) '시스템 점검 안내' 공지의 hit_count를 10으로 수정하세요.



-- Q7. (DML-삭제) '민원 처리 기간 안내' 공지를 삭제하세요.



-- Q8. (제약조건) 아래 INSERT는 왜 실패할까요? 실행해보고 이유를 주석으로 남기세요.
--     INSERT INTO complaint (citizen_id, department_id, category, title, content, status, channel, created_at)
--     VALUES (9999, 1, '기타', '테스트', '테스트', '접수', '온라인', NOW());
-- 이유:



-- Q9. (DDL-제거) notice 테이블을 삭제하세요.



-- ============================================================
-- [정답]
-- ============================================================
-- A1.
-- SHOW TABLES;
-- DESC complaint;

-- A2.
-- CREATE TABLE notice (
--     id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
--     title      VARCHAR(200) NOT NULL,
--     content    TEXT         NOT NULL,
--     created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
--     PRIMARY KEY (id)
-- );

-- A3.
-- ALTER TABLE notice ADD COLUMN view_count INT UNSIGNED NOT NULL DEFAULT 0;

-- A4.
-- ALTER TABLE notice CHANGE COLUMN view_count hit_count INT UNSIGNED NOT NULL DEFAULT 0;

-- A5.
-- INSERT INTO notice (title, content) VALUES
--     ('민원 처리 기간 안내', '일반 민원은 접수일로부터 14일 이내 처리됩니다.'),
--     ('시스템 점검 안내', '7월 25일 02시~04시 시스템 점검이 예정되어 있습니다.');

-- A6.
-- UPDATE notice SET hit_count = 10 WHERE title = '시스템 점검 안내';

-- A7.
-- DELETE FROM notice WHERE title = '민원 처리 기간 안내';

-- A8. citizen_id=9999인 민원인이 없어서 외래 키(FOREIGN KEY) 제약 위반으로 실패.
--     (Cannot add or update a child row: a foreign key constraint fails)

-- A9.
-- DROP TABLE notice;
