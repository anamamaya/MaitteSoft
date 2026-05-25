import bcrypt from 'bcryptjs';
import { SignJWT, jwtVerify } from 'jose';
import { env } from '../config/env';
import { authRepository } from '../repositories/auth.repository';
import { AppError } from '../middlewares/errorHandler';

const secret = new TextEncoder().encode(env.JWT_SECRET);

const ACCESS_TOKEN_TTL = '15m';
const REFRESH_TOKEN_TTL_MS = 7 * 24 * 60 * 60 * 1000;

async function signAccessToken(userId: string, email: string): Promise<string> {
  return new SignJWT({ email })
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(userId)
    .setIssuedAt()
    .setExpirationTime(ACCESS_TOKEN_TTL)
    .sign(secret);
}

async function signRefreshToken(userId: string): Promise<string> {
  return new SignJWT({})
    .setProtectedHeader({ alg: 'HS256' })
    .setSubject(userId)
    .setIssuedAt()
    .setExpirationTime('7d')
    .sign(secret);
}

export const authService = {
  async register(name: string, email: string, password: string) {
    const existing = await authRepository.findUserByEmail(email);
    if (existing) throw new AppError(409, 'Email already in use');

    const passwordHash = await bcrypt.hash(password, 12);
    const user = await authRepository.createUser({ name, email, passwordHash });

    const accessToken = await signAccessToken(user.id, user.email);
    const refreshToken = await signRefreshToken(user.id);
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_MS);

    await authRepository.saveRefreshToken(user.id, refreshToken, expiresAt);

    return {
      user: { id: user.id, name: user.name, email: user.email, createdAt: user.createdAt },
      accessToken,
      refreshToken,
    };
  },

  async login(email: string, password: string) {
    const user = await authRepository.findUserByEmail(email);
    if (!user) throw new AppError(401, 'Invalid credentials');

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid) throw new AppError(401, 'Invalid credentials');

    const accessToken = await signAccessToken(user.id, user.email);
    const refreshToken = await signRefreshToken(user.id);
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_MS);

    await authRepository.saveRefreshToken(user.id, refreshToken, expiresAt);

    return {
      user: { id: user.id, name: user.name, email: user.email, createdAt: user.createdAt },
      accessToken,
      refreshToken,
    };
  },

  async refresh(token: string) {
    const stored = await authRepository.findRefreshToken(token);
    if (!stored || stored.expiresAt < new Date()) {
      throw new AppError(401, 'Refresh token expired or invalid');
    }

    try {
      await jwtVerify(token, secret);
    } catch {
      await authRepository.deleteRefreshToken(token);
      throw new AppError(401, 'Refresh token expired or invalid');
    }

    const user = await authRepository.findUserById(stored.userId);
    if (!user) throw new AppError(401, 'User not found');

    await authRepository.deleteRefreshToken(token);

    const accessToken = await signAccessToken(user.id, user.email);
    const newRefreshToken = await signRefreshToken(user.id);
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_MS);

    await authRepository.saveRefreshToken(user.id, newRefreshToken, expiresAt);

    return { accessToken, refreshToken: newRefreshToken };
  },

  async logout(token: string) {
    await authRepository.deleteRefreshToken(token);
  },
};
