import React from 'react';

function escHtml(str) {
  return String(str ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function ResultTable({ columns, rows }) {
  if (!columns?.length) return null;
  return (
    <div className="result-table-wrap">
      <table className="res">
        <thead>
          <tr>{columns.map((c) => <th key={c}>{c}</th>)}</tr>
        </thead>
        <tbody>
          {rows.slice(0, 200).map((row, i) => (
            <tr key={i}>
              {columns.map((c) => {
                const v = row[c];
                return v === null || v === undefined
                  ? <td key={c} className="null">NULL</td>
                  : <td key={c} dangerouslySetInnerHTML={{ __html: escHtml(v) }} />;
              })}
            </tr>
          ))}
          {rows.length > 200 && (
            <tr>
              <td colSpan={columns.length} style={{ textAlign: 'center', color: 'var(--muted)' }}>
                ... {rows.length - 200}개 더 있음 (상위 200개만 표시)
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

export default function ResultPanel({ runResult, gradeResult, activeTab, onTabChange }) {
  const renderRunContent = () => {
    if (!runResult) return (
      <div className="empty-state" style={{ height: 100 }}>
        <div className="empty-text" style={{ fontSize: 12 }}>SQL을 실행하면 결과가 여기에 표시됩니다</div>
      </div>
    );
    if (runResult.loading) return <div className="verdict info"><span>⏳</span> 실행 중...</div>;
    if (runResult.error) return <div className="verdict error"><span>❌</span> 오류: {runResult.error}</div>;
    return (
      <>
        <div className="verdict info"><span>✅</span> {runResult.rowCount}개 행 조회됨</div>
        <ResultTable columns={runResult.columns} rows={runResult.rows} />
      </>
    );
  };

  const renderGradeContent = () => {
    if (!gradeResult) return (
      <div className="empty-state" style={{ height: 100 }}>
        <div className="empty-text" style={{ fontSize: 12 }}>채점 버튼을 누르면 결과가 여기에 표시됩니다</div>
      </div>
    );
    if (gradeResult.loading) return <div className="verdict info"><span>⏳</span> 채점 중...</div>;
    if (gradeResult.error) return <div className="verdict error"><span>❌</span> 오류: {gradeResult.error}</div>;

    const { passed, userRows, userCount, ansCount } = gradeResult;
    const cols = userRows?.length ? Object.keys(userRows[0]) : [];
    return (
      <>
        {passed
          ? <div className="verdict pass"><span>🎉</span> 정답입니다! {userCount}개 행이 일치합니다.</div>
          : <div className="verdict fail"><span>❌</span> 틀렸습니다. 내 결과: {userCount}행 / 정답: {ansCount}행</div>
        }
        {cols.length > 0 && (
          <>
            <div style={{ fontSize: 11, color: 'var(--muted)', margin: '8px 0 4px' }}>내 쿼리 결과 (상위 10행)</div>
            <ResultTable columns={cols} rows={(userRows || []).slice(0, 10)} />
          </>
        )}
      </>
    );
  };

  return (
    <div className="result-area">
      <div className="result-tabs">
        <div className={`result-tab ${activeTab === 'run' ? 'active' : ''}`} onClick={() => onTabChange('run')}>실행 결과</div>
        <div className={`result-tab ${activeTab === 'grade' ? 'active' : ''}`} onClick={() => onTabChange('grade')}>채점 결과</div>
      </div>
      <div className="result-content">
        {activeTab === 'run' ? renderRunContent() : renderGradeContent()}
      </div>
    </div>
  );
}
