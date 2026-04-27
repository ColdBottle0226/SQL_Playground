import { Entity, PrimaryColumn, Column, OneToMany } from 'typeorm';
import { Problem } from './problem.entity';

@Entity('chapters')
export class Chapter {
  @PrimaryColumn()
  chapter_id: number;

  @Column()
  chapter_title: string;

  @Column({ type: 'longtext', nullable: true })
  concept_content: string;

  @Column()
  sort_order: number;

  @OneToMany(() => Problem, (p) => p.chapter)
  problems: Problem[];
}
