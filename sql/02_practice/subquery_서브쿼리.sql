-- ============================================================
-- [실습 기록] 서브쿼리 (2026-07-23)
-- 노트: docs/notes/subquery_서브쿼리.md (섹션 완료 시 작성)
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- 도입: WHERE에는 집계 함수를 못 쓴다
-- ------------------------------------------------------------
-- SELECT id FROM complaint WHERE satisfaction_score >= AVG(satisfaction_score);  -- ❌ 에러

-- ------------------------------------------------------------
-- 스칼라 서브쿼리 (1행 1열 = 값 하나)
-- ------------------------------------------------------------
-- 습관: 서브쿼리는 항상 단독 검증 먼저!
SELECT AVG(satisfaction_score) FROM complaint WHERE status = '완료';   -- 3.16

-- 전체 평균 이상 만족도의 완료 민원 (데이터 바뀌면 기준도 자동 갱신)
SELECT id, title, satisfaction_score
FROM complaint
WHERE status = '완료'
  AND satisfaction_score >= (SELECT AVG(satisfaction_score)
                             FROM complaint
                             WHERE status = '완료');

-- 가장 최근 접수 민원 (동점자까지 전부 나옴 — LIMIT 1과의 차이)
SELECT id, title, created_at
FROM complaint
WHERE created_at = (SELECT MAX(created_at) FROM complaint);

-- ------------------------------------------------------------
-- 다중 행 서브쿼리 (N행 1열 = 목록) — IN / NOT IN
-- ------------------------------------------------------------
-- 만족도 5점을 준 적 있는 민원인 명단 (17명)
SELECT id, name, region
FROM citizen
WHERE id IN (SELECT citizen_id
             FROM complaint
             WHERE satisfaction_score = 5);

-- ⚠️ NOT IN + NULL 함정: 목록에 NULL이 있으면 무조건 0행!
-- id NOT IN (9, 18, NULL) = id≠9 AND id≠18 AND id≠NULL(unknown) → 전원 탈락
SELECT id, name
FROM officer
WHERE id NOT IN (SELECT officer_id
                 FROM complaint
                 WHERE status IN ('보류', '접수'));   -- 0행 (함정!)

-- ✅ 수정: NOT IN 서브쿼리엔 IS NOT NULL 반사적으로 (7명 나옴)
SELECT id, name
FROM officer
WHERE id NOT IN (SELECT officer_id
                 FROM complaint
                 WHERE status IN ('보류', '접수')
                   AND officer_id IS NOT NULL);

-- ------------------------------------------------------------
-- ANY / ALL: ANY = 하나만 이기면 됨(≡MIN) / ALL = 전부 이겨야 함(≡MAX)
-- 실무에선 (SELECT MAX/MIN ...) 스칼라 치환이 정석
-- ------------------------------------------------------------
-- > ALL: 도로관리과 최댓값(5)보다 커야 → 0행 (불가능)
SELECT id, department_id, satisfaction_score
FROM complaint
WHERE status = '완료' AND department_id != 2
  AND satisfaction_score > ALL (SELECT satisfaction_score
                                FROM complaint
                                WHERE status = '완료' AND department_id = 2);

-- > ANY: 도로관리과 최솟값(1)보다 크면 → 139행
SELECT COUNT(*)
FROM complaint
WHERE status = '완료' AND department_id != 2
  AND satisfaction_score > ANY (SELECT satisfaction_score
                                FROM complaint
                                WHERE status = '완료' AND department_id = 2);

-- ------------------------------------------------------------
-- 상관 서브쿼리: 바깥 행마다 재실행 (연결 고리 = 조인의 ON과 같은 역할)
-- ------------------------------------------------------------
-- 자기 부서 평균보다 잘 받은 완료 민원 (82행)
SELECT c1.id, c1.department_id, c1.satisfaction_score
FROM complaint c1
WHERE c1.status = '완료'
  AND c1.satisfaction_score > (SELECT AVG(c2.satisfaction_score)
                               FROM complaint c2
                               WHERE c2.status = '완료'
                                 AND c2.department_id = c1.department_id);

-- EXISTS: 접수 민원이 하나라도 있는 부서 (6부서, 감사담당관 제외)
SELECT d.id, d.name
FROM department d
WHERE EXISTS (SELECT 1 FROM complaint c
              WHERE c.department_id = d.id AND c.status = '접수');

-- NOT EXISTS: 반려가 한 건도 없는 부서 (감사담당관) — NULL 함정 면역!
SELECT d.id, d.name
FROM department d
WHERE NOT EXISTS (SELECT 1 FROM complaint c
                  WHERE c.department_id = d.id AND c.status = '반려');

-- ------------------------------------------------------------
-- SELECT 절 서브쿼리 (칼럼처럼) — 상관 스칼라
-- ------------------------------------------------------------
-- 부서 목록 + 민원 수 (감사담당관 0 — COUNT는 셀 게 없으면 0)
SELECT d.id, d.name,
       (SELECT COUNT(*)
        FROM complaint c
        WHERE c.department_id = d.id) AS 민원수
FROM department d;

-- ------------------------------------------------------------
-- FROM 절 서브쿼리 (테이블처럼, 인라인 뷰) — 별칭 필수!
-- ------------------------------------------------------------
-- 현황판을 표로 만들어 재조회 (단, 이 케이스는 HAVING으로도 가능 — 학습자 지적 ✔)
SELECT 부서명, 민원수, 평균만족도
FROM (SELECT d.name AS 부서명,
             COUNT(c.id) AS 민원수,
             IFNULL(ROUND(AVG(c.satisfaction_score), 2), 0) AS 평균만족도
      FROM department d
      LEFT JOIN complaint c ON c.department_id = d.id
      GROUP BY d.id) AS stats
WHERE 민원수 >= 40;

-- FROM 서브쿼리가 "필수"인 경우: 집계의 집계
-- 부서 평균들의 평균 = 3.20 (전체 평균 3.16과 다름 — 가중 vs 비가중)
SELECT ROUND(AVG(평균만족도), 2) AS 부서평균의평균
FROM (SELECT department_id,
             AVG(satisfaction_score) AS 평균만족도
      FROM complaint
      WHERE status = '완료'
      GROUP BY department_id) AS t;

-- 상관 서브쿼리 ↔ JOIN 변환 예 (자기 부서 평균 비교, 동일 82행)
SELECT c.id, c.department_id, c.satisfaction_score
FROM complaint c
INNER JOIN (SELECT department_id, AVG(satisfaction_score) AS avg_s
            FROM complaint WHERE status = '완료'
            GROUP BY department_id) t
        ON c.department_id = t.department_id
WHERE c.status = '완료'
  AND c.satisfaction_score > t.avg_s;

-- ------------------------------------------------------------
-- 서브쿼리 vs JOIN/HAVING 판단 기준
-- "그룹핑 1번으로 답 나오면 서브쿼리 쓰지 마라"
--  · 그룹 집계로 그룹 필터        → HAVING
--  · 전체 집계값 하나와 행 비교    → 스칼라
--  · 집계의 집계 / 집계+원본 조인 → FROM 서브쿼리 필수
--  · "~가 없는 X"               → NOT EXISTS / LEFT JOIN+IS NULL
-- ------------------------------------------------------------
