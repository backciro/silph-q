import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  OnGatewayInit,
  SubscribeMessage,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Logger } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { GuardSocketService } from './guard-socket.service';

@WebSocketGateway(parseInt(process.env.PORT) || 8080, {
  transports: ['websocket', 'polling'],
  namespace: '/guard',
})
export class GuardSocketGateway
  implements OnGatewayInit, OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer() server: Server;
  private logger: Logger = new Logger('WebSocketGateway');

  constructor(protected guardService: GuardSocketService) {}

  afterInit() {
    this.guardService.retrieveDataCollector().then((data) => {
      this.server.emit('valueRefresh', data);
    });
  }

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
    console.log('client.handshake.headers');
    console.log(client.handshake.headers);

    if (client.handshake.headers['spot'].toString().length > 8) {
      client.join(client.handshake.headers['spot']);
    }

    this.guardService.retrieveDataCollector().then((data) => {
      client.emit('valueRefresh', data);
    });
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  // CARE GUARD
  @SubscribeMessage('spotRefresh')
  async spotRefresh(client: Socket, payload: string) {
    const data = JSON.parse(payload);
    client.join(data.spot);

    const collector = await this.guardService.retrieveDataCollector();
    const final = new Map();

    final[data.spot] = collector[data.spot] || 0;

    this.server.to(data.spot).emit('valueRefresh', final);
    this.server.to(client.id).emit('valueRefresh', final);
  }

  @SubscribeMessage('enterPlace')
  enterPlace(client: Socket, payload: string) {
    const data = JSON.parse(payload);
    client.join(data.spot);

    const collector = this.guardService.incrementDataCollector(data.spot);
    this.server.to(data.spot).emit('valueRefresh', collector);
    this.server.to(client.id).emit('valueRefresh', collector);

    this.guardService.addVisit(data.spot, data.pubkey, data.timestamp).then();
  }

  @SubscribeMessage('placeQuit')
  placeQuit(client: Socket, payload: string) {
    const data = JSON.parse(payload);
    client.join(data.spot);

    this.guardService
      .sayGoodbye(data.spot, data.pubkey)
      .then((spot2decrement) => {
        console.log({ spot2decrement });
        const collector = this.guardService.decrementDataCollector(
          spot2decrement,
        );
        this.server.to(spot2decrement).emit('valueRefresh', collector);
        this.server.to(client.id).emit('valueRefresh', collector);
      });
  }

  // CARE
  @SubscribeMessage('requestContract')
  requestContract(client: Socket, payload: string): void {
    const data = JSON.parse(payload);

    switch (data.request) {
      case 0: // MED to CIT
        console.log('case 0 first pass');
        this.server.emit('broadcastMessage', payload);
        break;
      case 1: // CIT to MED
        console.log('case 1 second pass');
        this.server.emit('armyCallResponse', payload);
        break;
    }
  }
}
