
import { Routes } from '@angular/router';

export const routes: Routes = [
    {
        path: '',
        loadComponent: () =>
            import('./core/layout/app-shell/app-shell')
                .then(m => m.AppShell),
        children: [
            {
                path: '',
                pathMatch: 'full',
                redirectTo: 'decks',
            },
            {
                path: 'decks',
                loadChildren: () =>
                    import('./features/decks/decks.routes')
                        .then(m => m.DECK_ROUTES),
            },
        ],
    },
];
