import {Injectable} from '@nestjs/common';

@Injectable()
export class SignalizationService {
    alertInfection(pubKey: any, mins: number) {
        // 1 pub on the change-defcon func for me THEN
        // 2 call procedure w/ pubKey and mins params, then - for each person - pub on the change
        return true;
    }

}
