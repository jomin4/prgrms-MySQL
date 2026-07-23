# [심화] 조인 1 — 내부 조인 ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습: DataGrip 직접 타이핑

## 조인이 필요한 이유

- 섹션 7의 고통: `department_id 5가 1등` → "5번이 어딘데?"
- 부서명을 300행마다 박아놨다면 부서명 변경 시 300행 수정 → **정규화**(부서 정보는 department 1곳에만)
- 정규화의 대가 = 조회 시 테이블을 합쳐야 함 → **JOIN**

## 내부 조인 기본

```sql
SELECT c.id, c.title, d.name AS dept_name
FROM complaint AS c
INNER JOIN department AS d ON c.department_id = d.id;
```

- `ON` = 연결 규칙(짝짓기 조건). `AS` 별칭은 생략 가능(`FROM complaint c`)
- 양쪽에 같은 칼럼명(id 등)이 있으면 접두사 필수 (ambiguous 에러)
- 섹션 7 쿼리 업그레이드: `GROUP BY d.name` → 부서 "이름"으로 보고 가능 (1등 = 정보통신과 3.58)

## 조인의 본질 — ON을 빼는 실험

```sql
SELECT COUNT(*) FROM complaint INNER JOIN department;   -- 2,100행!
```

- ON 생략 → **카티전 곱**: 300 × 7 = 2,100 (1번 민원이 7개 부서 전부와 짝지어짐)
- 사고 모델: **"JOIN이 모든 조합을 만들고, ON이 진짜 짝만 남긴다"**
- ON 복원 → 300행 (department_id는 NOT NULL + FK라 전원 짝 있음)

## INNER JOIN의 치명적 특성 — NULL 행 증발

```sql
SELECT COUNT(*) FROM complaint c INNER JOIN officer o ON c.officer_id = o.id;
-- 268행 (300 - 32)
```

- `officer_id IS NULL`(접수 상태) 32건은 **어떤 행과도 짝을 못 맺어 조용히 사라짐**
- NULL은 `=` 비교가 항상 unknown (섹션 5 IS NULL과 같은 원리)
- "전체 민원 현황"에 접수 32건이 빠지는 사고 → **LEFT JOIN이 필요한 이유**

## 다중 테이블 조인 (체인)

```sql
SELECT c.id, c.title, c.status,
       d.name AS 부서, o.name AS 담당자, o.grade AS 직급, z.name AS 민원인
FROM complaint c
INNER JOIN department d ON c.department_id = d.id
INNER JOIN officer    o ON c.officer_id = o.id
INNER JOIN citizen    z ON c.citizen_id = z.id;
-- 268행 (officer 조인에서 32건 증발)
```

- 조인은 **위→아래 한 단계씩** 붙는다. 각 ON은 "지금까지 합쳐진 결과"의 칼럼 사용 가능
- 단계마다 "행 유지? 감소?"를 추적하는 게 조인 디버깅의 핵심

## 조인 + 집계 종합 — 우수 담당자 TOP 5

```sql
SELECT o.name AS 담당자, d.name AS 부서,
       COUNT(*) AS 완료건수, ROUND(AVG(c.satisfaction_score), 2) AS 평균만족도
FROM complaint c
INNER JOIN officer    o ON c.officer_id = o.id
INNER JOIN department d ON o.department_id = d.id   -- 조인 경로: 담당자의 소속!
WHERE c.status = '완료'
GROUP BY o.id                                        -- PK 그룹핑 → o.name, d.name SELECT 허용
ORDER BY 평균만족도 DESC LIMIT 5;
-- 1등: 송예린(정보통신과) 10건, 4.00
```

- **조인 경로**: 부서를 `c.department_id`(민원의 담당부서)가 아닌 `o.department_id`(담당자 소속)로 연결 — 질문이 무엇이냐에 따라 경로가 달라짐
- **`GROUP BY o.id`(PK)** → 함수적 종속으로 o.name 등 SELECT 허용 (47강 예외의 실전)

## 핵심 요약
1. JOIN = 모든 조합 생성, ON = 짝 필터
2. INNER JOIN은 짝 없는 행(NULL 포함)을 **에러 없이** 버린다
3. 조인은 체인 — 단계별 행 수 추적이 디버깅의 핵심
4. 조인 경로는 질문(비즈니스 의미)이 결정한다
