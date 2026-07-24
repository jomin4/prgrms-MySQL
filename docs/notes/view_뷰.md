# [심화] 뷰(View) ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습 쿼리: [sql/02_practice/view_뷰.sql](../../sql/02_practice/view_뷰.sql)

## 개념
> 뷰 = **이름 붙여 저장한 SELECT문** = 실행하면 그때 데이터가 나오는 가상의 표

- 테이블 = 실제 저장된 데이터(물리) / 뷰 = 저장된 쿼리(논리)
- **데이터 복사 아님** → 조회할 때마다 뒤의 SELECT 재실행 → 항상 최신
- FROM 절 서브쿼리(인라인 뷰)에 이름 붙여 저장한 것

## 생성·조회·수정·삭제
```sql
CREATE VIEW v_dept_status AS SELECT ...;      -- 생성 (관례: v_ 접두사)
SELECT * FROM v_dept_status;                   -- 테이블처럼 조회
SELECT 부서명, 완료 FROM v_dept_status WHERE 완료 >= 20;  -- 뷰 위에 조건 얹기 (진가)
CREATE OR REPLACE VIEW v_dept_status AS ...;   -- 정의 교체
SHOW CREATE VIEW v_dept_status;                -- 정의 확인
DROP VIEW v_dept_status;                        -- 삭제 (원본 테이블 안전!)
```

## 장점
1. **복잡한 쿼리 재사용** (가장 큰 이유) — 로직을 한 곳에 정의, 복붙 실수 방지
2. **보안/접근제어** — 민감 칼럼 뺀 뷰만 제공 (`v_citizen_public`: phone·birth_year 제외)
3. **추상화** — 뒤의 4테이블 조인을 숨기고 깔끔한 인터페이스 제공

## 단점/주의
1. **성능** — 뷰는 저장된 쿼리일 뿐, **매번 재실행**. 미리 계산해두지 않음!
   - "뷰라서 빨라진다"는 틀린 생각. 미리계산 원하면 Materialized View → **MySQL 미지원**(오라클/PG만)
2. **수정 제약** — GROUP BY·JOIN·집계 뷰는 **읽기 전용** (`not updatable` 에러). 단순 뷰만 INSERT/UPDATE 가능
3. **중첩의 함정** — 뷰 위 뷰 2단계 이상은 성능·디버깅 지옥 → 지양

## 판단 기준
| 상황 | 뷰? |
|---|---|
| 복잡 조회를 여러 곳 반복 | ✅ |
| 민감 칼럼 가리고 일부만 노출 | ✅ |
| 무거운 집계를 초당 수백 번 | ❌ 캐시/집계테이블 |
| 뷰로 데이터 수정 | ❌ 대부분 불가 |

## 핵심 요약
1. 뷰 = 저장된 SELECT, 조회 시마다 재실행(항상 최신)
2. 재사용·보안·추상화가 장점
3. 성능 개선 도구 아님(미리계산 X), 집계뷰는 읽기전용
4. DROP VIEW는 원본 데이터 안 건드림
