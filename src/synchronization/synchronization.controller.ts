import {Controller, Get, Req, Request} from '@nestjs/common';
import {SynchronizationService} from "./synchronization.service";

@Controller('synchronization')
export class SynchronizationController {
    constructor(private readonly syncService: SynchronizationService) {
    }

    @Get('/sync')
    syncro(@Req() request: Request) {
        const pubKey = request.headers['pubkey'];
        if (pubKey && pubKey !== 'null') {
            return this.syncService.getSyncroState(pubKey);
        } else {
            return false;
        }
    }
}
