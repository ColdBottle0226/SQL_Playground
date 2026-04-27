import { Injectable } from '@nestjs/common';
import { InjectDataSource } from '@nestjs/typeorm';
import { DataSource } from 'typeorm';

// 문제 관리용 테이블은 스키마 조회에서 제외
const EXCLUDED_TABLES = new Set(['chapters', 'problems']);

// 기초 문제용 테이블
const BASIC_TABLES = new Set([
  'departments', 'employees', 'products',
  'orders', 'order_items', 'salary_history',
]);

// 심화 문제용 테이블
const ADVANCED_TABLES = new Set([
  'member_grades', 'members', 'point_history',
  'coupon_policies', 'issued_coupons',
  'adv_categories', 'adv_products',
  'adv_orders', 'adv_order_items',
  'deliveries', 'reviews', 'stock_history', 'monthly_sales',
]);

@Injectable()
export class SchemaService {
  constructor(@InjectDataSource() private dataSource: DataSource) {}

  async getSchema() {
    const runner = this.dataSource.createQueryRunner();
    await runner.connect();
    try {
      const tables: any[] = await runner.query('SHOW TABLES');
      const basic: Record<string, any[]>    = {};
      const advanced: Record<string, any[]> = {};

      for (const row of tables) {
        const tbl: string = Object.values(row)[0] as string;
        if (EXCLUDED_TABLES.has(tbl)) continue;

        const cols = await runner.query(`DESCRIBE ${tbl}`);

        if (BASIC_TABLES.has(tbl))    basic[tbl]    = cols;
        else if (ADVANCED_TABLES.has(tbl)) advanced[tbl] = cols;
      }

      return { basic, advanced };
    } finally {
      await runner.release();
    }
  }
}
