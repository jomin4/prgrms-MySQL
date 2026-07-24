-- ============================================================
-- [실습 기록] 뷰(View) (2026-07-23)
-- 노트: docs/notes/view_뷰.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- 개념: 뷰 = 이름 붙여 저장한 SELECT문 = 가상의 표
--       데이터 복사 X → 조회할 때마다 뒤의 SELECT 재실행 → 항상 최신
-- ------------------------------------------------------------

-- 생성: 복잡한 현황판에 이름 붙이기 (관례: v_ 접두사)
CREATE VIEW v_dept_status AS
SELECT d.name AS 부서명,
       SUM(CASE WHEN c.status = '접수'  THEN 1 ELSE 0 END) AS 접수,
       SUM(CASE WHEN c.status = '처리중' THEN 1 ELSE 0 END) AS 처리중,
       SUM(CASE WHEN c.status = '완료'  THEN 1 ELSE 0 END) AS 완료,
       SUM(CASE WHEN c.status = '반려'  THEN 1 ELSE 0 END) AS 반려,
       COUNT(c.id) AS 합계
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
GROUP BY d.id;

-- 조회: 진짜 테이블처럼
SELECT * FROM v_dept_status;

-- 뷰 위에 조건 얹기 (뷰의 진가 — 복잡함을 숨긴 인터페이스)
SELECT 부서명, 완료 FROM v_dept_status WHERE 완료 >= 20 ORDER BY 완료 DESC;

-- 보안용 뷰: 민감 칼럼 제외하고 노출
CREATE VIEW v_citizen_public AS
SELECT id, name, region FROM citizen;   -- phone, birth_year 제외

-- ------------------------------------------------------------
-- 수정 / 확인 / 삭제
-- ------------------------------------------------------------
-- CREATE OR REPLACE VIEW v_dept_status AS SELECT ...;   -- 정의 교체
SHOW CREATE VIEW v_dept_status;                          -- 정의 확인

-- 집계 뷰는 읽기 전용 → UPDATE 에러 확인
-- UPDATE v_dept_status SET 완료 = 999 WHERE 부서명 = '민원봉사과';  -- ❌ not updatable

-- 삭제 (원본 테이블은 안전, 저장된 쿼리만 제거)
DROP VIEW IF EXISTS v_dept_status;
DROP VIEW IF EXISTS v_citizen_public;

-- ------------------------------------------------------------
-- 장단점 요약
-- 장점: 복잡 쿼리 재사용 / 보안(민감칼럼 은닉) / 추상화
-- 단점: 성능(매번 재실행, 미리계산 아님) / 집계·JOIN 뷰는 수정 불가 / 중첩 지양
--       (미리 계산: Materialized View는 MySQL 미지원)
-- ------------------------------------------------------------
