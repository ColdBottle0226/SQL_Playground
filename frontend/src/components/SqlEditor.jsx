import React, { useRef, useEffect } from 'react';

export default function SqlEditor({ value, onChange, onRun, onSubmit, onHint, onAnswer, onReset }) {
  const ref = useRef(null);

  useEffect(() => {
    const handler = (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
        e.preventDefault();
        onRun();
      }
    };
    const el = ref.current;
    el?.addEventListener('keydown', handler);
    return () => el?.removeEventListener('keydown', handler);
  }, [onRun]);

  const handleKeyDown = (e) => {
    if (e.key === 'Tab') {
      e.preventDefault();
      const el = e.target;
      const s = el.selectionStart;
      const end = el.selectionEnd;
      const next = value.substring(0, s) + '  ' + value.substring(end);
      onChange(next);
      setTimeout(() => {
        el.selectionStart = el.selectionEnd = s + 2;
      }, 0);
    }
  };

  return (
    <div className="editor-area">
      <div className="editor-toolbar">
        <span className="editor-label">✏️ SQL Editor</span>
        <button className="btn btn-hint" onClick={onHint}>💡 힌트</button>
        <button className="btn btn-reset" onClick={onReset}>↩ 초기화</button>
        <button className="btn btn-answer" onClick={onAnswer}>👀 정답보기</button>
        <button className="btn btn-run" onClick={onRun}>▶ 실행 (Ctrl+Enter)</button>
        <button className="btn btn-submit" onClick={onSubmit}>✔ 채점</button>
      </div>
      <textarea
        ref={ref}
        className="sql-textarea"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onKeyDown={handleKeyDown}
        spellCheck={false}
        placeholder={'-- SQL을 작성하세요\n-- Ctrl+Enter 로 실행\nSELECT ...'}
      />
    </div>
  );
}
