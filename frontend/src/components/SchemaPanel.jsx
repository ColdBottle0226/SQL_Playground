import React, { useState } from 'react';

function typeShort(type = '') {
  if (type.startsWith('int') || type.startsWith('decimal') || type.startsWith('bigint') || type.startsWith('tinyint')) return 'NUM';
  if (type.startsWith('varchar') || type.startsWith('char') || type.startsWith('text')) return 'STR';
  if (type.startsWith('date') || type.startsWith('datetime')) return 'DATE';
  if (type.startsWith('enum')) return 'ENUM';
  return type.substring(0, 6).toUpperCase();
}

function TableGroup({ label, tables, openState, toggle }) {
  return (
    <>
      <div className="schema-section-header">{label}</div>
      {Object.entries(tables).map(([tbl, cols]) => (
        <div key={tbl} className="schema-table">
          <div className="schema-table-name" onClick={() => toggle(tbl)}>
            <span>📋 {tbl}</span>
            <span style={{ color: 'var(--muted)', fontSize: 10 }}>
              {openState[tbl] ? '▴' : '▾'}
            </span>
          </div>
          {openState[tbl] && (
            <div className="schema-cols">
              {cols.map((col) => (
                <div key={col.Field} className="schema-col">
                  <span>{col.Field}{col.Key === 'PRI' ? ' 🔑' : col.Key === 'MUL' ? ' 🔗' : ''}</span>
                  <span className="col-type">{typeShort(col.Type)}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      ))}
    </>
  );
}

export default function SchemaPanel({ schema }) {
  const [open, setOpen] = useState({});
  const toggle = (tbl) => setOpen((prev) => ({ ...prev, [tbl]: !prev[tbl] }));

  // 구버전 호환 (flat object) 또는 신버전 {basic, advanced}
  const basic    = schema?.basic    ?? (schema && !schema.advanced ? schema : {});
  const advanced = schema?.advanced ?? {};

  const hasBasic    = Object.keys(basic).length > 0;
  const hasAdvanced = Object.keys(advanced).length > 0;

  return (
    <aside className="schema-panel">
      <div className="schema-header">🗂 테이블 스키마</div>
      <div className="schema-list">
        {!hasBasic && !hasAdvanced && (
          <div style={{ padding: 16, color: 'var(--muted)', fontSize: 12 }}>로딩 중...</div>
        )}
        {hasBasic && (
          <TableGroup
            label="📗 기초 테이블"
            tables={basic}
            openState={open}
            toggle={toggle}
          />
        )}
        {hasAdvanced && (
          <TableGroup
            label="📕 심화 테이블"
            tables={advanced}
            openState={open}
            toggle={toggle}
          />
        )}
      </div>
    </aside>
  );
}
