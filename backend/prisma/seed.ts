import 'dotenv/config';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient, Role } from '@prisma/client';

const prisma = new PrismaClient({
  adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }),
});

async function main() {
  const email = process.env.SUPER_ADMIN_EMAIL ?? 'leudygarciax@gmail.com';
  const password = process.env.SUPER_ADMIN_PASSWORD ?? crypto.randomBytes(9).toString('base64url');

  const existing = await prisma.user.findUnique({ where: { email } });
  if (existing) {
    console.log(`Ya existe un usuario con el correo ${email}, no se creó ninguno nuevo.`);
    return;
  }

  const passwordHash = await bcrypt.hash(password, 10);

  await prisma.user.create({
    data: {
      email,
      passwordHash,
      role: Role.SUPER_ADMIN,
      tenantId: null,
    },
  });

  console.log('Super usuario creado:');
  console.log(`  email:    ${email}`);
  console.log(`  password: ${password}`);
  console.log('Guarda esta contraseña ahora — no se volverá a mostrar.');
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
