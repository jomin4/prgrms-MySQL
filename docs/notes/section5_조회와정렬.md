# 섹션 5. SQL - 조회와 정렬 (SELECT · WHERE · ORDER BY · LIMIT · DISTINCT · NULL) ✅

> 상태: 수강 완료 (사전 학습) · 복습 문제: [sql/01_review/section5_조회와정렬_복습.sql](../../sql/01_review/section5_조회와정렬_복습.sql)

## 핵심 개념

### SELECT / WHERE
```sql
SELECT id, title, status FROM complaint WHERE status = '처리중';
```
- 비교: `=`, `!=`(또는 `<>`), `>=`, `<=`
- 논리: `AND`, `OR`, `NOT` (AND가 OR보다 우선 — 헷갈리면 괄호)

### 편리한 조건 검색
| 문법 | 의미 | 예시 |
|---|---|---|
| `IN (...)` | 목록 중 하나 | `category IN ('도로','교통')` |
| `BETWEEN a AND b` | a~b 범위(경계 포함) | `satisfaction_score BETWEEN 3 AND 5` |
| `LIKE '패턴'` | 부분 일치 (`%`=아무 문자열, `_`=한 글자) | `title LIKE '%소음%'` |

### ORDER BY / LIMIT
```sql
SELECT * FROM complaint ORDER BY status ASC, created_at DESC LIMIT 5;
```
- 다중 키: 왼쪽 키부터 정렬, **동점자만** 다음 키로 순서 결정
- `LIMIT n` — 상위 n건 (페이징의 기초)

### DISTINCT
```sql
SELECT DISTINCT category FROM complaint;  -- 중복 제거된 카테고리 목록
```

### NULL — 알 수 없는 값
- `= NULL` ❌ → **`IS NULL` / `IS NOT NULL`** ⭕
- NULL은 비교 연산의 결과도 NULL(unknown) → WHERE에서 탈락
- minwon 예: 담당자 미배정 민원 = `WHERE officer_id IS NULL`

## 날짜 범위 검색 팁
```sql
-- BETWEEN보다 안전한 패턴 (시각 경계 실수 방지)
WHERE created_at >= '2026-01-01' AND created_at < '2026-04-01'
```
