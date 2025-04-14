import { Body, Controller, Post, Get, Param } from '@nestjs/common';
import { SessionService } from './session.service';
import { Session as SessionDto } from './dto/session.dto';

@Controller("sessions")
export class SessionController {
    constructor(private readonly sessionService: SessionService) {}

    @Post()
    async createSession(@Body() sessionDto: SessionDto){
        return this.sessionService.createSession(sessionDto);
    }

    @Get()
    async getAllSession(){
        return this.sessionService.getAllSession();
    }

    @Get(':userID')
    async getSession(@Param('userID') userID: string){
        return this.sessionService.getSession(userID);
    }
}