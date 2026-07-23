# prgrms-MySQL

인프런 SQL 강의(기본·심화) 커리큘럼 기반 **성장형 MySQL 학습 리포지토리**.
실습 도메인은 **민원 시스템**(공군 IT 개발관리병 대비)입니다.

**학습 방식:** 강사(Claude)가 코드 제공 → 구체적 설명 → DataGrip에서 직접 타이핑 실습 → 반복.

## 구성
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — 커리큘럼 & 진행 현황
- [`docs/notes/`](docs/notes) — **섹션별 학습 기록** (핵심 개념·실습 쿼리·깨달음·Q&A를 md로 축적)
- [`sql/00_setup/`](sql/00_setup) — 민원 시스템(minwon DB) 시드 스크립트
- [`sql/01_review/`](sql/01_review) — 섹션 4~6 복습 문제 (데이터 관리 / 조회와 정렬 / 데이터 가공)
- `sql/` — 이후 섹션별 실습 기록 (진행하며 추가)
- `scripts/` — 챕터별 원격 반영 자동화

## 실습 환경
| 항목 | 값 |
|---|---|
| 컨테이너 | `prgrms-mysql` (MySQL 8.4, TZ=Asia/Seoul) |
| 접속 | `localhost:3306`, user `root`, pw `1234` |
| DB | `minwon` (부서 7 · 담당자 18 · 민원인 40 · 민원 300) |

```bash
# 최초 1회 생성
docker run --name prgrms-mysql -e MYSQL_ROOT_PASSWORD=1234 -e TZ=Asia/Seoul -p 3306:3306 -d mysql:8.4

# 재부팅 후 다시 시작
docker start prgrms-mysql

# 시드 적재(초기화)
docker exec -i prgrms-mysql mysql -uroot -p1234 --default-character-set=utf8mb4 < sql/00_setup/complaint_system_seed.sql
```
