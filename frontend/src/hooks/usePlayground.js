import { useState, useEffect } from 'react';
import { fetchProblems, fetchChapters, fetchSchema } from '../api';

export function usePlayground() {
  const [chapters, setChapters] = useState([]);
  const [problems, setProblems] = useState([]);
  const [schema, setSchema] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // 풀린 문제를 localStorage로 관리
  const [solvedSet, setSolvedSet] = useState(() => {
    try {
      return new Set(JSON.parse(localStorage.getItem('solved') || '[]'));
    } catch {
      return new Set();
    }
  });

  useEffect(() => {
    Promise.all([fetchChapters(), fetchProblems(), fetchSchema()])
      .then(([ch, pr, sc]) => {
        setChapters(ch);
        setProblems(pr);
        setSchema(sc);
      })
      .catch((e) => setError(e.message))
      .finally(() => setLoading(false));
  }, []);

  const markSolved = (id) => {
    setSolvedSet((prev) => {
      const next = new Set(prev);
      next.add(id);
      localStorage.setItem('solved', JSON.stringify([...next]));
      return next;
    });
  };

  // 챕터별로 문제를 그룹핑
  const grouped = chapters.map((ch) => ({
    ...ch,
    items: problems.filter((p) => p.chapter_id === ch.chapter_id),
  }));

  return { chapters, problems, schema, loading, error, solvedSet, markSolved, grouped };
}
