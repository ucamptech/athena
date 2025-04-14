import { Module } from "@nestjs/common";
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExercisesModule } from "./modules/exercises/excercise.module";
import { ExerciseList } from './modules/exercises/entities/exercise_list.entity';
import { Exercise } from './modules/exercises/entities/exercise.entity';


@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: 'database/exercises.db',
      entities: [ExerciseList, Exercise],
      synchronize: true,
    }),
    ExercisesModule,
  ],
})
export class AppModule {}