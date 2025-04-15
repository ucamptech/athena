import { Module } from "@nestjs/common";
import { ExerciseController } from "./exercise.controller";
import { ExerciseService } from "./exercise.service";
import { TypeOrmModule } from '@nestjs/typeorm';
import { Exercise as ExerciseEntity } from './entities/exercise.entity';
import { QuestionSet as QuestionSetEntity } from "../question-set/entities/question-set.entity";


@Module({
  imports: [TypeOrmModule.forFeature([ExerciseEntity, QuestionSetEntity])],
  controllers: [ExerciseController],
  providers: [ExerciseService],
})
export class ExercisesModule {}