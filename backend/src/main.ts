import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as os from 'os';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Enable CORS for mobile development
  app.enableCors({
    origin: true, // Allow all origins for development
    credentials: true,
  });

  const port = process.env.PORT ?? 3000;
  await app.listen(port);

  console.log(`Application is running on port ${port}`);
  console.log(`Local: http://localhost:${port}`);

  // Get network interfaces to find LAN IP
  const networkInterfaces = os.networkInterfaces();
  const lanIPs: string[] = [];

  for (const interfaceName in networkInterfaces) {
    const interfaces = networkInterfaces[interfaceName];
    if (interfaces) {
      for (const iface of interfaces) {
        // Skip internal and non-IPv4 addresses
        if (!iface.internal && iface.family === 'IPv4') {
          lanIPs.push(iface.address);
        }
      }
    }
  }

  if (lanIPs.length > 0) {
    console.log('\n🌐 LAN Addresses (use these for mobile testing):');
    lanIPs.forEach(ip => {
      console.log(`   http://${ip}:${port}`);
    });
    console.log('\n📱 Update your frontend API base URL to one of these addresses');
  } else {
    console.log('\n⚠️  No LAN IP addresses found');
  }
}

bootstrap().catch((error) => {
  console.error('Failed to start application:', error);
  process.exit(1);
});
