-- ============================================================
-- 문제 description / concept_explain 개선
-- ============================================================
SET NAMES utf8mb4;

-- ── CH1 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> 모든 컬럼(*)<br><br>employees 테이블의 모든 컬럼과 모든 행을 조회하세요.',
  concept_explain = '<strong>SELECT *</strong> 는 테이블의 모든 컬럼을 조회하는 가장 기본적인 구문입니다.<br>실무에서는 필요한 컬럼만 명시하는 것이 성능에 좋지만, 데이터 탐색 시엔 * 로 전체를 보는 것이 편합니다.<br><br><strong>예시</strong><div class="inline-code">SELECT * FROM employees;</div>'
WHERE problem_id = 1;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, job_title, salary<br><br>employees 테이블에서 emp_name, job_title, salary 컬럼만 조회하세요.',
  concept_explain = '컬럼을 명시적으로 지정하면 <strong>네트워크 트래픽 절감</strong>과 <strong>가독성 향상</strong>에 도움됩니다.<br>실무에서는 항상 필요한 컬럼만 SELECT 하는 것이 좋은 습관입니다.<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, job_title, salary<br>FROM employees;</div>'
WHERE problem_id = 2;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, job_title, salary<br><br>employees 테이블에서 <strong>salary가 700만원(7000000) 이상</strong>인 직원의 emp_name, job_title, salary를 조회하세요.',
  concept_explain = '<strong>WHERE</strong> 절은 행을 필터링합니다. 비교 연산자(=, !=, &gt;, &gt;=, &lt;, &lt;=)와 논리 연산자(AND, OR, NOT)를 조합해 복잡한 조건도 표현할 수 있습니다.<br><br><strong>예시</strong><div class="inline-code">-- 단순 조건<br>SELECT emp_name FROM employees WHERE salary &gt;= 7000000;<br><br>-- 복합 조건<br>SELECT emp_name FROM employees WHERE dept_id = 1 AND salary &gt;= 6000000;</div>'
WHERE problem_id = 3;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, salary<br><br>employees 테이블에서 emp_name, salary를 <strong>salary 내림차순(높은 순)</strong>으로 정렬하여 조회하세요.',
  concept_explain = '<strong>ORDER BY</strong> 는 결과를 정렬합니다. <code>ASC</code>(오름차순, 기본값) / <code>DESC</code>(내림차순)를 지정할 수 있습니다.<br><br><strong>예시</strong><div class="inline-code">-- 단일 컬럼 정렬<br>SELECT emp_name, salary FROM employees ORDER BY salary DESC;<br><br>-- 다중 컬럼 정렬<br>SELECT emp_name, dept_id, salary FROM employees ORDER BY dept_id ASC, salary DESC;</div>'
WHERE problem_id = 4;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, salary<br><br>employees 테이블에서 <strong>salary 내림차순 기준 상위 5명</strong>의 emp_name, salary를 조회하세요.',
  concept_explain = '<strong>LIMIT n</strong> 은 결과를 n개로 제한합니다. <code>LIMIT 5 OFFSET 10</code> 처럼 OFFSET을 함께 쓰면 페이지네이션을 구현할 수 있습니다.<br><br><strong>예시</strong><div class="inline-code">-- 상위 5개<br>SELECT emp_name, salary FROM employees ORDER BY salary DESC LIMIT 5;<br><br>-- 6~10번째 (OFFSET 활용)<br>SELECT emp_name, salary FROM employees ORDER BY salary DESC LIMIT 5 OFFSET 5;</div>'
WHERE problem_id = 5;

-- ── CH2 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> job_title<br><br>employees 테이블에서 <strong>중복을 제거한</strong> job_title 목록을 조회하세요.',
  concept_explain = '<strong>DISTINCT</strong> 는 중복 행을 제거합니다. 실무에서는 카테고리 목록, 코드 목록 조회 시 자주 사용됩니다.<br>⚠️ 컬럼이 여러 개이면 <em>모든 컬럼의 조합</em>이 중복인 경우만 제거됩니다.<br><br><strong>예시</strong><div class="inline-code">SELECT DISTINCT job_title FROM employees;<br><br>-- 두 컬럼 조합 중복 제거<br>SELECT DISTINCT dept_id, job_title FROM employees;</div>'
