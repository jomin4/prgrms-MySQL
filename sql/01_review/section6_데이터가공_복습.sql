-- ============================================================
-- [복습] 섹션 6. SQL - 데이터 가공 (산술 연산 / 문자열 함수 / NULL 함수 / 다양한 함수)
-- 환경: minwon DB (민원 시스템)
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- Q1. (산술 연산) 민원인의 만 나이를 계산해 조회하세요. (기준: 2026년)
--     출력: name, birth_year, 나이(2026 - birth_year)



-- Q2. (문자열 함수) 민원인 이름과 전화번호를 아래 형식으로 조회하세요.
--     형식: '강민준(010-1000-0001)' → CONCAT 사용



-- Q3. (문자열 함수) 민원 제목의 길이가 긴 순서로 상위 5건을 조회하세요.
--     출력: title, CHAR_LENGTH(title)



-- Q4. (문자열 함수) 민원인 전화번호의 뒷자리 4자리만 조회하세요. (SUBSTRING 또는 RIGHT)



-- Q5. (NULL 함수) 민원 목록에서 담당자 미배정(NULL)이면 0으로 표시하세요.
--     출력: id, title, IFNULL(officer_id, 0)



-- Q6. (NULL 함수) 만족도 점수가 NULL이면 '미평가'로 표시하세요.
--     힌트: 숫자와 문자를 섞으려면 COALESCE(CAST(... AS CHAR), '미평가') 또는 IFNULL 활용



-- Q7. (날짜 함수) 완료된 민원의 처리 소요일을 조회하세요.
--     출력: id, title, DATEDIFF(closed_at, created_at) AS 처리일수



-- Q8. (날짜 함수) 민원 접수일의 연도·월만 뽑아 조회하세요.
--     힌트: YEAR(), MONTH() 또는 DATE_FORMAT(created_at, '%Y-%m')



-- Q9. (반올림 함수) 완료 민원의 만족도 평균을 소수 둘째 자리까지 구하세요.
--     힌트: ROUND(AVG(...), 2)  ← 집계 맛보기!



-- ============================================================
-- [정답]
-- ============================================================
-- A1. SELECT name, birth_year, 2026 - birth_year AS 나이 FROM citizen;
-- A2. SELECT CONCAT(name, '(', phone, ')') AS 연락처 FROM citizen;
-- A3. SELECT title, CHAR_LENGTH(title) AS 길이 FROM complaint
--     ORDER BY 길이 DESC LIMIT 5;
-- A4. SELECT name, RIGHT(phone, 4) AS 뒷번호 FROM citizen;
--     (또는 SUBSTRING(phone, -4))
-- A5. SELECT id, title, IFNULL(officer_id, 0) AS 담당자 FROM complaint;
-- A6. SELECT id, title, IFNULL(CAST(satisfaction_score AS CHAR), '미평가') AS 만족도
--     FROM complaint;
-- A7. SELECT id, title, DATEDIFF(closed_at, created_at) AS 처리일수
--     FROM complaint WHERE closed_at IS NOT NULL;
-- A8. SELECT id, DATE_FORMAT(created_at, '%Y-%m') AS 접수월 FROM complaint;
-- A9. SELECT ROUND(AVG(satisfaction_score), 2) AS 평균만족도
--     FROM complaint WHERE status = '완료';
