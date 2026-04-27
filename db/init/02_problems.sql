-- ============================================================
-- SQL Playground - Problems Table & Data
-- ============================================================

SET NAMES utf8mb4;

-- ───────────────────────────── 챕터 테이블 ─────────────────────────────
CREATE TABLE chapters (
    chapter_id INT PRIMARY KEY,
    chapter_title VARCHAR(100) NOT NULL,
    sort_order INT NOT NULL DEFAULT 0
);

-- ───────────────────────────── 문제 테이블 ─────────────────────────────
CREATE TABLE problems (
    problem_id INT PRIMARY KEY AUTO_INCREMENT,
    chapter_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    difficulty ENUM('easy', 'medium', 'hard') NOT NULL DEFAULT 'easy',
    concept VARCHAR(100),
    description TEXT,
    hint TEXT,
    answer_sql TEXT NOT NULL,
    concept_explain TEXT,
    sort_order INT NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (chapter_id) REFERENCES chapters (chapter_id)
);

-- ───────────────────────────── 챕터 데이터 ─────────────────────────────
INSERT INTO
    chapters (
        chapter_id,
        chapter_title,
        sort_order
    )
VALUES (1, '기본 SELECT & 필터링', 1),
    (2, 'DISTINCT & 집계 함수', 2),
    (3, 'JOIN', 3),
    (4, '서브쿼리 (Subquery)', 4),
    (5, 'WITH (CTE)', 5),
    (6, 'CASE WHEN', 6),
    (
        7,
        '윈도우 함수 (Window Function)',
        7
    ),
    (8, '문자열 & 날짜 함수', 8),
    (9, '종합 실전 문제', 9);

-- ───────────────────────────── 문제 데이터 ─────────────────────────────

-- CH1: 기본 SELECT & 필터링
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        1,
        '전체 직원 조회',
        'easy',
        'SELECT *',
        'employees 테이블의 모든 컬럼과 행을 조회하세요.',
        'SELECT * FROM 테이블명 형태로 작성합니다.',
        'SELECT * FROM employees',
        '<strong>SELECT *</strong> 는 테이블의 모든 컬럼을 조회하는 가장 기본적인 구문입니다.<br>실무에서는 필요한 컬럼만 명시하는 것이 성능에 좋지만, 데이터 탐색 시엔 * 로 전체를 보는 것이 편합니다.',
        1
    ),
    (
        1,
        '특정 컬럼만 조회',
        'easy',
        'SELECT 컬럼 지정',
        'employees 테이블에서 emp_name, job_title, salary 컬럼만 조회하세요.',
        'SELECT 뒤에 원하는 컬럼명을 쉼표로 구분해서 나열하세요.',
        'SELECT emp_name, job_title, salary FROM employees',
        '컬럼을 명시적으로 지정하면 <strong>네트워크 트래픽 절감</strong>과 <strong>가독성 향상</strong>에 도움됩니다. 실무에서는 항상 필요한 컬럼만 SELECT 하는 것이 좋은 습관입니다.',
        2
    ),
    (
        1,
        'WHERE 조건 필터링',
        'easy',
        'WHERE',
        'employees 테이블의 salary가 700만원 이상인 직원의 emp_name, job_title, salary를 조회하세요.',
        'WHERE salary >= 7000000',
        'SELECT emp_name, job_title, salary FROM employees WHERE salary >= 7000000',
        '<strong>WHERE</strong> 절은 행을 필터링합니다. 비교 연산자(=, !=, >, >=, <, <=)와 논리 연산자(AND, OR, NOT)를 조합해 복잡한 조건도 표현할 수 있습니다.',
        3
    ),
    (
        1,
        'ORDER BY 정렬',
        'easy',
        'ORDER BY',
        'employees 테이블에서 salary가 높은 순서대로 emp_name, salary를 조회하세요.',
        'ORDER BY salary DESC',
        'SELECT emp_name, salary FROM employees ORDER BY salary DESC',
        '<strong>ORDER BY</strong> 는 결과를 정렬합니다. <code>ASC</code>(오름차순, 기본값) / <code>DESC</code>(내림차순)를 지정할 수 있습니다. 여러 컬럼 정렬도 가능합니다: <code>ORDER BY dept_id ASC, salary DESC</code>',
        4
    ),
    (
        1,
        'LIMIT & OFFSET',
        'easy',
        'LIMIT',
        'salary가 높은 순서로 상위 5명의 emp_name, salary를 조회하세요.',
        'ORDER BY ... DESC LIMIT 5',
        'SELECT emp_name, salary FROM employees ORDER BY salary DESC LIMIT 5',
        '<strong>LIMIT n</strong> 은 결과를 n개로 제한합니다. <code>LIMIT 5 OFFSET 10</code> 처럼 OFFSET을 함께 쓰면 페이지네이션을 구현할 수 있습니다.',
        5
    );

