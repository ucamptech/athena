import { Module } from "@nestjs/common";
import { QuestionSetController } from "./question-set.controller";
import { QuestionSetService } from "./question-set.service";
import { TypeOrmModule } from '@nestjs/typeorm';
import { QuestionSet as QuestionSetEntity } from './entities/question-set.entity';


@Module({
  imports: [TypeOrmModule.forFeature([QuestionSetEntity])],
  controllers: [QuestionSetController],
  providers: [QuestionSetService],
})
export class QuestionSetModule {}