import { Module } from "@nestjs/common";
import { ExerciseController } from "./exercise.controller";
import { ExerciseService } from "./exercise.service";
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExerciseList } from './entities/exercise_list.entity';
import { Exercise } from './entities/exercise.entity';


@Module({
  imports: [TypeOrmModule.forFeature([ExerciseList,Exercise])],
  controllers: [ExerciseController],
  providers: [ExerciseService],
})
export class ExercisesModule {}