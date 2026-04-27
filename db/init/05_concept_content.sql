-- ============================================================
-- 마이그레이션: chapters에 concept_content 컬럼 추가
-- ============================================================
SET NAMES utf8mb4;

ALTER TABLE chapters ADD COLUMN concept_content LONGTEXT AFTER chapter_title;

-- ================================================================
-- CH1: 기본 SELECT & 필터링
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH1. 기본 SELECT &amp; 필터링</h2>

<section>
<h3>1. SELECT — 데이터 조회의 시작</h3>
<p>SQL에서 데이터를 <strong>읽어오는(조회하는)</strong> 명령어입니다. 모든 SQL의 기본이며, 실무의 90% 이상이 SELECT로 시작합니다.</p>
<div class="code-block">-- 모든 컬럼 조회
SELECT * FROM employees;

-- 특정 컬럼만 조회
SELECT emp_name, salary FROM employees;

-- 컬럼에 별칭(alias) 부여
SELECT emp_name AS 이름, salary AS 급여 FROM employees;</div>
<p class="tip">💡 <strong>실무 팁:</strong> <code>SELECT *</code>는 편리하지만 불필요한 컬럼까지 가져와 성능 저하의 원인이 됩니다. 필요한 컬럼만 명시하세요.</p>
</section>

<section>
<h3>2. WHERE — 조건으로 행 필터링</h3>
<p>원하는 행만 골라낼 때 사용합니다. 비교 연산자와 논리 연산자를 조합합니다.</p>
<div class="code-block">-- 단순 조건
SELECT emp_name, salary FROM employees WHERE salary >= 7000000;

-- AND / OR 조합
SELECT emp_name FROM employees WHERE dept_id = 1 AND salary >= 6000000;

-- IN — 여러 값 중 하나
SELECT emp_name FROM employees WHERE dept_id IN (1, 2, 5);

-- BETWEEN — 범위
SELECT emp_name, salary FROM employees WHERE salary BETWEEN 5000000 AND 7000000;

-- LIKE — 패턴 매칭 (% = 0개 이상 문자)
SELECT emp_name FROM employees WHERE emp_name LIKE ''김%'';</div>
</section>

<section>
<h3>3. ORDER BY — 정렬</h3>
<p>결과를 오름차순(ASC) 또는 내림차순(DESC)으로 정렬합니다.</p>
<div class="code-block">-- 단일 컬럼 정렬
SELECT emp_name, salary FROM employees ORDER BY salary DESC;

-- 다중 컬럼 정렬 (dept_id 오름차순 → salary 내림차순)
SELECT emp_name, dept_id, salary
FROM employees
ORDER BY dept_id ASC, salary DESC;</div>
</section>

<section>
<h3>4. LIMIT / OFFSET — 결과 수 제한</h3>
<p>상위 N개만 가져오거나, 페이지네이션을 구현할 때 사용합니다.</p>
<div class="code-block">-- 상위 5개만
SELECT emp_name, salary FROM employees ORDER BY salary DESC LIMIT 5;

-- 6번째부터 10번째 (페이지네이션)
SELECT emp_name, salary FROM employees ORDER BY salary DESC LIMIT 5 OFFSET 5;</div>
</section>

<section>
<h3>5. SQL 실행 순서</h3>
<p>SQL은 작성 순서와 <strong>실행 순서가 다릅니다.</strong></p>
<div class="code-block">-- 실행 순서: FROM → WHERE → SELECT → ORDER BY → LIMIT
SELECT emp_name, salary      -- 3. 컬럼 선택
FROM employees               -- 1. 테이블 결정
WHERE salary >= 7000000      -- 2. 행 필터
ORDER BY salary DESC         -- 4. 정렬
LIMIT 3;                     -- 5. 개수 제한</div>
</section>

</div>
' WHERE chapter_id = 1;

-- ================================================================
-- CH2: DISTINCT & 집계 함수
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH2. DISTINCT &amp; 집계 함수</h2>

<section>
<h3>1. DISTINCT — 중복 제거</h3>
<p>SELECT 결과에서 중복된 행을 제거합니다.</p>
<div class="code-block">-- 직책 종류 조회 (중복 제거)
SELECT DISTINCT job_title FROM employees;

-- 두 컬럼 조합의 중복 제거 (dept_id + job_title 쌍이 중복인 경우만 제거)
SELECT DISTINCT dept_id, job_title FROM employees;</div>
</section>

<section>
<h3>2. 집계 함수 — COUNT / SUM / AVG / MAX / MIN</h3>
<p>여러 행을 하나의 값으로 요약합니다.</p>
<div class="code-block">-- 전체 직원 수
SELECT COUNT(*) AS total_count FROM employees;

-- NULL이 아닌 manager_id 수 (팀장을 가진 직원 수)
SELECT COUNT(manager_id) AS has_manager FROM employees;

-- 급여 합계 / 평균 / 최고 / 최저
SELECT
    SUM(salary)            AS total_salary,
    ROUND(AVG(salary), 0)  AS avg_salary,
    MAX(salary)            AS max_salary,
    MIN(salary)            AS min_salary
FROM employees;</div>
</section>