-- CH2: DISTINCT & 집계 함수
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        2,
        'DISTINCT - 중복 제거',
        'easy',
        'DISTINCT',
        'employees 테이블에서 중복 없이 job_title 목록을 조회하세요.',
        'SELECT DISTINCT 컬럼명 ...',
        'SELECT DISTINCT job_title FROM employees',
        '<strong>DISTINCT</strong> 는 중복 행을 제거합니다. 실무에서는 카테고리 목록, 코드 목록 조회 시 자주 사용됩니다.<br>⚠️ 컬럼이 여러 개이면 <em>모든 컬럼의 조합</em>이 중복인 경우만 제거됩니다.',
        1
    ),
    (
        2,
        'COUNT - 행 수 세기',
        'easy',
        'COUNT',
        'employees 테이블의 전체 직원 수를 조회하세요. 컬럼명은 total_count로 출력하세요.',
        'SELECT COUNT(*) AS total_count ...',
        'SELECT COUNT(*) AS total_count FROM employees',
        '<strong>COUNT(*)</strong> 는 NULL 포함 전체 행 수를 셉니다.<br><strong>COUNT(컬럼)</strong> 은 해당 컬럼이 NULL이 아닌 행만 셉니다.<br><code>AS</code> 별칭으로 컬럼명을 바꿀 수 있습니다.',
        2
    ),
    (
        2,
        'SUM / AVG / MAX / MIN',
        'easy',
        'SUM, AVG, MAX, MIN',
        'employees 테이블에서 전체 급여 합계(total_salary), 평균(avg_salary), 최고(max_salary), 최저(min_salary)를 조회하세요. 평균은 소수점 없이 정수로 반올림하세요.',
        'ROUND(AVG(salary), 0)',
        'SELECT SUM(salary) AS total_salary, ROUND(AVG(salary), 0) AS avg_salary, MAX(salary) AS max_salary, MIN(salary) AS min_salary FROM employees',
        '집계 함수는 여러 행을 하나의 값으로 요약합니다.<br><ul><li><strong>SUM</strong>: 합계</li><li><strong>AVG</strong>: 평균</li><li><strong>MAX / MIN</strong>: 최대 / 최솟값</li><li><strong>ROUND(값, 소수점자리)</strong>: 반올림</li></ul>',
        3
    ),
    (
        2,
        'GROUP BY - 그룹 집계',
        'medium',
        'GROUP BY',
        '부서(dept_id)별 직원 수(emp_count)와 평균 급여(avg_salary)를 조회하세요. 평균 급여는 정수로 반올림하고, 평균 급여 내림차순으로 정렬하세요.',
        'GROUP BY dept_id ORDER BY avg_salary DESC',
        'SELECT dept_id, COUNT(*) AS emp_count, ROUND(AVG(salary), 0) AS avg_salary FROM employees GROUP BY dept_id ORDER BY avg_salary DESC',
        '<strong>GROUP BY</strong> 는 지정한 컬럼의 값이 같은 행들을 하나의 그룹으로 묶고, 각 그룹에 집계 함수를 적용합니다.<br>SELECT 절에는 <em>GROUP BY에 명시한 컬럼</em> 또는 <em>집계 함수</em>만 올 수 있습니다.',
        4
    ),
    (
        2,
        'HAVING - 그룹 조건 필터',
        'medium',
        'HAVING',
        '부서별 평균 급여가 650만원 이상인 부서의 dept_id와 avg_salary(정수 반올림)를 조회하세요.',
        'HAVING AVG(salary) >= 6500000',
        'SELECT dept_id, ROUND(AVG(salary), 0) AS avg_salary FROM employees GROUP BY dept_id HAVING AVG(salary) >= 6500000',
        '<strong>HAVING</strong> 은 GROUP BY 이후에 그룹 단위로 조건을 거는 절입니다.<br><code>WHERE</code>는 행 단위 필터(집계 전), <code>HAVING</code>은 그룹 단위 필터(집계 후)로 역할이 다릅니다.<br>실행 순서: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY',
        5
    );