WHERE problem_id = 6;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> total_count<br><br>employees 테이블의 <strong>전체 직원 수</strong>를 조회하세요. 컬럼명은 <code>total_count</code>로 출력하세요.',
  concept_explain = '<strong>COUNT(*)</strong> 는 NULL 포함 전체 행 수를 셉니다.<br><strong>COUNT(컬럼)</strong> 은 해당 컬럼이 NULL이 아닌 행만 셉니다.<br><br><strong>예시</strong><div class="inline-code">-- 전체 직원 수<br>SELECT COUNT(*) AS total_count FROM employees;<br><br>-- 팀장이 있는 직원 수 (manager_id가 NULL이 아닌 행)<br>SELECT COUNT(manager_id) AS has_manager FROM employees;</div>'
WHERE problem_id = 7;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> total_salary, avg_salary, max_salary, min_salary<br><br>employees 테이블에서 salary의 <strong>합계(total_salary), 평균(avg_salary), 최고(max_salary), 최저(min_salary)</strong>를 조회하세요.<br>평균은 <code>ROUND</code>로 소수점 없이 정수로 반올림하세요.',
  concept_explain = '집계 함수는 여러 행을 하나의 값으로 요약합니다.<br><ul><li><strong>SUM</strong>: 합계</li><li><strong>AVG</strong>: 평균</li><li><strong>MAX / MIN</strong>: 최대 / 최솟값</li><li><strong>ROUND(값, 자릿수)</strong>: 반올림</li></ul><strong>예시</strong><div class="inline-code">SELECT SUM(salary)           AS total_salary,<br>       ROUND(AVG(salary), 0) AS avg_salary,<br>       MAX(salary)           AS max_salary,<br>       MIN(salary)           AS min_salary<br>FROM employees;</div>'
WHERE problem_id = 8;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> dept_id, emp_count, avg_salary<br><br>employees 테이블에서 <strong>dept_id별</strong> 직원 수(emp_count)와 평균 급여(avg_salary)를 조회하세요.<br>평균 급여는 정수로 반올림하고, <strong>avg_salary 내림차순</strong>으로 정렬하세요.',
  concept_explain = '<strong>GROUP BY</strong> 는 지정한 컬럼의 값이 같은 행들을 하나의 그룹으로 묶고, 각 그룹에 집계 함수를 적용합니다.<br>SELECT 절에는 GROUP BY에 명시한 컬럼 또는 집계 함수만 올 수 있습니다.<br><br><strong>예시</strong><div class="inline-code">SELECT dept_id,<br>       COUNT(*)                   AS emp_count,<br>       ROUND(AVG(salary), 0)      AS avg_salary<br>FROM employees<br>GROUP BY dept_id<br>ORDER BY avg_salary DESC;</div>'
WHERE problem_id = 9;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> dept_id, avg_salary<br><br>employees 테이블에서 <strong>dept_id별 평균 급여가 650만원(6500000) 이상</strong>인 부서의 dept_id와 avg_salary(정수 반올림)를 조회하세요.',
  concept_explain = '<strong>HAVING</strong> 은 GROUP BY 이후에 그룹 단위로 조건을 거는 절입니다.<br><code>WHERE</code>는 행 단위 필터(집계 전), <code>HAVING</code>은 그룹 단위 필터(집계 후)로 역할이 다릅니다.<br>실행 순서: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY<br><br><strong>예시</strong><div class="inline-code">SELECT dept_id, ROUND(AVG(salary), 0) AS avg_salary<br>FROM employees<br>GROUP BY dept_id<br>HAVING AVG(salary) &gt;= 6500000;</div>'
WHERE problem_id = 10;

-- ── CH3 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees, departments<br>📤 <strong>반환 컬럼:</strong> emp_name, dept_name, salary<br><br>employees와 departments를 <code>dept_id</code>로 JOIN하여 <strong>직원 이름(emp_name), 부서명(dept_name), 급여(salary)</strong>를 조회하세요.',
  concept_explain = '<strong>INNER JOIN</strong> 은 두 테이블에서 ON 조건이 일치하는 행만 반환합니다.<br>실무에서 가장 많이 사용하는 JOIN으로, 두 테이블의 교집합이라고 생각하면 됩니다.<br><br><strong>예시</strong><div class="inline-code">SELECT e.emp_name, d.dept_name, e.salary<br>FROM employees e<br>JOIN departments d ON e.dept_id = d.dept_id;</div>'
