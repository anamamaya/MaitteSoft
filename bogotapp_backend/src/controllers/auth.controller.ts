import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { authService } from '../services/auth.service';

const registerSchema = z.object({
  name: z.string().min(2).max(100),
  email: z.string().email(),
  password: z.string().min(8),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1),
});

export const authController = {
  async register(req: Request, res: Response, next: NextFunction) {
    try {
      const parsed = registerSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({ data: null, error: parsed.error.flatten(), meta: {} });
        return;
      }
      const { name, email, password } = parsed.data;
      const result = await authService.register(name, email, password);
      res.status(201).json({ data: result, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },

  async login(req: Request, res: Response, next: NextFunction) {
    try {
      const parsed = loginSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({ data: null, error: parsed.error.flatten(), meta: {} });
        return;
      }
      const { email, password } = parsed.data;
      const result = await authService.login(email, password);
      res.status(200).json({ data: result, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },

  async refresh(req: Request, res: Response, next: NextFunction) {
    try {
      const parsed = refreshSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({ data: null, error: parsed.error.flatten(), meta: {} });
        return;
      }
      const result = await authService.refresh(parsed.data.refreshToken);
      res.status(200).json({ data: result, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },

  async logout(req: Request, res: Response, next: NextFunction) {
    try {
      const parsed = refreshSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({ data: null, error: parsed.error.flatten(), meta: {} });
        return;
      }
      await authService.logout(parsed.data.refreshToken);
      res.status(200).json({ data: { message: 'Logged out successfully' }, error: null, meta: {} });
    } catch (err) {
      next(err);
    }
  },
};
