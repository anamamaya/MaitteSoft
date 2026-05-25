import { Response, NextFunction } from 'express';
import { z } from 'zod';
import { AuthenticatedRequest } from '../middlewares/auth';
import { placesService } from '../services/places.service';
import path from 'path';

const createPlaceSchema = z.object({
  name: z.string().min(2).max(150),
  description: z.string().min(5),
  category: z.enum(['cafe', 'park', 'food', 'secret', 'other']),
  lat: z.string().or(z.number()).transform(String),
  lng: z.string().or(z.number()).transform(String),
});

export const placesController = {
  async getAll(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const places = await placesService.getAll();
      res.status(200).json({ data: places, error: null, meta: { count: places.length } });
    } catch (err) {
      next(err);
    }
  },

  async getById(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const place = await placesService.getById(req.params['id'] as string);
      res.status(200).json({ data: place, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },

  async create(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const parsed = createPlaceSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({ data: null, error: parsed.error.flatten(), meta: {} });
        return;
      }

      const photoUrl = req.file
        ? `/uploads/${req.file.filename}`
        : undefined;

      const place = await placesService.create({
        ...parsed.data,
        photoUrl,
        userId: req.user!.id,
      });

      res.status(201).json({ data: place, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },

  async delete(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      await placesService.delete(req.params['id'] as string, req.user!.id);
      res.status(200).json({ data: { message: 'Place deleted' }, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },

  async toggleLike(req: AuthenticatedRequest, res: Response, next: NextFunction) {
    try {
      const result = await placesService.toggleLike(req.params['id'] as string, req.user!.id);
      res.status(200).json({ data: result, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },
};
