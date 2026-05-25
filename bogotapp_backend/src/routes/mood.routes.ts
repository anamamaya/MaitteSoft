import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth';
import { moodController } from '../controllers/mood.controller';

const router = Router();

router.post('/', authMiddleware, moodController.recommend);

export default router;
