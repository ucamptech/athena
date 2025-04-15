import { Module } from "@nestjs/common";
import { SessionController } from './session.controller';
import { SessionService } from './session.service';
import { TypeOrmModule } from "@nestjs/typeorm";
import { Session as SessionEntity } from './entities/session.entity';
import { Exercise as ExerciseEntity } from '../exercises/entities/exercise.entity';


@Module({
    imports: [TypeOrmModule.forFeature([SessionEntity,ExerciseEntity])],
    controllers: [SessionController],
    providers: [SessionService],
})

export class SessionModule {}