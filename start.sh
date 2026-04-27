#!/bin/bash
set -e

echo "🚀 SQL Playground (React + NestJS + MySQL) 시작 중..."
echo ""

# Docker 실행 여부 확인
if ! docker info > /dev/null 2>&1; then
  echo "❌ Docker가 실행 중이지 않습니다. Docker Desktop을 먼저 실행하세요."
  exit 1
fi

# 빌드 & 실행
docker-compose up -d --build

echo ""
echo "⏳ 서비스 초기화 대기 중..."

# 프론트엔드 헬스체크 (최대 120초)
for i in $(seq 1 24); do
  if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ 모든 서비스 준비 완료!"
    break
  fi
  echo -n "."
  sleep 5
done

echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ SQL Playground 실행 완료!"
echo ""
echo "  🌐 웹:     http://localhost:3000"
echo "  🔧 API:    http://localhost:4000/api"
echo "  🗄  MySQL: localhost:3306"
echo ""
echo "  종료: docker-compose down"
echo "  로그: docker-compose logs -f"
echo "════════════════════════════════════════════════"
