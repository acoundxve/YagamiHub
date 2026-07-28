import { existsSync, mkdirSync } from 'fs';
import { extname, join } from 'path';
import { randomUUID } from 'crypto';
import { BadRequestException } from '@nestjs/common';
import { diskStorage } from 'multer';

const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024;

export function imageUploadOptions(subfolder: 'avatars' | 'backgrounds') {
  const uploadDir = join(__dirname, '..', '..', '..', '..', 'uploads', subfolder);
  if (!existsSync(uploadDir)) {
    mkdirSync(uploadDir, { recursive: true });
  }

  return {
    storage: diskStorage({
      destination: uploadDir,
      filename: (_req, file, callback) => {
        callback(null, `${randomUUID()}${extname(file.originalname)}`);
      },
    }),
    limits: { fileSize: MAX_FILE_SIZE_BYTES },
    fileFilter: (_req: unknown, file: Express.Multer.File, callback: (error: Error | null, accept: boolean) => void) => {
      if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
        callback(new BadRequestException('Formato de imagen no soportado'), false);
        return;
      }
      callback(null, true);
    },
    publicPathPrefix: `/uploads/${subfolder}`,
  };
}
