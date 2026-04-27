import React from 'react';

const DIFF_LABEL = { easy: '🟢 쉬움', medium: '🟡 보통', hard: '🔴 어려움' };

export default function ProblemPanel({ problem }) {
  if (!problem) {
    return (
      <div className="problem-area">
        <div className="empty-state">
          <div className="empty-icon">👈</div>
          <div className="empty-text">왼쪽에서 문제를 선택하세요</div>
        </div>
      </div>
    );
  }

  return (
    <div className="problem-area">
      <div className="problem-meta">
        <span className="problem-number">CH{problem.chapter_id} · #{problem.problem_id}</span>
        <span className="problem-title-text">{problem.title}</span>
        <span style={{ fontSize: 12, color: 'var(--muted)' }}>{DIFF_LABEL[problem.difficulty]}</span>
        <span className="concept-tag">{problem.concept}</span>
      </div>
      <div
        className="problem-desc"
        dangerouslySetInnerHTML={{ __html: problem.description }}
      />
      <div
        className="concept-box"
        dangerouslySetInnerHTML={{
          __html: `<strong>📖 개념 설명</strong><br/>${problem.concept_explain}`,
        }}
      />
    </div>
  );
}
