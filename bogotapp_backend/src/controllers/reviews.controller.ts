import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../middlewares/auth';
import { reviewsService } from '../services/reviews.service';

const createReviewSchema = z.object({
  type: z.enum(['movie', 'series', 'music']),
  title: z.string().min(1).max(200),
  score: z.number().int().min(1).max(5),
  body: z.string().min(10),
});

export const reviewsController = {
  async getAll(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const typeRaw = req.query['type'];
      const type = typeof typeRaw === 'string' ? typeRaw : undefined;
      const reviews = await reviewsService.getAll(type);
      res.status(200).json({ data: reviews, error: null, meta: { count: reviews.length } });
    } catch (err) {
      next(err);
    }
  },

  async getById(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const review = await reviewsService.getById(req.params['id'] as string);
      res.status(200).json({ data: review, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },

  async create(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const parsed = createReviewSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({ data: null, error: parsed.error.flatten(), meta: {} });
        return;
      }
      const review = await reviewsService.create({ ...parsed.data, userId: req.user!.id });
      res.status(201).json({ data: review, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },

  async delete(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      await reviewsService.delete(req.params['id'] as string, req.user!.id);
      res.status(200).json({ data: { message: 'Review deleted' }, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },
};
