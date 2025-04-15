import { Body, Controller, Post, Get, Param, Patch, Delete} from '@nestjs/common';
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

    
  @Patch(':questionID')
  async patchQuestionSet(@Param('questionID') questionID: string, @Body() questionSetDto: QuestionSetDto){
        return this.questionSetService.patchQuestionSet(questionID,questionSetDto);
  }
  
  @Delete(':questionID')
  async deleteQuestionSet(@Param('questionID') questionID: string){
        return this.questionSetService.deleteQuestionSet(questionID);
  }
}