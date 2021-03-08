import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {PolicyComponent} from "./policy/policy.component";
import {HomeComponent} from "./home/home.component";
import {DownloadComponent} from "./download/download.component";


const routes: Routes = [
  {path: '', component: HomeComponent},
  {path: 'policy', component: PolicyComponent},
  {path: 'download', component: DownloadComponent},
  {path: 'spot', loadChildren: () => import('./spot/spot.module').then(m => m.SpotModule)},
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule {
}
