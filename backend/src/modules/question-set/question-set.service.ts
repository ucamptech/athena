import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { QuestionSet as QuestionSetEntity } from './entities/question-set.entity';
import { QuestionSet as QuestionSetDto} from './dto/question-set.dto';
import { Choices as ChoicesEntity } from '../choices/entities/choices.entity';

@Injectable()
export class QuestionSetService {
  constructor(
    @InjectRepository(QuestionSetEntity)
    private readonly questionSetRepository: Repository<QuestionSetEntity>,
    @InjectRepository(ChoicesEntity)
    private readonly choicesRepository: Repository<ChoicesEntity>,
  ) {}

  async createQuestionSet(data: QuestionSetDto) {
    if (!data) {
        throw new BadRequestException('Question Set data is required');
    }    
    const questionSet = this.questionSetRepository.create({
      questionID: data.questionID,
      question: data.question,
      questionImage: data.questionImage,
      questionAudio: data.questionAudio,
  });

    if(data.options && data.options.length > 0){

      const options = await this.choicesRepository.find({
        where: { choiceID: In(data.options) },
      });
  
      questionSet.options = options;

    }


    if(data.correctAnswer && data.correctAnswer.length > 0){

      const correctAnswer = await this.choicesRepository.find({
        where: { choiceID: In(data.correctAnswer) },
      })

      questionSet.correctAnswer = correctAnswer;

    }

    await this.questionSetRepository.save(questionSet);

    return { message: "Question Set created successfully", data: questionSet };
  }

  async getAllQuestionSet(){
      const questionSet = await this.questionSetRepository.find({
         relations: ['options','correctAnswer'],
      });
      
      if(!questionSet || questionSet.length === 0){
        throw new NotFoundException(`No Question Set Data found`);
      }

      return questionSet;
  }

  async getQuestionSet(questionID : string) {
    const questionSet = await this.questionSetRepository.findOne({ 
      where: { questionID }, 
      relations: ['options','correctAnswer'],
    });

    if(!questionSet){
      throw new NotFoundException(`Question Set with ID ${questionID} not found`);
    }

    return questionSet;
  }

  async patchQuestionSet(questionID: string, data: Partial<QuestionSetDto>){

    const questionSet = await this.questionSetRepository.findOne({
      where: {questionID},
      relations: ['options','correctAnswer'],
    });

    if(!questionSet){
      throw new NotFoundException(`Question Set with ID ${questionID} not found`);
    }

    Object.assign(questionSet,data);
    
    if(data.options) {

      const optionIDs = data.options?.map(opt => opt) ?? [];
      const options = await this.choicesRepository.find({
        where: { choiceID: In(optionIDs) },
      });

      questionSet.options = options;
    }

    if(data.correctAnswer){
      const correctAnswerIDs = data.correctAnswer?.map(ans => ans) ?? [];
      const correctAnswer = await this.choicesRepository.find({
        where: { choiceID: In(correctAnswerIDs) },
      })

      questionSet.correctAnswer = correctAnswer;
    } 


    await this.questionSetRepository.save(questionSet);
    
    return { message: `Question Set ${questionID} updated successfully`, data: questionSet };
  }

  async deleteQuestionSet(questionID: string) {
    const questionSet = await this.questionSetRepository.findOne({
      where: { questionID },
      relations: ['options','correctAnswer'],
    });
  
    if (!questionSet) {
      throw new NotFoundException(`Question Set with ID ${questionID} not found`);
    }
  
    await this.questionSetRepository.remove(questionSet);
    return { message: `Question Set ${questionID} deleted successfully` };
  }

}