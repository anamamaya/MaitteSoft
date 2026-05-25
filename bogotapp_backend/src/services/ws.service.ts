import { WebSocketServer, WebSocket } from 'ws';
import { Server } from 'http';
import { logger } from '../config/logger';

interface WsMessage {
  event: string;
  payload: unknown;
}

class WebSocketService {
  private wss: WebSocketServer | null = null;

  init(server: Server) {
    this.wss = new WebSocketServer({ server, path: '/ws' });

    this.wss.on('connection', (ws) => {
      logger.info('WebSocket client connected');

      ws.on('close', () => {
        logger.info('WebSocket client disconnected');
      });

      ws.on('error', (err) => {
        logger.error(err, 'WebSocket error');
      });

      ws.send(JSON.stringify({ event: 'connected', payload: { message: 'Welcome to BogotApp' } }));
    });

    logger.info('WebSocket server initialized at /ws');
  }

  broadcast(message: WsMessage) {
    if (!this.wss) return;

    const data = JSON.stringify(message);
    this.wss.clients.forEach((client) => {
      if (client.readyState === WebSocket.OPEN) {
        client.send(data);
      }
    });
  }
}

export const wsService = new WebSocketService();
