import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Session as SessionEntity } from './entities/session.entity';
import { Session as SessionDto } from './dto/session.dto';
@Injectable()
export class SessionService{

    constructor(
        @InjectRepository(SessionEntity)
        private readonly sessionRepository : Repository<SessionEntity>,
    ){}

    async createSession (data: SessionDto) {
    //Create session
        const session = this.sessionRepository.create({
            userID: data.userID,
            loginDate: data.loginDate,
            accumulatedSessionScore: data.accumulatedSessionScore,
            exerciseList: data.exerciseList,
        });

        await this.sessionRepository.save(session);
        return { message: "Session created successfully", data: session };
    }

    async getAllSession(){
        return this.sessionRepository.find({ 
            relations:['exerciseList'] 
        });
    }

    async getSession (userID: string) {

        return this.sessionRepository.find({ 
            where: { userID }, 
            relations: ['exerciseList'],
        });

    }   
}