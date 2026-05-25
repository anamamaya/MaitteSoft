import Anthropic from '@anthropic-ai/sdk';
import { env } from '../config/env';
import { placesRepository } from '../repositories/places.repository';
import { reviewsRepository } from '../repositories/reviews.repository';

const anthropic = new Anthropic({ apiKey: env.ANTHROPIC_API_KEY });

interface MoodRecommendation {
  type: 'lugar' | 'contenido';
  name: string;
  reason: string;
  lat?: string;
  lng?: string;
  category?: string;
}

export const aiService = {
  async getMoodRecommendation(mood: string): Promise<MoodRecommendation> {
    const [places, reviews] = await Promise.all([
      placesRepository.findAll(),
      reviewsRepository.findAll(),
    ]);

    const placesContext = places
      .slice(0, 20)
      .map((p) => `- ${p.name} (${p.category}): ${p.description} [lat: ${p.lat}, lng: ${p.lng}]`)
      .join('\n');

    const reviewsContext = reviews
      .slice(0, 20)
      .map((r) => `- ${r.title} (${r.type}, score: ${r.score}/5): ${r.body.slice(0, 100)}...`)
      .join('\n');

    const prompt = `Eres un asistente cultural de Bogotá. El usuario dice que se siente así: "${mood}".

Tienes disponibles los siguientes lugares en el mapa de la ciudad:
${placesContext || 'No hay lugares disponibles aún.'}

Y las siguientes reseñas culturales:
${reviewsContext || 'No hay reseñas disponibles aún.'}

Basado en el estado de ánimo del usuario, recomienda UNA sola cosa que se ajuste perfectamente a cómo se siente. Puede ser un lugar del mapa o un contenido cultural (película, serie o música).

Responde ÚNICAMENTE con un JSON válido con esta estructura exacta:
{
  "type": "lugar" o "contenido",
  "name": "nombre exacto del lugar o contenido",
  "reason": "explicación corta y cálida de por qué se ajusta a su estado de ánimo (máx 2 oraciones)",
  "lat": "latitud si es un lugar (opcional)",
  "lng": "longitud si es un lugar (opcional)",
  "category": "categoría si aplica (opcional)"
}`;

    const message = await anthropic.messages.create({
      model: 'claude-opus-4-5',
      max_tokens: 512,
      messages: [{ role: 'user', content: prompt }],
    });

    const text = message.content[0].type === 'text' ? message.content[0].text : '';
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) throw new Error('Claude did not return valid JSON');

    return JSON.parse(jsonMatch[0]) as MoodRecommendation;
  },
};
