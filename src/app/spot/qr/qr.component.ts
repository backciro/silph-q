import {NB_DIALOG_CONFIG} from "@nebular/theme";
import * as QRCode from 'easyqrcodejs';
import {Component, ElementRef, Inject, OnInit, Optional, ViewChild} from '@angular/core';

declare const google: any;

@Component({
  selector: 'app-qr',
  templateUrl: './qr.component.html',
  styleUrls: ['./qr.component.scss'],
})
export class QrComponent implements OnInit {
  @ViewChild('qrcode', {static: true}) qrcode: ElementRef;
  @Optional() @Inject(NB_DIALOG_CONFIG) data: any;

  ngOnInit(): void {
    console.log('this');
    console.log(this);
    console.log(this.data);

    const options = {
      text: this.data.data,
      width: 512,
      height: 512,
      colorDark: "#274156",
      colorLight: "white",
      correctLevel: QRCode.CorrectLevel.Q, // L, M, Q, H
      dotScale: 1,
      quietZone: 2,
      quietZoneColor: 'white',
    };

    this.qrcode = new QRCode(this.qrcode.nativeElement, options);
  }

  print(): void {
    const canvas = (document.getElementById('print-section').getElementsByTagName('canvas'));
    const dataUrl = canvas[0].toDataURL();
    let windowContent = '<!DOCTYPE html>';
    windowContent += '<html lang="en-US">';
    windowContent += '<head><title>PRINT QR CODE</title>';
    windowContent += `<style>.qr-img{width: 100%;margin-top:23px;}</style>`;
    windowContent += '</head>';
    windowContent += '<body>';
    windowContent += '<img class="qr-img" src="' + dataUrl + '" alt="">';
    windowContent += '</body>';
    windowContent += '</html>';
    const printWin = window.open('', '', 'width=540,height=600');
    printWin.document.write(windowContent);

    setTimeout(() => {
      printWin.document.close();
      printWin.focus();
      printWin.print();
      printWin.close();
    }, 0);
  }

  download(): void {
    const canvas = (document.getElementById('print-section').getElementsByTagName('canvas'));
    const dataUrl = canvas[0].toDataURL("image/png")
      .replace("image/png", "image/octet-stream");
    const link = document.createElement('a');
    link.download = `${this.data.name.toLowerCase()
      .split(' ').join('-')
      .split('/').join('-')
      .split('$').join('-')
      .split('^').join('-')
      .split('*').join('-')
      .split("'").join('-')
      .split('"').join('-')
      .split('`').join('-')
      .split(',').join('-')
      .split(';').join('-')
      .split(':').join('-')
      .split('.').join('')
    }-qrcode.png`;
    link.href = dataUrl;
    link.click();
  }
}