<section>
<h3>3. GROUP BY — 그룹별 집계</h3>
<p>지정한 컬럼 값이 같은 행들을 묶어 집계합니다.</p>
<div class="code-block">-- 부서별 직원 수와 평균 급여
SELECT dept_id,
       COUNT(*)                    AS emp_count,
       ROUND(AVG(salary), 0)       AS avg_salary
FROM employees
GROUP BY dept_id
ORDER BY avg_salary DESC;</div>
<p class="tip">⚠️ <strong>주의:</strong> SELECT 절에는 GROUP BY에 명시한 컬럼 또는 집계 함수만 올 수 있습니다.</p>
</section>

<section>
<h3>4. HAVING — 그룹 조건 필터</h3>
<p>GROUP BY 이후 그룹 단위 조건을 겁니다. WHERE와의 차이를 꼭 기억하세요.</p>
<div class="code-block">-- 평균 급여 650만 이상인 부서만
SELECT dept_id, ROUND(AVG(salary), 0) AS avg_salary
FROM employees
GROUP BY dept_id
HAVING AVG(salary) >= 6500000;</div>
<div class="compare-table">
  <div class="compare-row"><span class="label">WHERE</span><span>행(row) 단위 필터 — 집계 이전에 적용</span></div>
  <div class="compare-row"><span class="label">HAVING</span><span>그룹 단위 필터 — 집계 이후에 적용</span></div>
</div>
<div class="code-block">-- 실행 순서
-- FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY</div>
</section>

</div>
' WHERE chapter_id = 2;

-- ================================================================
-- CH3: JOIN
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH3. JOIN — 테이블 연결</h2>

<section>
<h3>1. JOIN이란?</h3>
<p>두 개 이상의 테이블을 <strong>공통 키(FK)</strong>로 연결하여 하나의 결과로 만드는 연산입니다.</p>
</section>

<section>
<h3>2. INNER JOIN — 교집합</h3>
<p>양쪽 테이블 모두에 <strong>일치하는 행만</strong> 반환합니다.</p>
<div class="code-block">-- 직원 + 부서명 조회
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;</div>
</section>

<section>
<h3>3. LEFT JOIN — 왼쪽 전체 포함</h3>
<p>왼쪽 테이블의 <strong>모든 행</strong>을 포함하고, 오른쪽에 매칭되지 않으면 NULL을 채웁니다.</p>
<div class="code-block">-- 주문이 없는 직원도 포함
SELECT e.emp_name,
       IFNULL(CAST(o.order_date AS CHAR), ''주문없음'') AS order_date
FROM employees e
LEFT JOIN orders o ON e.emp_id = o.emp_id
ORDER BY e.emp_name;</div>
</section>

<section>
<h3>4. 3개 이상 테이블 JOIN</h3>
<p>JOIN을 연속으로 작성합니다. 각 JOIN마다 ON 조건을 반드시 명시하세요.</p>
<div class="code-block">-- 주문 → 직원 → 부서
SELECT o.order_id, e.emp_name, d.dept_name, o.total_amount
FROM orders o
JOIN employees   e ON o.emp_id   = e.emp_id
JOIN departments d ON e.dept_id  = d.dept_id
WHERE o.status = ''완료''
ORDER BY o.total_amount DESC;</div>
</section>

<section>
<h3>5. JOIN 종류 한눈에 보기</h3>
<div class="compare-table">
  <div class="compare-row"><span class="label">INNER JOIN</span><span>양쪽 일치하는 행만 (교집합)</span></div>
  <div class="compare-row"><span class="label">LEFT JOIN</span><span>왼쪽 전체 + 오른쪽 일치 (없으면 NULL)</span></div>
  <div class="compare-row"><span class="label">RIGHT JOIN</span><span>오른쪽 전체 + 왼쪽 일치 (없으면 NULL)</span></div>
  <div class="compare-row"><span class="label">CROSS JOIN</span><span>모든 조합 (카티션 곱)</span></div>
</div>
<p class="tip">💡 실무에서는 INNER JOIN과 LEFT JOIN이 95% 이상을 차지합니다.</p>
</section>

</div>
' WHERE chapter_id = 3;

-- ================================================================
-- CH4: 서브쿼리
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH4. 서브쿼리 (Subquery)</h2>

<section>
<h3>1. 서브쿼리란?</h3>
<p>쿼리 안에 <strong>중첩된 또 다른 쿼리</strong>입니다. SELECT, FROM, WHERE 절 어디에나 위치할 수 있습니다.</p>
</section>

<section>
<h3>2. 스칼라 서브쿼리 (SELECT 절)</h3>
<p>단 하나의 값을 반환하며, 각 행마다 실행됩니다.</p>
<div class="code-block">-- 각 직원 급여와 전체 평균 급여를 나란히 표시
SELECT emp_name,
       salary,
       (SELECT ROUND(AVG(salary), 0) FROM employees) AS avg_all
FROM employees;</div>
</section>

<section>
<h3>3. WHERE 서브쿼리</h3>
<p>비교 연산자 뒤에 단일 값을 반환하는 서브쿼리를 씁니다.</p>
<div class="code-block">-- 평균 이상 급여 직원 조회
SELECT emp_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;</div>
</section>

