import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import { authMiddleware } from '../middlewares/auth';
import { placesController } from '../controllers/places.controller';

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, 'uploads/'),
  filename: (_req, file, cb) => {
    const unique = `${Date.now()}-${Math.round(Math.random() * 1e9)}`;
    cb(null, `${unique}${path.extname(file.originalname)}`);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const allowed = /jpeg|jpg|png|webp/;
    const valid = allowed.test(file.mimetype) && allowed.test(path.extname(file.originalname).toLowerCase());
    cb(null, valid);
  },
});

const router = Router();

router.get('/', authMiddleware, placesController.getAll);
router.post('/', authMiddleware, upload.single('photo'), placesController.create);
router.get('/:id', authMiddleware, placesController.getById);
router.delete('/:id', authMiddleware, placesController.delete);
router.post('/:id/likes', authMiddleware, placesController.toggleLike);

export default router;
