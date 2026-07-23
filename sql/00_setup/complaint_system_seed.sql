-- ============================================================
-- 민원 시스템(minwon) 실습 데이터 시드
-- 대상: 집계와 그룹핑 ~ 조인/서브쿼리/UNION/CASE/뷰/인덱스/무결성/트랜잭션
-- 실행: docker exec -i prgrms-mysql mysql -uroot -p1234 < 이파일
-- ============================================================

-- 클라이언트 문자셋 고정 (도커 initdb 자동 실행 시 한글 깨짐 방지)
SET NAMES utf8mb4;

DROP DATABASE IF EXISTS minwon;
CREATE DATABASE minwon CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE minwon;

-- ------------------------------------------------------------
-- 1. 부서 (department)
-- ------------------------------------------------------------
CREATE TABLE department (
    id          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    name        VARCHAR(50)     NOT NULL UNIQUE,
    location    VARCHAR(50)     NOT NULL,               -- 청사 위치
    created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
);

INSERT INTO department (name, location, created_at) VALUES
    ('민원봉사과', '본관 1층', '2020-01-02 09:00:00'),
    ('도로관리과', '본관 3층', '2020-01-02 09:00:00'),
    ('환경위생과', '별관 2층', '2020-01-02 09:00:00'),
    ('교통행정과', '본관 4층', '2020-01-02 09:00:00'),
    ('정보통신과', '별관 3층', '2021-03-02 09:00:00'),
    ('도시계획과', '본관 5층', '2020-01-02 09:00:00'),
    ('감사담당관', '본관 6층', '2026-07-01 09:00:00');  -- 신설 부서(담당자·민원 없음) → LEFT JOIN 실습용

-- ------------------------------------------------------------
-- 2. 담당자 (officer) : 부서별 3명 (과장/팀장/주무관), 감사담당관은 아직 없음
-- ------------------------------------------------------------
CREATE TABLE officer (
    id            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    department_id INT UNSIGNED  NOT NULL,
    name          VARCHAR(50)   NOT NULL,
    grade         VARCHAR(20)   NOT NULL,               -- 과장, 팀장, 주무관
    email         VARCHAR(100)  NOT NULL UNIQUE,
    hired_at      DATE          NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (department_id) REFERENCES department (id)
);

INSERT INTO officer (department_id, name, grade, email, hired_at) VALUES
    (1, '김민수', '과장',   'kim.ms@haneul.go.kr',   '2012-03-05'),
    (1, '이서연', '팀장',   'lee.sy@haneul.go.kr',   '2016-07-11'),
    (1, '박지훈', '주무관', 'park.jh@haneul.go.kr',  '2021-01-18'),
    (2, '최영호', '과장',   'choi.yh@haneul.go.kr',  '2010-09-01'),
    (2, '정다은', '팀장',   'jung.de@haneul.go.kr',  '2017-04-24'),
    (2, '한상우', '주무관', 'han.sw@haneul.go.kr',   '2022-02-14'),
    (3, '오세라', '과장',   'oh.sr@haneul.go.kr',    '2011-05-16'),
    (3, '임재현', '팀장',   'lim.jh@haneul.go.kr',   '2018-10-08'),
    (3, '강수진', '주무관', 'kang.sj@haneul.go.kr',  '2023-03-02'),
    (4, '윤성민', '과장',   'yoon.sm@haneul.go.kr',  '2013-11-25'),
    (4, '조하늘', '팀장',   'cho.hn@haneul.go.kr',   '2019-06-17'),
    (4, '신동혁', '주무관', 'shin.dh@haneul.go.kr',  '2024-01-08'),
    (5, '문지원', '과장',   'moon.jw@haneul.go.kr',  '2014-02-03'),
    (5, '배준서', '팀장',   'bae.js@haneul.go.kr',   '2020-08-31'),
    (5, '송예린', '주무관', 'song.yr@haneul.go.kr',  '2024-07-01'),
    (6, '홍길준', '과장',   'hong.gj@haneul.go.kr',  '2012-12-10'),
    (6, '서지우', '팀장',   'seo.jw@haneul.go.kr',   '2018-03-19'),
    (6, '노태윤', '주무관', 'noh.ty@haneul.go.kr',   '2023-09-04');

-- ------------------------------------------------------------
-- 3. 민원인 (citizen) : 40명, 가상 도시 '하늘시' 5개 구
-- ------------------------------------------------------------
CREATE TABLE citizen (
    id         INT UNSIGNED      NOT NULL AUTO_INCREMENT,
    name       VARCHAR(50)       NOT NULL,
    birth_year SMALLINT UNSIGNED NOT NULL,
    gender     CHAR(1)           NOT NULL,              -- 'M' / 'F'
    region     VARCHAR(30)       NOT NULL,              -- 거주 구
    phone      VARCHAR(20)       NOT NULL,
    PRIMARY KEY (id)
);

