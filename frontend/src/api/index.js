const BASE = '/api';

export async function fetchProblems() {
  const res = await fetch(`${BASE}/problems`);
  if (!res.ok) throw new Error('문제 목록 로드 실패');
  return res.json();
}

export async function fetchChapters() {
  const res = await fetch(`${BASE}/chapters`);
  if (!res.ok) throw new Error('챕터 목록 로드 실패');
  return res.json();
}

export async function fetchSchema() {
  const res = await fetch(`${BASE}/schema`);
  if (!res.ok) throw new Error('스키마 로드 실패');
  return res.json();
}

export async function runSQL(sql) {
  const res = await fetch(`${BASE}/run`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ sql }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || data.error || 'SQL 실행 오류');
  return data;
}

export async function gradeSQL(userSql, answerSql) {
  const res = await fetch(`${BASE}/grade`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ userSql, answerSql }),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.message || data.error || '채점 오류');
  return data;
}
