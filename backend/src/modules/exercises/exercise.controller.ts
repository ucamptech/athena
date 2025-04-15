import { Body, Controller, Post, Get, Param, Patch, Delete} from '@nestjs/common';
import { ExerciseService } from './exercise.service';
import { Exercise as ExerciseDto } from './dto/exercise.dto';
@Controller("exercises")
export class ExerciseController {
  constructor(private readonly exercisesService: ExerciseService) {}

  @Post()
  async createExercises(@Body() exerciseDto: ExerciseDto) {
    return this.exercisesService.createExercises(exerciseDto);
  }

  @Get()
  async getAllExercises() {
        return this.exercisesService.getAllExercises();
  } 

  @Get(':exerciseID')
   async getExercise(@Param('exerciseID') exerciseID: string){
         return this.exercisesService.getExercises(exerciseID);
     }
  
  @Patch(':exerciseID')
  async patchExercises(@Param('exerciseID') exerciseID: string, @Body() exerciseDto: ExerciseDto){
        return this.exercisesService.patchExercises(exerciseID, exerciseDto);
    }
  
  @Delete(':exerciseID')
  async deleteExercises(@Param('exerciseID') exerciseID: string){
        return this.exercisesService.deleteExercise(exerciseID);
    }
}