-- CH3: JOIN
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        3,
        'INNER JOIN - 기본',
        'medium',
        'INNER JOIN',
        '직원 이름(emp_name), 부서명(dept_name), 급여(salary)를 조회하세요. (직원-부서 JOIN)',
        'employees e JOIN departments d ON e.dept_id = d.dept_id',
        'SELECT e.emp_name, d.dept_name, e.salary FROM employees e JOIN departments d ON e.dept_id = d.dept_id',
        '<strong>INNER JOIN</strong> 은 두 테이블에서 ON 조건이 일치하는 행만 반환합니다.<br>실무에서 가장 많이 사용하는 JOIN으로, 두 테이블의 교집합이라고 생각하면 됩니다.',
        1
    ),
    (
        3,
        'LEFT JOIN - 포함 조회',
        'medium',
        'LEFT JOIN',
        '직원 이름(emp_name)과 주문 날짜(order_date)를 조회하되, 주문이 없는 직원도 포함하세요. order_date가 없는 경우 ''주문없음''으로 표시하세요. emp_name 오름차순 정렬.',
        'LEFT JOIN orders ON ... IFNULL(order_date, ...)',
        'SELECT e.emp_name, IFNULL(CAST(o.order_date AS CHAR), ''주문없음'') AS order_date FROM employees e LEFT JOIN orders o ON e.emp_id = o.emp_id ORDER BY e.emp_name',
        '<strong>LEFT JOIN</strong> 은 왼쪽 테이블의 모든 행을 포함하고, 오른쪽은 매칭되지 않으면 NULL을 채웁니다.<br><code>IFNULL(값, 대체값)</code>으로 NULL을 다른 값으로 치환할 수 있습니다.',
        2
    ),
    (
        3,
        '3개 테이블 JOIN',
        'medium',
        'Multi-table JOIN',
        '주문 ID(order_id), 직원 이름(emp_name), 부서명(dept_name), 주문 금액(total_amount)을 조회하세요. 완료 상태인 주문만 포함하고, 주문 금액 내림차순으로 정렬하세요.',
        'orders → employees → departments 순서로 JOIN',
        'SELECT o.order_id, e.emp_name, d.dept_name, o.total_amount FROM orders o JOIN employees e ON o.emp_id = e.emp_id JOIN departments d ON e.dept_id = d.dept_id WHERE o.status = ''완료'' ORDER BY o.total_amount DESC',
        '실무에서는 3개 이상의 테이블을 JOIN하는 경우가 많습니다. JOIN을 연속으로 작성하면 되며, 각 JOIN마다 ON 조건을 명시합니다.<br>⚠️ JOIN 순서와 인덱스 활용이 성능에 큰 영향을 미칩니다.',
        3
    );