<section>
<h3>4. IN 서브쿼리</h3>
<p>서브쿼리가 반환하는 목록 안에 값이 있는지 확인합니다.</p>
<div class="code-block">-- 개발팀 직원 조회
SELECT emp_name, salary
FROM employees
WHERE dept_id IN (
    SELECT dept_id FROM departments WHERE dept_name = ''개발팀''
);</div>
</section>

<section>
<h3>5. EXISTS / NOT EXISTS</h3>
<p>서브쿼리 결과가 1건이라도 있으면 TRUE. IN보다 대용량에서 성능이 좋습니다.</p>
<div class="code-block">-- 주문이 있는 직원
SELECT emp_name FROM employees e
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.emp_id = e.emp_id);

-- 주문이 없는 직원
SELECT emp_name FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.emp_id = e.emp_id);</div>
</section>

<section>
<h3>6. FROM 서브쿼리 (인라인 뷰)</h3>
<p>집계 결과를 임시 테이블처럼 활용합니다.</p>
<div class="code-block">-- 부서 평균 급여 TOP 2
SELECT * FROM (
    SELECT dept_id, ROUND(AVG(salary), 0) AS avg_salary
    FROM employees
    GROUP BY dept_id
) sub
ORDER BY avg_salary DESC
LIMIT 2;</div>
</section>

</div>
' WHERE chapter_id = 4;

-- ================================================================
-- CH5: WITH (CTE)
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH5. WITH (CTE — Common Table Expression)</h2>

<section>
<h3>1. WITH란?</h3>
<p>쿼리 안에서 <strong>임시 결과 집합에 이름을 붙여 재사용</strong>하는 기능입니다. 복잡한 서브쿼리를 분리해 가독성을 높입니다.</p>
<div class="code-block">WITH cte_name AS (
    -- 이 안에 서브쿼리 작성
    SELECT ...
)
SELECT * FROM cte_name WHERE ...;</div>
</section>

<section>
<h3>2. 단일 CTE 예시</h3>
<div class="code-block">-- 부서별 평균 급여를 CTE로 정의 후 필터
WITH dept_avg AS (
    SELECT dept_id, ROUND(AVG(salary), 0) AS avg_salary
    FROM employees
    GROUP BY dept_id
)
SELECT dept_id, avg_salary
FROM dept_avg
WHERE avg_salary >= 7000000;</div>
</section>

<section>
<h3>3. 다중 CTE — 쉼표로 구분</h3>
<div class="code-block">WITH
dept_info AS (
    SELECT dept_id, COUNT(*) AS emp_count, SUM(salary) AS total_salary
    FROM employees
    GROUP BY dept_id
),
dept_avg AS (
    SELECT dept_id, ROUND(AVG(salary), 0) AS avg_salary
    FROM employees
    GROUP BY dept_id
)
SELECT d.dept_name, di.emp_count, da.avg_salary
FROM departments d
JOIN dept_info di ON d.dept_id = di.dept_id
JOIN dept_avg  da ON d.dept_id = da.dept_id
ORDER BY da.avg_salary DESC;</div>
</section>

<section>
<h3>4. CTE vs 서브쿼리 비교</h3>
<div class="compare-table">
  <div class="compare-row"><span class="label">서브쿼리</span><span>중첩 구조로 가독성 낮음, 재사용 불가</span></div>
  <div class="compare-row"><span class="label">WITH (CTE)</span><span>이름 부여로 가독성 높음, 여러 번 참조 가능</span></div>
</div>
<p class="tip">💡 복잡한 분석 쿼리일수록 WITH로 단계별로 분리하면 디버깅이 훨씬 쉬워집니다.</p>
</section>

</div>
' WHERE chapter_id = 5;

-- ================================================================
-- CH6: CASE WHEN
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH6. CASE WHEN — 조건 분기</h2>

<section>
<h3>1. CASE WHEN 기본 구조</h3>
<p>SQL의 <strong>if-else</strong>입니다. 조건을 위에서부터 순서대로 평가하고 처음 일치하는 값을 반환합니다.</p>
<div class="code-block">-- 급여 등급 분류
SELECT emp_name, salary,
    CASE
        WHEN salary >= 8000000 THEN ''S등급''
        WHEN salary >= 7000000 THEN ''A등급''
        WHEN salary >= 6000000 THEN ''B등급''
        ELSE ''C등급''
    END AS salary_grade
FROM employees;</div>
<p class="tip">⚠️ 조건은 위에서 아래로 순서대로 평가됩니다. 순서가 중요합니다!</p>
</section>

<section>
<h3>2. CASE WHEN + 집계 — PIVOT 패턴</h3>
<p>행을 열로 변환(피벗)할 때 가장 많이 사용하는 패턴입니다.</p>
<div class="code-block">-- 상태별 주문 건수를 열로 피벗
SELECT
    SUM(CASE WHEN status = ''완료''   THEN 1 ELSE 0 END) AS done_count,
    SUM(CASE WHEN status = ''취소''   THEN 1 ELSE 0 END) AS cancel_count,
    SUM(CASE WHEN status = ''진행중'' THEN 1 ELSE 0 END) AS inprogress_count
