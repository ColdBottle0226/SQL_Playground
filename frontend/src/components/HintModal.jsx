import React from 'react';

export default function HintModal({ hint, onClose }) {
  if (!hint) return null;
  return (
    <div className="modal-overlay open" onClick={(e) => e.target === e.currentTarget && onClose()}>
      <div className="modal">
        <div className="modal-title">💡 힌트</div>
        <div className="modal-body">{hint}</div>
        <div className="modal-close">
          <button className="btn btn-reset" onClick={onClose}>닫기</button>
        </div>
      </div>
    </div>
  );
}
