import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class PublicService {
  constructor(private readonly prisma: PrismaService) {}

  async findBySlug(slug: string) {
    const tenant = await this.prisma.tenant.findUnique({
      where: { slug },
      select: {
        businessName: true,
        businessType: true,
        slug: true,
        backgroundImageUrl: true,
        isPublished: true,
      },
    });

    if (!tenant || !tenant.isPublished) {
      throw new NotFoundException('Sitio no encontrado');
    }

    const { isPublished: _isPublished, ...publicData } = tenant;
    return publicData;
  }
}
