import {BadRequestException, Controller, Post, Req} from '@nestjs/common';
import {Request} from "express";
import {SpotService} from "./spot.service";

@Controller('spot')
export class SpotController {
    constructor(private readonly spotService: SpotService) {
    }

    @Post('/spot')
    syncro(@Req() request: Request) {
        try {
            const spot = request.body;
            if (spot) {
                return this.spotService.spotSpot(spot);
            } else {
                return new BadRequestException();
            }
        } catch (e) {
            console.error(e);
            return new BadRequestException();
        }
    }
}
