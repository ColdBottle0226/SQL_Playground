import { Controller, Get, Param, ParseIntPipe } from '@nestjs/common';
import { ProblemsService } from './problems.service';

@Controller()
export class ProblemsController {
  constructor(private readonly problemsService: ProblemsService) {}

  @Get('chapters')
  getChapters() {
    return this.problemsService.findAllChapters();
  }

  @Get('problems')
  getProblems() {
    return this.problemsService.findAllProblems();
  }

  @Get('problems/:id')
  getProblem(@Param('id', ParseIntPipe) id: number) {
    return this.problemsService.findOneProblem(id);
  }

  @Get('chapters/:id/problems')
  getProblemsByChapter(@Param('id', ParseIntPipe) id: number) {
    return this.problemsService.findProblemsByChapter(id);
  }

  @Get('health')
  health() {
    return { ok: true };
  }
}
