-- ============================================================
-- [실습 기록] 저장 프로시저·함수·트리거 (2026-07-23)
-- 노트: docs/notes/procedure_프로시저함수트리거.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- ① 저장 프로시저: 저장된 명령 묶음 (CALL로 호출)
--    DELIMITER로 구분자 변경 (프로시저 내부 ; 와 충돌 방지)
-- ------------------------------------------------------------
DELIMITER //
CREATE PROCEDURE sp_dept_summary(IN dept_id INT)
BEGIN
    SELECT d.name AS 부서명, COUNT(c.id) AS 민원수,
           IFNULL(ROUND(AVG(c.satisfaction_score), 2), 0) AS 평균만족도
    FROM department d
    LEFT JOIN complaint c ON c.department_id = d.id
    WHERE d.id = dept_id
    GROUP BY d.id;
END //
DELIMITER ;

CALL sp_dept_summary(3);   -- IN 파라미터로 값 전달

-- ------------------------------------------------------------
-- ② 저장 함수: 하나의 값 반환 (SELECT 안에서 내장함수처럼)
--    DETERMINISTIC = 같은 입력 → 항상 같은 출력 (최적화 힌트)
-- ------------------------------------------------------------
DELIMITER //
CREATE FUNCTION fn_grade(score INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    RETURN CASE WHEN score >= 4 THEN '우수'
                WHEN score >= 2 THEN '보통'
                ELSE '미흡' END;
END //
DELIMITER ;

SELECT id, satisfaction_score, fn_grade(satisfaction_score) AS 등급
FROM complaint WHERE status = '완료' LIMIT 10;

-- ------------------------------------------------------------
-- ③ 트리거: 이벤트(INSERT/UPDATE/DELETE) 발생 시 자동 실행
--    FOR EACH ROW = 영향받는 행마다 실행 / NEW=바뀔값, OLD=기존값
-- ------------------------------------------------------------
DELIMITER //
CREATE TRIGGER trg_set_closed
BEFORE UPDATE ON complaint
FOR EACH ROW
BEGIN
    -- 방금 완료로 바뀌었고 완료시각이 비어있으면 자동 기록
    IF NEW.status = '완료' AND OLD.status != '완료' AND NEW.closed_at IS NULL THEN
        SET NEW.closed_at = NOW();
    END IF;
END //
DELIMITER ;

-- ------------------------------------------------------------
-- 정리 (삭제)
-- ------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_dept_summary;
DROP FUNCTION IF EXISTS fn_grade;
DROP TRIGGER IF EXISTS trg_set_closed;

-- ------------------------------------------------------------
-- DB 로직의 함정 & 현대적 대안
--  함정: 디버깅 지옥 / 버전관리 어려움 / 이식성 낮음 / 확장성 제약(DB 병목) / 테스트 어려움
--  대안: 비즈니스 로직은 애플리케이션(Spring 등), DB는 순수 CRUD에 집중
--  예외: 감사로그·복제·대량배치·극한 성능 → 이럴 때만 DB 로직
-- ------------------------------------------------------------
