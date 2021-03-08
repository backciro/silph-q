import {ChangeDetectorRef, Component, NgZone, OnInit} from '@angular/core';


@Component({
  selector: 'app-policy',
  templateUrl: './policy.component.html',
  styleUrls: ['./policy.component.scss']
})
export class PolicyComponent implements OnInit {
  constructor(
    public cf: ChangeDetectorRef,
    public zone: NgZone,
  ) {
  }

  ngOnInit(): void {
  }
}
