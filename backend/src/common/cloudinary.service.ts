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
    return this.uploadBuffer(buffer, {
      folder: options.folder,
      publicId: options.publicId,
      resourceType: 'image',
    });
  }

  async uploadRawFile(
    buffer: Buffer,
    options: {
      folder: string;
      publicId?: string;
    },
  ): Promise<string> {
    return this.uploadBuffer(buffer, {
      folder: options.folder,
      publicId: options.publicId,
      resourceType: 'raw',
    });
  }

  async deleteRawFile(publicId: string): Promise<void> {
    await this.deleteBuffer(publicId, 'raw');
  }

  private async uploadBuffer(
    buffer: Buffer,
    options: {
      folder: string;
      publicId?: string;
      resourceType: 'image' | 'raw';
    },
  ): Promise<string> {
    this.assertConfigured();

    try {
      return await new Promise<string>((resolve, reject) => {
        const upload = cloudinary.uploader.upload_stream(
          {
            folder: options.folder,
            public_id: options.publicId,
            resource_type: options.resourceType,
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
      throw new InternalServerErrorException('Failed to upload file to Cloudinary');
    }
  }

  private async deleteBuffer(
    publicId: string,
    resourceType: 'image' | 'raw',
  ): Promise<void> {
    this.assertConfigured();

    try {
      await cloudinary.uploader.destroy(publicId, {
        resource_type: resourceType,
      });
    } catch (error) {
      throw new InternalServerErrorException('Failed to delete file from Cloudinary');
    }
  }

  private assertConfigured() {
    if (
      !process.env.CLOUDINARY_NAME ||
      !process.env.CLOUDINARY_API_KEY ||
      !process.env.CLOUDINARY_API_SECRET
    ) {
      throw new InternalServerErrorException('Cloudinary config is missing');
    }
  }
}
