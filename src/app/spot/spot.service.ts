import {Injectable} from '@angular/core';
import {HttpClient} from "@angular/common/http";


@Injectable()
export class SpotService {
  constructor(private http: HttpClient) {
  }

  apiPath: string = 'https://silph-care.ey.r.appspot.com';

  insertSpot(data) {
    return new Promise((resolve, reject) => {
      return this.http.post(this.apiPath + '/spot/spot', data).toPromise().then(id => {
        resolve(id);
      })
    });
  }
}
