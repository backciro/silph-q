import {NbLayoutModule, NbThemeModule} from '@nebular/theme';

import {BrowserModule} from '@angular/platform-browser';
import {NgModule} from '@angular/core';

import {AppComponent} from './app.component';
import {AppRoutingModule} from './app-routing.module';
import {PolicyComponent} from "./policy/policy.component";
import {HomeComponent} from "./home/home.component";
import {DownloadComponent} from "./download/download.component";

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    PolicyComponent,
    DownloadComponent,
  ],
  imports: [
    NbThemeModule.forRoot({name: 'caretheme'}),
    AppRoutingModule,
    NbLayoutModule,
    BrowserModule,
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule {
}
