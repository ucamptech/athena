import { Module } from "@nestjs/common";
import { ExerciseController } from "./exercise.controller";
import { ExerciseService } from "./exercise.service";
import { TypeOrmModule } from '@nestjs/typeorm';
import { Exercise as ExerciseEntity } from './entities/exercise.entity';


@Module({
  imports: [TypeOrmModule.forFeature([ExerciseEntity])],
  controllers: [ExerciseController],
  providers: [ExerciseService],
})
export class ExercisesModule {}