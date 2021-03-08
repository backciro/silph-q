import {Module} from '@nestjs/common';
import {AppController} from './app.controller';
import {TypeOrmModule} from "@nestjs/typeorm";
import {GuardSocketGateway} from "./guard-socket/guard-socket.gateway";
import {GuardSocketService} from "./guard-socket/guard-socket.service";

@Module({
    imports: [TypeOrmModule.forRoot()],
    controllers: [
        AppController,
    ],
    providers: [
        GuardSocketGateway,
        GuardSocketService,
    ],
})
export class AppModule {
}
