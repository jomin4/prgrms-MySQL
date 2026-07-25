-- ============================================================
-- [실습 기록] 트랜잭션 (2026-07-23)
-- 노트: docs/notes/transaction_트랜잭션.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- 트랜잭션이 필요한 이유: "전부 되거나 전부 안 되거나" (계좌 이체)
-- MySQL 기본은 autocommit → 트랜잭션은 명시적으로 시작
-- ------------------------------------------------------------

-- 커밋 & 롤백 실습
SELECT COUNT(*) FROM complaint WHERE status = '접수';   -- 기준점

START TRANSACTION;
UPDATE complaint SET status = '처리중' WHERE status = '접수';
SELECT COUNT(*) FROM complaint WHERE status = '접수';   -- 0 (내 세션에선 보임)
ROLLBACK;                                                -- 되돌리기!
SELECT COUNT(*) FROM complaint WHERE status = '접수';   -- 원복됨

-- 확정 버전 (COMMIT은 되돌릴 수 없음)
-- START TRANSACTION;
-- UPDATE complaint SET status = '처리중' WHERE status = '접수';
-- COMMIT;
-- 복구 필요 시: docker compose down -v && docker compose up -d (시드 재적재)

-- ------------------------------------------------------------
-- 격리 수준 확인
-- ------------------------------------------------------------
SELECT @@transaction_isolation;   -- REPEATABLE-READ (MySQL 기본)
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;  -- 변경(개념)

-- ------------------------------------------------------------
-- ACID
--  Atomicity(원자성)   : 전부 or 전무 (ROLLBACK으로 체감)
--  Consistency(일관성) : 제약 항상 만족 (무결성과 연결)
--  Isolation(격리성)   : 동시 트랜잭션 서로 간섭 안 함
--  Durability(지속성)  : COMMIT되면 서버 죽어도 영구
--
-- 3대 이상현상: Dirty Read / Non-Repeatable Read / Phantom Read
-- 격리 수준(느슨→엄격):
--  READ UNCOMMITTED < READ COMMITTED < REPEATABLE READ(MySQL기본) < SERIALIZABLE
--
-- 실감 실습: DataGrip 콘솔 2개로 한쪽 미커밋 UPDATE, 다른쪽 조회
-- ------------------------------------------------------------
