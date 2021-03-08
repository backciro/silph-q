import {NgModule} from '@angular/core';
import {RouterModule, Routes} from '@angular/router';
import {SpotComponent} from "./spot.component";


const routes: Routes = [
  {
    path: '',
    component: SpotComponent,
    children: [
      {
        path: '',
        component: SpotComponent,
      },
      {
        path: '', redirectTo: '', pathMatch: 'full',
      },
    ],
  },
];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class SpotRoutingModule {
}
