const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '3306'),
  user: process.env.DB_USER || 'playground',
  password: process.env.DB_PASSWORD || 'playground1234',
  database: process.env.DB_NAME || 'sql_playground',
  charset: 'utf8mb4',
  waitForConnections: true,
  connectionLimit: 10,
};

let pool;

async function initPool() {
  let retries = 10;
  while (retries > 0) {
    try {
      pool = mysql.createPool(dbConfig);
      const conn = await pool.getConnection();
      conn.release();
      console.log('✅ DB connected');
      return;
    } catch (e) {
      console.log(`DB not ready, retrying... (${retries} left)`);
      retries--;
      await new Promise(r => setTimeout(r, 3000));
    }
  }
  throw new Error('DB connection failed');
}

// ───────────────────────────── SQL 실행 API ─────────────────────────────
app.post('/api/run', async (req, res) => {
  const { sql: userSql } = req.body;
  if (!userSql || !userSql.trim()) {
    return res.status(400).json({ error: 'SQL을 입력해주세요.' });
  }

  const normalized = userSql.trim().toUpperCase();
  if (!normalized.startsWith('SELECT') && !normalized.startsWith('WITH')) {
    return res.status(400).json({ error: 'SELECT 또는 WITH 구문만 실행할 수 있습니다.' });
  }

  try {
    const [rows, fields] = await pool.execute(userSql);
    const columns = fields ? fields.map(f => f.name) : [];
    res.json({ columns, rows, rowCount: rows.length });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// ───────────────────────────── 정답 채점 API ─────────────────────────────
app.post('/api/grade', async (req, res) => {
  const { userSql, answerSql } = req.body;

  const normalize = s => s.trim().toUpperCase();
  if (!normalize(userSql).startsWith('SELECT') && !normalize(userSql).startsWith('WITH')) {
    return res.status(400).json({ error: 'SELECT 구문만 실행할 수 있습니다.' });
  }

  try {
    const [userRows] = await pool.execute(userSql);
    const [ansRows]  = await pool.execute(answerSql);

    const toStr = rows => JSON.stringify(
      rows.map(r => Object.values(r).map(v => (v === null ? null : String(v))))
    );

    const passed = toStr(userRows) === toStr(ansRows);
    res.json({
      passed,
      userRows,
      ansRows,
      userCount: userRows.length,
      ansCount: ansRows.length,
    });
  } catch (e) {
    res.status(400).json({ error: e.message });
  }
});

// ───────────────────────────── 테이블 목록 ─────────────────────────────
app.get('/api/schema', async (_req, res) => {
  try {
    const [tables] = await pool.query(`SHOW TABLES`);
    const result = {};
    for (const row of tables) {
      const tbl = Object.values(row)[0];
      const [cols] = await pool.query(`DESCRIBE ${tbl}`);
      result[tbl] = cols;
    }
    res.json(result);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ───────────────────────────── 챕터 목록 ─────────────────────────────
app.get('/api/chapters', (_req, res) => {
  const chapters = [...new Map(
    PROBLEMS.map(p => [p.chapter, { chapter_id: p.chapter, title: p.chapterTitle }])
  ).values()].sort((a, b) => a.chapter_id - b.chapter_id);
  res.json(chapters);
});

// ───────────────────────────── 문제 목록 ─────────────────────────────
app.get('/api/problems', (_req, res) => {
  const mapped = PROBLEMS.map(p => ({
    problem_id:   p.id,
    chapter_id:   p.chapter,
    chapterTitle: p.chapterTitle,
    title:        p.title,
    difficulty:   p.difficulty,
    concept:      p.concept,
    description:  p.description,
    hint:         p.hint,
    answer_sql:   p.answer,
    conceptExplain: p.conceptExplain,
  }));
  res.json(mapped);
});

app.get('/api/health', (_req, res) => res.json({ ok: true }));
app.get('/health', (_req, res) => res.json({ ok: true }));

initPool().then(() => {
  app.listen(4000, () => console.log('🚀 Backend running on :4000'));
});

// ═══════════════════════════════════════════════════════════════════════
//  PROBLEMS DATA
// ═══════════════════════════════════════════════════════════════════════
const PROBLEMS = [
  // ──────────────── CHAPTER 1: 기본 SELECT ────────────────
  {
    id: 1, chapter: 1, chapterTitle: '기본 SELECT & 필터링',
    title: '전체 직원 조회',
    difficulty: 'easy',
    concept: 'SELECT *',
    description: `employees 테이블의 모든 컬럼과 행을 조회하세요.`,
    hint: 'SELECT * FROM 테이블명 형태로 작성합니다.',
    answer: 'SELECT * FROM employees',
    conceptExplain: `<strong>SELECT *</strong> 는 테이블의 모든 컬럼을 조회하는 가장 기본적인 구문입니다.<br>실무에서는 필요한 컬럼만 명시하는 것이 성능에 좋지만, 데이터 탐색 시엔 * 로 전체를 보는 것이 편합니다.`,
  },
  {
    id: 2, chapter: 1, chapterTitle: '기본 SELECT & 필터링',
    title: '특정 컬럼만 조회',
    difficulty: 'easy',
    concept: 'SELECT 컬럼 지정',
    description: `employees 테이블에서 emp_name, job_title, salary 컬럼만 조회하세요.`,
    hint: 'SELECT 뒤에 원하는 컬럼명을 쉼표로 구분해서 나열하세요.',
    answer: 'SELECT emp_name, job_title, salary FROM employees',
    conceptExplain: `컬럼을 명시적으로 지정하면 <strong>네트워크 트래픽 절감</strong>과 <strong>가독성 향상</strong>에 도움됩니다. 실무에서는 항상 필요한 컬럼만 SELECT 하는 것이 좋은 습관입니다.`,
  },
  {
    id: 3, chapter: 1, chapterTitle: '기본 SELECT & 필터링',
    title: 'WHERE 조건 필터링',
    difficulty: 'easy',
    concept: 'WHERE',
    description: `salary가 700만원 이상인 직원의 emp_name, job_title, salary를 조회하세요.`,
    hint: 'WHERE salary >= 7000000',
    answer: 'SELECT emp_name, job_title, salary FROM employees WHERE salary >= 7000000',
    conceptExplain: `<strong>WHERE</strong> 절은 행을 필터링합니다. 비교 연산자(=, !=, >, >=, <, <=)와 논리 연산자(AND, OR, NOT)를 조합해 복잡한 조건도 표현할 수 있습니다.`,
  },
  {
    id: 4, chapter: 1, chapterTitle: '기본 SELECT & 필터링',
    title: 'ORDER BY 정렬',
    difficulty: 'easy',
    concept: 'ORDER BY',
    description: `employees 테이블에서 salary가 높은 순서대로 emp_name, salary를 조회하세요.`,
    hint: 'ORDER BY salary DESC',
    answer: 'SELECT emp_name, salary FROM employees ORDER BY salary DESC',
    conceptExplain: `<strong>ORDER BY</strong> 는 결과를 정렬합니다. <code>ASC</code>(오름차순, 기본값) / <code>DESC</code>(내림차순)를 지정할 수 있습니다. 여러 컬럼 정렬도 가능합니다: <code>ORDER BY dept_id ASC, salary DESC</code>`,
  },
  {
    id: 5, chapter: 1, chapterTitle: '기본 SELECT & 필터링',
    title: 'LIMIT & OFFSET',
    difficulty: 'easy',
    concept: 'LIMIT',
    description: `salary가 높은 순서로 상위 5명의 emp_name, salary를 조회하세요.`,
    hint: 'ORDER BY ... DESC LIMIT 5',
    answer: 'SELECT emp_name, salary FROM employees ORDER BY salary DESC LIMIT 5',
    conceptExplain: `<strong>LIMIT n</strong> 은 결과를 n개로 제한합니다. <code>LIMIT 5 OFFSET 10</code> 처럼 OFFSET을 함께 쓰면 페이지네이션을 구현할 수 있습니다.`,
  },

  // ──────────────── CHAPTER 2: DISTINCT & 집계 ────────────────
  {
    id: 6, chapter: 2, chapterTitle: 'DISTINCT & 집계 함수',
    title: 'DISTINCT - 중복 제거',
    difficulty: 'easy',
    concept: 'DISTINCT',
    description: `employees 테이블에서 중복 없이 job_title 목록을 조회하세요.`,
    hint: 'SELECT DISTINCT 컬럼명 ...',
    answer: 'SELECT DISTINCT job_title FROM employees',
    conceptExplain: `<strong>DISTINCT</strong> 는 중복 행을 제거합니다. 실무에서는 카테고리 목록, 코드 목록 조회 시 자주 사용됩니다.<br>⚠️ 컬럼이 여러 개이면 <em>모든 컬럼의 조합</em>이 중복인 경우만 제거됩니다.`,
  },
  {
    id: 7, chapter: 2, chapterTitle: 'DISTINCT & 집계 함수',
    title: 'COUNT - 행 수 세기',
    difficulty: 'easy',
    concept: 'COUNT',
    description: `employees 테이블의 전체 직원 수를 조회하세요. 컬럼명은 total_count로 출력하세요.`,
    hint: 'SELECT COUNT(*) AS total_count ...',
    answer: 'SELECT COUNT(*) AS total_count FROM employees',
    conceptExplain: `<strong>COUNT(*)</strong> 는 NULL 포함 전체 행 수를 셉니다.<br><strong>COUNT(컬럼)</strong> 은 해당 컬럼이 NULL이 아닌 행만 셉니다.<br><code>AS</code> 별칭으로 컬럼명을 바꿀 수 있습니다.`,
  },
  {
    id: 8, chapter: 2, chapterTitle: 'DISTINCT & 집계 함수',
    title: 'SUM / AVG / MAX / MIN',
    difficulty: 'easy',
    concept: 'SUM, AVG, MAX, MIN',
    description: `employees 테이블에서 전체 급여 합계(total_salary), 평균(avg_salary), 최고(max_salary), 최저(min_salary)를 조회하세요. 평균은 소수점 없이 정수로 반올림하세요.`,
    hint: 'ROUND(AVG(salary), 0)',
    answer: 'SELECT SUM(salary) AS total_salary, ROUND(AVG(salary), 0) AS avg_salary, MAX(salary) AS max_salary, MIN(salary) AS min_salary FROM employees',
    conceptExplain: `집계 함수는 여러 행을 하나의 값으로 요약합니다.<br><ul><li><strong>SUM</strong>: 합계</li><li><strong>AVG</strong>: 평균</li><li><strong>MAX / MIN</strong>: 최대 / 최솟값</li><li><strong>ROUND(값, 소수점자리)</strong>: 반올림</li></ul>`,
  },
  {
    id: 9, chapter: 2, chapterTitle: 'DISTINCT & 집계 함수',
    title: 'GROUP BY - 그룹 집계',
    difficulty: 'medium',
    concept: 'GROUP BY',
    description: `부서(dept_id)별 직원 수(emp_count)와 평균 급여(avg_salary)를 조회하세요. 평균 급여는 정수로 반올림하고, 평균 급여 내림차순으로 정렬하세요.`,
    hint: 'GROUP BY dept_id ORDER BY avg_salary DESC',
    answer: 'SELECT dept_id, COUNT(*) AS emp_count, ROUND(AVG(salary), 0) AS avg_salary FROM employees GROUP BY dept_id ORDER BY avg_salary DESC',
    conceptExplain: `<strong>GROUP BY</strong> 는 지정한 컬럼의 값이 같은 행들을 하나의 그룹으로 묶고, 각 그룹에 집계 함수를 적용합니다.<br>SELECT 절에는 <em>GROUP BY에 명시한 컬럼</em> 또는 <em>집계 함수</em>만 올 수 있습니다.`,
  },
  {
    id: 10, chapter: 2, chapterTitle: 'DISTINCT & 집계 함수',
    title: 'HAVING - 그룹 조건 필터',
    difficulty: 'medium',
    concept: 'HAVING',
    description: `부서별 평균 급여가 650만원 이상인 부서의 dept_id와 avg_salary(정수 반올림)를 조회하세요.`,
    hint: 'HAVING AVG(salary) >= 6500000',
    answer: 'SELECT dept_id, ROUND(AVG(salary), 0) AS avg_salary FROM employees GROUP BY dept_id HAVING AVG(salary) >= 6500000',
    conceptExplain: `<strong>HAVING</strong> 은 GROUP BY 이후에 그룹 단위로 조건을 거는 절입니다.<br><code>WHERE</code>는 행 단위 필터(집계 전), <code>HAVING</code>은 그룹 단위 필터(집계 후)로 역할이 다릅니다.<br>실행 순서: FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY`,
  },

  // ──────────────── CHAPTER 3: JOIN ────────────────
  {
    id: 11, chapter: 3, chapterTitle: 'JOIN',
    title: 'INNER JOIN - 기본',
    difficulty: 'medium',
    concept: 'INNER JOIN',
    description: `직원 이름(emp_name), 부서명(dept_name), 급여(salary)를 조회하세요. (직원-부서 JOIN)`,
    hint: 'employees e JOIN departments d ON e.dept_id = d.dept_id',
    answer: 'SELECT e.emp_name, d.dept_name, e.salary FROM employees e JOIN departments d ON e.dept_id = d.dept_id',
    conceptExplain: `<strong>INNER JOIN</strong> 은 두 테이블에서 ON 조건이 일치하는 행만 반환합니다.<br>실무에서 가장 많이 사용하는 JOIN으로, 두 테이블의 교집합이라고 생각하면 됩니다.`,
  },
  {
    id: 12, chapter: 3, chapterTitle: 'JOIN',
    title: 'LEFT JOIN - 포함 조회',
    difficulty: 'medium',
    concept: 'LEFT JOIN',
    description: `직원 이름(emp_name)과 주문 날짜(order_date)를 조회하되, 주문이 없는 직원도 포함하세요. order_date가 없는 경우 '주문없음'으로 표시하세요. emp_name 오름차순 정렬.`,
    hint: 'LEFT JOIN orders ON ... IFNULL(order_date, ...)',
    answer: "SELECT e.emp_name, IFNULL(CAST(o.order_date AS CHAR), '주문없음') AS order_date FROM employees e LEFT JOIN orders o ON e.emp_id = o.emp_id ORDER BY e.emp_name",
    conceptExplain: `<strong>LEFT JOIN</strong> 은 왼쪽 테이블의 모든 행을 포함하고, 오른쪽은 매칭되지 않으면 NULL을 채웁니다.<br><code>IFNULL(값, 대체값)</code>으로 NULL을 다른 값으로 치환할 수 있습니다.`,
  },
  {
    id: 13, chapter: 3, chapterTitle: 'JOIN',
    title: '3개 테이블 JOIN',
    difficulty: 'medium',
    concept: 'Multi-table JOIN',
    description: `주문 ID(order_id), 직원 이름(emp_name), 부서명(dept_name), 주문 금액(total_amount)을 조회하세요. 완료 상태인 주문만 포함하고, 주문 금액 내림차순으로 정렬하세요.`,
    hint: 'orders → employees → departments 순서로 JOIN',
    answer: "SELECT o.order_id, e.emp_name, d.dept_name, o.total_amount FROM orders o JOIN employees e ON o.emp_id = e.emp_id JOIN departments d ON e.dept_id = d.dept_id WHERE o.status = '완료' ORDER BY o.total_amount DESC",
    conceptExplain: `실무에서는 3개 이상의 테이블을 JOIN하는 경우가 많습니다. JOIN을 연속으로 작성하면 되며, 각 JOIN마다 ON 조건을 명시합니다.<br>⚠️ JOIN 순서와 인덱스 활용이 성능에 큰 영향을 미칩니다.`,
  },

  // ──────────────── CHAPTER 4: 서브쿼리 ────────────────
  {
    id: 14, chapter: 4, chapterTitle: '서브쿼리 (Subquery)',
    title: '스칼라 서브쿼리',
    difficulty: 'medium',
    concept: 'Scalar Subquery',
    description: `각 직원의 emp_name, salary와 함께 전체 직원 평균 급여(avg_all, 정수 반올림)를 옆에 표시하세요.`,
    hint: 'SELECT ..., (SELECT ROUND(AVG(salary),0) FROM employees) AS avg_all',
    answer: 'SELECT emp_name, salary, (SELECT ROUND(AVG(salary),0) FROM employees) AS avg_all FROM employees',
    conceptExplain: `<strong>스칼라 서브쿼리</strong>는 SELECT 절 안에 위치하며 단 하나의 값을 반환합니다. 매 행마다 실행되므로 데이터가 많으면 성능 이슈가 생길 수 있어 JOIN이나 WITH으로 대체하는 것이 좋습니다.`,
  },
  {
    id: 15, chapter: 4, chapterTitle: '서브쿼리 (Subquery)',
    title: 'WHERE 서브쿼리',
    difficulty: 'medium',
    concept: 'Subquery in WHERE',
    description: `평균 급여보다 급여가 높은 직원의 emp_name, salary를 조회하세요. salary 내림차순 정렬.`,
    hint: 'WHERE salary > (SELECT AVG(salary) FROM employees)',
    answer: 'SELECT emp_name, salary FROM employees WHERE salary > (SELECT AVG(salary) FROM employees) ORDER BY salary DESC',
    conceptExplain: `WHERE 절에 서브쿼리를 사용하면 동적인 조건을 만들 수 있습니다. 비교 연산자 뒤에 단일 값을 반환하는 서브쿼리를 위치시킵니다.`,
  },
  {
    id: 16, chapter: 4, chapterTitle: '서브쿼리 (Subquery)',
    title: 'EXISTS - 존재 여부',
    difficulty: 'medium',
    concept: 'EXISTS',
    description: `주문을 한 번이라도 한 직원의 emp_name과 dept_id를 중복 없이 조회하세요.`,
    hint: 'WHERE EXISTS (SELECT 1 FROM orders o WHERE o.emp_id = e.emp_id)',
    answer: 'SELECT DISTINCT e.emp_name, e.dept_id FROM employees e WHERE EXISTS (SELECT 1 FROM orders o WHERE o.emp_id = e.emp_id)',
    conceptExplain: `<strong>EXISTS</strong>는 서브쿼리가 한 건이라도 결과를 반환하면 TRUE입니다. IN보다 <em>성능이 좋은 경우</em>가 많아 실무에서 선호됩니다. <code>SELECT 1</code>처럼 실제 값은 중요하지 않습니다.`,
  },
  {
    id: 17, chapter: 4, chapterTitle: '서브쿼리 (Subquery)',
    title: 'IN 서브쿼리',
    difficulty: 'medium',
    concept: 'IN Subquery',
    description: `개발팀(dept_name = '개발팀') 소속 직원들의 emp_name, salary를 조회하세요.`,
    hint: 'WHERE dept_id IN (SELECT dept_id FROM departments WHERE dept_name = ...)',
    answer: "SELECT emp_name, salary FROM employees WHERE dept_id IN (SELECT dept_id FROM departments WHERE dept_name = '개발팀')",
    conceptExplain: `<strong>IN</strong>은 서브쿼리가 반환하는 목록 안에 값이 있는지 확인합니다. 반환 건수가 많으면 성능이 저하될 수 있어 EXISTS나 JOIN으로 대체를 고려합니다.`,
  },

  // ──────────────── CHAPTER 5: WITH (CTE) ────────────────
  {
    id: 18, chapter: 5, chapterTitle: 'WITH (CTE)',
    title: 'WITH 기본',
    difficulty: 'medium',
    concept: 'WITH / CTE',
    description: `WITH를 사용해 부서별 평균 급여를 dept_avg라는 이름으로 정의한 뒤, 평균 급여가 700만원 이상인 부서의 dept_id와 avg_salary(정수)를 조회하세요.`,
    hint: 'WITH dept_avg AS (SELECT dept_id, ROUND(AVG...) FROM employees GROUP BY dept_id) SELECT ... FROM dept_avg WHERE ...',
    answer: 'WITH dept_avg AS (SELECT dept_id, ROUND(AVG(salary),0) AS avg_salary FROM employees GROUP BY dept_id) SELECT dept_id, avg_salary FROM dept_avg WHERE avg_salary >= 7000000',
    conceptExplain: `<strong>WITH (CTE, Common Table Expression)</strong>는 쿼리 안에서 임시 결과 집합을 이름 붙여 정의합니다.<br>장점: 복잡한 서브쿼리를 분리해 <em>가독성</em>과 <em>재사용성</em>을 높입니다. 실무에서 복잡한 분석 쿼리를 작성할 때 필수입니다.`,
  },
  {
    id: 19, chapter: 5, chapterTitle: 'WITH (CTE)',
    title: 'WITH 다중 CTE',
    difficulty: 'hard',
    concept: 'Multiple CTE',
    description: `WITH를 사용해:<br>① dept_info: 부서별 직원 수(emp_count)와 급여 합계(total_salary)<br>② 결과: dept_info와 departments를 JOIN해 dept_name, emp_count, total_salary를 조회하세요. total_salary 내림차순 정렬.`,
    hint: 'WITH dept_info AS (...) SELECT d.dept_name, di.emp_count, di.total_salary FROM dept_info di JOIN departments d ON ...',
    answer: 'WITH dept_info AS (SELECT dept_id, COUNT(*) AS emp_count, SUM(salary) AS total_salary FROM employees GROUP BY dept_id) SELECT d.dept_name, di.emp_count, di.total_salary FROM dept_info di JOIN departments d ON di.dept_id = d.dept_id ORDER BY di.total_salary DESC',
    conceptExplain: `WITH 절에 여러 CTE를 정의할 수 있습니다. 쉼표로 구분하여 <code>WITH cte1 AS (...), cte2 AS (...) SELECT ...</code> 형식으로 작성합니다. 뒤에 나오는 CTE는 앞의 CTE를 참조할 수도 있습니다.`,
  },

  // ──────────────── CHAPTER 6: CASE WHEN ────────────────
  {
    id: 20, chapter: 6, chapterTitle: 'CASE WHEN',
    title: 'CASE WHEN 기본',
    difficulty: 'medium',
    concept: 'CASE WHEN',
    description: `employees 테이블에서 emp_name, salary와 함께 급여 등급(salary_grade)을 표시하세요.<br>- 800만 이상: S등급<br>- 700만 이상: A등급<br>- 600만 이상: B등급<br>- 그 외: C등급`,
    hint: 'CASE WHEN salary >= 8000000 THEN ... WHEN ... ELSE ... END AS salary_grade',
    answer: "SELECT emp_name, salary, CASE WHEN salary >= 8000000 THEN 'S등급' WHEN salary >= 7000000 THEN 'A등급' WHEN salary >= 6000000 THEN 'B등급' ELSE 'C등급' END AS salary_grade FROM employees",
    conceptExplain: `<strong>CASE WHEN</strong>은 조건에 따라 다른 값을 반환하는 조건 표현식입니다. 프로그래밍의 if-else와 동일합니다.<br>CASE는 위에서부터 순서대로 평가하므로 조건 순서가 중요합니다.`,
  },
  {
    id: 21, chapter: 6, chapterTitle: 'CASE WHEN',
    title: 'CASE WHEN + GROUP BY',
    difficulty: 'hard',
    concept: 'CASE WHEN + 집계',
    description: `orders 테이블에서 상태(status)별 주문 건수를 피벗 형식으로 조회하세요.<br>컬럼: 완료건수(done_count), 취소건수(cancel_count), 진행중건수(inprogress_count)`,
    hint: 'SUM(CASE WHEN status = ... THEN 1 ELSE 0 END)',
    answer: "SELECT SUM(CASE WHEN status = '완료' THEN 1 ELSE 0 END) AS done_count, SUM(CASE WHEN status = '취소' THEN 1 ELSE 0 END) AS cancel_count, SUM(CASE WHEN status = '진행중' THEN 1 ELSE 0 END) AS inprogress_count FROM orders",
    conceptExplain: `<strong>CASE WHEN + 집계 함수</strong> 패턴은 행을 열로 변환(Pivot)할 때 사용합니다. 실무에서 대시보드 쿼리나 리포트 쿼리에서 매우 자주 사용됩니다.`,
  },

  // ──────────────── CHAPTER 7: 윈도우 함수 ────────────────
  {
    id: 22, chapter: 7, chapterTitle: '윈도우 함수 (Window Function)',
    title: 'ROW_NUMBER',
    difficulty: 'hard',
    concept: 'ROW_NUMBER()',
    description: `부서(dept_id)별로 급여 순위(rn)를 매기되, 같은 부서 안에서 급여 내림차순으로 순위를 부여하세요. emp_name, dept_id, salary, rn을 조회하고, dept_id 오름차순 → rn 오름차순으로 정렬하세요.`,
    hint: 'ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC)',
    answer: 'SELECT emp_name, dept_id, salary, ROW_NUMBER() OVER (PARTITION BY dept_id ORDER BY salary DESC) AS rn FROM employees ORDER BY dept_id, rn',
    conceptExplain: `<strong>ROW_NUMBER()</strong>는 각 행에 고유한 번호를 부여합니다.<br><code>PARTITION BY</code>는 GROUP BY처럼 그룹을 나누고, <code>ORDER BY</code>는 그룹 내 정렬 기준입니다. 행을 제거하지 않는다는 점이 GROUP BY와 다릅니다.`,
  },
  {
    id: 23, chapter: 7, chapterTitle: '윈도우 함수 (Window Function)',
    title: 'RANK vs DENSE_RANK',
    difficulty: 'hard',
    concept: 'RANK, DENSE_RANK',
    description: `전체 직원 중 급여 기준으로 RANK(rk)와 DENSE_RANK(dense_rk)를 함께 조회하세요. emp_name, salary, rk, dense_rk를 salary 내림차순으로 정렬하세요.`,
    hint: 'RANK() OVER (ORDER BY salary DESC), DENSE_RANK() OVER (ORDER BY salary DESC)',
    answer: 'SELECT emp_name, salary, RANK() OVER (ORDER BY salary DESC) AS rk, DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rk FROM employees ORDER BY salary DESC',
    conceptExplain: `<ul><li><strong>RANK()</strong>: 동점이면 같은 순위, 다음 순위는 건너뜀 (1,1,3,...)</li><li><strong>DENSE_RANK()</strong>: 동점이면 같은 순위, 다음 순위는 연속 (1,1,2,...)</li></ul>실무에서 TOP N 순위를 구할 때 둘을 구분해서 사용합니다.`,
  },
  {
    id: 24, chapter: 7, chapterTitle: '윈도우 함수 (Window Function)',
    title: 'SUM OVER - 누적 합계',
    difficulty: 'hard',
    concept: 'SUM() OVER',
    description: `hire_date 오름차순으로 직원을 정렬했을 때, emp_name, hire_date, salary와 함께 salary의 누적 합계(cumulative_salary)를 조회하세요.`,
    hint: 'SUM(salary) OVER (ORDER BY hire_date)',
    answer: 'SELECT emp_name, hire_date, salary, SUM(salary) OVER (ORDER BY hire_date) AS cumulative_salary FROM employees ORDER BY hire_date',
    conceptExplain: `<strong>SUM() OVER (ORDER BY ...)</strong>는 현재 행까지의 누적 합계를 구합니다. 기본적으로 <code>ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW</code>가 적용됩니다. 매출 누적, 재고 누적 계산에 활용됩니다.`,
  },

  // ──────────────── CHAPTER 8: 문자열 함수 ────────────────
  {
    id: 25, chapter: 8, chapterTitle: '문자열 & 날짜 함수',
    title: 'SUBSTR - 문자열 자르기',
    difficulty: 'medium',
    concept: 'SUBSTR',
    description: `employees 테이블에서 hire_date의 연도(year_hired)만 추출하여 emp_name, hire_date, year_hired를 조회하세요. SUBSTR 함수를 사용하세요.`,
    hint: 'SUBSTR(hire_date, 1, 4)',
    answer: 'SELECT emp_name, hire_date, SUBSTR(hire_date, 1, 4) AS year_hired FROM employees',
    conceptExplain: `<strong>SUBSTR(문자열, 시작위치, 길이)</strong>는 문자열의 일부를 추출합니다. MySQL에서는 <code>SUBSTRING()</code>과 동일합니다.<br>날짜는 'YYYY-MM-DD' 형식이므로 SUBSTR로 연/월/일을 자유롭게 추출할 수 있습니다.`,
  },
  {
    id: 26, chapter: 8, chapterTitle: '문자열 & 날짜 함수',
    title: 'DATE 함수 - 날짜 계산',
    difficulty: 'medium',
    concept: 'DATEDIFF, DATE_FORMAT',
    description: `직원별 근속 일수(working_days)를 계산하세요. emp_name, hire_date, working_days를 조회하고, working_days 내림차순으로 정렬하세요. 기준일은 2024-06-30로 합니다.`,
    hint: "DATEDIFF('2024-06-30', hire_date)",
    answer: "SELECT emp_name, hire_date, DATEDIFF('2024-06-30', hire_date) AS working_days FROM employees ORDER BY working_days DESC",
    conceptExplain: `<strong>DATEDIFF(날짜1, 날짜2)</strong>는 날짜1 - 날짜2의 일수 차이를 반환합니다.<br>그 외 유용한 날짜 함수: <code>DATE_FORMAT(date, '%Y-%m')</code>, <code>MONTH(date)</code>, <code>YEAR(date)</code>, <code>DATE_ADD(date, INTERVAL n DAY)</code>`,
  },
  {
    id: 27, chapter: 8, chapterTitle: '문자열 & 날짜 함수',
    title: 'GROUP_CONCAT - 목록 합치기',
    difficulty: 'hard',
    concept: 'GROUP_CONCAT',
    description: `부서(dept_id)별 직원 이름을 쉼표로 연결한 목록(emp_list)을 조회하세요. 이름은 emp_name 오름차순으로 연결하세요.`,
    hint: "GROUP_CONCAT(emp_name ORDER BY emp_name SEPARATOR ', ')",
    answer: "SELECT dept_id, GROUP_CONCAT(emp_name ORDER BY emp_name SEPARATOR ', ') AS emp_list FROM employees GROUP BY dept_id",
    conceptExplain: `<strong>GROUP_CONCAT()</strong>은 MySQL에서 그룹 내 여러 값을 하나의 문자열로 합칩니다. Oracle의 LISTAGG()와 동일한 역할입니다.<br><code>SEPARATOR</code>로 구분자를 지정하고, <code>ORDER BY</code>로 순서를 제어합니다.`,
  },

  // ──────────────── CHAPTER 9: 종합 실전 ────────────────
  {
    id: 28, chapter: 9, chapterTitle: '종합 실전 문제',
    title: '부서별 주문 통계',
    difficulty: 'hard',
    concept: '종합 JOIN + GROUP BY',
    description: `부서명(dept_name)별 완료 주문 건수(order_count)와 총 주문 금액(total_amount)을 조회하세요. 주문이 없는 부서는 제외합니다. total_amount 내림차순 정렬.`,
    hint: 'orders → employees → departments JOIN, status = 완료 WHERE',
    answer: "SELECT d.dept_name, COUNT(o.order_id) AS order_count, SUM(o.total_amount) AS total_amount FROM orders o JOIN employees e ON o.emp_id = e.emp_id JOIN departments d ON e.dept_id = d.dept_id WHERE o.status = '완료' GROUP BY d.dept_name ORDER BY total_amount DESC",
    conceptExplain: `실무 쿼리의 전형적인 패턴입니다: 여러 테이블을 JOIN한 뒤 GROUP BY로 집계하고 ORDER BY로 정렬합니다. WHERE로 불필요한 데이터를 먼저 줄이면 성능이 좋아집니다.`,
  },
  {
    id: 29, chapter: 9, chapterTitle: '종합 실전 문제',
    title: '가장 많이 팔린 상품 TOP 3',
    difficulty: 'hard',
    concept: 'JOIN + 집계 + LIMIT',
    description: `상품명(product_name), 총 판매 수량(total_qty)을 조회하고, 판매 수량 기준 상위 3개 상품을 출력하세요. (취소 주문 제외)`,
    hint: 'order_items → orders → products JOIN, 취소 제외, SUM(quantity), LIMIT 3',
    answer: "SELECT p.product_name, SUM(oi.quantity) AS total_qty FROM order_items oi JOIN orders o ON oi.order_id = o.order_id JOIN products p ON oi.product_id = p.product_id WHERE o.status != '취소' GROUP BY p.product_id, p.product_name ORDER BY total_qty DESC LIMIT 3",
    conceptExplain: `취소 주문 제외 시 <code>WHERE status != '취소'</code> 또는 <code>WHERE status IN ('완료', '진행중')</code>처럼 명시적으로 포함할 상태를 지정하는 방법 중 상황에 맞게 선택합니다.`,
  },
  {
    id: 30, chapter: 9, chapterTitle: '종합 실전 문제',
    title: '부서별 급여 1등 직원',
    difficulty: 'hard',
    concept: 'ROW_NUMBER + WITH + 필터',
    description: `부서별로 급여가 가장 높은 직원 1명씩 조회하세요. 결과: dept_name, emp_name, salary. dept_name 오름차순 정렬.`,
    hint: 'WITH ranked AS (ROW_NUMBER() OVER PARTITION BY dept_id) WHERE rn = 1',
    answer: 'WITH ranked AS (SELECT e.emp_name, e.dept_id, e.salary, ROW_NUMBER() OVER (PARTITION BY e.dept_id ORDER BY e.salary DESC) AS rn FROM employees e) SELECT d.dept_name, r.emp_name, r.salary FROM ranked r JOIN departments d ON r.dept_id = d.dept_id WHERE r.rn = 1 ORDER BY d.dept_name',
    conceptExplain: `<strong>ROW_NUMBER() + WITH + WHERE rn = 1</strong> 패턴은 그룹별 TOP 1을 구하는 가장 실무적인 방법입니다. 이 패턴만 잘 이해해도 많은 실무 문제를 해결할 수 있습니다.`,
  },
];
