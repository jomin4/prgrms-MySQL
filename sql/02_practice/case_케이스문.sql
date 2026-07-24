-- ============================================================
-- [실습 기록] CASE 문 (2026-07-23)
-- 노트: docs/notes/case_케이스문.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- CASE 기본 — SQL의 if-else
-- 형태 A (Searched): 조건식 직접 — 범위/복합 조건 가능 (주력)
-- 형태 B (Simple): 한 칼럼 등호 비교만
-- ------------------------------------------------------------

-- 형태 A: 연령대 분류 (위에서부터 검사, 처음 참에서 멈춤 → 순서 중요)
SELECT name, birth_year,
       CASE WHEN 2026 - birth_year >= 60 THEN '60대이상'
            WHEN 2026 - birth_year >= 40 THEN '40~50대'
            WHEN 2026 - birth_year >= 20 THEN '20~30대'
            ELSE '10대이하'
       END AS 연령대
FROM citizen;

-- 형태 B: status 등호 비교 (범위/AND 불가 → 그럴 땐 형태 A)
SELECT title, status,
       CASE status WHEN '완료' THEN '처리됨'
                   WHEN '반려' THEN '처리됨'
                   ELSE '진행중'
       END AS 처리여부
FROM complaint
LIMIT 10;

-- ------------------------------------------------------------
-- 조건부 집계 = 피벗 (세로 → 가로)
-- SUM(CASE WHEN 조건 THEN 1 ELSE 0 END) = 조건 맞는 것만 세는 카운터
-- ------------------------------------------------------------

-- 부서별 상태 현황판 (부서=행, 상태=열) — LEFT JOIN으로 감사담당관도 0
SELECT d.name AS 부서명,
       SUM(CASE WHEN c.status = '접수'  THEN 1 ELSE 0 END) AS 접수,
       SUM(CASE WHEN c.status = '처리중' THEN 1 ELSE 0 END) AS 처리중,
       SUM(CASE WHEN c.status = '완료'  THEN 1 ELSE 0 END) AS 완료,
       SUM(CASE WHEN c.status = '반려'  THEN 1 ELSE 0 END) AS 반려,
       COUNT(c.id) AS 합계
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
GROUP BY d.id;

-- ------------------------------------------------------------
-- AVG(CASE...) 조건부 평균
-- 철칙: SUM(CASE)엔 ELSE 0 / AVG(CASE)엔 ELSE 생략(NULL) — AVG는 NULL 무시
-- ------------------------------------------------------------
SELECT d.name AS 부서명,
       ROUND(AVG(CASE WHEN c.channel = '온라인' THEN c.satisfaction_score END), 2) AS 온라인만족도,
       ROUND(AVG(CASE WHEN c.channel = '방문'   THEN c.satisfaction_score END), 2) AS 방문만족도
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
WHERE c.status = '완료'
GROUP BY d.id;
