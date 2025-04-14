import { Module } from "@nestjs/common";
import { ChoicesController } from "./choices.controller";
import { ChoicesService } from "./choices.service";
import { TypeOrmModule } from '@nestjs/typeorm';
import { Choices as ChoicesEntity } from './entities/choices.entity';


@Module({
  imports: [TypeOrmModule.forFeature([ChoicesEntity])],
  controllers: [ChoicesController],
  providers: [ChoicesService],
})
export class ChoicesModule {}