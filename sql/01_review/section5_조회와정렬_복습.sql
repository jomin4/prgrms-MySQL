-- ============================================================
-- [복습] 섹션 5. SQL - 조회와 정렬 (SELECT / WHERE / ORDER BY / LIMIT / DISTINCT / NULL)
-- 환경: minwon DB (민원 시스템)
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- Q1. (SELECT) 민원 전체를 조회하되, id·title·status·created_at 칼럼만 보세요.



-- Q2. (WHERE) 상태가 '처리중'인 민원만 조회하세요.



-- Q3. (WHERE-비교) 만족도 점수가 4점 이상인 완료 민원을 조회하세요. (id, title, satisfaction_score)



-- Q4. (WHERE-편리한 조건) 카테고리가 '도로' 또는 '교통'인 민원을 IN을 사용해 조회하세요.



-- Q5. (WHERE-LIKE) 제목에 '소음'이라는 단어가 들어간 민원을 조회하세요.



-- Q6. (WHERE-BETWEEN) 2026년 1월 1일 ~ 2026년 3월 31일 사이에 접수된 민원을 조회하세요.



-- Q7. (ORDER BY) 민원을 최신 접수순으로 정렬해서 조회하세요.



-- Q8. (ORDER BY-다중) 상태 오름차순 → 같은 상태 안에서는 최신 접수순으로 정렬하세요.



-- Q9. (LIMIT) 가장 최근에 접수된 민원 5건만 조회하세요.



-- Q10. (DISTINCT) 민원 카테고리의 종류(중복 제거)를 조회하세요.



-- Q11. (NULL) 아직 담당자가 배정되지 않은 민원을 조회하세요.
--      주의: = NULL 이 아니라 IS NULL!



-- Q12. (NULL) 담당자가 배정된 민원 수를 세지 말고, 우선 배정된 민원만 조회해보세요.



-- ============================================================
-- [정답]
-- ============================================================
-- A1. SELECT id, title, status, created_at FROM complaint;
-- A2. SELECT * FROM complaint WHERE status = '처리중';
-- A3. SELECT id, title, satisfaction_score FROM complaint
--     WHERE status = '완료' AND satisfaction_score >= 4;
-- A4. SELECT * FROM complaint WHERE category IN ('도로', '교통');
-- A5. SELECT * FROM complaint WHERE title LIKE '%소음%';
-- A6. SELECT * FROM complaint
--     WHERE created_at BETWEEN '2026-01-01 00:00:00' AND '2026-03-31 23:59:59';
--     (또는 WHERE created_at >= '2026-01-01' AND created_at < '2026-04-01')
-- A7. SELECT * FROM complaint ORDER BY created_at DESC;
-- A8. SELECT * FROM complaint ORDER BY status ASC, created_at DESC;
-- A9. SELECT * FROM complaint ORDER BY created_at DESC LIMIT 5;
-- A10. SELECT DISTINCT category FROM complaint;
-- A11. SELECT * FROM complaint WHERE officer_id IS NULL;
-- A12. SELECT * FROM complaint WHERE officer_id IS NOT NULL;
