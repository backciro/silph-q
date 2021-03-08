import {BadRequestException, Controller, Post, Req} from '@nestjs/common';
import {Request} from "express";
import {CheckinService} from "./checkin.service";

@Controller('checkin')
export class CheckinController {

    constructor(private readonly checkinService: CheckinService) {
    }

    @Post('/reservation')
    reservation(@Req() request: Request) {
        const timeStamp = request.body['timestamp'];
        const pubKey = request.body['pubkey'];
        const spot = request.body['spot'];

        if (pubKey && spot && timeStamp) {
            return this.checkinService.checkInPlace(timeStamp, pubKey, spot)
        } else {
            return false
        }
    }

    @Post('/jumpIn')
    jumpIn(@Req() request: Request) {
        const committee = request.headers['committee'];

        if (committee) {
            const pubKey = request.body['pubkey'];
            const defcon = request.body['defcon'];

            if (pubKey && defcon) {
                return this.checkinService.registerMe(pubKey, defcon);
            } else {
                return new BadRequestException();
            }
        }
    }

    @Post('/reviewState')
    reviewState(@Req() request: Request) {
        const pubKey = request.body['pubkey'];
        const defcon = parseInt(request.body['defcon'].toString());

        if (pubKey && defcon) {
            return this.checkinService.reviewDEFCON(pubKey, defcon);
        } else {
            return new BadRequestException();
        }
    }
}
