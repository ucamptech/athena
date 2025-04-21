import { Entity, PrimaryGeneratedColumn, Column, JoinTable, ManyToMany, OneToMany } from 'typeorm';
import { Choices } from '../../choices/entities/choices.entity'
import { Exercise } from '../../exercises/entities/exercise.entity';

@Entity()
export class QuestionSet {
  @PrimaryGeneratedColumn()
  id: number;
  
  @Column({ nullable: false })
  questionID: string;
  
  @Column({ nullable: true })
  question: string;

  @Column({ nullable: true })
  questionImage: string;

  @Column({ nullable: false})
  questionAudio: string;
  
  @ManyToMany(() => Choices, (choices) => choices.questionSetOption, {
    cascade: true,
  })
  @JoinTable({ name: 'options'})
  options: Choices[];

  @ManyToMany(() => Choices, (choices) => choices.questionSetAnswer, {
    cascade: true,
  })
  @JoinTable({ name: 'correctAnswer'})
  correctAnswer: Choices[];

  @OneToMany(() => Exercise, (exercise) => exercise.questionSet)
  exerciseLink: Exercise[];
}