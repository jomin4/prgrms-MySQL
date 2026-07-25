# [심화] 인덱스 1 — 기초 ✅ 완료 (2026-07-23)

> 환경: minwon DB, member 테이블(약 104만 건) · 실습 쿼리: [sql/02_practice/index1_인덱스기초.sql](../../sql/02_practice/index1_인덱스기초.sql)

## 인덱스가 필요한 이유
- 대용량에서 `WHERE col = 값` = 책의 색인 없이 1페이지부터 넘기며 찾기(Full Scan)
- 인덱스 = 책 뒤의 "찾아보기" = 정렬된 별도 자료구조 → 위치를 바로 찾아감

## 트리 자료구조 (B-Tree)
- 값을 **정렬해서 트리로 저장** → 이진 탐색처럼 절반씩 후보 축소
- 100만 건: 순차검색 최악 100만 번 vs B-Tree 약 20번 (log₂)
- 데이터 2배 → 단계는 +1만 증가 (대용량일수록 격차 폭발)
- 인덱스 = **정렬된 값 + "실제 행은 몇 번" 포인터** (원본 미변경, 별도 구조)

## 실측 (member 104만~838만 건)
| | type | key | 시간 |
|---|---|---|---|
| 인덱스 없음 | ALL | NULL | ~7.8초(838만) |
| 인덱스 있음 | ref | idx_loginId | ~0.001초 |

## 생성 / 조회 / 삭제
```sql
CREATE INDEX idx_loginId ON member (loginId);   -- 값 정렬해 트리 구성 (생성 느림)
SHOW INDEX FROM member;
ALTER TABLE member DROP INDEX idx_loginId;        -- = DROP INDEX idx_loginId ON member (삭제 빠름)
```
- 인덱스 비용: 생성시간 + 저장공간 + 쓰기부담(INSERT/UPDATE마다 트리 갱신) ↔ 읽기속도 이득

## 인덱스가 먹는 조건 (EXPLAIN type)
| 조건 | type |
|---|---|
| `loginId = 'user1'` (동등) | ref |
| `id BETWEEN 100 AND 200` (범위) | range |
| `id > 1000000` | range |
| `loginId IN ('user1','user2')` | range |

## 인덱스가 안 먹는 조건 ★핵심
```sql
WHERE SUBSTRING(loginId,1,5) = 'user1'  -- ALL (칼럼에 함수)
WHERE id + 1 = 101                       -- ALL (칼럼에 연산)
```
> **철칙: 인덱스 칼럼은 조건절에서 "맨몸"으로. 함수·연산으로 감싸면 인덱스는 죽는다.**
> `WHERE id + 1 = 101` → `WHERE id = 100`으로 고쳐 쓸 것

## LIKE — 앞부분 고정 여부
| 패턴 | type | 이유 |
|---|---|---|
| `LIKE 'user%'` | range | 앞 'user' 고정 → 트리에서 구간 찾음 |
| `LIKE '%user'` | ALL | 앞글자 모름 → 트리 어디부터 볼지 모름 |
> 양쪽 `%검색어%`는 인덱스 못 씀 → 대용량은 Full-Text Index / 검색엔진(ES)

## 정렬(ORDER BY) — 인덱스 = 이미 정렬된 결과
```sql
EXPLAIN SELECT id FROM member ORDER BY loginId LIMIT 10;  -- filesort 없음 (인덱스 순서 이용)
EXPLAIN SELECT * FROM member ORDER BY name LIMIT 10;      -- Extra: Using filesort (별도 정렬)
```
- `Using filesort` = "추가 정렬 비용 발생" 신호 (파일과 무관). 자주 ORDER BY 하는 칼럼엔 인덱스 고려

## 핵심 요약
1. 인덱스 = 정렬된 값 + 행 포인터 (읽기↑ / 저장·쓰기 비용↑)
2. 동등(ref)·범위(range)·IN·`접두어%`·정렬에 유리
3. 칼럼에 함수/연산 씌우면 인덱스 무효 (맨몸 원칙)
4. `%검색어`·`%검색어%`는 인덱스 불가
5. EXPLAIN의 type(ALL/ref/range)·Extra(Using filesort)로 진단
