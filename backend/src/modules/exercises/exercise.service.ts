import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ExerciseList as ExerciseListDto, Exercise as ExerciseDto }  from './dto/exercise.dto';
import { ExerciseList } from './entities/exercise_list.entity';
import { Exercise } from './entities/exercise.entity';


@Injectable()
export class ExerciseService {
  constructor(
    @InjectRepository(ExerciseList)
    private readonly exerciseListRepository: Repository<ExerciseList>,
    @InjectRepository(Exercise)
    private readonly exerciseRepository: Repository<Exercise>,
  ) {}

  async createExercises(data: ExerciseListDto) {

    const exercisesData = data.exercises || [];

    const exerciseList = this.exerciseListRepository.create({
      userID: data.userID,
      loginDate: data.loginDate,
      accumulatedSessionScore: data.accumulatedSessionScore,
    });
    
    await this.exerciseListRepository.save(exerciseList);

    if (exercisesData.length > 0) {
        const exercises = exercisesData.map((exercise) =>
          this.exerciseRepository.create({ ...exercise, exerciseList })
        );

          await this.exerciseRepository.save(exercises);
      }

    return { message: "Exercise data created successfully" };
  }

  async getExercises() {
    return this.exerciseListRepository.find({ relations: ['exercises'] });
  }
}