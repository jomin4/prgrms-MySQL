# [심화] 서브쿼리 ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습 쿼리: [sql/02_practice/subquery_서브쿼리.sql](../../sql/02_practice/subquery_서브쿼리.sql)

## 서브쿼리란?

> **어떤 쿼리의 결과를, 다른 쿼리의 재료로 쓰는 도구.** 결과의 "모양"에 따라 꽂는 자리가 다름.

| 결과 모양 | ~처럼 쓴다 | 꽂는 자리 |
|---|---|---|
| 1행 1열 (스칼라) | 값 | WHERE 비교, SELECT 칼럼 |
| N행 1열 (목록) | 리스트 | `IN`, `ANY`, `ALL` |
| N행 N열 (표) | 테이블 | FROM 절 (인라인 뷰) |

> 습관: **서브쿼리는 항상 단독 실행으로 먼저 검증** → 안쪽 결과를 눈으로 확인하면 바깥은 평범한 조회로 읽힘.

## 도입 — WHERE는 집계 함수를 못 쓴다
- `WHERE score >= AVG(score)` ❌ (`Invalid use of group function`) — WHERE(②) 시점엔 집계값이 없음
- 사람의 2단계 사고(①평균 구함 → ②그 값으로 필터)를 한 문장에 담는 게 스칼라 서브쿼리

## 스칼라 서브쿼리 (1행 1열)
```sql
SELECT id, title FROM complaint
WHERE status = '완료'
  AND satisfaction_score >= (SELECT AVG(satisfaction_score) FROM complaint WHERE status='완료');
```
- 하드코딩(`>= 3.16`)과 결과 같지만 **데이터 바뀌면 자동 갱신**
- 비교 자리 서브쿼리가 2행 이상 반환 시 `Subquery returns more than 1 row` 에러

## 다중 행 서브쿼리 (N행 1열) — IN / NOT IN
```sql
-- 5점 준 민원인 (IN은 NULL·중복에 관대)
SELECT * FROM citizen WHERE id IN (SELECT citizen_id FROM complaint WHERE satisfaction_score=5);
```
### ⚠️ NOT IN + NULL 함정 (핵심)
- `id NOT IN (9,18,NULL)` = `id≠9 AND id≠18 AND id≠NULL(unknown)` → **전체 unknown → 0행**
- **규칙: NOT IN 서브쿼리엔 `IS NOT NULL`을 반사적으로 붙인다** (0행 → 정상)

## ANY / ALL
- **ANY = 하나만 이기면 됨(OR판정) ≡ MIN 비교** / **ALL = 전부 이겨야 함(AND판정) ≡ MAX 비교**
- `> ALL(목록)` ≡ `> (SELECT MAX)`, `> ANY(목록)` ≡ `> (SELECT MIN)`
- `= ANY` ≡ `IN`, `!= ALL` ≡ `NOT IN`
- **실무 결론: ANY/ALL은 읽을 줄만. 쓸 때는 `(SELECT MAX/MIN)` 스칼라로** (명확·NULL 안전)
- 엣지: 빈 목록이면 `>ALL`=TRUE(전원통과), `>ANY`=FALSE(전원탈락) — 공허한 참

## 상관 서브쿼리 (서브쿼리가 바깥 칼럼 참조 → 바깥 행마다 재실행)
```sql
-- 자기 부서 평균보다 높은 완료 민원
SELECT c1.id FROM complaint c1
WHERE c1.status='완료'
  AND c1.satisfaction_score > (SELECT AVG(c2.satisfaction_score) FROM complaint c2
                               WHERE c2.status='완료' AND c2.department_id = c1.department_id);
```
- **연결 고리 `c2.department_id = c1.department_id`는 조인의 ON과 같은 역할** (같은 테이블을 c1/c2 셀프 참조)
- 이 조건 유무 = "부서별 맞춤 기준"(상관) vs "전체 고정 기준 3.16"(독립 스칼라)

### EXISTS / NOT EXISTS
```sql
WHERE EXISTS (SELECT 1 FROM complaint c WHERE c.department_id=d.id AND c.status='접수')
```
- `EXISTS` = 1행이라도 있으면 TRUE (내용 무시 → `SELECT 1` 관례, 찾는 즉시 중단)
- **`NOT EXISTS`는 NULL 함정 면역** → "~가 없는 X 찾기"의 정석 (NOT IN 대신)

## SELECT 절 서브쿼리 (칼럼처럼)
```sql
SELECT d.id, d.name, (SELECT COUNT(*) FROM complaint c WHERE c.department_id=d.id) AS 민원수
FROM department d;   -- 감사담당관 0 (COUNT는 셀 게 없으면 0)
```
- 상관 스칼라. 결과 0행이면 그 칸은 NULL

## FROM 절 서브쿼리 (테이블처럼, 인라인 뷰)
```sql
SELECT 부서명, 민원수 FROM (SELECT ... GROUP BY d.id) AS stats WHERE 민원수 >= 40;
```
- **별칭 필수** (`Every derived table must have its own alias`)
- 바깥 WHERE에서 안쪽 별칭 사용 가능 (안쪽이 이미 실행돼 칼럼으로 굳음) → "별칭 WHERE 금지" 우회 정석
- **FROM 서브쿼리가 필수인 경우 = 집계의 집계**: 부서 평균들의 평균(3.20) ≠ 전체 평균(3.16, 가중)

## 서브쿼리 vs JOIN/HAVING — 판단 기준
> **그룹핑 1번으로 답 나오면 서브쿼리 쓰지 마라.**

| 상황 | 도구 |
|---|---|
| 그룹 집계로 그룹 필터 | HAVING (서브쿼리 불필요) |
| 전체 집계값 하나와 행 비교 | 스칼라 서브쿼리 |
| 집계의 집계 / 집계+원본 조인 | FROM 서브쿼리 필수 |
| 행마다 다른 기준과 비교 | 상관 서브쿼리 (또는 FROM 서브쿼리+JOIN) |
| "~가 없는 X" | NOT EXISTS / LEFT JOIN+IS NULL |

- 감별 질문: **"그룹핑을 몇 번 해야 하는 문제인가?"** (1번→JOIN+HAVING, 2번+→FROM 서브쿼리)
- 1순위 기준은 성능보다 **의도의 명확성** (MySQL 8은 상당수 서브쿼리를 조인으로 자동 변환)

## 핵심 요약
1. 서브쿼리 = 쿼리 결과를 값/목록/표로 재사용
2. NOT IN엔 IS NOT NULL 필수, "없는 것 찾기"는 NOT EXISTS
3. ANY/ALL은 MAX/MIN 스칼라로 치환해 쓴다
4. 상관 서브쿼리의 연결 고리 = 조인 ON
5. 집계의 집계엔 FROM 서브쿼리, 단일 그룹 필터엔 HAVING