FROM orders;</div>
</section>

<section>
<h3>3. CASE WHEN 활용 패턴</h3>
<div class="code-block">-- NULL 처리 (COALESCE 대체)
SELECT emp_name,
    CASE WHEN manager_id IS NULL THEN ''팀장'' ELSE ''팀원'' END AS role
FROM employees;

-- 조건부 집계 (특정 조건 행만 합산)
SELECT dept_id,
    SUM(CASE WHEN salary >= 7000000 THEN salary ELSE 0 END) AS high_salary_sum
FROM employees
GROUP BY dept_id;</div>
</section>

</div>
' WHERE chapter_id = 6;

-- ================================================================
-- CH7: 윈도우 함수
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH7. 윈도우 함수 (Window Function)</h2>

<section>
<h3>1. 윈도우 함수란?</h3>
<p>GROUP BY처럼 그룹을 나누지만 <strong>행을 제거하지 않고</strong>, 각 행에 집계/순위 값을 붙입니다.</p>
<div class="code-block">함수명() OVER (
    PARTITION BY 그룹기준컬럼   -- GROUP BY 역할
    ORDER BY     정렬기준컬럼   -- 그룹 내 순서
)</div>
</section>

<section>
<h3>2. ROW_NUMBER / RANK / DENSE_RANK</h3>
<div class="code-block">SELECT emp_name, dept_id, salary,
    ROW_NUMBER()  OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn,
    RANK()        OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rk,
    DENSE_RANK()  OVER (PARTITION BY dept_id ORDER BY salary DESC) AS dense_rk
FROM employees;</div>
<div class="compare-table">
  <div class="compare-row"><span class="label">ROW_NUMBER</span><span>동점 무관, 항상 고유 번호 (1,2,3,4...)</span></div>
  <div class="compare-row"><span class="label">RANK</span><span>동점 같은 순위, 다음 순위 건너뜀 (1,1,3...)</span></div>
  <div class="compare-row"><span class="label">DENSE_RANK</span><span>동점 같은 순위, 다음 순위 연속 (1,1,2...)</span></div>
</div>
</section>

