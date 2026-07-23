# 섹션 7. SQL - 집계와 그룹핑 ✅ 완료 (2026-07-23)

> 환경: minwon DB · DataGrip에서 직접 타이핑 실습

## 45. 집계 함수 ✅ (2026-07-23)

여러 행을 **하나의 값으로 요약**하는 함수: `COUNT` `SUM` `AVG` `MAX` `MIN`

### 실습한 쿼리
```sql
SELECT COUNT(*) FROM complaint;                 -- 300 (행 자체를 셈)
SELECT COUNT(officer_id) FROM complaint;        -- 268 (NULL 제외하고 셈)

SELECT AVG(satisfaction_score) FROM complaint WHERE status = '완료';   -- 3.16xx
SELECT SUM(satisfaction_score), MAX(satisfaction_score), MIN(satisfaction_score)
FROM complaint;                                 -- 582, 5, 1
```

### 핵심 깨달음
- `COUNT(*)` vs `COUNT(칼럼)`: 후자는 **NULL을 세지 않는다** (300 vs 268)
- **집계 함수는 NULL을 무시한다** (`COUNT(*)`만 예외)
  - 증거: `AVG = 582 ÷ 184(완료 건수) = 3.163` ← NULL을 0으로 쳤다면 582÷300=1.94였을 것
  - 그래서 WHERE 없이 SUM해도 582로 동일 (미완료 건 만족도는 전부 NULL)

## 46. GROUP BY — 그룹으로 묶기 ✅ (2026-07-23)

전체 요약(1행)이 아니라 **"~별로" 요약**(그룹당 1행).

### 실습한 쿼리
```sql
-- 상태별 민원 건수 (5행: 접수/처리중/보류/완료/반려)
SELECT status, COUNT(*) FROM complaint GROUP BY status;

-- 카테고리별 건수 많은 순
SELECT category, COUNT(*) AS cnt FROM complaint GROUP BY category ORDER BY cnt DESC;

-- 부서별 완료 민원 평균 만족도
SELECT department_id, ROUND(AVG(satisfaction_score), 2) AS avg_score
FROM complaint WHERE status = '완료' GROUP BY department_id;
-- 결과: 1→3.04, 2→3.10, 3→3.03, 4→3.36, 5→3.58(1등), 6→3.11
```

### 동작 원리 (머릿속 그림)
1. `FROM` 300행 → 2. `WHERE`로 필터 → 3. `GROUP BY`로 그룹핑 → 4. 그룹**마다** 집계 실행 → 5. 그룹당 1행 출력
- `WHERE`는 그룹핑 **이전에** 행을 거른다 (HAVING과의 차이 복선)
- 부서 "이름"이 안 보이는 답답함 → JOIN을 배우는 이유 (5번 부서 = 정보통신과)

## 47. GROUP BY — 주의사항 ✅ (2026-07-23)

### 일부러 낸 에러
```sql
SELECT status, title, COUNT(*) FROM complaint GROUP BY status;
-- [1055] 'minwon.complaint.title' isn't in GROUP BY
```

### 규칙 (암기)
> GROUP BY 쿼리의 SELECT에는 **① GROUP BY에 쓴 칼럼 ② 집계 함수** 만 올 수 있다.
> = "그룹당 값이 1개로 확정되지 않는 칼럼"이 하나라도 있으면 1055 에러

- '완료' 그룹엔 title이 184개 → MySQL이 "어떤 title?"이라며 거부
- MySQL 5.x는 허용했음(아무 행이나 반환하는 버그 양산기) → 8.0부터 `ONLY_FULL_GROUP_BY` 기본
- **예외**: PK로 그룹핑하면(`GROUP BY id`) 다른 칼럼도 SELECT 가능 (함수적 종속)

### 다중 그룹핑
```sql
SELECT department_id, status, COUNT(*) AS cnt
FROM complaint
GROUP BY department_id, status      -- (부서, 상태) 조합별 그룹
ORDER BY department_id, status;
```

### Q&A: ORDER BY 2차 키를 생략하면?
| | GROUP BY에서 빠진 칼럼 | ORDER BY에서 뺀 2차 키 |
|---|---|---|
| 결과 | ❌ 에러(1055) | ⚠️ 에러 아님, 실행됨 |
| 이유 | 그룹당 값 미확정 | 동점자 내부 순서만 미확정 |
| 위험 | 실행 자체가 안 됨 | **조용히** 순서가 뒤섞임 |

- ORDER BY는 왼쪽 키부터 정렬, 값이 같은 **동점자끼리만** 다음 키로 순서 결정
- 2차 키 생략 시 동점자 내부 순서는 **비결정적** (인덱스/플랜 따라 달라짐)
- LIMIT 페이징과 만나면 같은 행이 중복/누락되는 실무 버그의 단골 원인

## 48. HAVING — 그룹 필터링 1 ✅

