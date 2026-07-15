# prgrms-MySQL

몰입코딩(장희성) [MySQL 강의](https://www.slog.gg/p/14160) 기반 성장형 학습 리포지토리.

**학습 방식:** 강사(Claude)가 코드 제공 → 구체적 설명 → 직접 타이핑 실습 → 반복.

## 구성
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — 전 25강 커리큘럼 & 진행 현황
- `sql/` — 강별 실습 SQL 기록
- `scripts/` — 챕터별 원격 반영 자동화

## 실습 환경
Docker 컨테이너의 MySQL 8.0 사용.
```bash
docker run --name mysql-1 -e MYSQL_ROOT_PASSWORD=1234 -p 3306:3306 -d mysql:8.0
docker exec -it mysql-1 mysql -uroot -p1234
```
