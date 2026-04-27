import { Controller, Post, Body, HttpCode } from '@nestjs/common';
import { SqlRunnerService } from './sql-runner.service';

class RunDto {
  sql: string;
}

class GradeDto {
  userSql: string;
  answerSql: string;
}

@Controller()
export class SqlRunnerController {
  constructor(private readonly sqlRunnerService: SqlRunnerService) {}

  @Post('run')
  @HttpCode(200)
  run(@Body() body: RunDto) {
    return this.sqlRunnerService.runSql(body.sql);
  }

  @Post('grade')
  @HttpCode(200)
  grade(@Body() body: GradeDto) {
    return this.sqlRunnerService.gradeSql(body.userSql, body.answerSql);
  }
}