```
WHERE  : 행(row)을 거른다   — 그룹핑 전
HAVING : 그룹(group)을 거른다 — 그룹핑 후
```

```sql
-- 부서별 건수 45건 이상만
SELECT department_id, COUNT(*) AS cnt
FROM complaint GROUP BY department_id HAVING cnt >= 45;

-- WHERE와 HAVING 공존: 완료 행만 → 그룹핑 → 평균 3.1 이상 그룹만
SELECT department_id, ROUND(AVG(satisfaction_score), 2) AS avg_score
FROM complaint WHERE status = '완료'
GROUP BY department_id HAVING avg_score >= 3.1;
-- 결과: 4번(3.36), 5번(3.58), 6번(3.11) — 3개 부서 생존
```

## 49. HAVING — 그룹 필터링 2 ✅

1. **표준 방식**: `HAVING COUNT(*) >= 45` — 별칭(`HAVING cnt >= 45`)은 MySQL 확장. 다른 DBMS/코테는 집계식 직접 쓰기가 안전
2. **SELECT에 없는 집계로도 필터 가능**: 보여주는 값(건수)과 거르는 기준(평균)이 달라도 됨
3. **안티패턴**: `HAVING department_id <= 3` — 동작하지만 그룹핑 전 판단 가능한 조건은 WHERE로
   > 판단 기준: **집계 결과 조건 → HAVING, 그 외 전부 → WHERE**

## 50. SQL 실행 순서 ✅ (섹션 하이라이트)

> **쓰는 순서 ≠ 실행 순서**

```
① FROM → ② WHERE → ③ GROUP BY(+집계) → ④ HAVING → ⑤ SELECT(별칭 탄생) → ⑥ ORDER BY → ⑦ LIMIT
```

예제 흐름(완료 20건 이상 부서 중 평균 만족도 TOP3):
`300행 → WHERE 184행 → GROUP BY 6그룹 → HAVING 5그룹(6번 부서 18건 탈락) → ORDER BY → LIMIT 3행`

- 별칭을 **WHERE에 쓰면 에러** (`Unknown column 'cnt'`) — WHERE(②) 시점에 별칭(⑤)은 미탄생
- **HAVING/ORDER BY에선 별칭 허용** — ORDER BY(⑥)는 표준상 당연, HAVING(④)은 MySQL 확장 덕분
- 퀴즈: LIMIT 3 결과에 6번 부서? → **없다** (HAVING에서 이미 탈락) ✔ 정답 맞힘

## 51. 문제와 풀이 ✅ (풀이 생략, 정답 기록)

민원 시스템 실무 시나리오 5문제 — 시간 관계상 직접 풀이는 생략하고 정답만 기록.

```sql
-- Q1. 채널별 민원 건수 많은 순
SELECT channel, COUNT(*) AS cnt
FROM complaint GROUP BY channel ORDER BY cnt DESC;
-- 온라인 147 / 전화 91 / 방문 62

-- Q2. 월별 접수 추이 (최신 월부터)
SELECT DATE_FORMAT(created_at, '%Y-%m') AS 접수월, COUNT(*) AS cnt
FROM complaint GROUP BY 접수월 ORDER BY 접수월 DESC;

-- Q3. 다발 민원인 TOP 5
SELECT citizen_id, COUNT(*) AS cnt
FROM complaint GROUP BY citizen_id ORDER BY cnt DESC LIMIT 5;
-- 23번(14건), 6번(13건), 15·26·18번(12건)

-- Q4. 부서별 평균 처리일 10일 이하, 빠른 순
SELECT department_id, ROUND(AVG(DATEDIFF(closed_at, created_at)), 1) AS avg_days
FROM complaint WHERE status = '완료'
GROUP BY department_id HAVING avg_days <= 10 ORDER BY avg_days;
-- 5번(8.9일), 4번(9.3일), 6번(9.3일)

-- Q5. (도전) 카테고리별 완료율 — 비교식이 1/0인 성질 활용
SELECT category, COUNT(*) AS total,
       SUM(status = '완료') AS done,
       ROUND(SUM(status = '완료') / COUNT(*) * 100, 1) AS done_rate
FROM complaint GROUP BY category ORDER BY done_rate DESC;
-- 소음 75.5% ~ 시설 52.9% (CASE 조건부 집계의 예고편)
```

## 52. 정리 ✅

- 집계 함수(COUNT/SUM/AVG/MAX/MIN)는 여러 행 → 1개 값. **NULL은 무시** (`COUNT(*)`만 예외)
- `GROUP BY` = "~별로" 요약, 그룹당 1행. SELECT엔 **그룹 키 + 집계 함수만** (1055 에러)
- `HAVING` = 그룹 필터. **집계 조건만 HAVING, 나머지는 WHERE**
- 실행 순서: **FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT**
- 다음 섹션에서 `department_id`를 부서명으로 바꾸는 법(JOIN)을 배운다
