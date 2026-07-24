# [심화] CASE 문 ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습 쿼리: [sql/02_practice/case_케이스문.sql](../../sql/02_practice/case_케이스문.sql)

## 개념 — SQL의 if-else
`IF(조건,참,거짓)`의 확장판. 조건이 여러 개일 때 사용.

### 두 가지 형태
```sql
-- 형태 A: Searched CASE (조건식 직접 — 범위/복합 조건 가능, 주력)
CASE WHEN 조건1 THEN 값1
     WHEN 조건2 THEN 값2
     ELSE 값3 END

-- 형태 B: Simple CASE (한 칼럼 등호 비교 전용)
CASE 칼럼 WHEN 값1 THEN 결과1
          WHEN 값2 THEN 결과2
          ELSE 결과3 END
```

## 동작 원리 (기본)
```sql
CASE WHEN 2026 - birth_year >= 60 THEN '60대이상'
     WHEN 2026 - birth_year >= 40 THEN '40~50대'
     WHEN 2026 - birth_year >= 20 THEN '20~30대'
     ELSE '10대이하' END AS 연령대
```
1. **위에서부터 검사, 처음 참인 WHEN에서 멈춤** → 조건 순서 중요 (넓은 조건을 위에 두면 다 걸림)
2. **ELSE 생략 가능하나 안 걸리면 NULL** → ELSE 넣는 습관
3. 형태 B는 등호 비교만 — 범위/AND 필요하면 형태 A

## 조건부 집계 = 피벗 (세로 → 가로) ★핵심
```sql
SUM(CASE WHEN status = '완료' THEN 1 ELSE 0 END)  -- = 완료 건수 (조건 맞는 것만 세는 카운터)
```
- `SUM(status='완료')`의 정식 버전

### 부서별 상태 현황판 (부서=행, 상태=열)
```sql
SELECT d.name AS 부서명,
       SUM(CASE WHEN c.status='접수'  THEN 1 ELSE 0 END) AS 접수,
       SUM(CASE WHEN c.status='처리중' THEN 1 ELSE 0 END) AS 처리중,
       SUM(CASE WHEN c.status='완료'  THEN 1 ELSE 0 END) AS 완료,
       SUM(CASE WHEN c.status='반려'  THEN 1 ELSE 0 END) AS 반려,
       COUNT(c.id) AS 합계
FROM department d LEFT JOIN complaint c ON c.department_id=d.id
GROUP BY d.id;
```
- GROUP BY로 부서가 행, 각 SUM(CASE)가 열 → 엑셀 피벗을 SQL로
- `부서×상태` 여러 행을 부서당 1행으로 압축

## AVG(CASE...) 조건부 평균
```sql
ROUND(AVG(CASE WHEN c.channel='온라인' THEN c.satisfaction_score END), 2)  -- ELSE 없음!
```
> **철칙: SUM(CASE)엔 `ELSE 0` / AVG(CASE)엔 `ELSE 생략(NULL)`**
- 카운트: 조건 불일치는 0으로 세야 함 → ELSE 0
- 평균: 조건 불일치는 NULL로 둬야 함 → AVG가 NULL 무시(섹션7). ELSE 0 넣으면 0점이 섞여 왜곡

## 핵심 요약
1. CASE = SQL의 if-else, 형태 A(범위/복합) 주력
2. 위→아래 첫 참에서 멈춤, ELSE 없으면 NULL
3. SUM(CASE)로 세로→가로 피벗 (부서별 상태 현황판)
4. SUM(CASE)=ELSE 0, AVG(CASE)=ELSE 생략