-- CH4: 서브쿼리
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        4,
        '스칼라 서브쿼리',
        'medium',
        'Scalar Subquery',
        '각 직원의 emp_name, salary와 함께 전체 직원 평균 급여(avg_all, 정수 반올림)를 옆에 표시하세요.',
        'SELECT ..., (SELECT ROUND(AVG(salary),0) FROM employees) AS avg_all',
        'SELECT emp_name, salary, (SELECT ROUND(AVG(salary),0) FROM employees) AS avg_all FROM employees',
        '<strong>스칼라 서브쿼리</strong>는 SELECT 절 안에 위치하며 단 하나의 값을 반환합니다. 매 행마다 실행되므로 데이터가 많으면 성능 이슈가 생길 수 있어 JOIN이나 WITH으로 대체하는 것이 좋습니다.',
        1
    ),
    (
        4,
        'WHERE 서브쿼리',
        'medium',
        'Subquery in WHERE',
        '평균 급여보다 급여가 높은 직원의 emp_name, salary를 조회하세요. salary 내림차순 정렬.',
        'WHERE salary > (SELECT AVG(salary) FROM employees)',
        'SELECT emp_name, salary FROM employees WHERE salary > (SELECT AVG(salary) FROM employees) ORDER BY salary DESC',
        'WHERE 절에 서브쿼리를 사용하면 동적인 조건을 만들 수 있습니다. 비교 연산자 뒤에 단일 값을 반환하는 서브쿼리를 위치시킵니다.',
        2
    ),
    (
        4,
        'EXISTS - 존재 여부',
        'medium',
        'EXISTS',
        '주문을 한 번이라도 한 직원의 emp_name과 dept_id를 중복 없이 조회하세요.',
        'WHERE EXISTS (SELECT 1 FROM orders o WHERE o.emp_id = e.emp_id)',
        'SELECT DISTINCT e.emp_name, e.dept_id FROM employees e WHERE EXISTS (SELECT 1 FROM orders o WHERE o.emp_id = e.emp_id)',
        '<strong>EXISTS</strong>는 서브쿼리가 한 건이라도 결과를 반환하면 TRUE입니다. IN보다 <em>성능이 좋은 경우</em>가 많아 실무에서 선호됩니다. <code>SELECT 1</code>처럼 실제 값은 중요하지 않습니다.',
        3
    ),
    (
        4,
        'IN 서브쿼리',
        'medium',
        'IN Subquery',
        '개발팀(dept_name = ''개발팀'') 소속 직원들의 emp_name, salary를 조회하세요.',
        'WHERE dept_id IN (SELECT dept_id FROM departments WHERE dept_name = ...)',
        'SELECT emp_name, salary FROM employees WHERE dept_id IN (SELECT dept_id FROM departments WHERE dept_name = ''개발팀'')',
        '<strong>IN</strong>은 서브쿼리가 반환하는 목록 안에 값이 있는지 확인합니다. 반환 건수가 많으면 성능이 저하될 수 있어 EXISTS나 JOIN으로 대체를 고려합니다.',
        4
    );

-- CH5: WITH (CTE)
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        5,
        'WITH 기본',
        'medium',
        'WITH / CTE',
        'WITH를 사용해 부서별 평균 급여를 dept_avg라는 이름으로 정의한 뒤, 평균 급여가 700만원 이상인 부서의 dept_id와 avg_salary(정수)를 조회하세요.',
        'WITH dept_avg AS (SELECT dept_id, ROUND(AVG...) FROM employees GROUP BY dept_id) SELECT ... FROM dept_avg WHERE ...',
        'WITH dept_avg AS (SELECT dept_id, ROUND(AVG(salary),0) AS avg_salary FROM employees GROUP BY dept_id) SELECT dept_id, avg_salary FROM dept_avg WHERE avg_salary >= 7000000',
        '<strong>WITH (CTE, Common Table Expression)</strong>는 쿼리 안에서 임시 결과 집합을 이름 붙여 정의합니다.<br>장점: 복잡한 서브쿼리를 분리해 <em>가독성</em>과 <em>재사용성</em>을 높입니다. 실무에서 복잡한 분석 쿼리를 작성할 때 필수입니다.',
        1
    ),
    (
        5,
        'WITH 다중 CTE',
        'hard',
        'Multiple CTE',
        'WITH를 사용해:<br>① dept_info: 부서별 직원 수(emp_count)와 급여 합계(total_salary)<br>② 결과: dept_info와 departments를 JOIN해 dept_name, emp_count, total_salary를 조회하세요. total_salary 내림차순 정렬.',
        'WITH dept_info AS (...) SELECT d.dept_name, di.emp_count, di.total_salary FROM dept_info di JOIN departments d ON ...',
        'WITH dept_info AS (SELECT dept_id, COUNT(*) AS emp_count, SUM(salary) AS total_salary FROM employees GROUP BY dept_id) SELECT d.dept_name, di.emp_count, di.total_salary FROM dept_info di JOIN departments d ON di.dept_id = d.dept_id ORDER BY di.total_salary DESC',
        'WITH 절에 여러 CTE를 정의할 수 있습니다. 쉼표로 구분하여 <code>WITH cte1 AS (...), cte2 AS (...) SELECT ...</code> 형식으로 작성합니다. 뒤에 나오는 CTE는 앞의 CTE를 참조할 수도 있습니다.',
        2
    );

