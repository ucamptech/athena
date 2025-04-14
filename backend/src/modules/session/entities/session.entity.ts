import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { Exercise } from '../../exercises/entities/exercise.entity'

@Entity()
export class Session {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userID: string;

  @Column()
  loginDate: string;

  @Column({ nullable: true })
  accumulatedSessionScore: number;

  @OneToMany(() => Exercise, (exercise) => exercise.exerciseSession, {
    cascade: true,
  })
  exerciseList: Exercise[];
}
