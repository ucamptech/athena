import { Module } from '@nestjs/common';
import { UploadImagesController } from './upload-images.controller';
import { UploadAudioController } from './upload-audio.controller';

@Module({
  controllers: [UploadImagesController, UploadAudioController],
})
export class UploadModule {}