-- CH6: CASE WHEN
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        6,
        'CASE WHEN 기본',
        'medium',
        'CASE WHEN',
        'employees 테이블에서 emp_name, salary와 함께 급여 등급(salary_grade)을 표시하세요.<br>- 800만 이상: S등급<br>- 700만 이상: A등급<br>- 600만 이상: B등급<br>- 그 외: C등급',
        'CASE WHEN salary >= 8000000 THEN ... WHEN ... ELSE ... END AS salary_grade',
        'SELECT emp_name, salary, CASE WHEN salary >= 8000000 THEN ''S등급'' WHEN salary >= 7000000 THEN ''A등급'' WHEN salary >= 6000000 THEN ''B등급'' ELSE ''C등급'' END AS salary_grade FROM employees',
        '<strong>CASE WHEN</strong>은 조건에 따라 다른 값을 반환하는 조건 표현식입니다. 프로그래밍의 if-else와 동일합니다.<br>CASE는 위에서부터 순서대로 평가하므로 조건 순서가 중요합니다.',
        1
    ),
    (
        6,
        'CASE WHEN + GROUP BY',
        'hard',
        'CASE WHEN + 집계',
        'orders 테이블에서 상태(status)별 주문 건수를 피벗 형식으로 조회하세요.<br>컬럼: 완료건수(done_count), 취소건수(cancel_count), 진행중건수(inprogress_count)',
        'SUM(CASE WHEN status = ... THEN 1 ELSE 0 END)',
        'SELECT SUM(CASE WHEN status = ''완료'' THEN 1 ELSE 0 END) AS done_count, SUM(CASE WHEN status = ''취소'' THEN 1 ELSE 0 END) AS cancel_count, SUM(CASE WHEN status = ''진행중'' THEN 1 ELSE 0 END) AS inprogress_count FROM orders',
        '<strong>CASE WHEN + 집계 함수</strong> 패턴은 행을 열로 변환(Pivot)할 때 사용합니다. 실무에서 대시보드 쿼리나 리포트 쿼리에서 매우 자주 사용됩니다.',
        2
    );

