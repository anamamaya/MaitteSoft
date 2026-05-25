import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/logger';

export class AppError extends Error {
  constructor(
    public statusCode: number,
    message: string,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void {
  if (err instanceof AppError) {
    res.status(err.statusCode).json({ data: null, error: err.message, meta: {} });
    return;
  }

  logger.error(err, 'Unhandled error');
  res.status(500).json({ data: null, error: 'Internal server error', meta: {} });
}
