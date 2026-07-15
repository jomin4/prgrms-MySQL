# MySQL 학습 로드맵 (몰입코딩 · 장희성 강의 기반)

원본: https://www.slog.gg/p/14160 (전 25강)

## 학습 방식
1. 강사(Claude)가 **코드 제공**
2. 코드를 **구체적으로 설명**
3. 학습자(나)가 **직접 타이핑**하며 실습
4. 이해되면 다음 단계로 → 점진적으로 확장/개선하는 성장형 학습

## 진행 현황
- [ ] **0강. 환경 세팅** — Docker로 MySQL 컨테이너 실행, 접속
- [ ] **1~4강. 개념** — DBMS/DB/테이블/칼럼/로우, SQL이란
- [ ] **5강. CRUD 기초** — CREATE/INSERT/SELECT/ALTER/UPDATE/DELETE, DATETIME, NOW()
- [ ] **6~8강. 테이블 설계** — NOT NULL, PRIMARY KEY, AUTO_INCREMENT, UNSIGNED, VARCHAR
- [ ]           WHERE / LIKE / ORDER BY / LIMIT / AND · OR
- [ ] **9~10강. JOIN 기초** — 부서·사원 모델, ON, AS, 정규화(부서명→부서번호)
- [ ] **11강. GROUP BY & 서브쿼리** — 집계함수(COUNT/SUM/MAX/MIN/AVG), HAVING, GROUP_CONCAT, 실행순서
- [ ] **12강. 서브쿼리 심화** — 부서별 최고연봉자 필터링
- [ ] **13강. INNER JOIN vs LEFT JOIN**
- [ ] **14강. UNION / UNION ALL**
- [ ] **15강. 집계 응용** — COUNT vs SUM+IF, CASE
- [ ] **16강. CHAR vs VARCHAR**
- [ ] **17강. DELETE vs TRUNCATE**
- [ ] **18~19강. 트랜잭션 개념/순서**
- [ ] **20~22강. 인덱스** — 장단점, 종류, EXPLAIN
- [ ] **23~25강. 인덱스 실습** — 백만 행 성능 비교, UNIQUE INDEX

## SELECT 실행 순서 (핵심 암기)
FROM/JOIN → ON/WHERE → GROUP BY → 집계함수 → HAVING → SELECT필드 → ORDER BY → LIMIT

## 참고
- 실습 문제집: 프로그래머스 SQL 고득점 Kit
- MySQL == MariaDB, DBMS의 일종
