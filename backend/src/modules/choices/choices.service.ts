import { BadRequestException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Choices as ChoicesEntity } from './entities/choices.entity';
import { Choices as ChoicesDto} from './dto/choices.dto';

@Injectable()
export class ChoicesService {
  constructor(
    @InjectRepository(ChoicesEntity)
    private readonly choicesRepository: Repository<ChoicesEntity>,
  ) {}

  async createChoices(data: ChoicesDto) {
    if (!data) {
        throw new BadRequestException('Choices data is required');
    }
    const choices = this.choicesRepository.create({
      choiceID: data.choiceID,
      image: data.image,
      name: data.name,
      audio: data.audio,
  });
  
    await this.choicesRepository.save(choices);

    return { message: "Choices created successfully", data: choices };
  }

  async getAllChoices(){
    const choices = await this.choicesRepository.find();

    if(!choices || choices.length === 0){
      throw new NotFoundException('No choices found');
    }

    return choices;
  }

  async getChoices(choiceID : string) {
    const choice = await this.choicesRepository.findOne({ 
      where: { choiceID }, 
    });

    if(!choice){
      throw new NotFoundException(`Choice with ID ${choiceID} not found`);
    }

    return choice;
  }

  async patchChoice(choiceID: string, data: Partial<ChoicesDto>){

    const choice = await this.choicesRepository.findOne({
      where: {choiceID},
    });

    if(!choice){
      throw new NotFoundException(`Choice with ID ${choiceID} not found`);
    }

    Object.assign(choice,data);
    
    await this.choicesRepository.save(choice);

    return { message: `Choice ${choiceID} updated successfully`, data: choice };
  }

  async deleteChoice(choiceID: string) {
    const choice = await this.choicesRepository.findOne({
      where: { choiceID },
    });
  
    if (!choice) {
      throw new NotFoundException(`Choice with ID ${choiceID} not found`);
    }
  
    await this.choicesRepository.remove(choice);
    return { message: `Choice ${choiceID} deleted successfully` };
  }
  
}