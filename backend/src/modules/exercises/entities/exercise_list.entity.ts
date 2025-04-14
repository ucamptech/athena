import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { Exercise } from './exercise.entity'

@Entity()
export class ExerciseList {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userID: string;

  @Column()
  loginDate: string;

  @Column({ nullable: true })
  accumulatedSessionScore: number;

  @OneToMany(() => Exercise, (exercise) => exercise.exerciseList, {
    eager: true,
  })
  exercises: Exercise[];
}
