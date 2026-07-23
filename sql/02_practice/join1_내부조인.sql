-- ============================================================
-- [실습 기록] 조인 1 — 내부 조인 (2026-07-23)
-- 노트: docs/notes/join1_내부조인.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- 내부 조인 기본
-- ------------------------------------------------------------
-- 민원 목록 + 부서 이름 (ON = 짝짓기 규칙)
SELECT complaint.id, complaint.title, department.name
FROM complaint
INNER JOIN department ON complaint.department_id = department.id;

-- 별칭(AS 생략 가능)
SELECT c.id, c.title, d.name AS dept_name
FROM complaint AS c
INNER JOIN department AS d ON c.department_id = d.id;

-- 섹션 7 쿼리 업그레이드: 부서 "이름"으로 보고 (1등: 정보통신과 3.58)
SELECT d.name AS 부서명, ROUND(AVG(c.satisfaction_score), 2) AS 평균만족도
FROM complaint c
INNER JOIN department d ON c.department_id = d.id
WHERE c.status = '완료'
GROUP BY d.name
ORDER BY 평균만족도 DESC;

-- ------------------------------------------------------------
-- 조인의 본질: ON을 빼는 실험 (카티전 곱)
-- ------------------------------------------------------------
-- ON 생략 → 300 × 7 = 2,100행 (모든 조합)
SELECT COUNT(*) FROM complaint INNER JOIN department;

-- 1번 민원이 7개 부서 전부와 짝지어짐 (엉터리 조합 확인)
SELECT c.id, c.title, d.name
FROM complaint c
INNER JOIN department d
ORDER BY c.id
LIMIT 10;

-- ON 복원 → 300행 (department_id는 NOT NULL + FK라 전원 짝 있음)
SELECT COUNT(*) FROM complaint c INNER JOIN department d ON c.department_id = d.id;

-- ------------------------------------------------------------
-- INNER JOIN의 치명적 특성: NULL 행 증발
-- ------------------------------------------------------------
-- officer_id NULL(접수) 32건이 짝을 못 맺어 증발 → 268행
SELECT COUNT(*)
FROM complaint c
INNER JOIN officer o ON c.officer_id = o.id;

-- ------------------------------------------------------------
-- 다중 테이블 조인 (체인)
-- ------------------------------------------------------------
-- 3개: 민원 + 부서 + 민원인 (300행 유지)
SELECT c.id, c.title, d.name AS 부서, z.name AS 민원인
FROM complaint c
INNER JOIN department d ON c.department_id = d.id
INNER JOIN citizen z ON c.citizen_id = z.id
ORDER BY c.id
LIMIT 10;

-- 4개: + 담당자 (officer 조인에서 32건 증발 → 268행)
SELECT c.id, c.title, c.status,
       d.name AS 부서, o.name AS 담당자, o.grade AS 직급, z.name AS 민원인
FROM complaint c
INNER JOIN department d ON c.department_id = d.id
INNER JOIN officer    o ON c.officer_id = o.id
INNER JOIN citizen    z ON c.citizen_id = z.id
ORDER BY c.id
LIMIT 10;

-- ------------------------------------------------------------
-- 조인 + 집계 종합: 우수 담당자 TOP 5 (1등: 송예린/정보통신과 10건 4.00)
-- 포인트1: 조인 경로 — 부서를 o.department_id(담당자 소속)로 연결
-- 포인트2: GROUP BY o.id(PK) → 함수적 종속으로 o.name 등 SELECT 허용
-- ------------------------------------------------------------
SELECT o.name AS 담당자, d.name AS 부서,
       COUNT(*) AS 완료건수,
       ROUND(AVG(c.satisfaction_score), 2) AS 평균만족도
FROM complaint c
INNER JOIN officer    o ON c.officer_id = o.id
INNER JOIN department d ON o.department_id = d.id
WHERE c.status = '완료'
GROUP BY o.id
ORDER BY 평균만족도 DESC
LIMIT 5;
