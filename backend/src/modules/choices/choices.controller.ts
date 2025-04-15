import { Body, Controller, Post, Get, Param, Delete, Patch} from '@nestjs/common';
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

  @Patch(':choicesID')
  async patchChoice(@Param('choicesID') choicesID: string, @Body() choicesDto: ChoicesDto){
        return this.choicesService.patchChoice(choicesID, choicesDto);
    }

  @Delete(':choicesID')
   async deleteChoice(@Param('choicesID') choicesID: string){
         return this.choicesService.deleteChoice(choicesID);
     }

}