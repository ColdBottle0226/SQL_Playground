import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ProblemsService } from './problems.service';
import { ProblemsController } from './problems.controller';
import { Chapter } from './chapter.entity';
import { Problem } from './problem.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Chapter, Problem])],
  controllers: [ProblemsController],
  providers: [ProblemsService],
})
export class ProblemsModule {}
