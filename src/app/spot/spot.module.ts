import {NgModule} from '@angular/core';
import {RouterModule} from "@angular/router";
import {
  NbButtonModule,
  NbCheckboxModule,
  NbDialogModule,
  NbDialogService,
  NbInputModule,
  NbLayoutModule,
  NbSidebarModule,
  NbSpinnerModule
} from "@nebular/theme";
import {SpotComponent} from './spot.component';
import {SpotRoutingModule} from "./spot-routing.module";
import {CommonModule} from "@angular/common";
import {FormsModule} from "@angular/forms";
import {AutocompComponent} from './autocomp/autocomp.component';
import {SpotService} from "./spot.service";
import {HttpClientModule} from "@angular/common/http";
import {QrComponent} from "./qr/qr.component";

@NgModule({
  imports: [
    RouterModule,
    SpotRoutingModule,
    HttpClientModule,
    NbCheckboxModule,
    NbSidebarModule,
    NbDialogModule.forChild(),
    NbButtonModule,
    NbLayoutModule,
    NbInputModule,
    CommonModule,
    FormsModule,
    NbSpinnerModule
  ],
  declarations: [
    QrComponent,
    SpotComponent,
    AutocompComponent,
  ],
  entryComponents: [QrComponent],
  providers: [NbDialogService, SpotService],
})
export class SpotModule {
}