WHERE problem_id = 11;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees, orders<br>📤 <strong>반환 컬럼:</strong> emp_name, order_date<br><br>employees와 orders를 <code>emp_id</code>로 LEFT JOIN하여 직원 이름(emp_name)과 주문 날짜(order_date)를 조회하세요.<br>✅ <strong>주문이 없는 직원도 포함</strong>하고, order_date가 없는 경우 <code>주문없음</code>으로 표시하세요.<br>emp_name <strong>오름차순</strong> 정렬.',
  concept_explain = '<strong>LEFT JOIN</strong> 은 왼쪽 테이블의 모든 행을 포함하고, 오른쪽은 매칭되지 않으면 NULL을 채웁니다.<br><code>IFNULL(값, 대체값)</code>으로 NULL을 다른 값으로 치환할 수 있습니다.<br><br><strong>예시</strong><div class="inline-code">SELECT e.emp_name,<br>       IFNULL(CAST(o.order_date AS CHAR), ''주문없음'') AS order_date<br>FROM employees e<br>LEFT JOIN orders o ON e.emp_id = o.emp_id<br>ORDER BY e.emp_name;</div>'
WHERE problem_id = 12;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> orders, employees, departments<br>📤 <strong>반환 컬럼:</strong> order_id, emp_name, dept_name, total_amount<br><br>orders → employees → departments 순으로 JOIN하여 주문 ID(order_id), 직원 이름(emp_name), 부서명(dept_name), 주문 금액(total_amount)을 조회하세요.<br>✅ <strong>status가 ''완료''인 주문만</strong> 포함하고, <strong>total_amount 내림차순</strong> 정렬.',
  concept_explain = '실무에서는 3개 이상의 테이블을 JOIN하는 경우가 많습니다. JOIN을 연속으로 작성하면 되며, 각 JOIN마다 ON 조건을 명시합니다.<br><br><strong>예시</strong><div class="inline-code">SELECT o.order_id, e.emp_name, d.dept_name, o.total_amount<br>FROM orders o<br>JOIN employees   e ON o.emp_id  = e.emp_id<br>JOIN departments d ON e.dept_id = d.dept_id<br>WHERE o.status = ''완료''<br>ORDER BY o.total_amount DESC;</div>'
WHERE problem_id = 13;

-- ── CH4 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, salary, avg_all<br><br>employees 테이블에서 각 직원의 emp_name, salary와 함께<br><strong>전체 직원 평균 급여(avg_all)</strong>를 옆에 표시하세요. avg_all은 정수로 반올림하세요.',
  concept_explain = '<strong>스칼라 서브쿼리</strong>는 SELECT 절 안에 위치하며 단 하나의 값을 반환합니다. 매 행마다 실행되므로 데이터가 많으면 성능 이슈가 생길 수 있어 JOIN이나 WITH으로 대체하는 것이 좋습니다.<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, salary,<br>       (SELECT ROUND(AVG(salary), 0) FROM employees) AS avg_all<br>FROM employees;</div>'
WHERE problem_id = 14;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, salary<br><br>employees 테이블에서 <strong>전체 평균 급여보다 높은</strong> 직원의 emp_name, salary를 조회하세요.<br>salary <strong>내림차순</strong> 정렬.',
  concept_explain = 'WHERE 절에 서브쿼리를 사용하면 동적인 조건을 만들 수 있습니다. 비교 연산자 뒤에 단일 값을 반환하는 서브쿼리를 위치시킵니다.<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, salary<br>FROM employees<br>WHERE salary &gt; (SELECT AVG(salary) FROM employees)<br>ORDER BY salary DESC;</div>'
WHERE problem_id = 15;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees, orders<br>📤 <strong>반환 컬럼:</strong> emp_name, dept_id (중복 제거)<br><br>employees 테이블에서 <strong>주문을 한 번이라도 한 직원</strong>의 emp_name과 dept_id를 <strong>중복 없이</strong> 조회하세요.',
  concept_explain = '<strong>EXISTS</strong>는 서브쿼리가 한 건이라도 결과를 반환하면 TRUE입니다. IN보다 성능이 좋은 경우가 많아 실무에서 선호됩니다.<br><br><strong>예시</strong><div class="inline-code">-- EXISTS: 주문이 있는 직원<br>SELECT DISTINCT e.emp_name, e.dept_id<br>FROM employees e<br>WHERE EXISTS (<br>    SELECT 1 FROM orders o WHERE o.emp_id = e.emp_id<br>);</div>'
