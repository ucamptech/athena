import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { QuestionSet as QuestionSetEntity } from './entities/question-set.entity';
import { QuestionSet as QuestionSetDto} from './dto/question-set.dto';
import { Choices as ChoicesEntity } from '../choices/entities/choices.entity'

@Injectable()
export class QuestionSetService {
  constructor(
    @InjectRepository(QuestionSetEntity)
    private readonly questionSetRepository: Repository<QuestionSetEntity>,
    @InjectRepository(ChoicesEntity)
    private readonly choicesRepository: Repository<ChoicesEntity>,
  ) {}

  async createQuestionSet(data: QuestionSetDto) {

    const questionSet = this.questionSetRepository.create({
      questionID: data.questionID,
      question: data.question,
      questionAudio: data.questionAudio,
  });

    const options = await this.choicesRepository.find({
      where: { id: In(data.options) },
    });

    const correctAnswer = await this.choicesRepository.find({
      where: { id: In(data.correctAnswer) },
  })

    questionSet.options = options;
    questionSet.correctAnswer = correctAnswer;

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