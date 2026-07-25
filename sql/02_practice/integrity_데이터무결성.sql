-- ============================================================
-- [실습 기록] 데이터 무결성 — 제약조건 (2026-07-23)
-- 노트: docs/notes/integrity_데이터무결성.md
-- ============================================================
USE minwon;

-- ------------------------------------------------------------
-- ① 기본 제약조건 (NOT NULL / UNIQUE / PK / DEFAULT / AUTO_INCREMENT)
-- ------------------------------------------------------------
DESC complaint;

-- UNIQUE 위반: 이미 있는 이메일로 담당자 등록 → 에러
-- INSERT INTO officer (department_id, name, grade, email, hired_at)
-- VALUES (1, '테스트', '주무관', 'kim.ms@haneul.go.kr', '2026-01-01');
-- → Duplicate entry '...' for key 'email'

-- ------------------------------------------------------------
-- ② 외래 키(FK) 제약 — 관계의 무결성
-- ------------------------------------------------------------
-- 없는 부서(999)에 민원 배정 → 에러 (자식이 없는 부모 참조 불가)
-- INSERT INTO complaint (citizen_id, department_id, category, title, content, status, channel, created_at)
-- VALUES (1, 999, '기타', '테스트', '내용', '접수', '온라인', NOW());
-- → Cannot add or update a child row: a foreign key constraint fails

-- 민원이 딸린 부서 삭제 → 에러 (자식이 참조 중)
-- DELETE FROM department WHERE id = 3;
-- → Cannot delete or update a parent row

-- ------------------------------------------------------------
-- ③ CHECK 제약 — 값의 범위/규칙 (MySQL 8.0.16+)
-- ------------------------------------------------------------
-- 만족도 1~5만 허용
ALTER TABLE complaint
ADD CONSTRAINT chk_score CHECK (satisfaction_score BETWEEN 1 AND 5);

-- 7점 등록 시도 → 에러
-- INSERT INTO complaint (citizen_id, department_id, officer_id, category, title, content, status, channel, created_at, satisfaction_score)
-- VALUES (1, 1, 3, '기타', '테스트', '내용', '완료', '온라인', NOW(), 7);
-- → Check constraint 'chk_score' is violated

-- CHECK로 표현 가능한 규칙들 (개념)
-- CHECK (status IN ('접수','처리중','보류','완료','반려'))  -- 허용 목록
-- CHECK (birth_year >= 1900)                              -- 하한
-- CHECK (closed_at >= created_at)                         -- 칼럼 간 관계

-- 확인 / 삭제
SHOW CREATE TABLE complaint;
ALTER TABLE complaint DROP CONSTRAINT chk_score;

-- ------------------------------------------------------------
-- 4대 제약 총정리
--  NOT NULL : 빈 값 차단        UNIQUE : 중복 차단
--  FK       : 관계 깨짐 차단    CHECK  : 규칙 위반 값 차단
--  철학: 앱이 실수해도 DB가 마지막에 막는다 (최후 방어선)
-- ------------------------------------------------------------
