# MySQL 학습 로드맵 (인프런 강의 커리큘럼 기반)

## 학습 방식
1. 강사(Claude)가 **코드 제공** → 2. **구체적 설명** → 3. 학습자가 **DataGrip에서 직접 타이핑** → 반복
- 실습 도메인: **민원 시스템** (공군 IT 개발관리병 대비) — `minwon` DB
- 각 섹션 완료 시 Claude가 자동으로 커밋 + 원격 푸시

## 실습 환경
- Docker 컨테이너 `prgrms-mysql` (MySQL 8.4, 포트 3306, root/1234, TZ=Asia/Seoul)
- 클라이언트: DataGrip (`localhost:3306`, user `root`, pw `1234`, DB `minwon`)
- 시드: [sql/00_setup/complaint_system_seed.sql](../sql/00_setup/complaint_system_seed.sql)

## 진행 현황 — SQL 기본
- [x] 섹션 4. 데이터 관리 (DDL·DML·제약조건) — 수강 완료 · [복습 파일](../sql/01_review/section4_데이터관리_복습.sql)
- [x] 섹션 5. 조회와 정렬 (SELECT·WHERE·ORDER BY·LIMIT·DISTINCT·NULL) — 수강 완료 · [복습 파일](../sql/01_review/section5_조회와정렬_복습.sql)
- [x] 섹션 6. 데이터 가공 (산술·문자열·NULL·기타 함수) — 수강 완료 · [복습 파일](../sql/01_review/section6_데이터가공_복습.sql)
- [x] **섹션 7. 집계와 그룹핑** — 완료 (2026-07-23) · [학습 기록](notes/section7_집계와그룹핑.md)
  - [x] 집계 함수 (COUNT·SUM·AVG·MIN·MAX)
  - [x] GROUP BY — 그룹으로 묶기 / 주의사항
  - [x] HAVING — 그룹 필터링
  - [x] SQL 실행 순서
  - [x] 문제와 풀이 / 정리 (풀이 생략, 정답 기록)

## 진행 현황 — SQL 심화
- [x] **조인 1 — 내부 조인** — 완료 (2026-07-23) · [학습 기록](notes/join1_내부조인.md)
- [ ] **조인 2 — 외부 조인** (LEFT JOIN 등) ← 현재 진행
- [ ] 서브쿼리 (스칼라·다중 행·다중 컬럼·상관·SELECT·테이블 / 서브쿼리 vs JOIN)
- [ ] UNION / UNION ALL / UNION 정렬
- [ ] CASE 문 (기본·그룹핑·조건부 집계)
- [ ] 뷰(View) — 생성·조회·수정·삭제, 장단점
- [ ] 인덱스 1 — 필요한 이유, 트리 자료구조, 생성·조회·삭제, 동등·범위·LIKE·정렬
- [ ] 인덱스 2 — 옵티마이저, 커버링·복합 인덱스, 설계 가이드라인, 단점
- [ ] 데이터 무결성 — 기본·외래 키·CHECK 제약조건
- [ ] 트랜잭션 — 커밋·롤백, ACID, 격리 수준
- [ ] 저장 프로시저·함수·트리거

## SQL 실행 순서 (핵심 암기)
FROM/JOIN → ON/WHERE → GROUP BY → 집계함수 → HAVING → SELECT필드 → ORDER BY → LIMIT

## minwon DB 구조 요약
| 테이블 | 설명 | 행 수 |
|---|---|---|
| department | 부서 (감사담당관은 신설·담당자 없음 → LEFT JOIN 실습용) | 7 |
| officer | 담당자 (부서별 과장/팀장/주무관) | 18 |
| citizen | 민원인 (하늘시 5개 구) | 40 |
| complaint | 민원 (접수/처리중/보류/완료/반려, 완료 건만 만족도 1~5) | 300 |
