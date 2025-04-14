import { Entity, PrimaryGeneratedColumn, Column, JoinColumn, OneToMany } from 'typeorm';
import { Choices } from '../../choices/entities/choices.entity'

@Entity()
export class QuestionSet {
  @PrimaryGeneratedColumn()
  id: number;
  
  @Column({ nullable: false })
  questionID: string;
  
  @Column({ nullable: true })
  question: string;

  @OneToMany(() => Choices, (choices) => choices.options, {
    cascade: true,
  })
  @JoinColumn({ name: 'options'})
  options: Choices[];

  @OneToMany(() => Choices, (choices) => choices.correctAnswer, {
    cascade: true,
  })
  @JoinColumn({ name: 'correctAnswer'})
  correctAnswer: Choices[];

}