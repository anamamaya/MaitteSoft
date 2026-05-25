import { Request, Response, NextFunction } from 'express';
import { jwtVerify } from 'jose';
import { env } from '../config/env';

export interface AuthenticatedRequest extends Request {
  user?: { id: string; email: string };
}

const secret = new TextEncoder().encode(env.JWT_SECRET);

export async function authMiddleware(
  req: AuthenticatedRequest,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    res.status(401).json({ data: null, error: 'Missing or invalid Authorization header', meta: {} });
    return;
  }

  const token = authHeader.slice(7);

  try {
    const { payload } = await jwtVerify(token, secret);
    req.user = { id: payload.sub as string, email: payload.email as string };
    next();
  } catch {
    res.status(401).json({ data: null, error: 'Token expired or invalid', meta: {} });
  }
}
