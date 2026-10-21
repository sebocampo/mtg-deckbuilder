import { Routes } from '@angular/router';

export const DECK_ROUTES: Routes = [
    {
        path: '',
        loadComponent: () =>
            import('./deck-library/deck-library')
                .then(m => m.DeckLibrary),
    },
];
