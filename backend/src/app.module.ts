import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProblemsModule } from './problems/problems.module';
import { SqlRunnerModule } from './sql-runner/sql-runner.module';
import { SchemaModule } from './schema/schema.module';
import { Chapter } from './problems/chapter.entity';
import { Problem } from './problems/problem.entity';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'mysql',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '3306'),
      username: process.env.DB_USER || 'playground',
      password: process.env.DB_PASSWORD || 'playground1234',
      database: process.env.DB_NAME || 'sql_playground',
      entities: [Chapter, Problem],
      synchronize: false,
      charset: 'utf8mb4',
      retryAttempts: 10,
      retryDelay: 3000,
    }),
    ProblemsModule,
    SqlRunnerModule,
    SchemaModule,
  ],
})
export class AppModule {}
