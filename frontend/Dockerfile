FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# ── Nginx 서빙 ──
FROM nginx:1.25-alpine AS runner

# 기본 nginx 설정 제거
RUN rm -f /etc/nginx/conf.d/default.conf

# 빌드 결과물 복사
COPY --from=builder /app/dist /usr/share/nginx/html

# 커스텀 nginx 설정 복사
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