-- CH7: 윈도우 함수
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        7,
        'ROW_NUMBER',
        'hard',
        'ROW_NUMBER()',
        '부서(dept_id)별로 급여 순위(rn)를 매기되, 같은 부서 안에서 급여 내림차순으로 순위를 부여하세요. emp_name, dept_id, salary, rn을 조회하고, dept_id 오름차순 → rn 오름차순으로 정렬하세요.',
        'ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC)',
        'SELECT emp_name, dept_id, salary, ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn FROM employees ORDER BY dept_id, rn',
        '<strong>ROW_NUMBER()</strong>는 각 행에 고유한 번호를 부여합니다.<br><code>PARTITION BY</code>는 GROUP BY처럼 그룹을 나누고, <code>ORDER BY</code>는 그룹 내 정렬 기준입니다. 행을 제거하지 않는다는 점이 GROUP BY와 다릅니다.',
        1
    ),
    (
        7,
        'RANK vs DENSE_RANK',
        'hard',
        'RANK, DENSE_RANK',
        '전체 직원 중 급여 기준으로 RANK(rk)와 DENSE_RANK(dense_rk)를 함께 조회하세요. emp_name, salary, rk, dense_rk를 salary 내림차순으로 정렬하세요.',
        'RANK() OVER (ORDER BY salary DESC), DENSE_RANK() OVER (ORDER BY salary DESC)',
        'SELECT emp_name, salary, RANK() OVER (ORDER BY salary DESC) AS rk, DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rk FROM employees ORDER BY salary DESC',
        '<ul><li><strong>RANK()</strong>: 동점이면 같은 순위, 다음 순위는 건너뜀 (1,1,3,...)</li><li><strong>DENSE_RANK()</strong>: 동점이면 같은 순위, 다음 순위는 연속 (1,1,2,...)</li></ul>실무에서 TOP N 순위를 구할 때 둘을 구분해서 사용합니다.',
        2
    ),
    (
        7,
        'SUM OVER - 누적 합계',
        'hard',
        'SUM() OVER',
        'hire_date 오름차순으로 직원을 정렬했을 때, emp_name, hire_date, salary와 함께 salary의 누적 합계(cumulative_salary)를 조회하세요.',
        'SUM(salary) OVER (ORDER BY hire_date)',
        'SELECT emp_name, hire_date, salary, SUM(salary) OVER (ORDER BY hire_date) AS cumulative_salary FROM employees ORDER BY hire_date',
        '<strong>SUM() OVER (ORDER BY ...)</strong>는 현재 행까지의 누적 합계를 구합니다. 기본적으로 <code>ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW</code>가 적용됩니다. 매출 누적, 재고 누적 계산에 활용됩니다.',
        3
    );

-- CH8: 문자열 & 날짜 함수
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        8,
        'SUBSTR - 문자열 자르기',
        'medium',
        'SUBSTR',
        'employees 테이블에서 hire_date의 연도(year_hired)만 추출하여 emp_name, hire_date, year_hired를 조회하세요. SUBSTR 함수를 사용하세요.',
        'SUBSTR(hire_date, 1, 4)',
        'SELECT emp_name, hire_date, SUBSTR(hire_date, 1, 4) AS year_hired FROM employees',
        '<strong>SUBSTR(문자열, 시작위치, 길이)</strong>는 문자열의 일부를 추출합니다. MySQL에서는 <code>SUBSTRING()</code>과 동일합니다.<br>날짜는 ''YYYY-MM-DD'' 형식이므로 SUBSTR로 연/월/일을 자유롭게 추출할 수 있습니다.',
        1
    ),
    (
        8,
        'DATE 함수 - 날짜 계산',
        'medium',
        'DATEDIFF, DATE_FORMAT',
        '직원별 근속 일수(working_days)를 계산하세요. emp_name, hire_date, working_days를 조회하고, working_days 내림차순으로 정렬하세요. 기준일은 2024-06-30로 합니다.',
        'DATEDIFF(''2024-06-30'', hire_date)',
        'SELECT emp_name, hire_date, DATEDIFF(''2024-06-30'', hire_date) AS working_days FROM employees ORDER BY working_days DESC',
        '<strong>DATEDIFF(날짜1, 날짜2)</strong>는 날짜1 - 날짜2의 일수 차이를 반환합니다.<br>그 외 유용한 날짜 함수: <code>DATE_FORMAT(date, ''%Y-%m'')</code>, <code>MONTH(date)</code>, <code>YEAR(date)</code>, <code>DATE_ADD(date, INTERVAL n DAY)</code>',
        2
    ),
    (
        8,
        'GROUP_CONCAT - 목록 합치기',
        'hard',
        'GROUP_CONCAT',
        '부서(dept_id)별 직원 이름을 쉼표로 연결한 목록(emp_list)을 조회하세요. 이름은 emp_name 오름차순으로 연결하세요.',
        'GROUP_CONCAT(emp_name ORDER BY emp_name SEPARATOR '', '')',
        'SELECT dept_id, GROUP_CONCAT(emp_name ORDER BY emp_name SEPARATOR '', '') AS emp_list FROM employees GROUP BY dept_id',
        '<strong>GROUP_CONCAT()</strong>은 MySQL에서 그룹 내 여러 값을 하나의 문자열로 합칩니다. Oracle의 LISTAGG()와 동일한 역할입니다.<br><code>SEPARATOR</code>로 구분자를 지정하고, <code>ORDER BY</code>로 순서를 제어합니다.',
        3
    );

