import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { QuestionSet } from '../../question-set/entities/question-set.entity';

@Entity()
export class Choices {
@PrimaryGeneratedColumn()
id: number;

@Column({ nullable: false })
choiceID: string;

@Column({ nullable: true })
image: string;

@Column()
name: string;

@Column()
audio: string;

@ManyToOne(() => QuestionSet, (questionSet) => questionSet.options)
options: QuestionSet;

@ManyToOne(() => QuestionSet, (questionSet) => questionSet.options)
correctAnswer: QuestionSet;

}