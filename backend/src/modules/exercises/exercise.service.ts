import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Exercise as ExerciseEntity } from './entities/exercise.entity';
import { Exercise as ExerciseDto} from './dto/exercise.dto';

@Injectable()
export class ExerciseService {
  constructor(
    @InjectRepository(ExerciseEntity)
    private readonly exerciseRepository: Repository<ExerciseEntity>,
  ) {}

  async createExercises(data: ExerciseDto) {

    const exercise = this.exerciseRepository.create({
      exerciseID: data.exerciseID,
      assets: data.assets,
      result: data.result,
      timeActivityIsDisplayed: data.timeActivityIsDisplayed,
      timeUserIsActive: data.timeUserIsActive,
  });
  
    await this.exerciseRepository.save(exercise);

    return { message: "Exercise created successfully", data: exercise };
  }

  async getAllExercises(){
    return this.exerciseRepository.find({
      relations: ['exerciseSession'],
    });
  }

  async getExercises(exerciseID : string) {
    return this.exerciseRepository.findOne({ 
      where: { exerciseID }, 
      relations: ['exerciseSession'],
  });
  }
}