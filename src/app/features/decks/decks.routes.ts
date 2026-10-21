
import { Routes } from '@angular/router';

export const DECK_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () =>
      import('./deck-library/deck-library')
        .then(m => m.DeckLibrary),
  },
  {
    path: 'new',
    loadComponent: () =>
      import('./deck-create/deck-create')
        .then(m => m.DeckCreate),
  },
  {
    path: ':id',
    loadComponent: () =>
      import('./deck-editor/deck-editor')
        .then(m => m.DeckEditor),
  },
];