<section>
<h3>3. SUM / AVG OVER — 누적·이동 집계</h3>
<div class="code-block">-- 입사일 순 누적 급여
SELECT emp_name, hire_date, salary,
    SUM(salary) OVER (ORDER BY hire_date)     AS cumulative_salary,
    AVG(salary) OVER (ORDER BY hire_date
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM employees
ORDER BY hire_date;</div>
</section>

<section>
<h3>4. 그룹별 TOP 1 추출 — 핵심 패턴</h3>
<div class="code-block">-- 부서별 급여 1등 직원 (실무 최빈 패턴)
WITH ranked AS (
    SELECT emp_name, dept_id, salary,
           ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT emp_name, dept_id, salary
FROM ranked
WHERE rn = 1;</div>
<p class="tip">💡 이 패턴(ROW_NUMBER + WITH + WHERE rn=1)은 실무에서 매우 자주 쓰입니다. 꼭 익혀두세요!</p>
</section>

</div>
' WHERE chapter_id = 7;

-- ================================================================
-- CH8: 문자열 & 날짜 함수
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH8. 문자열 &amp; 날짜 함수</h2>

<section>
<h3>1. 문자열 함수</h3>
<div class="code-block">-- 길이
SELECT CHAR_LENGTH(''안녕하세요'');   -- 5 (문자 수)
SELECT LENGTH(''안녕하세요'');        -- 15 (바이트 수, UTF-8 한글=3byte)

-- 자르기
SELECT SUBSTR(''2024-01-15'', 1, 4);  -- ''2024''
SELECT LEFT(''홍길동'', 1);            -- ''홍''
SELECT RIGHT(''Hello'', 3);           -- ''llo''

-- 합치기
SELECT CONCAT(emp_name, '' ('', job_title, '')'') FROM employees;

-- 치환 / 반복
SELECT REPLACE(''hello world'', ''world'', ''SQL''); -- ''hello SQL''
SELECT REPEAT(''★'', 3);                            -- ''★★★''

-- 검색
SELECT SUBSTRING_INDEX(''user@gmail.com'', ''@'', -1); -- ''gmail.com''</div>
</section>

<section>
<h3>2. 날짜 함수</h3>
<div class="code-block">-- 오늘 날짜 / 현재 시각
SELECT CURDATE();         -- 2024-06-30
SELECT NOW();             -- 2024-06-30 14:30:00

-- 날짜 차이
SELECT DATEDIFF(''2024-12-31'', ''2024-01-01'');  -- 365 (일 수)
SELECT TIMESTAMPDIFF(HOUR, ''2024-01-01 09:00'', ''2024-01-02 11:00''); -- 26 (시간)

-- 날짜 포맷
SELECT DATE_FORMAT(hire_date, ''%Y-%m'')  AS ym  FROM employees;
SELECT DATE_FORMAT(hire_date, ''%Y년 %m월 %d일'') FROM employees;

-- 날짜 연산
SELECT DATE_ADD(CURDATE(), INTERVAL 30 DAY);   -- 30일 후
SELECT DATE_SUB(CURDATE(), INTERVAL 1 MONTH);  -- 1달 전

-- 추출
SELECT YEAR(hire_date), MONTH(hire_date), DAY(hire_date) FROM employees;</div>
</section>

<section>
<h3>3. GROUP_CONCAT — 여러 행을 하나로</h3>
<div class="code-block">-- 부서별 직원 이름 목록 (Oracle의 LISTAGG와 동일)
SELECT dept_id,
       GROUP_CONCAT(emp_name ORDER BY emp_name SEPARATOR '', '') AS emp_list
FROM employees
GROUP BY dept_id;</div>
</section>

</div>
' WHERE chapter_id = 8;

-- ================================================================
-- CH9: 종합 실전
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH9. 종합 실전 문제</h2>

<section>
<h3>지금까지 배운 것을 모두 활용합니다</h3>
<p>실무에서는 단일 기능이 아닌 <strong>여러 개념의 조합</strong>으로 쿼리를 작성합니다.</p>
</section>

<section>
<h3>실전 쿼리 작성 순서</h3>
<div class="code-block">-- 1단계: 필요한 테이블과 컬럼 파악
-- 2단계: JOIN 관계 설계
-- 3단계: WHERE 조건 적용
-- 4단계: GROUP BY / 집계
-- 5단계: HAVING / 윈도우 함수
-- 6단계: ORDER BY / LIMIT

-- 예시: 부서별 완료 주문 통계
SELECT d.dept_name,
       COUNT(o.order_id)    AS order_count,
       SUM(o.total_amount)  AS total_amount
FROM orders o
JOIN employees   e ON o.emp_id  = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
WHERE o.status = ''완료''
GROUP BY d.dept_name
ORDER BY total_amount DESC;</div>
</section>

<section>
<h3>자주 쓰이는 복합 패턴</h3>
<div class="code-block">-- 그룹별 TOP N (ROW_NUMBER + CTE)
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT * FROM ranked WHERE rn <= 2;

-- 집계 + 비율 계산
SELECT dept_id,
       SUM(salary)                                      AS dept_total,
       SUM(salary) / SUM(SUM(salary)) OVER () * 100    AS pct
FROM employees
GROUP BY dept_id;</div>
</section>

</div>
' WHERE chapter_id = 9;

-- ================================================================
-- CH10: 다중 JOIN & 복합 조건
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH10. 다중 JOIN &amp; 복합 조건</h2>

<section>
<h3>1. 3개 이상 테이블 JOIN 전략</h3>
<p>JOIN을 이어붙이는 순서는 논리 흐름을 따릅니다. 중심 테이블(가장 많은 데이터를 가진)을 FROM에 놓고 참조 방향으로 JOIN을 연결하세요.</p>
<div class="code-block">-- 주문 → 회원 → 등급 (3개 JOIN)
SELECT o.order_id, m.member_name, g.grade_name, o.final_amount
FROM adv_orders o
JOIN members       m ON o.member_id = m.member_id
JOIN member_grades g ON m.grade_id  = g.grade_id
WHERE o.status = ''delivered'';</div>
</section>

<section>
<h3>2. Self JOIN — 같은 테이블을 두 번</h3>
<p>계층형 데이터(카테고리 트리, 조직도)에서 부모-자식 관계를 펼칠 때 사용합니다.</p>
<div class="code-block">-- 계층형 카테고리: 소분류 → 중분류 → 대분류
SELECT c3.cat_name AS small_cat,
       c2.cat_name AS mid_cat,
       c1.cat_name AS top_cat
FROM adv_categories c3
JOIN adv_categories c2 ON c3.parent_id = c2.cat_id
JOIN adv_categories c1 ON c2.parent_id = c1.cat_id
WHERE c3.depth = 3;</div>
</section>

<section>
<h3>3. LEFT JOIN으로 NULL 분석</h3>
<div class="code-block">-- 쿠폰 발급됐지만 사용 안 한 건 수 집계
SELECT cp.policy_name,
       COUNT(ic.coupon_id)                                      AS issued_cnt,
       SUM(CASE WHEN ic.used_at IS NOT NULL THEN 1 ELSE 0 END)  AS used_cnt,
       SUM(CASE WHEN ic.used_at IS NULL     THEN 1 ELSE 0 END)  AS unused_cnt
FROM coupon_policies cp
LEFT JOIN issued_coupons ic ON cp.policy_id = ic.policy_id
GROUP BY cp.policy_id, cp.policy_name;</div>
</section>

<section>
<h3>4. JOIN 성능 팁</h3>
<div class="compare-table">
  <div class="compare-row"><span class="label">인덱스 활용</span><span>ON 조건의 컬럼에 인덱스가 있으면 빠름 (FK 컬럼은 자동 인덱스)</span></div>
  <div class="compare-row"><span class="label">WHERE 먼저</span><span>JOIN 전에 WHERE로 행을 줄이면 JOIN 비용 감소</span></div>
  <div class="compare-row"><span class="label">EXPLAIN</span><span>EXPLAIN SELECT ... 로 실행 계획 확인 가능</span></div>
</div>
</section>

</div>
' WHERE chapter_id = 10;

-- ================================================================
-- CH11: 윈도우 함수 심화
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH11. 윈도우 함수 심화</h2>

<section>
<h3>1. LAG / LEAD — 이전/다음 행 참조</h3>
<div class="code-block">-- 전월 대비 매출 증감
SELECT member_id,
       DATE_FORMAT(order_date, ''%Y-%m'')  AS order_ym,
       SUM(final_amount)                  AS monthly_amt,
       LAG(SUM(final_amount)) OVER (
           PARTITION BY member_id
           ORDER BY DATE_FORMAT(order_date, ''%Y-%m'')
       )                                  AS prev_amt
FROM adv_orders
WHERE status = ''delivered''
GROUP BY member_id, DATE_FORMAT(order_date, ''%Y-%m'');</div>
<div class="compare-table">
  <div class="compare-row"><span class="label">LAG(col, n)</span><span>현재 행보다 n행 이전 값 (기본 n=1)</span></div>
  <div class="compare-row"><span class="label">LEAD(col, n)</span><span>현재 행보다 n행 이후 값 (기본 n=1)</span></div>
</div>
</section>

<section>
<h3>2. NTILE — N분위 분류</h3>
<div class="code-block">-- 가격 기준 4분위 (1=최저가, 4=최고가 그룹)
SELECT product_name, sale_price,
       NTILE(4) OVER (ORDER BY sale_price) AS price_tile
FROM adv_products
WHERE is_selling = 1;</div>
</section>

<section>
<h3>3. ROWS BETWEEN — 프레임 지정</h3>
<div class="code-block">-- 직전 2건 포함 이동 평균
SELECT review_id, product_id, rating,
    AVG(rating) OVER (
        PARTITION BY product_id
        ORDER BY created_at
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg
FROM reviews;</div>
<div class="compare-table">
  <div class="compare-row"><span class="label">UNBOUNDED PRECEDING</span><span>파티션의 처음 행부터</span></div>
  <div class="compare-row"><span class="label">n PRECEDING</span><span>현재 행에서 n행 이전</span></div>
  <div class="compare-row"><span class="label">CURRENT ROW</span><span>현재 행</span></div>
  <div class="compare-row"><span class="label">n FOLLOWING</span><span>현재 행에서 n행 이후</span></div>
  <div class="compare-row"><span class="label">UNBOUNDED FOLLOWING</span><span>파티션의 마지막 행까지</span></div>
</div>
</section>

<section>
<h3>4. 전체 비율 계산</h3>
<div class="code-block">-- 매출 누적 비율 (파레토 분석)
SELECT order_id, final_amount,
    SUM(final_amount) OVER (ORDER BY final_amount DESC)  AS cum_amount,
    ROUND(
        SUM(final_amount) OVER (ORDER BY final_amount DESC)
        / SUM(final_amount) OVER () * 100, 1
    )                                                    AS cum_pct
FROM adv_orders
WHERE status = ''delivered'';</div>
</section>

</div>
' WHERE chapter_id = 11;

-- ================================================================
-- CH12: WITH CTE 심화
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH12. WITH (CTE) 심화</h2>

<section>
<h3>1. 재귀 CTE (WITH RECURSIVE)</h3>
<p>자기 자신을 참조하는 CTE로, 계층형 데이터 순회에 사용합니다.</p>
<div class="code-block">-- 카테고리 전체 경로 생성
WITH RECURSIVE cat_path AS (
    -- 앵커(종료조건): 최상위 카테고리
    SELECT cat_id, cat_name, cat_name AS full_path, parent_id
    FROM adv_categories
    WHERE parent_id IS NULL

    UNION ALL

    -- 재귀: 자식 카테고리
    SELECT c.cat_id, c.cat_name,
           CONCAT(cp.full_path, '' > '', c.cat_name),
           c.parent_id
    FROM adv_categories c
    JOIN cat_path cp ON c.parent_id = cp.cat_id
)
SELECT cat_id, cat_name, full_path FROM cat_path ORDER BY cat_id;</div>
</section>

<section>
<h3>2. 다중 CTE로 단계 분리</h3>
<div class="code-block">WITH
step1 AS (
    -- 1단계: 회원별 총 구매액
    SELECT member_id, SUM(final_amount) AS total_paid
    FROM adv_orders WHERE status = ''delivered''
    GROUP BY member_id
),
step2 AS (
    -- 2단계: 업그레이드 가능한 등급 탐색
    SELECT s.member_id, s.total_paid, MAX(g.min_amount) AS next_min
    FROM step1 s
    JOIN member_grades g ON g.min_amount <= s.total_paid
    GROUP BY s.member_id, s.total_paid
)
SELECT m.member_name, s2.total_paid
FROM step2 s2
JOIN members m ON s2.member_id = m.member_id;</div>
<p class="tip">💡 CTE는 단계별로 나누면 각 단계를 독립적으로 테스트할 수 있어 디버깅이 쉽습니다.</p>
</section>

<section>
<h3>3. CTE Self JOIN — YoY 비교</h3>
<div class="code-block">WITH monthly AS (
    SELECT ym, SUM(total_revenue) AS total_rev
    FROM monthly_sales GROUP BY ym
)
SELECT cur.ym, cur.total_rev, prev.total_rev AS prev_year_rev,
    ROUND((cur.total_rev - prev.total_rev) / prev.total_rev * 100, 1) AS yoy_pct
FROM monthly cur
JOIN monthly prev
  ON SUBSTR(cur.ym,6,2) = SUBSTR(prev.ym,6,2)
 AND CAST(SUBSTR(cur.ym,1,4) AS UNSIGNED) = CAST(SUBSTR(prev.ym,1,4) AS UNSIGNED) + 1;</div>
</section>

</div>
' WHERE chapter_id = 12;

-- ================================================================
-- CH13: 서브쿼리 심화
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH13. 서브쿼리 &amp; EXISTS 심화</h2>

<section>
<h3>1. 상관 서브쿼리 (Correlated Subquery)</h3>
<p>외부 쿼리의 값을 내부 서브쿼리에서 참조합니다. 행마다 실행되므로 대용량 시 성능 주의.</p>
<div class="code-block">-- 각 카테고리에서 평균 이상 평점 상품
SELECT product_name, cat_id, rating_avg
FROM adv_products ap
WHERE rating_avg > (
    SELECT AVG(rating_avg)
    FROM adv_products
    WHERE cat_id = ap.cat_id   -- 외부 쿼리의 cat_id 참조
);</div>
</section>

<section>
<h3>2. NOT EXISTS — 없는 것 찾기</h3>
<div class="code-block">-- 쿠폰을 발급받았지만 한 번도 사용하지 않은 회원
SELECT m.member_name, m.email
FROM members m
WHERE EXISTS (
    SELECT 1 FROM issued_coupons ic WHERE ic.member_id = m.member_id
)
AND NOT EXISTS (
    SELECT 1 FROM issued_coupons ic2
    WHERE ic2.member_id = m.member_id AND ic2.used_at IS NOT NULL
);</div>
<p class="tip">💡 <strong>NOT IN vs NOT EXISTS:</strong> 서브쿼리 결과에 NULL이 있으면 NOT IN은 항상 FALSE를 반환합니다. NOT EXISTS가 더 안전합니다.</p>
</section>

<section>
<h3>3. 인라인 뷰 + HAVING</h3>
<div class="code-block">-- 포인트 잔액 1000 이상인 회원
SELECT m.member_name, ph.balance
FROM members m
JOIN (
    SELECT member_id, SUM(point_amt) AS balance
    FROM point_history
    GROUP BY member_id
    HAVING SUM(point_amt) >= 1000
) ph ON m.member_id = ph.member_id
ORDER BY ph.balance DESC;</div>
</section>

</div>
' WHERE chapter_id = 13;

-- ================================================================
-- CH14: 날짜/문자열 함수 심화
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH14. 날짜 &amp; 문자열 함수 심화</h2>

<section>
<h3>1. 날짜 심화 함수</h3>
<div class="code-block">-- TIMESTAMPDIFF: 정밀한 시간 차이
SELECT TIMESTAMPDIFF(HOUR,  ''2024-01-01 09:00'', ''2024-01-02 11:30''); -- 26
SELECT TIMESTAMPDIFF(MINUTE,''2024-01-01 09:00'', ''2024-01-01 11:30''); -- 150

-- DATE vs DATETIME 추출
SELECT DATE(''2024-01-15 14:30:00'');   -- 2024-01-15
SELECT TIME(''2024-01-15 14:30:00'');   -- 14:30:00

-- 월별 그룹핑
SELECT DATE_FORMAT(order_date, ''%Y-%m'') AS ym,
       COUNT(*) AS cnt
FROM adv_orders
GROUP BY ym
ORDER BY ym;</div>
</section>

<section>
<h3>2. 문자열 심화 함수</h3>
<div class="code-block">-- SUBSTRING_INDEX: 구분자 기준 분리
SELECT SUBSTRING_INDEX(''user@gmail.com'', ''@'', 1);   -- ''user''
SELECT SUBSTRING_INDEX(''user@gmail.com'', ''@'', -1);  -- ''gmail.com''

-- CHAR_LENGTH vs LENGTH (한글 차이)
SELECT CHAR_LENGTH(''안녕'');   -- 2 (글자 수)
SELECT LENGTH(''안녕'');        -- 6 (바이트 수, UTF-8)

-- REPEAT: 반복
SELECT REPEAT(''★'', 5);  -- ''★★★★★''

-- LPAD / RPAD: 패딩
SELECT LPAD(''7'', 3, ''0'');   -- ''007''</div>
</section>

<section>
<h3>3. 윈도우 + DATE_FORMAT 조합</h3>
<div class="code-block">-- 월별 누적 가입자 수
SELECT DATE_FORMAT(join_date, ''%Y-%m'')                              AS join_ym,
       COUNT(*)                                                        AS new_cnt,
       SUM(COUNT(*)) OVER (ORDER BY DATE_FORMAT(join_date, ''%Y-%m'')) AS cum_cnt
FROM members
WHERE is_active = 1
GROUP BY DATE_FORMAT(join_date, ''%Y-%m'');</div>
</section>

</div>
' WHERE chapter_id = 14;

-- ================================================================
-- CH15: 집계 & PIVOT 심화
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH15. 집계 &amp; PIVOT 심화</h2>

<section>
<h3>1. 이중 PIVOT — 행×열 교차 분석</h3>
<div class="code-block">-- 결제수단 × 주문상태 교차표
SELECT payment_method,
    SUM(CASE WHEN status = ''delivered'' THEN 1 ELSE 0 END) AS delivered_cnt,
    SUM(CASE WHEN status = ''cancelled'' THEN 1 ELSE 0 END) AS cancelled_cnt,
    SUM(CASE WHEN status = ''pending''   THEN 1 ELSE 0 END) AS pending_cnt
FROM adv_orders
GROUP BY payment_method
ORDER BY payment_method;</div>
</section>

<section>
<h3>2. 마진율 분석</h3>
<div class="code-block">-- 상품별 매출 / 원가 / 마진율
SELECT p.product_name,
    SUM(oi.unit_price  * oi.quantity) AS revenue,
    SUM(oi.cost_price  * oi.quantity) AS cost,
    SUM(oi.unit_price  * oi.quantity)
    - SUM(oi.cost_price * oi.quantity) AS margin,
    ROUND(
        (SUM(oi.unit_price * oi.quantity) - SUM(oi.cost_price * oi.quantity))
        / SUM(oi.unit_price * oi.quantity) * 100, 1
    ) AS margin_pct
FROM adv_order_items oi
JOIN adv_products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.product_name
HAVING margin_pct >= 30
ORDER BY margin_pct DESC;</div>
</section>

<section>
<h3>3. 비중 계산 — 윈도우 SUM 활용</h3>
<div class="code-block">-- 월별 카테고리 매출 비중
SELECT ym, cat_id, total_revenue,
    SUM(total_revenue) OVER (PARTITION BY ym)     AS monthly_total,
    ROUND(
        total_revenue / SUM(total_revenue) OVER (PARTITION BY ym) * 100, 1
    )                                              AS share_pct
FROM monthly_sales
WHERE ym LIKE ''2024%''
ORDER BY ym, share_pct DESC;</div>
</section>

</div>
' WHERE chapter_id = 15;

-- ================================================================
-- CH16: 종합 실전 (복합 쿼리)
-- ================================================================
UPDATE chapters SET concept_content = '
<div class="concept-page">

<h2>CH16. 종합 실전 — 복합 쿼리</h2>

<section>
<h3>복잡한 실무 쿼리 작성 전략</h3>
<p>실무의 어려운 쿼리는 항상 <strong>작은 단계로 분해</strong>해서 작성합니다.</p>
<div class="code-block">-- 전략: CTE로 단계 분리 후 합치기
WITH
-- 1단계: 필요한 기본 집계
sales AS (
    SELECT product_id, SUM(quantity) AS total_qty,
           SUM(unit_price * quantity) AS total_revenue
    FROM adv_order_items oi
    JOIN adv_orders ao ON oi.order_id = ao.order_id
    WHERE ao.status NOT IN (''cancelled'',''refunded'')
    GROUP BY product_id
),
-- 2단계: 추가 정보 집계
reviews_agg AS (
    SELECT product_id, COUNT(*) AS review_cnt, ROUND(AVG(rating),2) AS avg_rating
    FROM reviews GROUP BY product_id
),
-- 3단계: 순위 계산
ranked AS (
    SELECT p.product_name, s.total_qty, s.total_revenue,
           COALESCE(r.review_cnt, 0) AS review_cnt,
           COALESCE(r.avg_rating, 0) AS avg_rating,
           RANK() OVER (ORDER BY s.total_revenue DESC) AS revenue_rank
    FROM sales s
    JOIN adv_products p ON s.product_id = p.product_id
    LEFT JOIN reviews_agg r ON s.product_id = r.product_id
)
-- 4단계: 최종 결과 + 등급 부여
SELECT *, CASE
    WHEN revenue_rank <= 3 AND avg_rating >= 4.5 THEN ''S''
    WHEN revenue_rank <= 5 THEN ''A''
    ELSE ''B''
END AS performance
FROM ranked
ORDER BY revenue_rank;</div>
</section>

<section>
<h3>핵심 실무 패턴 요약</h3>
<div class="compare-table">
  <div class="compare-row"><span class="label">그룹별 TOP N</span><span>ROW_NUMBER + CTE + WHERE rn &lt;= N</span></div>
  <div class="compare-row"><span class="label">전월 비교</span><span>LAG() OVER (PARTITION BY ... ORDER BY ym)</span></div>
  <div class="compare-row"><span class="label">비중 계산</span><span>SUM(col) OVER () 전체합 나누기</span></div>
  <div class="compare-row"><span class="label">NULL 처리</span><span>LEFT JOIN + COALESCE/IFNULL</span></div>
  <div class="compare-row"><span class="label">PIVOT</span><span>SUM(CASE WHEN ... THEN 1 ELSE 0 END)</span></div>
</div>
</section>

</div>
' WHERE chapter_id = 16;
