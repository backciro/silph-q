import {Module} from '@nestjs/common';
import {AppController} from './app.controller';
import {AppService} from './app.service';
import {TypeOrmModule} from "@nestjs/typeorm";
import {SynchronizationController} from './synchronization/synchronization.controller';
import {CheckinController} from './checkin/checkin.controller';
import {SignalizationController} from './signalization/signalization.controller';
import {CheckinService} from "./checkin/checkin.service";
import {SignalizationService} from "./signalization/signalization.service";
import {SynchronizationService} from "./synchronization/synchronization.service";
import {SpotController} from './spot/spot.controller';
import {SpotService} from "./spot/spot.service";
import {GuardController} from "./guard/guard.controller";
import {GuardService} from "./guard/guard.service";

@Module({
    imports: [TypeOrmModule.forRoot()],
    controllers: [
        AppController,
        SpotController,
        GuardController,
        CheckinController,
        SignalizationController,
        SynchronizationController,
    ],
    providers: [
        AppService,
        SpotService,
        GuardService,
        CheckinService,
        SignalizationService,
        SynchronizationService,
    ],
})
export class AppModule {
}
