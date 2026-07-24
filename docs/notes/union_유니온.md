# [심화] UNION ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습 쿼리: [sql/02_practice/union_유니온.sql](../../sql/02_practice/union_유니온.sql)

## 개념 — JOIN과 구분
- **JOIN** = 테이블을 옆으로(가로) 붙임 → 칼럼 증가
- **UNION** = SELECT 결과를 아래로(세로) 붙임 → 행 증가

## 규칙
1. 위아래 SELECT의 **칼럼 개수 동일** (다르면 에러)
2. 칼럼 순서/타입 대응 (1번째끼리, 2번째끼리 쌓임)
3. **칼럼명은 첫 SELECT 기준** (아래쪽 별칭 무시)

## UNION vs UNION ALL (핵심)
| | 중복 | 성능 |
|---|---|---|
| `UNION` | 제거 | 느림 (중복 제거 위해 정렬/비교) |
| `UNION ALL` | 유지 | 빠름 — **실무 기본 선택** |

- 예: `region UNION region` → 5행(중복제거) / `UNION ALL` → 80행
- **중복이 없다고 확신하거나 있어도 무방하면 무조건 UNION ALL**
- status로 이미 갈린 결과(완료 vs 반려)는 겹칠 수 없으니 UNION 쓸 이유 없음

## ORDER BY
- **맨 끝에 한 번**, 합쳐진 전체 결과 대상
- 중간 SELECT의 ORDER BY는 무의미

## 실전 패턴
### 1. 서로 다른 테이블 명단 통합
```sql
SELECT name, email, '담당자' AS 구분 FROM officer
UNION ALL
SELECT name, phone, '민원인' AS 구분 FROM citizen;
```
- 다른 테이블·칼럼이라도 "이름/연락처/구분" 틀만 맞추면 합쳐짐
- **고정 문자열 칼럼('담당자')으로 출처 구분**하는 게 관용

### 2. 집계 + 총계 행 (엑셀 피벗 총계 흉내)
```sql
SELECT d.name, COUNT(c.id) FROM department d LEFT JOIN complaint c ON c.department_id=d.id GROUP BY d.id
UNION ALL
SELECT '── 전체 합계 ──', COUNT(*) FROM complaint
ORDER BY (부서명 = '── 전체 합계 ──'), 민원수 DESC;
```
- `WITH ROLLUP` 대안 — UNION ALL이 더 직관적·통제 쉬움

## 정렬 트릭 — `ORDER BY (비교식)` 원리
- **비교식은 참=1 / 거짓=0인 숫자를 반환** (섹션7 `SUM(status='완료')`와 같은 성질)
- `ORDER BY (부서명 = '── 전체 합계 ──')` = `ORDER BY 0또는1` → 오름차순이라 1(합계행)이 맨 아래
- 1차 키가 같은(0인) 행들끼리만 2차 키(민원수 DESC)로 정렬 — 동점자 개념
- 맨 위로 올리려면 DESC 또는 조건 반전

## 핵심 요약
1. UNION = 세로 결합, JOIN = 가로 결합
2. 기본은 UNION ALL (UNION은 중복제거로 느림)
3. ORDER BY는 전체에 맨 끝 한 번
4. `ORDER BY (비교식)`로 특정 행을 맨 위/아래 고정
