import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { corsOptions } from './config/cors';
import { logger } from './config/logger';
import { errorHandler } from './middlewares/errorHandler';
import { wsService } from './services/ws.service';
import authRoutes from './routes/auth.routes';
import placesRoutes from './routes/places.routes';
import reviewsRoutes from './routes/reviews.routes';
import moodRoutes from './routes/mood.routes';
import path from 'path';
import { env } from './config/env';

const app = express();
const server = createServer(app);

wsService.init(server);

app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(process.cwd(), 'uploads')));

app.get('/health', (_req, res) => {
  res.status(200).json({ data: { status: 'ok' }, error: null, meta: {} });
});

app.use('/auth', authRoutes);
app.use('/places', placesRoutes);
app.use('/reviews', reviewsRoutes);
app.use('/mood', moodRoutes);

app.use(errorHandler);

server.listen(env.PORT, () => {
  logger.info(`BogotApp backend running on port ${env.PORT}`);
});

export { app, server };
