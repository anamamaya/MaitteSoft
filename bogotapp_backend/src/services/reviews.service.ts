import { reviewsRepository } from '../repositories/reviews.repository';
import { AppError } from '../middlewares/errorHandler';
import { NewReview } from '../db/schema';

export const reviewsService = {
  async getAll(type?: string) {
    return reviewsRepository.findAll(type);
  },

  async getById(id: string) {
    const review = await reviewsRepository.findById(id);
    if (!review) throw new AppError(404, 'Review not found');
    return review;
  },

  async create(data: Omit<NewReview, 'id' | 'createdAt'>) {
    return reviewsRepository.create(data);
  },

  async delete(id: string, userId: string) {
    const review = await reviewsRepository.findById(id);
    if (!review) throw new AppError(404, 'Review not found');
    if (review.userId !== userId) throw new AppError(403, 'Not authorized to delete this review');
    await reviewsRepository.delete(id);
  },
};
