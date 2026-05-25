import { placesRepository } from '../repositories/places.repository';
import { AppError } from '../middlewares/errorHandler';
import { NewPlace } from '../db/schema';
import { wsService } from './ws.service';

export const placesService = {
  async getAll() {
    return placesRepository.findAll();
  },

  async getById(id: string) {
    const place = await placesRepository.findById(id);
    if (!place) throw new AppError(404, 'Place not found');
    return place;
  },

  async create(data: Omit<NewPlace, 'id' | 'createdAt' | 'likesCount'>) {
    const place = await placesRepository.create(data);
    wsService.broadcast({ event: 'place:created', payload: place });
    return place;
  },

  async delete(id: string, userId: string) {
    const place = await placesRepository.findById(id);
    if (!place) throw new AppError(404, 'Place not found');
    if (place.userId !== userId) throw new AppError(403, 'Not authorized to delete this place');
    await placesRepository.delete(id);
  },

  async toggleLike(placeId: string, userId: string) {
    const place = await placesRepository.findById(placeId);
    if (!place) throw new AppError(404, 'Place not found');

    const hasLiked = await placesRepository.userHasLiked(userId, placeId);
    if (hasLiked) {
      await placesRepository.removeLike(userId, placeId);
      return { liked: false };
    } else {
      await placesRepository.addLike(userId, placeId);
      return { liked: true };
    }
  },
};
