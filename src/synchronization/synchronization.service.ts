import {Injectable} from '@nestjs/common';
import {PubKey} from "../entities/pubkey.entity";
import * as crypto from "crypto";
import {KeyObject} from "crypto";

@Injectable()
export class SynchronizationService {
    async getSyncroState(pubKey: string): Promise<any> {
        let _pubKey = pubKey;
        _pubKey = _pubKey.split('|').join('\n');

        const dataEncoder = await PubKey.find({
            select: ["defcon"],
            where: {
                pubkey: _pubKey
            },
        });

        const buffer = dataEncoder.length > 0
            ? Buffer.from(JSON.stringify(dataEncoder))
            : Buffer.from(JSON.stringify('first access'));

        const pkey: KeyObject = crypto.createPublicKey(_pubKey);
        return Buffer.from(crypto.publicEncrypt(pkey, buffer)).toString('base64');
    }
}
