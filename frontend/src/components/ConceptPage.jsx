import React from 'react';

export default function ConceptPage({ chapter }) {
  if (!chapter) return null;

  return (
    <div className="concept-page-wrap">
      <div
        className="concept-page-content"
        dangerouslySetInnerHTML={{ __html: chapter.concept_content || '<p>개념 설명을 불러오는 중...</p>' }}
      />
    </div>
  );
}
