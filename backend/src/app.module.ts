import { Module } from "@nestjs/common";
import { TypeOrmModule } from '@nestjs/typeorm';

import { ExercisesModule } from "./modules/exercises/excercise.module";
import { SessionModule } from "./modules/session/session.module";
import { QuestionSetModule } from "./modules/question-set/question-set.module";
import { ChoicesModule } from "./modules/choices/choices.module";
import { UploadModule } from "./modules/upload/upload.module";

import { Session } from './modules/session/entities/session.entity';
import { Exercise } from './modules/exercises/entities/exercise.entity';
import { QuestionSet } from './modules/question-set/entities/question-set.entity';
import { Choices } from "./modules/choices/entities/choices.entity";



@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: 'src/database/exercises.db',
      entities: [Session, Exercise, QuestionSet, Choices],
      synchronize: true,
    }),
    ExercisesModule,
    SessionModule,
    QuestionSetModule,
    ChoicesModule,
    UploadModule,
  ],
})
export class AppModule {}