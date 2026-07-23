# 섹션 4. SQL - 데이터 관리 (DDL · DML · 제약조건) ✅

> 상태: 수강 완료 (사전 학습) · 복습 문제: [sql/01_review/section4_데이터관리_복습.sql](../../sql/01_review/section4_데이터관리_복습.sql)

## 핵심 개념

### DDL (Data Definition Language) — 구조를 다루는 명령
| 작업 | 명령 | 예시 (minwon) |
|---|---|---|
| 생성 | `CREATE TABLE` | `CREATE TABLE notice (id INT UNSIGNED NOT NULL AUTO_INCREMENT, ... PRIMARY KEY(id));` |
| 칼럼 추가 | `ALTER TABLE ~ ADD COLUMN` | `ALTER TABLE notice ADD COLUMN view_count INT UNSIGNED NOT NULL DEFAULT 0;` |
| 칼럼명 변경 | `ALTER TABLE ~ CHANGE COLUMN` | `ALTER TABLE notice CHANGE COLUMN view_count hit_count INT UNSIGNED NOT NULL;` |
| 타입/제약 변경 | `ALTER TABLE ~ MODIFY COLUMN` | `ALTER TABLE notice MODIFY COLUMN title VARCHAR(300) NOT NULL;` |
| 제거 | `DROP TABLE` | `DROP TABLE notice;` |
| 구조 확인 | `DESC` / `SHOW TABLES` | `DESC complaint;` |

### DML (Data Manipulation Language) — 데이터를 다루는 명령
| 작업 | 명령 | 주의 |
|---|---|---|
| 등록 | `INSERT INTO ~ VALUES` / `SET` | 다중 행은 `VALUES (...), (...)` |
| 수정 | `UPDATE ~ SET ~ WHERE` | **WHERE 없으면 전체 행 수정!** |
| 삭제 | `DELETE FROM ~ WHERE` | **WHERE 없으면 전체 행 삭제!** |

### 제약조건 (Constraints)
- `NOT NULL` — NULL 금지 (모든 필수 칼럼의 기본)
- `PRIMARY KEY` — 행의 유일 식별자 (유니크 + NOT NULL)
- `AUTO_INCREMENT` — 자동 증가 번호 (반드시 KEY여야 적용 가능)
- `UNSIGNED` — 음수 불필요한 INT의 기본
- `DEFAULT` — 기본값 (예: `DEFAULT CURRENT_TIMESTAMP`)
- `UNIQUE` — 중복 금지 (예: officer.email)
- `FOREIGN KEY` — 참조 무결성: 존재하지 않는 부모를 가리키는 INSERT는 실패
  - 예: `complaint.citizen_id = 9999` INSERT → citizen에 9999가 없으면 에러

## minwon DB 적용 사례
- 4개 테이블 전부 `PK + AUTO_INCREMENT + UNSIGNED + NOT NULL` 패턴 적용
- `complaint`은 3개의 FK(citizen_id, department_id, officer_id)를 가짐
- `officer_id`는 미배정 상태를 표현하기 위해 의도적으로 NULL 허용
