import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { Session } from '../../session/entities/session.entity'
import { QuestionSet } from 'src/modules/question-set/entities/question-set.entity';

@Entity()
export class Exercise {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  exerciseID: string;
  
  @ManyToOne(() => QuestionSet,(questionSet) => questionSet.exerciseLink, {
    cascade: true,  
  })
  questionSet: QuestionSet;

  @Column({ nullable: true })
  result: 'correct' | 'incorrect';

  @Column({ nullable: true })
  timeActivityIsDisplayed: string;

  @Column({ nullable: true })
  timeUserIsActive: string;

  @ManyToOne(() => Session, (session) => session.exerciseList)
  exerciseSession: Session;
}