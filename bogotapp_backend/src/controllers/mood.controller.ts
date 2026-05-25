import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../middlewares/auth';
import { aiService } from '../services/ai.service';

const moodSchema = z.object({
  mood: z.string().min(3).max(500),
});

export const moodController = {
  async recommend(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const parsed = moodSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({ data: null, error: parsed.error.flatten(), meta: {} });
        return;
      }
      const recommendation = await aiService.getMoodRecommendation(parsed.data.mood);
      res.status(200).json({ data: recommendation, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },
};
