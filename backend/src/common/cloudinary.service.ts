import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { v2 as cloudinary } from 'cloudinary';

@Injectable()
export class CloudinaryService {
  constructor() {
    cloudinary.config({
      cloud_name: process.env.CLOUDINARY_NAME,
      api_key: process.env.CLOUDINARY_API_KEY,
      api_secret: process.env.CLOUDINARY_API_SECRET,
    });
  }

  async uploadImage(
    buffer: Buffer,
    options: {
      folder: string;
      publicId?: string;
    },
  ): Promise<string> {
    if (
      !process.env.CLOUDINARY_NAME ||
      !process.env.CLOUDINARY_API_KEY ||
      !process.env.CLOUDINARY_API_SECRET
    ) {
      throw new InternalServerErrorException('Cloudinary config is missing');
    }

    try {
      return await new Promise<string>((resolve, reject) => {
        const upload = cloudinary.uploader.upload_stream(
          {
            folder: options.folder,
            public_id: options.publicId,
            resource_type: 'image',
          },
          (error, result) => {
            if (error || !result?.secure_url) {
              reject(error ?? new Error('Cloudinary upload failed'));
              return;
            }
            resolve(result.secure_url);
          },
        );

        upload.end(buffer);
      });
    } catch (error) {
      throw new InternalServerErrorException(
        'Failed to upload image to Cloudinary',
      );
    }
  }
}
