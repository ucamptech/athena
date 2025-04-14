import { Body, Controller, Post, Get} from '@nestjs/common';
import { ExerciseList as ExerciseListDto  } from '../exercises/dto/exercise.dto';
import { ExerciseService } from './exercise.service';

@Controller("exercises")
export class ExerciseController {
  constructor(private readonly exercisesService: ExerciseService) {}

  @Post()
  async createExercises(@Body() exerciseListDto: ExerciseListDto) {
    return this.exercisesService.createExercises(exerciseListDto);
  }

  @Get()
  getExercise() {
    return this.exercisesService.getExercises();
  }
}