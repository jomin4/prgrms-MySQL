# [심화] 인덱스 2 — 옵티마이저·커버링·복합 인덱스·설계 ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습 쿼리: [sql/02_practice/index2_복합인덱스.sql](../../sql/02_practice/index2_복합인덱스.sql)

## 옵티마이저 — 인덱스가 있어도 안 쓸 수 있다
- MySQL 옵티마이저가 비용 계산으로 "인덱스 vs Full Scan" 판단
- **결과가 테이블 대부분(20~30%↑)이면 인덱스 있어도 Full Scan 선택**
  - `loginId = 'user1'` → ref (극소수) / `loginId LIKE '9%'` → ALL (거의 전체)
- **인덱스는 소수를 콕 집을 때 유리** → 카디널리티 낮은 칼럼(성별 M/F 등)엔 무의미

## 커버링 인덱스 — 원본 방문 생략
- 인덱스 검색 = ①트리에서 값 찾기 → ②포인터로 원본 방문 (2단계)
- **필요한 칼럼이 전부 인덱스 안에 있으면 ②를 건너뜀**
```sql
SELECT * FROM member WHERE loginId='user1';       -- 원본 방문 (loginPw,name 없음)
SELECT loginId FROM member WHERE loginId='user1'; -- Extra: Using index (원본 불필요, 가장 빠름)
```
- 필요한 칼럼만 SELECT하는 게 좋은 이유의 근거

## 복합 인덱스 — 순서가 생명 ★핵심
> `(A, B)` 인덱스와 `(B, A)` 인덱스는 완전히 다르다.

### 최좌측 접두사(leftmost prefix) 원칙
`(department_id, status)` = 전화번호부 `(성, 이름)`:

| WHERE | 비유 | 인덱스 |
|---|---|---|
| `dept=3` | "김"씨 찾기 | ✅ (1차만) |
| `dept=3 AND status='완료'` | "김민수" | ✅✅ 완벽 |
| `status='완료' AND dept=3` | 순서 바꿔도 옵티마이저 재배열 | ✅✅ |
| `status='완료'` | 이름만 (성 모름) | ❌ 2차 단독 불가 |

- **WHERE 작성 순서는 무관** (옵티마이저가 재배열). 중요한 건 **인덱스 정의 순서**
- 2차 칼럼 단독으로는 인덱스 못 탐

## 설계 가이드라인
### 복합 인덱스 칼럼 순서
1. **등호(=) 조건 칼럼을 앞에**
2. **카디널리티 높은(값 종류 많은) 칼럼을 앞에**
3. **범위(>,<,BETWEEN) 조건은 뒤로** — 범위 만나는 순간 그 뒤 칼럼은 인덱스 못 탐
```sql
-- WHERE department_id=? ORDER BY created_at → (department_id, created_at)
-- 등호 앞, 정렬/범위 뒤 → 부서로 좁힌 뒤 이미 날짜순 정렬 → 정렬비용도 절약
CREATE INDEX idx_dept_created ON complaint (department_id, created_at);
```

### 인덱스를 걸지 말아야 할 때
- 카디널리티 낮은 칼럼(성별, status 5종) / 자주 UPDATE되는 칼럼
- 작은 테이블(수천 행 — Full Scan이 이미 빠름) / 쓰기 압도적인 로그성 테이블
- 한 줄: **자주 조회 + 데이터 많음 + 값 종류 많음** 칼럼에만

## 인덱스 트레이드오프 (챕터 결론)
```
✅ 읽기(SELECT) 속도 ↑↑↑
❌ 저장공간 추가 / 쓰기(INSERT·UPDATE·DELETE) 느려짐 / 잘못 걸면 안 쓰임
```
> **인덱스 = 읽기 속도를 쓰기 속도·저장공간과 맞바꾸는 거래**

## 핵심 요약
1. 옵티마이저는 결과가 많으면 인덱스를 스스로 포기
2. 커버링(Using index) = 원본 방문 생략, 가장 빠름
3. 복합 인덱스는 왼쪽 칼럼부터 순서대로만 작동(최좌측 접두사)
4. 등호 앞·범위 뒤, 카디널리티 높은 것 앞
5. 인덱스는 읽기↑ ↔ 쓰기·공간↓ 트레이드오프
