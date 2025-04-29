import { Controller, Post, UploadedFile, UseInterceptors } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join} from 'path';

@Controller('upload/audio')
export class UploadAudioController {
  @Post()
  @UseInterceptors(FileInterceptor('file', {
    storage: diskStorage({
        destination: join(__dirname, '..', '..', '..', 'static', 'audio'),
      filename: (req, file, callback) => {
        const uniqueSuffix = Date.now();
        const ext = extname(file.originalname);
        callback(null, `${file.fieldname}-${uniqueSuffix}${ext}`);
      },
    }),
  }))
  uploadFile(@UploadedFile() file: Express.Multer.File) {
    console.log('Received file:', file);
    return {
      message: 'File uploaded successfully!',
      path: `/audio/${file.filename}`,
    };
  }
}