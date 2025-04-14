import { Module } from "@nestjs/common";
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExercisesModule } from "./modules/exercises/excercise.module";
import { SessionModule } from "./modules/session/session.module";
import { Session } from './modules/session/entities/session.entity';
import { Exercise } from './modules/exercises/entities/exercise.entity';


@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: 'src/database/exercises.db',
      entities: [Session, Exercise],
      synchronize: true,
    }),
    ExercisesModule,
    SessionModule,
  ],
})
export class AppModule {}