WHERE problem_id = 16;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees, departments<br>📤 <strong>반환 컬럼:</strong> emp_name, salary<br><br>employees 테이블에서 <strong>dept_name이 ''개발팀''인 부서</strong>에 소속된 직원의 emp_name, salary를 조회하세요.<br>IN + 서브쿼리를 사용하세요.',
  concept_explain = '<strong>IN</strong>은 서브쿼리가 반환하는 목록 안에 값이 있는지 확인합니다. 반환 건수가 많으면 성능이 저하될 수 있어 EXISTS나 JOIN으로 대체를 고려합니다.<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, salary<br>FROM employees<br>WHERE dept_id IN (<br>    SELECT dept_id FROM departments WHERE dept_name = ''개발팀''<br>);</div>'
WHERE problem_id = 17;

-- ── CH5 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> dept_id, avg_salary<br><br>WITH를 사용해 employees에서 <strong>부서별 평균 급여를 dept_avg</strong>라는 CTE로 정의한 뒤,<br>그 결과에서 <strong>avg_salary가 700만원(7000000) 이상</strong>인 부서의 dept_id와 avg_salary(정수 반올림)를 조회하세요.',
  concept_explain = '<strong>WITH (CTE)</strong>는 쿼리 안에서 임시 결과 집합을 이름 붙여 정의합니다.<br>복잡한 서브쿼리를 분리해 가독성과 재사용성을 높입니다.<br><br><strong>예시</strong><div class="inline-code">WITH dept_avg AS (<br>    SELECT dept_id, ROUND(AVG(salary), 0) AS avg_salary<br>    FROM employees<br>    GROUP BY dept_id<br>)<br>SELECT dept_id, avg_salary<br>FROM dept_avg<br>WHERE avg_salary &gt;= 7000000;</div>'
WHERE problem_id = 18;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees, departments<br>📤 <strong>반환 컬럼:</strong> dept_name, emp_count, total_salary<br><br>WITH를 사용해 두 개의 CTE를 정의하세요:<br>① <strong>dept_info</strong>: employees를 dept_id별로 그룹핑하여 직원 수(emp_count)와 급여 합계(total_salary) 계산<br>② dept_info와 departments를 JOIN하여 <strong>dept_name, emp_count, total_salary</strong>를 조회하세요.<br>total_salary <strong>내림차순</strong> 정렬.',
  concept_explain = 'WITH 절에 여러 CTE를 정의할 수 있습니다. 쉼표로 구분하여 작성하며, 뒤 CTE는 앞 CTE를 참조할 수 있습니다.<br><br><strong>예시</strong><div class="inline-code">WITH<br>dept_info AS (<br>    SELECT dept_id, COUNT(*) AS emp_count, SUM(salary) AS total_salary<br>    FROM employees<br>    GROUP BY dept_id<br>)<br>SELECT d.dept_name, di.emp_count, di.total_salary<br>FROM dept_info di<br>JOIN departments d ON di.dept_id = d.dept_id<br>ORDER BY di.total_salary DESC;</div>'
WHERE problem_id = 19;

-- ── CH6 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, salary, salary_grade<br><br>employees 테이블에서 emp_name, salary와 함께 아래 기준으로 <strong>급여 등급(salary_grade)</strong>을 표시하세요.<br>- salary &gt;= 8,000,000 → S등급<br>- salary &gt;= 7,000,000 → A등급<br>- salary &gt;= 6,000,000 → B등급<br>- 그 외 → C등급',
  concept_explain = '<strong>CASE WHEN</strong>은 조건에 따라 다른 값을 반환하는 조건 표현식입니다. 프로그래밍의 if-else와 동일합니다.<br>CASE는 위에서부터 순서대로 평가하므로 조건 순서가 중요합니다.<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, salary,<br>    CASE<br>        WHEN salary &gt;= 8000000 THEN ''S등급''<br>        WHEN salary &gt;= 7000000 THEN ''A등급''<br>        WHEN salary &gt;= 6000000 THEN ''B등급''<br>        ELSE ''C등급''<br>    END AS salary_grade<br>FROM employees;</div>'
