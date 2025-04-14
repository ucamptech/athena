import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { QuestionSet as QuestionSetEntity } from './entities/question-set.entity';
import { QuestionSet as QuestionSetDto} from './dto/question-set.dto';

@Injectable()
export class QuestionSetService {
  constructor(
    @InjectRepository(QuestionSetEntity)
    private readonly questionSetRepository: Repository<QuestionSetEntity>,
  ) {}

  async createQuestionSet(data: QuestionSetDto) {

    const questionSet = this.questionSetRepository.create({
      questionID: data.questionID,
      question: data.question,
      options: data.options,
      correctAnswer: data.correctAnswer,
  });
  
    await this.questionSetRepository.save(questionSet);

    return { message: "Question Set created successfully", data: questionSet };
  }

  async getAllQuestionSet(){
    return this.questionSetRepository.find({
      relations: ['options','correctAnswer'],
    });
  }

  async getQuestionSet(questionID : string) {
    return this.questionSetRepository.findOne({ 
      where: { questionID }, 
      relations: ['options','correctAnswer'],
  });
  }
}