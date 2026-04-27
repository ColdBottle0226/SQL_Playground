import React, { useState } from 'react';
import { usePlayground } from './hooks/usePlayground';
import { runSQL, gradeSQL } from './api';
import Sidebar from './components/Sidebar';
import ProblemPanel from './components/ProblemPanel';
import SqlEditor from './components/SqlEditor';
import ResultPanel from './components/ResultPanel';
import SchemaPanel from './components/SchemaPanel';
import HintModal from './components/HintModal';
import ConceptPage from './components/ConceptPage';

// 현재 뷰 모드
// 'concept' | 'problem'
export default function App() {
  const { grouped, problems, schema, loading, error, solvedSet, markSolved } = usePlayground();

  const [viewMode, setViewMode] = useState('welcome'); // 'welcome' | 'concept' | 'problem'
  const [currentProblem, setCurrentProblem] = useState(null);
  const [currentConceptChapter, setCurrentConceptChapter] = useState(null);

  const [sql, setSql] = useState('');
  const [runResult, setRunResult] = useState(null);
  const [gradeResult, setGradeResult] = useState(null);
  const [activeTab, setActiveTab] = useState('run');
  const [hintVisible, setHintVisible] = useState(false);

  // 문제 선택
  const selectProblem = (p) => {
    setCurrentProblem(p);
    setCurrentConceptChapter(null);
    setViewMode('problem');
    setSql('');
    setRunResult(null);
    setGradeResult(null);
    setActiveTab('run');
  };

  // 개념 설명 선택
  const selectConcept = (chapter) => {
    setCurrentConceptChapter(chapter);
    setCurrentProblem(null);
    setViewMode('concept');
  };

  const handleRun = async () => {
    if (!sql.trim()) return;
    setActiveTab('run');
    setRunResult({ loading: true });
    try {
      const data = await runSQL(sql);
      setRunResult(data);
    } catch (e) {
      setRunResult({ error: e.message });
    }
  };

  const handleSubmit = async () => {
    if (!currentProblem) { alert('문제를 먼저 선택하세요.'); return; }
    if (!sql.trim()) { alert('SQL을 입력하세요.'); return; }
    setActiveTab('grade');
    setGradeResult({ loading: true });
    try {
      const data = await gradeSQL(sql, currentProblem.answer_sql);
      setGradeResult(data);
      if (data.passed) markSolved(currentProblem.problem_id);
    } catch (e) {
      setGradeResult({ error: e.message });
    }
  };

  const handleHint = () => {
    if (!currentProblem) { alert('문제를 먼저 선택하세요.'); return; }
    setHintVisible(true);
  };

  const handleAnswer = () => {
    if (!currentProblem) { alert('문제를 먼저 선택하세요.'); return; }
    if (window.confirm('정답을 보시겠습니까?')) {
      setSql(currentProblem.answer_sql);
    }
  };

  const handleReset = () => {
    setSql('');
    setRunResult(null);
    setGradeResult(null);
  };

  const solved = solvedSet.size;
  const total = problems.length;
  const progress = total > 0 ? (solved / total) * 100 : 0;

  if (loading) return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh', color: 'var(--muted)', fontFamily: 'var(--mono)' }}>
      데이터베이스 연결 중...
    </div>
  );

  if (error) return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100vh', color: 'var(--red)', gap: 12 }}>
      <div style={{ fontSize: 40 }}>⚠️</div>
      <div>서버 연결 실패: {error}</div>
      <div style={{ fontSize: 13, color: 'var(--muted)' }}>docker-compose up 이 실행 중인지 확인하세요.</div>
    </div>
  );

  return (
    <>
      <header>
        <div className="logo">SQL<span>Playground</span></div>
        <div style={{ fontSize: 12, color: 'var(--muted)', borderLeft: '1px solid var(--border)', paddingLeft: 16 }}>
          실무 SELECT 마스터 · MySQL 8.0
        </div>
        <div className="header-stats">
          <div className="stat-badge">
            <span>해결</span>
            <span className="num">{solved}</span>
            <span>/ {total}</span>
          </div>
          <div className="progress-bar-wrap" style={{ width: 100, borderRadius: 2 }}>
            <div className="progress-bar-fill" style={{ width: `${progress}%` }} />
          </div>
        </div>
      </header>

      <div className="app">
        <Sidebar
          grouped={grouped}
          solvedSet={solvedSet}
          currentId={currentProblem?.problem_id}
          currentConceptChapterId={currentConceptChapter?.chapter_id}
          onSelect={selectProblem}
          onSelectConcept={selectConcept}
        />

        <main className="main">
          {/* 개념 설명 뷰 */}
          {viewMode === 'concept' && (
            <ConceptPage chapter={currentConceptChapter} />
          )}

          {/* 문제 풀이 뷰 */}
          {viewMode === 'problem' && (
            <>
              <ProblemPanel problem={currentProblem} />
              <SqlEditor
                value={sql}
                onChange={setSql}
                onRun={handleRun}
                onSubmit={handleSubmit}
                onHint={handleHint}
                onAnswer={handleAnswer}
                onReset={handleReset}
              />
              <ResultPanel
                runResult={runResult}
                gradeResult={gradeResult}
                activeTab={activeTab}
                onTabChange={setActiveTab}
              />
            </>
          )}

          {/* 초기 웰컴 화면 */}
          {viewMode === 'welcome' && (
            <div className="welcome-screen">
              <div className="welcome-icon">🗄️</div>
              <div className="welcome-title">SQL Playground</div>
              <div className="welcome-desc">
                왼쪽 사이드바에서 챕터를 선택하세요.<br />
                <strong>📖 개념 설명</strong>으로 개념을 먼저 익히고,<br />
                문제를 풀어보세요!
              </div>
              <div className="welcome-stats">
                <div className="ws-item"><span className="ws-num">{total}</span><span>총 문제</span></div>
                <div className="ws-item"><span className="ws-num">{solved}</span><span>해결</span></div>
                <div className="ws-item"><span className="ws-num">{total - solved}</span><span>남은 문제</span></div>
              </div>
            </div>
          )}
        </main>

        <SchemaPanel schema={schema} />
      </div>

      {hintVisible && (
        <HintModal hint={currentProblem?.hint} onClose={() => setHintVisible(false)} />
      )}
    </>
  );
}