WHERE problem_id = 20;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> orders<br>📤 <strong>반환 컬럼:</strong> done_count, cancel_count, inprogress_count<br><br>orders 테이블에서 <strong>주문 상태(status)별 건수를 피벗(가로) 형식</strong>으로 조회하세요.<br>- 완료 건수: done_count<br>- 취소 건수: cancel_count<br>- 진행중 건수: inprogress_count',
  concept_explain = '<strong>CASE WHEN + SUM</strong> 패턴은 행을 열로 변환(Pivot)할 때 사용합니다. 실무 대시보드 쿼리에서 매우 자주 사용됩니다.<br><br><strong>예시</strong><div class="inline-code">SELECT<br>    SUM(CASE WHEN status = ''완료''   THEN 1 ELSE 0 END) AS done_count,<br>    SUM(CASE WHEN status = ''취소''   THEN 1 ELSE 0 END) AS cancel_count,<br>    SUM(CASE WHEN status = ''진행중'' THEN 1 ELSE 0 END) AS inprogress_count<br>FROM orders;</div>'
WHERE problem_id = 21;

-- ── CH7 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, dept_id, salary, rn<br><br>employees 테이블에서 <strong>dept_id별로 salary 내림차순 기준 순위(rn)</strong>를 부여하세요.<br>dept_id <strong>오름차순 → rn 오름차순</strong> 정렬.',
  concept_explain = '<strong>ROW_NUMBER()</strong>는 각 행에 고유한 번호를 부여합니다.<br><code>PARTITION BY</code>: GROUP BY처럼 그룹을 나눔<br><code>ORDER BY</code>: 그룹 내 정렬 기준<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, dept_id, salary,<br>    ROW_NUMBER() OVER (<br>        PARTITION BY dept_id<br>        ORDER BY salary DESC<br>    ) AS rn<br>FROM employees<br>ORDER BY dept_id, rn;</div>'
WHERE problem_id = 22;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, salary, rk, dense_rk<br><br>employees 테이블에서 전체 직원의 salary 기준으로 <strong>RANK(rk)와 DENSE_RANK(dense_rk)</strong>를 함께 조회하세요.<br>salary <strong>내림차순</strong> 정렬.',
  concept_explain = '<ul><li><strong>RANK()</strong>: 동점이면 같은 순위, 다음 순위는 건너뜀 (1,1,3,...)</li><li><strong>DENSE_RANK()</strong>: 동점이면 같은 순위, 다음 순위는 연속 (1,1,2,...)</li></ul><strong>예시</strong><div class="inline-code">SELECT emp_name, salary,<br>    RANK()       OVER (ORDER BY salary DESC) AS rk,<br>    DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rk<br>FROM employees<br>ORDER BY salary DESC;</div>'
WHERE problem_id = 23;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, hire_date, salary, cumulative_salary<br><br>employees 테이블에서 <strong>hire_date 오름차순</strong>으로 정렬하면서,<br>emp_name, hire_date, salary와 함께 <strong>salary의 누적 합계(cumulative_salary)</strong>를 조회하세요.',
  concept_explain = '<strong>SUM() OVER (ORDER BY ...)</strong>는 현재 행까지의 누적 합계를 구합니다.<br>ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW가 기본으로 적용됩니다.<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, hire_date, salary,<br>    SUM(salary) OVER (ORDER BY hire_date) AS cumulative_salary<br>FROM employees<br>ORDER BY hire_date;</div>'
WHERE problem_id = 24;

-- ── CH8 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, hire_date, year_hired<br><br>employees 테이블에서 emp_name, hire_date와 함께<br><strong>hire_date에서 연도만 추출한 year_hired</strong>를 조회하세요. <code>SUBSTR</code> 함수를 사용하세요.',
  concept_explain = '<strong>SUBSTR(문자열, 시작위치, 길이)</strong>는 문자열의 일부를 추출합니다. MySQL에서는 SUBSTRING()과 동일합니다.<br>날짜는 ''YYYY-MM-DD'' 형식이므로 SUBSTR로 연/월/일을 자유롭게 추출할 수 있습니다.<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, hire_date,<br>       SUBSTR(hire_date, 1, 4) AS year_hired  -- ''2021-02-10'' → ''2021''<br>FROM employees;</div>'
WHERE problem_id = 25;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> emp_name, hire_date, working_days<br><br>employees 테이블에서 emp_name, hire_date와 함께<br><strong>2024-06-30 기준 근속 일수(working_days)</strong>를 계산하여 조회하세요.<br>working_days <strong>내림차순</strong> 정렬.',
  concept_explain = '<strong>DATEDIFF(날짜1, 날짜2)</strong>는 날짜1 - 날짜2의 일수 차이를 반환합니다.<br><br><strong>예시</strong><div class="inline-code">SELECT emp_name, hire_date,<br>       DATEDIFF(''2024-06-30'', hire_date) AS working_days<br>FROM employees<br>ORDER BY working_days DESC;<br><br>-- 다른 날짜 함수들<br>SELECT DATE_FORMAT(hire_date, ''%Y-%m'') AS ym FROM employees;</div>'
