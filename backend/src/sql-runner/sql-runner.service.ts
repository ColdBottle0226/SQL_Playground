import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

// 학습용 DB에서 허용할 읽기 전용 키워드
const ALLOWED_START = ['SELECT', 'WITH', 'SHOW', 'DESCRIBE', 'EXPLAIN'];

function isSafeQuery(sql: string): boolean {
  const upper = sql.trim().toUpperCase();
  return ALLOWED_START.some((kw) => upper.startsWith(kw));
}

@Injectable()
export class SqlRunnerService {
  constructor(@InjectDataSource() private dataSource: DataSource) {}

  async runSql(sql: string) {
    if (!sql?.trim()) throw new BadRequestException('SQL을 입력해주세요.');
    if (!isSafeQuery(sql))
      throw new BadRequestException('SELECT 또는 WITH 구문만 실행할 수 있습니다.');

    try {
      const manager = this.dataSource.createQueryRunner();
      await manager.connect();
      const result = await manager.query(sql);
      await manager.release();

      if (!Array.isArray(result) || result.length === 0) {
        return { columns: [], rows: [], rowCount: 0 };
      }
      const columns = Object.keys(result[0]);
      return { columns, rows: result, rowCount: result.length };
    } catch (e) {
      throw new BadRequestException(e.message);
    }
  }

  async gradeSql(userSql: string, answerSql: string) {
    if (!isSafeQuery(userSql))
      throw new BadRequestException('SELECT 구문만 실행할 수 있습니다.');

    const runner1 = this.dataSource.createQueryRunner();
    const runner2 = this.dataSource.createQueryRunner();
    await runner1.connect();
    await runner2.connect();
    try {
      const userRows = await runner1.query(userSql);
      const ansRows = await runner2.query(answerSql);

      const toStr = (rows: any[]) =>
        JSON.stringify(
          rows.map((r) =>
            Object.values(r).map((v) => (v === null ? null : String(v))),
          ),
        );

      const passed = toStr(userRows) === toStr(ansRows);
      return {
        passed,
        userRows,
        ansRows,
        userCount: userRows.length,
        ansCount: ansRows.length,
      };
    } catch (e) {
      throw new BadRequestException(e.message);
    } finally {
      await runner1.release();
      await runner2.release();
    }
  }
}
