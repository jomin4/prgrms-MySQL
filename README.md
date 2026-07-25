# prgrms-MySQL

인프런 SQL 강의(기본·심화) 커리큘럼 기반 **성장형 MySQL 학습 리포지토리**.
실습 도메인은 **민원 시스템**(공군 IT 개발관리병 대비)입니다. ✅ **전 커리큘럼 완주 (2026-07-23)**

**학습 방식:** 강사(Claude)가 코드 제공 → 구체적 설명 → DataGrip에서 직접 타이핑 실습 → 반복.

## 학습한 내용
| 파트 | 주제 |
|---|---|
| SQL 기본 | 데이터 관리(DDL/DML) · 조회와 정렬 · 데이터 가공 · **집계와 그룹핑** |
| 조인 | 내부 조인(INNER) · 외부 조인(LEFT/RIGHT) |
| 고급 조회 | 서브쿼리 · UNION · CASE · 뷰(View) |
| 성능 | 인덱스 1(B-Tree·EXPLAIN) · 인덱스 2(복합·커버링·옵티마이저) |
| 안정성 | 데이터 무결성(제약조건) · 트랜잭션(ACID·격리수준) |
| DB 로직 | 저장 프로시저 · 함수 · 트리거 |

## 구성
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — 커리큘럼 & 진행 현황 (전 항목 완료 ✅)
- [`docs/notes/`](docs/notes) — **섹션별 학습 기록** 14편 (핵심 개념·실습 쿼리·깨달음·Q&A)
- [`sql/00_setup/`](sql/00_setup) — 민원 시스템(minwon DB) 시드 스크립트
- [`sql/01_review/`](sql/01_review) — 섹션 4~6 복습 문제 (데이터 관리 / 조회와 정렬 / 데이터 가공)
- [`sql/02_practice/`](sql/02_practice) — **섹션별 실습 쿼리 기록** 11편 (집계~프로시저)
- `scripts/` — 챕터별 원격 반영 자동화

## 실습 환경
| 항목 | 값 |
|---|---|
| 컨테이너 | `prgrms-mysql` (MySQL 8.4, TZ=Asia/Seoul) |
| 접속 | `localhost:3306`, user `root`, pw `1234` |
| DB | `minwon` (부서 7 · 담당자 18 · 민원인 40 · 민원 300) |

[docker-compose.yml](docker-compose.yml)로 관리 — 최초 기동 시 minwon 시드가 **자동 적재**됩니다.

```bash
# 시작 (최초 실행 시 시드 자동 적재)
docker compose up -d

# 중지 / 재시작
docker compose stop
docker compose start

# 완전 초기화 (볼륨 삭제 → 시드 재적재)
docker compose down -v && docker compose up -d

# 수동 시드 재적재가 필요할 때
docker exec -i prgrms-mysql mysql -uroot -p1234 --default-character-set=utf8mb4 < sql/00_setup/complaint_system_seed.sql
```
