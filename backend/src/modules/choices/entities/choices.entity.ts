import { Entity, PrimaryGeneratedColumn, Column, ManyToMany } from 'typeorm';
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

@Column({ nullable: true})
audio: string;

@ManyToMany(() => QuestionSet, (questionSet) => questionSet.options)
questionSetOption: QuestionSet;

@ManyToMany(() => QuestionSet, (questionSet) => questionSet.correctAnswer)
questionSetAnswer: QuestionSet;

}