import {BadRequestException, Controller, Post, Req} from '@nestjs/common';
import {Request} from "express";
import {SignalizationService} from "./signalization.service";

@Controller('signalization')
export class SignalizationController {
    constructor(private readonly signalService: SignalizationService) {
    }

    @Post('/alert')
    alert(@Req() request: Request) {
        const pubKey = request.body['pubKey'];
        const mins = request.body['minutes'];

        if (pubKey) {
            return this.signalService.alertInfection(pubKey, mins);
        } else {
            return new BadRequestException();
        }
    }
}
