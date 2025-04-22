import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Exercise as ExerciseEntity } from './entities/exercise.entity';
import { Exercise as ExerciseDto} from './dto/exercise.dto';
import { QuestionSet as QuestionSetEntity } from '../question-set/entities/question-set.entity';

@Injectable()
export class ExerciseService {
  constructor(
    @InjectRepository(ExerciseEntity)
    private readonly exerciseRepository: Repository<ExerciseEntity>,
    @InjectRepository(QuestionSetEntity)
    private readonly questionSetRepository: Repository<QuestionSetEntity>,
  ) {}

  async createExercises(data: ExerciseDto) {
    if (!data) {
        throw new BadRequestException('Exercise data is required');
    }
    const exercise = this.exerciseRepository.create({
      exerciseID: data.exerciseID,
  });
  
    if(data.questionSet){

      const questionSet = await this.questionSetRepository.findOne({
         where: { questionID: In(data.questionSet) },
      });

      if(!questionSet){
        throw new NotFoundException(`No Question Set found`);
      }

     exercise.questionSet = questionSet;

    }


    await this.exerciseRepository.save(exercise);

    return { message: "Exercise created successfully", data: exercise };
  }

  async getAllExercises(){
    const exercise = await this.exerciseRepository.find({
      relations: ['exerciseSession', 'questionSet', 'questionSet.options','questionSet.correctAnswer']
    });

    if(!exercise || exercise.length === 0){
      throw new NotFoundException(`No Exercises data found`);
    }

    return exercise;
  }

  async getExercises(exerciseID : string) {
    const exercise = await this.exerciseRepository.findOne({ 
      where: { exerciseID }, 
      relations: ['exerciseSession', 'questionSet', 'questionSet.options','questionSet.correctAnswer'],
    });

    if(!exercise){
      throw new NotFoundException(`Exercise with ID ${exerciseID} not found`);
    }

    return exercise;
  }
  
  async deleteExercise(exerciseID: string) {
    const exercise = await this.exerciseRepository.findOne({
      where: { exerciseID },
      relations: ['exerciseSession', 'questionSet'],
    });
  
    if (!exercise) {
      throw new NotFoundException(`Exercise with ID ${exerciseID} not found`);
    }
  
    await this.exerciseRepository.remove(exercise);
    return { message: `Exercise ${exerciseID} deleted successfully` };
  }

  async patchExercises(exerciseID: string, data: Partial<ExerciseDto>){

    const exercise = await this.exerciseRepository.findOne({
      where: {exerciseID},
      relations: ['exerciseSession', 'questionSet'],
    });

    if(!exercise){
      throw new NotFoundException(`Exercise with ID ${exerciseID} not found`);
    }

    Object.assign(exercise,data);
    
    if(data.questionSet){
      const questionSet = await this.questionSetRepository.findOne({
        where: { questionID: In(data.questionSet) },
      })

      exercise.questionSet = questionSet;
    } 

    await this.exerciseRepository.save(exercise);

    return { message: `Exercise ${exerciseID} updated successfully`, data: exercise };
  }
}