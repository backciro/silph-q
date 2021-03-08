import {Component} from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <nb-layout>
      <nb-layout-header fixed>
        <div class="company_title" [routerLink]="['/']">
          SILPH CARE
        </div>
      </nb-layout-header>
      <nb-layout-column>

        <router-outlet></router-outlet>
      </nb-layout-column>
      <nb-layout-footer class="footer-heart" fixed>Created with ♥ by&nbsp;<a class="link" href="https://silph.tech">SILPH
        Technologies</a>&nbsp;2020 | ITALAMBIENTE Group
      </nb-layout-footer>
    </nb-layout>`,
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  title = 'care-spot';
}
