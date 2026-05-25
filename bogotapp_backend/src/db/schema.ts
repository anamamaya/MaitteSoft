import { pgTable, uuid, varchar, text, numeric, integer, timestamp, pgEnum, primaryKey } from 'drizzle-orm/pg-core';

export const reviewTypeEnum = pgEnum('review_type', ['movie', 'series', 'music']);
export const placeCategoryEnum = pgEnum('place_category', ['cafe', 'park', 'food', 'secret', 'other']);

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 100 }).notNull(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  passwordHash: varchar('password_hash', { length: 255 }).notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const places = pgTable('places', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: varchar('name', { length: 150 }).notNull(),
  description: text('description').notNull(),
  category: placeCategoryEnum('category').notNull(),
  lat: numeric('lat', { precision: 10, scale: 7 }).notNull(),
  lng: numeric('lng', { precision: 10, scale: 7 }).notNull(),
  photoUrl: varchar('photo_url', { length: 500 }),
  likesCount: integer('likes_count').default(0).notNull(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const reviews = pgTable('reviews', {
  id: uuid('id').primaryKey().defaultRandom(),
  type: reviewTypeEnum('type').notNull(),
  title: varchar('title', { length: 200 }).notNull(),
  score: integer('score').notNull(),
  body: text('body').notNull(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export const likes = pgTable('likes', {
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  placeId: uuid('place_id').notNull().references(() => places.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at').defaultNow().notNull(),
}, (table) => ({
  pk: primaryKey({ columns: [table.userId, table.placeId] }),
}));

export const refreshTokens = pgTable('refresh_tokens', {
  id: uuid('id').primaryKey().defaultRandom(),
  token: text('token').notNull().unique(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  expiresAt: timestamp('expires_at').notNull(),
  createdAt: timestamp('created_at').defaultNow().notNull(),
});

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type Place = typeof places.$inferSelect;
export type NewPlace = typeof places.$inferInsert;
export type Review = typeof reviews.$inferSelect;
export type NewReview = typeof reviews.$inferInsert;
export type Like = typeof likes.$inferSelect;
