import { eq } from 'drizzle-orm';
import { db } from '../db/client';
import { users, refreshTokens, NewUser } from '../db/schema';

export const authRepository = {
  async findUserByEmail(email: string) {
    return db.query.users.findFirst({ where: eq(users.email, email) });
  },

  async findUserById(id: string) {
    return db.query.users.findFirst({ where: eq(users.id, id) });
  },

  async createUser(data: NewUser) {
    const [user] = await db.insert(users).values(data).returning();
    return user;
  },

  async saveRefreshToken(userId: string, token: string, expiresAt: Date) {
    await db.insert(refreshTokens).values({ userId, token, expiresAt });
  },

  async findRefreshToken(token: string) {
    return db.query.refreshTokens.findFirst({ where: eq(refreshTokens.token, token) });
  },

  async deleteRefreshToken(token: string) {
    await db.delete(refreshTokens).where(eq(refreshTokens.token, token));
  },

  async deleteAllUserRefreshTokens(userId: string) {
    await db.delete(refreshTokens).where(eq(refreshTokens.userId, userId));
  },
};
