-- ============================================================
-- [실습 기록] UNION (2026-07-23)
-- 노트: docs/notes/union_유니온.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- UNION 기본: 결과를 세로로 이어붙임 (JOIN=가로, UNION=세로)
-- 규칙: 칼럼 개수 동일 / 칼럼명은 첫 SELECT 기준
-- ------------------------------------------------------------
SELECT id, title, status FROM complaint WHERE status = '완료'
UNION
SELECT id, title, status FROM complaint WHERE status = '반려';

-- ------------------------------------------------------------
-- UNION vs UNION ALL
-- ------------------------------------------------------------
-- UNION: 중복 제거 (region 5개 구 → 5행). 정렬/비교로 느림
SELECT region FROM citizen
UNION
SELECT region FROM citizen;

-- UNION ALL: 중복 유지 (40 + 40 = 80행). 실무 기본 선택
SELECT region FROM citizen
UNION ALL
SELECT region FROM citizen;

-- ------------------------------------------------------------
-- UNION + ORDER BY: 맨 끝에 한 번, 전체 결과 대상
-- ------------------------------------------------------------
SELECT id, title, status FROM complaint WHERE status = '완료'
UNION ALL
SELECT id, title, status FROM complaint WHERE status = '반려'
ORDER BY id;

-- ------------------------------------------------------------
-- 실전 1: 서로 다른 테이블 명단 통합 (구분 칼럼으로 출처 표시)
-- ------------------------------------------------------------
SELECT name, email, '담당자' AS 구분 FROM officer
UNION ALL
SELECT name, phone, '민원인' AS 구분 FROM citizen;   -- 18 + 40 = 58행

-- ------------------------------------------------------------
-- 실전 2: 집계 + 총계 행 (엑셀 피벗 하단 총계 흉내)
-- ORDER BY (비교식) → 비교식은 참=1/거짓=0, 오름차순이라 합계행(1)이 맨 아래
-- ------------------------------------------------------------
SELECT d.name AS 부서명, COUNT(c.id) AS 민원수
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
GROUP BY d.id
UNION ALL
SELECT '── 전체 합계 ──', COUNT(*) FROM complaint
ORDER BY (부서명 = '── 전체 합계 ──'), 민원수 DESC;