INSERT INTO citizen (name, birth_year, gender, region, phone) VALUES
    ('강민준', 1988, 'M', '중앙구', '010-1000-0001'),
    ('김서아', 1995, 'F', '동부구', '010-1000-0002'),
    ('박도윤', 1979, 'M', '서부구', '010-1000-0003'),
    ('이하은', 2001, 'F', '남부구', '010-1000-0004'),
    ('최시우', 1992, 'M', '북부구', '010-1000-0005'),
    ('정지안', 1985, 'F', '중앙구', '010-1000-0006'),
    ('조은우', 1998, 'M', '동부구', '010-1000-0007'),
    ('윤서준', 1973, 'M', '서부구', '010-1000-0008'),
    ('장하린', 1990, 'F', '남부구', '010-1000-0009'),
    ('임지호', 1983, 'M', '북부구', '010-1000-0010'),
    ('한아린', 1996, 'F', '중앙구', '010-1000-0011'),
    ('오준우', 1969, 'M', '동부구', '010-1000-0012'),
    ('서다인', 2000, 'F', '서부구', '010-1000-0013'),
    ('신유찬', 1987, 'M', '남부구', '010-1000-0014'),
    ('권소율', 1993, 'F', '북부구', '010-1000-0015'),
    ('황시온', 1978, 'M', '중앙구', '010-1000-0016'),
    ('안채원', 1999, 'F', '동부구', '010-1000-0017'),
    ('송건우', 1965, 'M', '서부구', '010-1000-0018'),
    ('전예나', 1991, 'F', '남부구', '010-1000-0019'),
    ('홍지환', 1980, 'M', '북부구', '010-1000-0020'),
    ('고나윤', 1997, 'F', '중앙구', '010-1000-0021'),
    ('문선호', 1975, 'M', '동부구', '010-1000-0022'),
    ('양다연', 2002, 'F', '서부구', '010-1000-0023'),
    ('손민재', 1986, 'M', '남부구', '010-1000-0024'),
    ('배가은', 1994, 'F', '북부구', '010-1000-0025'),
    ('조성진', 1971, 'M', '중앙구', '010-1000-0026'),
    ('백서윤', 1989, 'F', '동부구', '010-1000-0027'),
    ('허준영', 1996, 'M', '서부구', '010-1000-0028'),
    ('유채린', 1984, 'F', '남부구', '010-1000-0029'),
    ('남도현', 1977, 'M', '북부구', '010-1000-0030'),
    ('심규리', 2003, 'F', '중앙구', '010-1000-0031'),
    ('노현우', 1982, 'M', '동부구', '010-1000-0032'),
    ('하윤서', 1998, 'F', '서부구', '010-1000-0033'),
    ('곽태민', 1968, 'M', '남부구', '010-1000-0034'),
    ('성지유', 1995, 'F', '북부구', '010-1000-0035'),
    ('차승원', 1981, 'M', '중앙구', '010-1000-0036'),
    ('주아영', 1992, 'F', '동부구', '010-1000-0037'),
    ('우재원', 1974, 'M', '서부구', '010-1000-0038'),
    ('민하율', 2000, 'F', '남부구', '010-1000-0039'),
    ('추성연', 1987, 'M', '북부구', '010-1000-0040');

-- ------------------------------------------------------------
-- 4. 민원 (complaint) : 300건 자동 생성
--    카테고리 → 담당 부서 매핑
--      도로→도로관리과, 소음/환경→환경위생과, 교통→교통행정과,
--      정보공개→정보통신과, 시설→도시계획과, 기타→민원봉사과
--    상태 분포: 접수 10% / 처리중 18% / 보류 8% / 완료 57% / 반려 7%
--    접수 상태는 담당자 미배정(NULL), 완료 건만 만족도(1~5) 존재
-- ------------------------------------------------------------
CREATE TABLE complaint (
    id                 INT UNSIGNED     NOT NULL AUTO_INCREMENT,
    citizen_id         INT UNSIGNED     NOT NULL,
    department_id      INT UNSIGNED     NOT NULL,
    officer_id         INT UNSIGNED     NULL,           -- 미배정 시 NULL
    category           VARCHAR(20)      NOT NULL,       -- 도로/소음/환경/교통/정보공개/시설/기타
    title              VARCHAR(200)     NOT NULL,
    content            TEXT             NOT NULL,
    status             VARCHAR(10)      NOT NULL,       -- 접수/처리중/보류/완료/반려
    channel            VARCHAR(10)      NOT NULL,       -- 온라인/전화/방문
    created_at         DATETIME         NOT NULL,
    closed_at          DATETIME         NULL,           -- 완료/반려 시각
    satisfaction_score TINYINT UNSIGNED NULL,           -- 1~5 (완료 건만)
    PRIMARY KEY (id),
    FOREIGN KEY (citizen_id)    REFERENCES citizen (id),
    FOREIGN KEY (department_id) REFERENCES department (id),
    FOREIGN KEY (officer_id)    REFERENCES officer (id)
);

