import { Entity, PrimaryGeneratedColumn, Column, ManyToOne } from 'typeorm';
import { Session } from '../../session/entities/session.entity'

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

  @ManyToOne(() => Session, (session) => session.exerciseList, { 
    nullable: true, 
  })
  exerciseSession: Session;
}