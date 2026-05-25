import { eq, sql } from 'drizzle-orm';
import { db } from '../db/client';
import { places, likes, NewPlace } from '../db/schema';

export const placesRepository = {
  async findAll() {
    return db.query.places.findMany({ orderBy: (p, { desc }) => [desc(p.createdAt)] });
  },

  async findById(id: string) {
    return db.query.places.findFirst({ where: eq(places.id, id) });
  },

  async create(data: NewPlace) {
    const [place] = await db.insert(places).values(data).returning();
    return place;
  },

  async delete(id: string) {
    await db.delete(places).where(eq(places.id, id));
  },

  async addLike(userId: string, placeId: string) {
    await db.insert(likes).values({ userId, placeId }).onConflictDoNothing();
    await db
      .update(places)
      .set({ likesCount: sql`${places.likesCount} + 1` })
      .where(eq(places.id, placeId));
  },

  async removeLike(userId: string, placeId: string) {
    const result = await db
      .delete(likes)
      .where(sql`${likes.userId} = ${userId} AND ${likes.placeId} = ${placeId}`)
      .returning();

    if (result.length > 0) {
      await db
        .update(places)
        .set({ likesCount: sql`GREATEST(${places.likesCount} - 1, 0)` })
        .where(eq(places.id, placeId));
    }
  },

  async userHasLiked(userId: string, placeId: string) {
    const like = await db.query.likes.findFirst({
      where: sql`${likes.userId} = ${userId} AND ${likes.placeId} = ${placeId}`,
    });
    return !!like;
  },
};
