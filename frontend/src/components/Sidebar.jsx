import React, { useState } from 'react';

const DIFF_MAP = { easy: '쉬움', medium: '보통', hard: '어려움' };
const DIFF_CLASS = { easy: 'diff-easy', medium: 'diff-medium', hard: 'diff-hard' };

export default function Sidebar({ grouped, solvedSet, currentId, onSelect }) {
  const [collapsed, setCollapsed] = useState({});

  const toggle = (chId) =>
    setCollapsed((prev) => ({ ...prev, [chId]: !prev[chId] }));

  return (
    <aside className="sidebar">
      <div className="sidebar-header">📚 문제 목록</div>
      <div className="sidebar-list">
        {grouped.map((ch) => {
          const solvedCount = ch.items.filter((p) => solvedSet.has(p.problem_id)).length;
          const isOpen = !collapsed[ch.chapter_id];
          return (
            <div key={ch.chapter_id} className="chapter-group">
              <div className="chapter-title" onClick={() => toggle(ch.chapter_id)}>
                <span>CH{ch.chapter_id}. {ch.chapter_title}</span>
                <span className="ch-num">{solvedCount}/{ch.items.length}</span>
              </div>
              {isOpen && (
                <div className="problem-list">
                  {ch.items.map((p) => {
                    const solved = solvedSet.has(p.problem_id);
                    const active = currentId === p.problem_id;
                    return (
                      <div
                        key={p.problem_id}
                        className={`problem-item ${solved ? 'solved' : ''} ${active ? 'active' : ''}`}
                        onClick={() => onSelect(p)}
                      >
                        <div className="pi-check">{solved ? '✓' : ''}</div>
                        <div className="pi-title">{p.problem_id}. {p.title}</div>
                        <div className={`pi-diff ${DIFF_CLASS[p.difficulty]}`}>
                          {DIFF_MAP[p.difficulty]}
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          );
        })}
      </div>
    </aside>
  );
}
