-- ============================================================
-- [실습 기록] 조인 2 — 외부 조인 (2026-07-23)
-- 노트: docs/notes/join2_외부조인.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- LEFT JOIN: 왼쪽 행 전부 유지, 짝 없으면 오른쪽 NULL
-- ------------------------------------------------------------
-- INNER 268행 → LEFT 300행 (접수 32건이 담당자 NULL로 생존)
SELECT c.id, c.status, o.name AS 담당자
FROM complaint c
LEFT JOIN officer o ON c.officer_id = o.id;

-- ------------------------------------------------------------
-- LEFT JOIN + IS NULL: "짝 없는 행만" 관용구 (미배정 민원 32건)
-- ------------------------------------------------------------
SELECT c.id, c.title, c.status
FROM complaint c
LEFT JOIN officer o ON c.officer_id = o.id
WHERE o.id IS NULL;

-- ------------------------------------------------------------
-- 민원 0건 부서 포함 통계 + COUNT 함정
-- ------------------------------------------------------------
-- COUNT(c.id): 감사담당관 0 ✅ (NULL 제외)
SELECT d.name AS 부서명, COUNT(c.id) AS 민원수
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
GROUP BY d.id;

-- COUNT(*): 감사담당관 1 ❌ (NULL로 채워진 행도 "행"이라 세어버림)
SELECT d.name AS 부서명, COUNT(*) AS 민원수
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
GROUP BY d.id;
-- 철칙: LEFT JOIN + 집계 개수는 COUNT(오른쪽테이블.칼럼)!

-- ------------------------------------------------------------
-- RIGHT JOIN: A LEFT JOIN B ≡ B RIGHT JOIN A (실무는 LEFT로 통일)
-- ------------------------------------------------------------
SELECT d.name AS 부서명, COUNT(c.id) AS 민원수
FROM complaint c
RIGHT JOIN department d ON c.department_id = d.id
GROUP BY d.id;

-- ------------------------------------------------------------
-- NULL 표현 다듬기 + 실전 완성형 현황판
-- ------------------------------------------------------------
SELECT c.id, c.status, IFNULL(o.name, '(미배정)') AS 담당자
FROM complaint c
LEFT JOIN officer o ON c.officer_id = o.id
ORDER BY c.id
LIMIT 10;

-- 전 부서 민원 현황판 (감사담당관 0 / 0.00 등장)
SELECT d.name AS 부서명,
       COUNT(c.id) AS 민원수,
       IFNULL(ROUND(AVG(c.satisfaction_score), 2), 0) AS 평균만족도
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
GROUP BY d.id
ORDER BY 민원수 DESC;
