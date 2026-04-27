import { Module } from '@nestjs/common';
import { SqlRunnerService } from './sql-runner.service';
import { SqlRunnerController } from './sql-runner.controller';

@Module({
  controllers: [SqlRunnerController],
  providers: [SqlRunnerService],
})
export class SqlRunnerModule {}
