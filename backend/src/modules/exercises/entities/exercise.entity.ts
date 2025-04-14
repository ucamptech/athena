import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { ExerciseList } from './exercise_list.entity'

@Entity()
export class Exercise {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  exerciseID: string;
  
  @Column({ nullable: true })
  assets: string;

  @Column({ nullable: true })
  result: 'correct' | 'incorrect';

  @Column()
  timeActivityIsDisplayed: string;

  @Column()
  timeUserIsActive: string;

  @ManyToOne(() => ExerciseList, (exerciseList) => exerciseList.exercises, { nullable: true })
  exerciseList: ExerciseList;
}