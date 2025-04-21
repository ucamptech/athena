import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Session as SessionEntity } from './entities/session.entity';
import { Session as SessionDto } from './dto/session.dto';
import { Exercise as ExerciseEntity } from '../exercises/entities/exercise.entity';

@Injectable()
export class SessionService{

    constructor(
        @InjectRepository(SessionEntity)
        private readonly sessionRepository : Repository<SessionEntity>,
        @InjectRepository(ExerciseEntity)
        private readonly exerciseRepository : Repository<ExerciseEntity>,
    ){}

    async createSession (data: SessionDto) {

        if (!data) {
            throw new BadRequestException('Session data is required');
        }

        const session = this.sessionRepository.create({
            userID: data.userID,
            loginDate: data.loginDate,
            accumulatedSessionScore: data.accumulatedSessionScore,
        });

        if(data.exerciseList || data.exerciseList.length > 0){

          const exercise = await this.exerciseRepository.find({
            where: { exerciseID: In(data.exerciseList) },
          });

          if(!exercise || exercise.length === 0){
              throw new NotFoundException(`Exercises not found`);
          }

          session.exerciseList = exercise;
        }

        await this.sessionRepository.save(session);
        
        return { message: `Session with user ${data.userID} created successfully`, data: session };
    }

    async getAllSession(){
        const session = await this.sessionRepository.find({ 
            relations:['exerciseList'] 
        });

        if(!session || session.length === 0){
            throw new NotFoundException(`No session data found`);
        }

        return session;
    }

    async getSession(userID: string) {
        const session = await this.sessionRepository.find({
          where: { userID },
          relations: ['exerciseList'],
        });
      
        if (!session || session.length === 0) {
          throw new NotFoundException(`No session for user ${userID} found`);
        }
      
        return session;
      }

      async patchSession(userID: string, data: Partial<SessionDto>){
    
        const session = await this.sessionRepository.findOne({
          where: {userID},
          relations: ['exerciseList'],
        });
    
        if(!session){
          throw new NotFoundException(`No session for user ${userID} found`);
        }
    
        Object.assign(session,data);
    
        await this.exerciseRepository.save(session);
    
        return { message: `Session with user ${userID} updated successfully`, data: session };
      }

      async deleteSession(userID: string) {
        const session = await this.sessionRepository.findOne({
          where: { userID },
          relations: ['exerciseList'],
        });
      
        if (!session) {
          throw new NotFoundException(`No session for user ${userID} found`);
        }
      
        await this.sessionRepository.remove(session);
        return { message: `Session with user ${userID} deleted successfully` };
      }
}