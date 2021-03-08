import {Injectable} from '@nestjs/common';
import {Like} from "typeorm";
import {Guarded} from "../entities/guarded.entity";

@Injectable()
export class GuardService {
    async checkTruth(place, pbkey): Promise<boolean> {
        if (pbkey && pbkey.startsWith('-----')) // pubKey
            return await Guarded.find({
                spot: place,
                pubkey: pbkey,
                checkout: null,
            }).then(found => {
                return found.length > 0;
            });
        else {
            const isAnyoneUntracked = await Guarded.findOne({
                where: {
                    spot: place,
                    pubkey: Like('NOCODE_%'),
                    checkout: null,
                }
            });
            return isAnyoneUntracked != null;
        }
    }
}
