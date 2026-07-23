-- ============================================================
-- [실습 기록] 섹션 7. 집계와 그룹핑 (2026-07-23)
-- 노트: docs/notes/section7_집계와그룹핑.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- 45. 집계 함수
-- ------------------------------------------------------------
-- COUNT(*) vs COUNT(칼럼): 후자는 NULL 제외 (300 vs 268)
SELECT COUNT(*) FROM complaint;
SELECT COUNT(officer_id) FROM complaint;

-- 집계 함수는 NULL 무시: AVG = 582/184 = 3.16 (582/300 아님!)
SELECT AVG(satisfaction_score) FROM complaint WHERE status = '완료';
SELECT SUM(satisfaction_score), MAX(satisfaction_score), MIN(satisfaction_score)
FROM complaint;

-- ------------------------------------------------------------
-- 46. GROUP BY — 그룹으로 묶기
-- ------------------------------------------------------------
-- 상태별 민원 건수 (그룹당 1행 → 5행)
SELECT status, COUNT(*)
FROM complaint
GROUP BY status;

-- 카테고리별 건수, 많은 순
SELECT category, COUNT(*) AS cnt
FROM complaint
GROUP BY category
ORDER BY cnt DESC;

-- 부서별 완료 민원 평균 만족도 (WHERE는 그룹핑 "전" 행 필터)
SELECT department_id, ROUND(AVG(satisfaction_score), 2) AS avg_score
FROM complaint
WHERE status = '완료'
GROUP BY department_id;
-- 결과: 1→3.04, 2→3.10, 3→3.03, 4→3.36, 5→3.58(1등), 6→3.11

-- ------------------------------------------------------------
-- 47. GROUP BY — 주의사항
-- ------------------------------------------------------------
-- 1055 에러 체험: title은 그룹당 1개로 확정되지 않음
-- SELECT status, title, COUNT(*) FROM complaint GROUP BY status;  -- ❌ 에러

-- 규칙에 맞게: 그룹 키 + 집계 함수만
SELECT status, COUNT(*) AS cnt, MAX(created_at) AS 최근접수
FROM complaint
GROUP BY status;

-- 다중 그룹핑: (부서, 상태) 조합별
SELECT department_id, status, COUNT(*) AS cnt
FROM complaint
GROUP BY department_id, status
ORDER BY department_id, status;

-- ------------------------------------------------------------
-- 48. HAVING — 그룹 필터링 1
-- ------------------------------------------------------------
-- WHERE = 행 필터(그룹핑 전) / HAVING = 그룹 필터(그룹핑 후)
SELECT department_id, COUNT(*) AS cnt
FROM complaint
GROUP BY department_id
HAVING cnt >= 45;

-- WHERE + HAVING 공존
SELECT department_id, ROUND(AVG(satisfaction_score), 2) AS avg_score
FROM complaint
WHERE status = '완료'
GROUP BY department_id
HAVING avg_score >= 3.1;
-- 4번(3.36), 5번(3.58), 6번(3.11) 생존

-- ------------------------------------------------------------
-- 49. HAVING — 그룹 필터링 2
-- ------------------------------------------------------------
-- 표준 방식: 집계식 직접 (별칭은 MySQL 확장)
SELECT category, COUNT(*) AS cnt
FROM complaint
GROUP BY category
HAVING COUNT(*) >= 45;

-- SELECT에 없는 집계로도 필터 가능
SELECT department_id, COUNT(*) AS 민원수
FROM complaint
WHERE status = '완료'
GROUP BY department_id
HAVING AVG(satisfaction_score) >= 3.1;

-- 안티패턴: 행 조건을 HAVING에 (동작하지만 WHERE로!)
-- SELECT department_id, COUNT(*) FROM complaint GROUP BY department_id HAVING department_id <= 3;

-- ------------------------------------------------------------
-- 50. SQL 실행 순서
-- FROM → WHERE → GROUP BY(+집계) → HAVING → SELECT(별칭 탄생) → ORDER BY → LIMIT
-- ------------------------------------------------------------
-- 별칭을 WHERE에 쓰면 에러 (WHERE 시점에 별칭 미탄생)
-- SELECT department_id, COUNT(*) AS cnt FROM complaint WHERE cnt >= 45 GROUP BY department_id;  -- ❌

-- 종합: 완료 20건 이상 부서 중 평균 만족도 TOP 3
-- 300행 → WHERE 184행 → 6그룹 → HAVING 5그룹(6번 탈락) → 정렬 → 3행
SELECT department_id, ROUND(AVG(satisfaction_score), 2) AS avg_score, COUNT(*) AS cnt
FROM complaint
WHERE status = '완료'
GROUP BY department_id
HAVING COUNT(*) >= 20
ORDER BY avg_score DESC
LIMIT 3;

-- ------------------------------------------------------------
-- 51. 문제와 풀이 (정답 기록)
-- ------------------------------------------------------------
-- Q1. 채널별 민원 건수 많은 순 (온라인 147 / 전화 91 / 방문 62)
SELECT channel, COUNT(*) AS cnt
FROM complaint GROUP BY channel ORDER BY cnt DESC;

-- Q2. 월별 접수 추이 (최신 월부터)
SELECT DATE_FORMAT(created_at, '%Y-%m') AS 접수월, COUNT(*) AS cnt
FROM complaint GROUP BY 접수월 ORDER BY 접수월 DESC;

-- Q3. 다발 민원인 TOP 5 (23번 14건 1등)
SELECT citizen_id, COUNT(*) AS cnt
FROM complaint GROUP BY citizen_id ORDER BY cnt DESC LIMIT 5;

-- Q4. 부서별 평균 처리일 10일 이하, 빠른 순 (5번 8.9일 1등)
SELECT department_id, ROUND(AVG(DATEDIFF(closed_at, created_at)), 1) AS avg_days
FROM complaint WHERE status = '완료'
GROUP BY department_id HAVING avg_days <= 10 ORDER BY avg_days;

-- Q5. 카테고리별 완료율 (비교식 1/0 성질 활용, 소음 75.5% 1등)
SELECT category, COUNT(*) AS total,
       SUM(status = '완료') AS done,
       ROUND(SUM(status = '완료') / COUNT(*) * 100, 1) AS done_rate
FROM complaint GROUP BY category ORDER BY done_rate DESC;
