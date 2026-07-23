# 섹션 6. SQL - 데이터 가공 (산술 · 문자열 · NULL · 다양한 함수) ✅

> 상태: 수강 완료 (사전 학습) · 복습 문제: [sql/01_review/section6_데이터가공_복습.sql](../../sql/01_review/section6_데이터가공_복습.sql)

## 핵심 개념

### 산술 연산
```sql
SELECT name, 2026 - birth_year AS 나이 FROM citizen;
```
- SELECT 절에서 `+ - * / %` 바로 사용 가능, `AS`로 별칭

### 문자열 함수
| 함수 | 용도 | 예시 |
|---|---|---|
| `CONCAT(a, b, ...)` | 이어붙이기 | `CONCAT(name, '(', phone, ')')` |
| `CHAR_LENGTH(s)` | 글자 수 | `CHAR_LENGTH(title)` (바이트 수는 `LENGTH`) |
| `SUBSTRING(s, pos, len)` | 부분 추출 | `SUBSTRING(phone, -4)` |
| `LEFT / RIGHT(s, n)` | 앞/뒤 n글자 | `RIGHT(phone, 4)` |
| `UPPER / LOWER` | 대소문자 | `UPPER(email)` |
| `REPLACE(s, a, b)` | 치환 | `REPLACE(phone, '-', '')` |
| `TRIM(s)` | 공백 제거 | `TRIM(title)` |

### NULL 함수
```sql
SELECT IFNULL(officer_id, 0) FROM complaint;              -- NULL이면 0
SELECT COALESCE(closed_at, created_at) FROM complaint;    -- 첫 번째 non-NULL
```
- 타입이 다른 값으로 대체할 땐 `CAST(... AS CHAR)` 조합

### 날짜 함수
| 함수 | 용도 |
|---|---|
| `NOW()` | 현재 시각 |
| `DATEDIFF(a, b)` | a - b 일수 → 처리 소요일 계산 |
| `YEAR() / MONTH() / DAY()` | 부분 추출 |
| `DATE_FORMAT(d, '%Y-%m')` | 형식화 → 월별 통계 키로 활용 |
| `DATE_ADD / DATE_SUB` | 날짜 연산 (`INTERVAL n DAY`) |

### 기타
- `ROUND(x, n)` 반올림 / `CEIL` 올림 / `FLOOR` 내림
- minwon 예: `ROUND(AVG(satisfaction_score), 2)` → 평균 만족도 소수 2자리
