import { Module } from "@nestjs/common";
import { SessionController } from './session.controller';
import { SessionService } from './session.service';
import { TypeOrmModule } from "@nestjs/typeorm";
import { Session as SessionEntity } from './entities/session.entity';

@Module({
    imports: [TypeOrmModule.forFeature([SessionEntity])],
    controllers: [SessionController],
    providers: [SessionService],
})

export class SessionModule {}