import {ChangeDetectorRef, Component, NgZone, OnInit} from '@angular/core';
import {SpotService} from "./spot.service";
import {NbDialogService} from "@nebular/theme";
import {QrComponent} from "./qr/qr.component";


@Component({
  selector: 'app-spot',
  templateUrl: './spot.component.html',
  styleUrls: ['./spot.component.scss']
})
export class SpotComponent implements OnInit {
  showQR: boolean = false;
  checkedOpt: boolean = false;
  showSpinner: boolean = false;

  address: Object;
  establishmentAddress: Object;
  capacity: number;

  formattedEstablishmentAddress: string;
  nameidentity: string;

  uniqueAddress: string;

  constructor(
    private readonly spotService: SpotService,
    public cf: ChangeDetectorRef,
    public zone: NgZone,
    private dialogService: NbDialogService,
  ) {
  }

  ngOnInit(): void {
    this.showQR = true;
  }

  submitForm() {
    this.showSpinner = true;
    const data = {
      address: this.formattedEstablishmentAddress || '',
      nameidentity: this.nameidentity || '',
      capacity: this.capacity || 0,
    };
    this.createSpot(data);
  }

  createQr(data) {
    // const options = {
    //   text: data,
    //   width: 400,
    //   height: 400,
    //   colorDark: "#274156",
    //   colorLight: "white",
    //   correctLevel: QRCode.CorrectLevel.Q, // L, M, Q, H
    //   dotScale: 1,
    //   quietZone: 2,
    //   quietZoneColor: 'white',
    // };

    // if (this.showQR) {
    //   this.qrcode =
    //     new QRCode(this.qrcode.nativeElement, options);
    //   this.showQR = false;
    // } else {
    //   (this.qrcode as any).makeCode(data);
    // }
    this.dialogService.open(QrComponent, {
      context: {data: {data: data, name: this.nameidentity}},
      closeOnBackdropClick: false,
    });
  }

  getEstablishmentAddress(place: object) {
    this.establishmentAddress = place['formatted_address'];
    this.formattedEstablishmentAddress = place['formatted_address'];

    this.zone.run(() => {
      this.formattedEstablishmentAddress = place['formatted_address'];
    });

    if (place['types'].includes('establishment'))
      this.nameidentity = place['name'];

    this.uniqueAddress = this.formattedEstablishmentAddress;
    this.cf.detectChanges();
  }

  createSpot(data) {
    this.spotService.insertSpot(data).then((id: { sid: string }) => {
      console.log(id.sid);
      this.createQr(id.sid)
    });
  }
}