WHERE problem_id = 26;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees<br>📤 <strong>반환 컬럼:</strong> dept_id, emp_list<br><br>employees 테이블에서 <strong>dept_id별 직원 이름을 쉼표로 연결한 목록(emp_list)</strong>을 조회하세요.<br>이름은 <strong>emp_name 오름차순</strong>으로 연결하세요.',
  concept_explain = '<strong>GROUP_CONCAT()</strong>은 그룹 내 여러 값을 하나의 문자열로 합칩니다. Oracle의 LISTAGG()와 동일합니다.<br><br><strong>예시</strong><div class="inline-code">SELECT dept_id,<br>       GROUP_CONCAT(emp_name ORDER BY emp_name SEPARATOR '', '') AS emp_list<br>FROM employees<br>GROUP BY dept_id;</div>'
WHERE problem_id = 27;

-- ── CH9 문제들 ──
UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> orders, employees, departments<br>📤 <strong>반환 컬럼:</strong> dept_name, order_count, total_amount<br><br>orders → employees → departments를 JOIN하여<br><strong>부서명(dept_name)별 완료(''완료'') 주문 건수(order_count)와 총 금액(total_amount)</strong>를 조회하세요.<br>주문이 없는 부서는 제외하고, total_amount <strong>내림차순</strong> 정렬.',
  concept_explain = '실무 쿼리의 전형적인 패턴: 여러 테이블 JOIN → GROUP BY 집계 → ORDER BY 정렬.<br>WHERE로 불필요한 데이터를 먼저 줄이면 성능이 좋아집니다.<br><br><strong>예시</strong><div class="inline-code">SELECT d.dept_name, COUNT(o.order_id) AS order_count, SUM(o.total_amount) AS total_amount<br>FROM orders o<br>JOIN employees   e ON o.emp_id  = e.emp_id<br>JOIN departments d ON e.dept_id = d.dept_id<br>WHERE o.status = ''완료''<br>GROUP BY d.dept_name<br>ORDER BY total_amount DESC;</div>'
WHERE problem_id = 28;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> order_items, orders, products<br>📤 <strong>반환 컬럼:</strong> product_name, total_qty<br><br>order_items → orders → products를 JOIN하여<br><strong>상품명(product_name)과 총 판매 수량(total_qty)</strong>을 조회하고,<br>판매 수량 기준 <strong>상위 3개</strong> 상품을 출력하세요. ✅ 취소(''취소'') 주문은 제외하세요.',
  concept_explain = '취소 주문 제외는 WHERE 조건으로 처리합니다. != 보다 NOT IN 또는 IN으로 포함할 상태를 명시하는 것이 더 명확합니다.<br><br><strong>예시</strong><div class="inline-code">SELECT p.product_name, SUM(oi.quantity) AS total_qty<br>FROM order_items oi<br>JOIN orders   o ON oi.order_id  = o.order_id<br>JOIN products p ON oi.product_id = p.product_id<br>WHERE o.status != ''취소''<br>GROUP BY p.product_id, p.product_name<br>ORDER BY total_qty DESC<br>LIMIT 3;</div>'
WHERE problem_id = 29;

UPDATE problems SET
  description    = '📋 <strong>테이블:</strong> employees, departments<br>📤 <strong>반환 컬럼:</strong> dept_name, emp_name, salary<br><br>WITH와 ROW_NUMBER를 활용하여 <strong>부서별로 salary가 가장 높은 직원 1명씩</strong> 조회하세요.<br>결과는 dept_name <strong>오름차순</strong> 정렬.',
  concept_explain = '<strong>ROW_NUMBER() + WITH + WHERE rn = 1</strong> 패턴은 그룹별 TOP 1을 구하는 가장 실무적인 방법입니다.<br><br><strong>예시</strong><div class="inline-code">WITH ranked AS (<br>    SELECT emp_name, dept_id, salary,<br>           ROW_NUMBER() OVER (<br>               PARTITION BY dept_id ORDER BY salary DESC<br>           ) AS rn<br>    FROM employees<br>)<br>SELECT d.dept_name, r.emp_name, r.salary<br>FROM ranked r<br>JOIN departments d ON r.dept_id = d.dept_id<br>WHERE r.rn = 1<br>ORDER BY d.dept_name;</div>'
WHERE problem_id = 30;
