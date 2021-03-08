import {ChangeDetectorRef, Component, NgZone, OnInit} from '@angular/core';


@Component({
  selector: 'app-download',
  templateUrl: './download.component.html',
  styleUrls: ['./download.component.scss']
})
export class DownloadComponent implements OnInit {
  constructor(
    public cf: ChangeDetectorRef,
    public zone: NgZone,
  ) {
  }

  ngOnInit(): void {
  }
}
