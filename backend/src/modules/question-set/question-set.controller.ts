import { Body, Controller, Post, Get, Param} from '@nestjs/common';
import { QuestionSet as QuestionSetDto } from './dto/question-set.dto';
import { QuestionSetService } from './question-set.service';

@Controller("question-set")
export class QuestionSetController {
  constructor(private readonly questionSetService: QuestionSetService) {}

  @Post()
  async createQuestionSet(@Body() questionSetDto: QuestionSetDto) {
    return this.questionSetService.createQuestionSet(questionSetDto);
  }

  @Get()
  async getAllQuestionSet() {
        return this.questionSetService.getAllQuestionSet();
  } 

  @Get(':questionID')
   async getQuestionSet(@Param('questionID') questionID: string){
         return this.questionSetService.getQuestionSet(questionID);
     }
}