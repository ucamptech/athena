import { Body, Controller, Post, Get, Param} from '@nestjs/common';
import { Choices as ChoicesDto } from './dto/choices.dto';
import { ChoicesService } from './choices.service';

@Controller("choices")
export class ChoicesController {
  constructor(private readonly choicesService: ChoicesService) {}

  @Post()
  async createChoices(@Body() choicesDto: ChoicesDto) {
    return this.choicesService.createChoices(choicesDto);
  }

  @Get()
  async getAllChoices() {
        return this.choicesService.getAllChoices();
  } 

  @Get(':choicesID')
   async getChoices(@Param('choicesID') choicesID: string){
         return this.choicesService.getChoices(choicesID);
     }
}