-- 랜덤값을 먼저 임시 테이블에 '고정'한다.
-- (파생 테이블을 그대로 쓰면 MySQL의 derived merge 최적화로 인해
--  RAND() 기반 status가 참조될 때마다 재계산되어 데이터 규칙이 깨진다)
DROP TEMPORARY TABLE IF EXISTS tmp_seed;
CREATE TEMPORARY TABLE tmp_seed AS
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 300
)
SELECT
    n,
    1 + FLOOR(RAND() * 40)                                                  AS citizen_id,
    1 + FLOOR(RAND() * 7)                                                   AS cat_idx,
    RAND()                                                                  AS r1,
    DATE_SUB('2026-07-20 18:00:00',
             INTERVAL 25 + FLOOR(RAND() * 360) DAY)
        - INTERVAL FLOOR(RAND() * 10) HOUR                                  AS created_at
FROM seq;

-- 상태까지 확정한 2차 임시 테이블
DROP TEMPORARY TABLE IF EXISTS tmp_gen;
CREATE TEMPORARY TABLE tmp_gen AS
SELECT
    n,
    citizen_id,
    ELT(cat_idx, '도로', '소음', '환경', '교통', '정보공개', '시설', '기타')  AS category,
    ELT(cat_idx, 2, 3, 3, 4, 5, 6, 1)                                        AS dept_id,
    ELT(cat_idx,
        '도로 파손 및 포트홀 신고',
        '심야 시간대 소음 신고',
        '생활 쓰레기 무단투기 신고',
        '교차로 불법 주정차 신고',
        '행정정보 공개 청구',
        '공원 시설물 파손 보수 요청',
        '민원 처리 절차 문의')                                               AS title_base,
    CASE
        WHEN r1 < 0.10 THEN '접수'
        WHEN r1 < 0.28 THEN '처리중'
        WHEN r1 < 0.36 THEN '보류'
        WHEN r1 < 0.93 THEN '완료'
        ELSE '반려'
    END                                                                      AS status,
    created_at
FROM tmp_seed;

INSERT INTO complaint
    (citizen_id, department_id, officer_id, category, title, content,
     status, channel, created_at, closed_at, satisfaction_score)
SELECT
    citizen_id,
    dept_id,
    IF(status = '접수', NULL, (dept_id - 1) * 3 + 1 + FLOOR(RAND() * 3))       AS officer_id,
    category,
    CONCAT(title_base, ' (접수번호 ', 2600000 + n, ')')                         AS title,
    CONCAT('[', category, '] ', title_base, '에 대한 민원 상세 내용입니다.')     AS content,
    status,
    ELT(1 + FLOOR(RAND() * 10),
        '온라인','온라인','온라인','온라인','온라인',
        '전화','전화','전화','방문','방문')                                     AS channel,
    created_at,
    IF(status IN ('완료', '반려'),
       created_at + INTERVAL 1 + FLOOR(RAND() * 20) DAY
                  + INTERVAL FLOOR(RAND() * 8) HOUR,
       NULL)                                                                    AS closed_at,
    IF(status = '완료',
       ELT(1 + FLOOR(RAND() * 10), 1, 2, 2, 3, 3, 4, 4, 4, 5, 5),
       NULL)                                                                    AS satisfaction_score
FROM tmp_gen;

DROP TEMPORARY TABLE IF EXISTS tmp_seed;
DROP TEMPORARY TABLE IF EXISTS tmp_gen;

-- ------------------------------------------------------------
-- 확인용 요약
-- ------------------------------------------------------------
SELECT '부서'   AS 항목, COUNT(*) AS 건수 FROM department
UNION ALL SELECT '담당자', COUNT(*) FROM officer
UNION ALL SELECT '민원인', COUNT(*) FROM citizen
UNION ALL SELECT '민원',   COUNT(*) FROM complaint;
