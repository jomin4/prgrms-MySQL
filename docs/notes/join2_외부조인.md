# [심화] 조인 2 — 외부 조인 (LEFT JOIN) ✅ 완료 (2026-07-23)

> 환경: minwon DB · 실습: DataGrip 직접 타이핑

## LEFT JOIN 개념

> **왼쪽(FROM 쪽) 테이블 행은 전부 유지**, 짝 없으면 오른쪽 칼럼을 NULL로 채워서라도 내보낸다.

```sql
SELECT c.id, c.status, o.name AS 담당자
FROM complaint c
LEFT JOIN officer o ON c.officer_id = o.id;
-- INNER: 268행 → LEFT: 300행 (접수 32건이 담당자 NULL로 생존)
```

## LEFT JOIN + IS NULL — "짝 없는 행만" 관용구

```sql
-- 미배정 민원만 (32행)
SELECT c.id, c.title, c.status
FROM complaint c
LEFT JOIN officer o ON c.officer_id = o.id
WHERE o.id IS NULL;
```
- "주문 없는 회원", "댓글 없는 게시물" 등 실무 단골 패턴

## ⚠️ COUNT(*) vs COUNT(칼럼) 함정 (핵심!)

```sql
SELECT d.name AS 부서명, COUNT(c.id) AS 민원수
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
GROUP BY d.id;
```

| | 감사담당관(민원 0건) 결과 | 이유 |
|---|---|---|
| `COUNT(c.id)` | **0** ✅ | c.id 전부 NULL → COUNT(칼럼)은 NULL 제외 |
| `COUNT(*)` | **1** ❌ | LEFT JOIN이 NULL로 채운 행도 "행"이라서 |

> **철칙: LEFT JOIN + 집계에서 개수는 `COUNT(오른쪽테이블.칼럼)`으로 센다.**

## RIGHT JOIN

- `A LEFT JOIN B` ≡ `B RIGHT JOIN A` — 방향만 반대, 결과 동일
- 실무 관례: FROM 순서를 바꿔 **LEFT로 통일** (기준 테이블을 FROM에)

## 실전 완성형 — 전 부서 민원 현황판

```sql
SELECT d.name AS 부서명,
       COUNT(c.id) AS 민원수,
       IFNULL(ROUND(AVG(c.satisfaction_score), 2), 0) AS 평균만족도
FROM department d
LEFT JOIN complaint c ON c.department_id = d.id
GROUP BY d.id
ORDER BY 민원수 DESC;
-- 감사담당관이 0 / 0.00 으로 등장 (LEFT JOIN + COUNT(칼럼) + AVG의 NULL 무시 + IFNULL 합작)
```

## 핵심 요약
1. INNER = 교집합 / LEFT = 왼쪽 전부 유지 + 오른쪽 NULL 채움
2. `LEFT JOIN ~ WHERE 오른쪽.id IS NULL` = 짝 없는 행 추출 관용구
3. LEFT JOIN 집계에서 `COUNT(*)`는 0을 1로 둔갑시킨다 — `COUNT(칼럼)` 필수
4. LEFT JOIN이 만든 NULL은 `IFNULL`로 다듬어 보고서 완성