-- CH9: 종합 실전 문제
INSERT INTO
    problems (
        chapter_id,
        title,
        difficulty,
        concept,
        description,
        hint,
        answer_sql,
        concept_explain,
        sort_order
    )
VALUES (
        9,
        '부서별 주문 통계',
        'hard',
        '종합 JOIN + GROUP BY',
        '부서명(dept_name)별 완료 주문 건수(order_count)와 총 주문 금액(total_amount)을 조회하세요. 주문이 없는 부서는 제외합니다. total_amount 내림차순 정렬.',
        'orders → employees → departments JOIN, status = 완료 WHERE',
        'SELECT d.dept_name, COUNT(o.order_id) AS order_count, SUM(o.total_amount) AS total_amount FROM orders o JOIN employees e ON o.emp_id = e.emp_id JOIN departments d ON e.dept_id = d.dept_id WHERE o.status = ''완료'' GROUP BY d.dept_name ORDER BY total_amount DESC',
        '실무 쿼리의 전형적인 패턴입니다: 여러 테이블을 JOIN한 뒤 GROUP BY로 집계하고 ORDER BY로 정렬합니다. WHERE로 불필요한 데이터를 먼저 줄이면 성능이 좋아집니다.',
        1
    ),
    (
        9,
        '가장 많이 팔린 상품 TOP 3',
        'hard',
        'JOIN + 집계 + LIMIT',
        '상품명(product_name), 총 판매 수량(total_qty)을 조회하고, 판매 수량 기준 상위 3개 상품을 출력하세요. (취소 주문 제외)',
        'order_items → orders → products JOIN, 취소 제외, SUM(quantity), LIMIT 3',
        'SELECT p.product_name, SUM(oi.quantity) AS total_qty FROM order_items oi JOIN orders o ON oi.order_id = o.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.status != ''취소'' GROUP BY p.product_id, p.product_name ORDER BY total_qty DESC LIMIT 3',
        '취소 주문 제외 시 <code>WHERE status != ''취소''</code> 또는 <code>WHERE status IN (''완료'', ''진행중'')</code>처럼 명시적으로 포함할 상태를 지정하는 방법 중 상황에 맞게 선택합니다.',
        2
    ),
    (
        9,
        '부서별 급여 1등 직원',
        'hard',
        'ROW_NUMBER + WITH + 필터',
        '부서별로 급여가 가장 높은 직원 1명씩 조회하세요. 결과: dept_name, emp_name, salary. dept_name 오름차순 정렬.',
        'WITH ranked AS (ROW_NUMBER() OVER PARTITION BY dept_id) WHERE rn = 1',
        'WITH ranked AS (SELECT e.emp_name, e.dept_id, e.salary, ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rn FROM employees e) SELECT d.dept_name, r.emp_name, r.salary FROM ranked r JOIN departments d ON r.dept_id = d.dept_id WHERE r.rn = 1 ORDER BY d.dept_name',
        '<strong>ROW_NUMBER() + WITH + WHERE rn = 1</strong> 패턴은 그룹별 TOP 1을 구하는 가장 실무적인 방법입니다. 이 패턴만 잘 이해해도 많은 실무 문제를 해결할 수 있습니다.',
        3
    );