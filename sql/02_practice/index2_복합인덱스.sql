-- ============================================================
-- [실습 기록] 인덱스 2 — 옵티마이저·커버링·복합 인덱스·설계 (2026-07-23)
-- 노트: docs/notes/index2_복합인덱스.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- 옵티마이저: 인덱스가 있어도 결과가 대부분이면 Full Scan 선택
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM member WHERE loginId = 'user1';   -- ref (극소수 → 인덱스)
EXPLAIN SELECT * FROM member WHERE loginId LIKE '9%';   -- ALL (거의 전체 → 인덱스 포기)
-- 인덱스는 "소수를 콕 집을 때" 유리. 카디널리티 낮으면(성별 등) 무의미

-- ------------------------------------------------------------
-- 커버링 인덱스: 필요한 칼럼이 전부 인덱스 안 → 원본 방문 생략
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM member WHERE loginId = 'user1';        -- Using index 없음(원본 방문)
EXPLAIN SELECT loginId FROM member WHERE loginId = 'user1';  -- Extra: Using index (원본 불필요)

-- ------------------------------------------------------------
-- 복합 인덱스: 칼럼 순서가 생명 (최좌측 접두사 원칙)
-- (department_id, status) = 전화번호부 (성, 이름)
-- ------------------------------------------------------------
CREATE INDEX idx_dept_status ON complaint (department_id, status);

EXPLAIN SELECT * FROM complaint WHERE department_id = 3;                      -- ✅ 1차만
EXPLAIN SELECT * FROM complaint WHERE department_id = 3 AND status = '완료';  -- ✅✅ 1+2차
EXPLAIN SELECT * FROM complaint WHERE status = '완료' AND department_id = 3;  -- ✅ 옵티마이저 재배열
EXPLAIN SELECT * FROM complaint WHERE status = '완료';                        -- ❌ 2차 단독 못 씀
-- (300건이라 옵티마이저가 Full Scan 택할 수 있음 — 논리 이해가 핵심)

-- ------------------------------------------------------------
-- 설계 가이드라인 적용: WHERE 등호 + ORDER BY
-- 등호(department_id) 앞, 정렬/범위(created_at) 뒤
-- ------------------------------------------------------------
CREATE INDEX idx_dept_created ON complaint (department_id, created_at);
EXPLAIN SELECT * FROM complaint WHERE department_id = 3 ORDER BY created_at DESC;

-- ------------------------------------------------------------
-- 정리
-- ------------------------------------------------------------
SHOW INDEX FROM complaint;
DROP INDEX idx_dept_status ON complaint;
DROP INDEX idx_dept_created ON complaint;
