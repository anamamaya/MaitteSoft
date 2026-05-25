import { eq, and } from 'drizzle-orm';
import { db } from '../db/client';
import { reviews, NewReview } from '../db/schema';

export const reviewsRepository = {
  async findAll(type?: string) {
    if (type) {
      return db.query.reviews.findMany({
        where: eq(reviews.type, type as 'movie' | 'series' | 'music'),
        orderBy: (r, { desc }) => [desc(r.createdAt)],
      });
    }
    return db.query.reviews.findMany({ orderBy: (r, { desc }) => [desc(r.createdAt)] });
  },

  async findById(id: string) {
    return db.query.reviews.findFirst({ where: eq(reviews.id, id) });
  },

  async create(data: NewReview) {
    const [review] = await db.insert(reviews).values(data).returning();
    return review;
  },

  async delete(id: string) {
    await db.delete(reviews).where(eq(reviews.id, id));
  },
};
