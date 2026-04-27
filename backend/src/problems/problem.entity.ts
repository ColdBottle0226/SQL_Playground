import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { Chapter } from './chapter.entity';

@Entity('problems')
export class Problem {
  @PrimaryGeneratedColumn()
  problem_id: number;

  @Column()
  chapter_id: number;

  @Column()
  title: string;

  @Column()
  difficulty: 'easy' | 'medium' | 'hard';

  @Column({ nullable: true })
  concept: string;

  @Column('text', { nullable: true })
  description: string;

  @Column('text', { nullable: true })
  hint: string;

  @Column('text')
  answer_sql: string;

  @Column('text', { nullable: true })
  concept_explain: string;

  @Column()
  sort_order: number;

  @ManyToOne(() => Chapter, (c) => c.problems)
  @JoinColumn({ name: 'chapter_id' })
  chapter: Chapter;
}
