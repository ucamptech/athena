import { Injectable } from '@nestjs/common';
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
    return this.choicesRepository.find();
  }

  async getChoices(choiceID : string) {
    return this.choicesRepository.findOne({ 
      where: { choiceID }, 
  });
  }
}