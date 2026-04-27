import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Chapter } from './chapter.entity';
import { Problem } from './problem.entity';

@Injectable()
export class ProblemsService {
  constructor(
    @InjectRepository(Chapter)
    private chapterRepo: Repository<Chapter>,
    @InjectRepository(Problem)
    private problemRepo: Repository<Problem>,
  ) {}

  async findAllChapters() {
    return this.chapterRepo.find({ order: { sort_order: 'ASC' } });
  }

  async findAllProblems() {
    const problems = await this.problemRepo.find({
      order: { chapter_id: 'ASC', sort_order: 'ASC' },
    });
    return problems;
  }

  async findOneProblem(id: number) {
    return this.problemRepo.findOne({ where: { problem_id: id } });
  }

  async findProblemsByChapter(chapterId: number) {
    return this.problemRepo.find({
      where: { chapter_id: chapterId },
      order: { sort_order: 'ASC' },
    });
  }
}
