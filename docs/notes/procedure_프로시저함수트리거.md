# [심화] 저장 프로시저·함수·트리거 ✅ 완료 (2026-07-23) — 커리큘럼 마지막

> 환경: minwon DB · 실습 쿼리: [sql/02_practice/procedure_프로시저함수트리거.sql](../../sql/02_practice/procedure_프로시저함수트리거.sql)

DB 안에 로직(프로그램)을 저장·실행하는 3가지. `DELIMITER //`로 구분자를 바꿔 내부 `;`와 충돌 방지.

## ① 저장 프로시저 (Stored Procedure)
- 여러 SQL을 이름으로 묶어 `CALL`로 호출. `IN` 파라미터로 값 전달
```sql
DELIMITER //
CREATE PROCEDURE sp_dept_summary(IN dept_id INT)
BEGIN
    SELECT ... WHERE d.id = dept_id GROUP BY d.id;
END //
DELIMITER ;
CALL sp_dept_summary(3);
```

## ② 저장 함수 (Stored Function)
- **하나의 값 반환** → SELECT 안에서 내장함수처럼 사용
- **`DETERMINISTIC`** = "같은 입력 → 항상 같은 출력" 선언 (최적화 힌트, 캐싱 가능)
  - 반대는 NOT DETERMINISTIC: `NOW()`·`RAND()`처럼 결과가 매번 달라지는 것
```sql
CREATE FUNCTION fn_grade(score INT) RETURNS VARCHAR(10) DETERMINISTIC
BEGIN RETURN CASE WHEN score>=4 THEN '우수' WHEN score>=2 THEN '보통' ELSE '미흡' END; END
SELECT id, fn_grade(satisfaction_score) AS 등급 FROM complaint;
```

## ③ 트리거 (Trigger)
- 이벤트(INSERT/UPDATE/DELETE) 발생 시 **자동 실행**
- **`FOR EACH ROW`** = 영향받는 행마다 실행 (UPDATE가 50행 바꾸면 50번). MySQL은 행 단위만 지원
- **`NEW`**=바뀔 값, **`OLD`**=기존 값
- **`IF 조건 THEN 동작 END IF`** 구조 (SET=대입). Java의 `if(){ x=y; }`와 동일
```sql
CREATE TRIGGER trg_set_closed BEFORE UPDATE ON complaint FOR EACH ROW
BEGIN
    IF NEW.status='완료' AND OLD.status!='완료' AND NEW.closed_at IS NULL THEN
        SET NEW.closed_at = NOW();   -- 방금 완료된 것만 시각 자동 기록(OLD 조건이 덮어쓰기 방지)
    END IF;
END
```

## DB 로직의 함정 & 현대적 대안 ★중요
| 함정 | 설명 |
|---|---|
| 디버깅 지옥 | 트리거는 보이지 않게 자동 실행 → 원인 추적 어려움 |
| 버전관리 | 앱 코드는 Git, DB 로직은 별도 → 이력·리뷰 누락 |
| 이식성 | MySQL/오라클/PG 프로시저 문법 상이 → DB 교체 시 재작성 |
| 확장성 | 로직이 DB에 몰림 → DB 병목 (앱 서버는 늘리기 쉬움) |
| 테스트 | 단위 테스트 자동화 어려움 |

> **현대 주류: DB는 순수 CRUD, 비즈니스 로직은 애플리케이션(Spring 등).**
> "완료 시 시각 기록"도 트리거 대신 Spring 서비스 코드에서 처리 → Git·테스트·디버깅·DB교체 자유
> **예외(DB 로직 유효)**: 감사 로그, 복제/마이그레이션, 앱 우회 대량 배치, 극한 성능
> 결론: **기본은 앱, 꼭 필요할 때만 DB**

## 핵심 요약
1. 프로시저(CALL, 명령묶음) / 함수(값 반환, SELECT에서) / 트리거(이벤트 자동실행)
2. DETERMINISTIC=입출력 고정 선언, FOR EACH ROW=행마다, NEW/OLD=바뀔값/기존값
3. 요즘은 로직을 앱으로 → DB는 데이터에 집중 (디버깅·버전관리·확장성)
