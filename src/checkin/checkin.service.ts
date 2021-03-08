import {Injectable} from '@nestjs/common';
import {Track} from "../entities/track.entity";
import {Spot} from "../entities/spot.entity";
import {PubKey} from "../entities/pubkey.entity";

@Injectable()
export class CheckinService {
    async checkInPlace(timeStamp: any, pubKey: any, spot: any): Promise<string | boolean> {
        const _spot = await Spot.findOne(spot);
        if (_spot) {
            const data = await Track.insert({
                timestamp: timeStamp,
                pubkey: pubKey,
                spot: _spot,
            }).catch(() => null);
            return data !== null ? _spot.nameidentity : false;
        } else return false;
    }

    async registerMe(pubKey: string, defcon: number) {
        const data = await PubKey.insert({
            pubkey: pubKey,
            defcon: defcon,
        }).catch(() => false);
        return data !== false;
    }

    async reviewDEFCON(pubKey: string, defcon: number) {
        const data = await PubKey.update({
            pubkey: pubKey
        }, {
            defcon: defcon,
        }).catch(() => false);
        return data !== false;
    }

    async addSpot(spotname: string, spotaddress: string) {
        const data = await Spot.insert({
            nameidentity: spotname,
            address: spotaddress,
        }).catch(() => null);

        return data !== null ? data.identifiers[0] : false;
    }
}
