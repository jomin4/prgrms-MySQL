# [심화] 트랜잭션 ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습 쿼리: [sql/02_practice/transaction_트랜잭션.sql](../../sql/02_practice/transaction_트랜잭션.sql)

## 트랜잭션이 필요한 이유
- 계좌 이체 = 출금 UPDATE + 입금 UPDATE. 중간에 실패하면 돈이 증발
- **"쪼갤 수 없는 작업 묶음"** = 전부 되거나 전부 안 되거나
- MySQL 기본은 **autocommit**(쿼리마다 자동 확정) → 트랜잭션은 명시적 시작

## 커밋 & 롤백
```sql
START TRANSACTION;       -- 작업 묶음 시작
UPDATE complaint SET status='처리중' WHERE status='접수';
SELECT COUNT(*) ...;     -- 내 세션에선 변경 보임 (임시)
ROLLBACK;                -- 전부 취소 → 시작 시점 복구
-- 또는 COMMIT;          -- 전부 확정 (되돌리기 불가)
```
- COMMIT 전 변경은 **임시** → ROLLBACK으로 통째 취소 가능
- **COMMIT은 되돌릴 수 없다** (복구는 시드 재적재)

## ACID — 4대 속성
| 속성 | 뜻 | 예시 |
|---|---|---|
| **A**tomicity 원자성 | 전부 or 전무 | 출금+입금 둘 다 or 둘 다 안 됨 |
| **C**onsistency 일관성 | 규칙(제약) 항상 유지 | 이체 전후 총액 동일, FK·CHECK 유지 |
| **I**solation 격리성 | 동시 트랜잭션 서로 간섭 안 함 | 미확정 데이터를 남이 못 봄 |
| **D**urability 지속성 | 확정은 영구 | 커밋된 이체는 정전에도 유지 |

## 격리 수준 — 동시성의 핵심
동시 트랜잭션이 "남의 미확정 작업을 얼마나 보나". 느슨=빠름/위험, 엄격=느림/안전 (트레이드오프)

### 3대 이상현상
1. **Dirty Read** — 커밋 안 된 값을 읽음 (상대가 ROLLBACK하면 유령 데이터)
2. **Non-Repeatable Read** — 같은 행 두 번 읽는데 값이 다름 (사이에 남이 UPDATE+커밋)
3. **Phantom Read** — 같은 조건 두 번 조회에 행 개수가 다름 (사이에 남이 INSERT+커밋)

### 4단계 (위=느슨/빠름, 아래=엄격/안전)
| 격리 수준 | Dirty | Non-Repeatable | Phantom | 비고 |
|---|---|---|---|---|
| READ UNCOMMITTED | ⭕ | ⭕ | ⭕ | 거의 안 씀 |
| READ COMMITTED | ❌ | ⭕ | ⭕ | 오라클·PostgreSQL 기본 |
| **REPEATABLE READ** | ❌ | ❌ | ⭕(MySQL은 대부분 막음) | **MySQL 기본** |
| SERIALIZABLE | ❌ | ❌ | ❌ | 사실상 순차 실행 |

```sql
SELECT @@transaction_isolation;   -- REPEATABLE-READ
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```
- MySQL 기본 REPEATABLE READ: 트랜잭션 내 첫 스냅샷 유지 → 같은 조회 같은 결과
- 실감 실습: DataGrip 콘솔 2개로 한쪽 미커밋 UPDATE, 다른쪽 조회

## 핵심 요약
1. 트랜잭션 = 전부 되거나 전부 안 되거나 (START TRANSACTION ~ COMMIT/ROLLBACK)
2. ACID: 원자성·일관성·격리성·지속성
3. 3대 이상현상(Dirty/Non-Repeatable/Phantom)을 격리 수준으로 통제
4. MySQL 기본 = REPEATABLE READ
