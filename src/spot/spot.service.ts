import {Injectable} from '@nestjs/common';
import {Spot} from "../entities/spot.entity";

@Injectable()
export class SpotService {
    async spotSpot(spot: Spot): Promise<string | boolean> {
        const data = await Spot.insert(spot).catch(() => null);
        return data !== null ? data.identifiers[0] : false;
    }

}
