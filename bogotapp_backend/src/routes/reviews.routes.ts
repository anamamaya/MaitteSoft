import { Router } from 'express';
import { authMiddleware } from '../middlewares/auth';
import { reviewsController } from '../controllers/reviews.controller';

const router = Router();

router.get('/', authMiddleware, reviewsController.getAll);
router.post('/', authMiddleware, reviewsController.create);
router.get('/:id', authMiddleware, reviewsController.getById);
router.delete('/:id', authMiddleware, reviewsController.delete);

export default router;
