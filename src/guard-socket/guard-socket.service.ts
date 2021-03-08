import {Injectable} from '@nestjs/common';
import {Guarded} from "../entities/guarded.entity";
import {RandomGenerator} from "typeorm/util/RandomGenerator";
import {Like} from "typeorm";

@Injectable()
export class GuardSocketService {
    public dataCollector: Map<string, number> = new Map<string, number>();

    retrieveDataCollector() {
        return Guarded.find({
            relations: ['spot']
        }).then((guards => {
                this.dataCollector = new Map<string, number>();
                guards.forEach(el => {
                    this.dataCollector[el.spot.sid] =
                        guards.filter(f => f.spot.sid === el.spot.sid && f.checkout === null).length;
                });
                return this.dataCollector
            }),
        );
    }

    incrementDataCollector(spot: string) {
        if (this.dataCollector[spot])
            +this.dataCollector[spot]++;
        else {
            this.dataCollector[spot] = 1;
        }

        const final = new Map();
        final[spot] = this.dataCollector[spot] || 0;

        return final;
    }

    decrementDataCollector(spot: string) {
        if (this.dataCollector[spot])
            +this.dataCollector[spot]--;
        else {
            this.dataCollector[spot] = 0;
        }

        const final = new Map();
        final[spot] = this.dataCollector[spot] || 0;

        return final;
    }

    async addVisit(place, pbkey, timestamp): Promise<boolean> {
        if (pbkey && pbkey.startsWith('-----')) //pubKey
            return await Guarded.insert({
                spot: place,
                pubkey: pbkey,
                checkin: timestamp,
                checkout: null,
            }).then(inserted => {
                return !!inserted;
            });
        else // NOCODE_USER
            return await Guarded.insert({
                spot: place,
                pubkey: `NOCODE_${RandomGenerator.uuid4().toUpperCase()}`,
                checkin: timestamp,
                checkout: null,
            }).then(inserted => {
                return !!inserted;
            });

    }

    async sayGoodbye(place, pbkey): Promise<any> {
        return new Promise(async (resolve) => {
            if (pbkey && pbkey.startsWith('-----')) { //pubKey
                const trackFound = await Guarded.find({
                    where: {
                        pubkey: pbkey,
                        checkout: null,
                    },
                    relations: ['spot']
                });

                console.log({trackFound});

                if (trackFound && trackFound.length > 0) {
                    const spotFound = trackFound[0].spot;

                    Guarded.delete({
                        spot: spotFound,
                        pubkey: pbkey,
                        checkout: null,
                    }).then(() => {
                        resolve(spotFound.sid);
                        return spotFound.sid;
                    });
                }
            } else {
                const oneToRemove = await Guarded.findOne({
                    where: {
                        spot: place,
                        pubkey: Like('NOCODE_%'),
                        checkout: null,
                    }
                });
                if (oneToRemove) {
                    Guarded.remove(oneToRemove).then(() => {
                        resolve(place);
                        return place;
                    });
                } else {
                    resolve(false);
                    return false;
                }
            }
        });
    }
}
