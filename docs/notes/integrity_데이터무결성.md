# [심화] 데이터 무결성 — 제약조건 ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습 쿼리: [sql/02_practice/integrity_데이터무결성.sql](../../sql/02_practice/integrity_데이터무결성.sql)

## 무결성이 중요한 이유
- 무결성 = 데이터가 항상 "말이 되는" 상태 유지
- 잘못된 데이터가 **애초에 못 들어오게** DB가 문을 지킴
- 앱 코드 검증보다 강력: **DB 레벨은 어떤 경로로 들어와도 100% 보장** (최후 방어선)

## ① 기본 제약조건
| 제약 | 역할 | 위반 시 |
|---|---|---|
| NOT NULL | 필수값 | 값 없이 INSERT 에러 |
| UNIQUE | 중복 금지 | `Duplicate entry` |
| PRIMARY KEY | 식별자(UNIQUE+NOT NULL) | 중복/NULL PK 에러 |
| DEFAULT | 기본값 | 생략 시 자동 채움 |
| AUTO_INCREMENT | 자동 증가 | — |

```sql
-- UNIQUE 위반 (officer.email)
INSERT INTO officer (...) VALUES (..., 'kim.ms@haneul.go.kr', ...);
-- → Duplicate entry 'kim.ms@haneul.go.kr' for key 'email'
```

## ② 외래 키(FK) — 관계의 무결성 ★핵심
```sql
-- 없는 부서(999) 참조 → 에러
INSERT INTO complaint (..., department_id, ...) VALUES (..., 999, ...);
-- → Cannot add or update a child row: a foreign key constraint fails

-- 민원 딸린 부서 삭제 → 에러
DELETE FROM department WHERE id = 3;
-- → Cannot delete or update a parent row
```
- 부모(department)에 없는 값은 자식(complaint)에 못 넣음
- 자식이 참조 중인 부모는 못 지움 → 관계 깨짐 원천 차단

## ③ CHECK — 값의 범위/규칙 (MySQL 8.0.16+)
```sql
ALTER TABLE complaint ADD CONSTRAINT chk_score CHECK (satisfaction_score BETWEEN 1 AND 5);
-- 7점 INSERT → Check constraint 'chk_score' is violated
ALTER TABLE complaint DROP CONSTRAINT chk_score;
```
표현 가능한 규칙:
```sql
CHECK (satisfaction_score BETWEEN 1 AND 5)             -- 범위
CHECK (status IN ('접수','처리중','보류','완료','반려'))  -- 허용 목록
CHECK (birth_year >= 1900)                             -- 하한
CHECK (closed_at >= created_at)                        -- 칼럼 간 관계! (강력)
```

## 4대 제약 총정리
| 제약 | 막는 것 |
|---|---|
| NOT NULL | 빈 값 |
| UNIQUE | 중복 |
| FK | 관계 깨짐 |
| CHECK | 규칙 위반 값 |

> 철학: **앱이 실수해도 DB가 마지막에 막는다.** 중요한 규칙일수록 DB 레벨에 박아둔다.

## 핵심 요약
1. 무결성 = DB가 잘못된 데이터를 원천 차단 (최후 방어선)
2. NOT NULL/UNIQUE/PK = 값 자체 규칙
3. FK = 테이블 간 관계 규칙 (없는 부모 참조·참조된 부모 삭제 차단)
4. CHECK = 값 범위·목록·칼럼 간 관계 규칙 (8.0.16+)
