<img width="1964" height="1442" alt="image" src="https://github.com/user-attachments/assets/3554b3fd-c7d9-4119-bd11-60a422d1824a" /># SQL Playground 🎯

> **실무 SQL 문제** — React + NestJS + MySQL 8.0

---
## Preview
1. 개념설명
<img width="2498" height="1474" alt="image" src="https://github.com/user-attachments/assets/6ea724ff-ed0c-435d-8e81-d98b530e68aa" />
<br/>
<br/>
2. 사이드 문제목록 및 풀이현황
<img width="524" height="1314" alt="image" src="https://github.com/user-attachments/assets/31c9f7e5-491a-43bd-a136-b0da9295bd05" />
<br/>
<br/>
3. 문제풀이 및 채점
<img width="1964" height="1442" alt="image" src="https://github.com/user-attachments/assets/c7c48600-32cd-47b0-b2ec-430edf597f8a" />



---
## 🗂 프로젝트 구조

```
sql-playground/
├── docker-compose.yml
├── start.sh
├── db/
│   └── init/
│       ├── 01_schema_and_data.sql   # 샘플 테이블 & 데이터
│       └── 02_problems.sql          # 챕터/문제 데이터 (MySQL 저장)
├── backend/                         # NestJS (TypeORM + MySQL)
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── problems/                # 문제/챕터 CRUD
│   │   ├── sql-runner/              # SQL 실행 & 채점
│   │   └── schema/                  # DB 스키마 조회
│   └── Dockerfile
└── frontend/                        # React + Vite
    ├── src/
    │   ├── App.jsx
    │   ├── api/index.js
    │   ├── hooks/usePlayground.js
    │   └── components/
    │       ├── Sidebar.jsx
    │       ├── ProblemPanel.jsx
    │       ├── SqlEditor.jsx
    │       ├── ResultPanel.jsx
    │       ├── SchemaPanel.jsx
    │       └── HintModal.jsx
    ├── nginx.conf
    └── Dockerfile
```

---

## 🚀 실행 방법

### Docker로 전체 실행 (권장)

```bash
chmod +x start.sh
./start.sh
```

→ http://localhost:3000 접속

### 로컬 개발 환경

```bash
# 1. DB만 Docker로 실행
docker-compose up mysql -d

# 2. 백엔드 개발 서버
cd backend && npm install && npm run start:dev

# 3. 프론트엔드 개발 서버
cd frontend && npm install && npm run dev
```

→ http://localhost:5173 접속 (Vite 개발 서버)

---

## 🔧 API 엔드포인트

| Method | Path | 설명 |
|--------|------|------|
| GET | /api/chapters | 챕터 목록 |
| GET | /api/problems | 전체 문제 목록 |
| GET | /api/problems/:id | 문제 단건 조회 |
| GET | /api/schema | DB 테이블 스키마 |
| POST | /api/run | SQL 실행 |
| POST | /api/grade | SQL 채점 |
| GET | /api/health | 헬스체크 |

---

## 🛠 직접 MySQL 접속

```bash
docker exec -it sql-playground-db mysql -u playground -pplayground1234 sql_playground
```

## 📌 단축키

- `Ctrl + Enter` — SQL 실행
- `Tab` — 들여쓰기 (2 spaces)

## 종료

```bash
docker-compose down
```
