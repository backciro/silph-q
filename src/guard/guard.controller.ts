import {Controller, Get, Post, Req} from '@nestjs/common';
import {Request} from "express";
import {Token} from "../entities/token.entity";
import {Spot} from "../entities/spot.entity";
import {GuardService} from "./guard.service";

@Controller('guard')
export class GuardController {

    constructor(protected guardService: GuardService) {
    }

    @Post('/login')
    async login(@Req() request: Request) {
        const token = request.body['authToken'];
        const expiration = new Date();
        expiration.setHours(expiration.getHours() + 8);

        if (token) {
            const _token = await Token.insert({
                token: token,
                expiration: expiration,
            });
            return _token !== null;
        } else return false;
    }

    @Get('/getSpot')
    async getSpot(@Req() request: Request) {
        const token = request.headers['authorization'].replace('Bearer ', '');
        const spotId = request.headers['spot'].toString();

        if (token) {
            if (spotId) {
                return await Spot.findOne(spotId);
            } else {
                return {err: 'spot not found'}
            }
        } else return {err: 'unauthorized'};
    }

    @Get('/firstCheck')
    async firstCheck(@Req() request: Request) {
        if (request.headers['authorization']) {
            const token = request.headers['authorization'].replace('Bearer ', '');
            if (token) {
                const _token = await Token.findOne({token: token});
                if ((_token) && (new Date() < _token.expiration))
                    return {success: 'ok'};
                else return {err: 'unauthorized'};
            } else return false;
        } else return false;
    }

    @Get('/checkTruth')
    async checkTruth(@Req() request: Request) {
        const token = request.headers['authorization'].replace('Bearer ', '');
        const pKey = request.headers['pubkey'].toString().split('|').join('\n');
        const spot = request.headers['spot'].toString();

        if (token) {
            if (spot && pKey) {
                return this.guardService.checkTruth(spot, pKey);
            } else {
                return {err: 'spot not found'}
            }
        } else return {err: 'unauthorized'};
    }
}
