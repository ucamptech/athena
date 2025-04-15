import { Entity, PrimaryGeneratedColumn, Column, ManyToMany, ManyToOne, JoinTable } from 'typeorm';
import { Session } from '../../session/entities/session.entity'
import { QuestionSet } from 'src/modules/question-set/entities/question-set.entity';

@Entity()
export class Exercise {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  exerciseID: string;
  
  @ManyToMany(() => QuestionSet,(questionSet) => questionSet.exercise, {
     nullable: false,   
  })
  @JoinTable({ name: 'questionSet'})
  questionSet: QuestionSet[];

  @Column({ nullable: true })
  result: 'correct' | 'incorrect';

  @Column()
  timeActivityIsDisplayed: string;

  @Column()
  timeUserIsActive: string;

  @ManyToOne(() => Session, (session) => session.exerciseList, { 
    nullable: true, 
  })
  exerciseSession: Session;
}