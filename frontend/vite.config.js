import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  // 빌드 시 base를 '/'로 명시 → 절대 경로로 assets 참조
  base: '/',
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    // 청크 크기 경고 기준 상향
    chunkSizeWarningLimit: 1000,
  },
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:4000',
        changeOrigin: true,
      },
    },
  },
})
