
import { Component, inject } from '@angular/core';
import {
  RouterOutlet,
  RouterLink,
  RouterLinkActive
} from '@angular/router';
import { DeckStore } from '../../../features/decks/data-access/deck.store';

@Component({
  selector: 'app-shell',
  standalone: true,
  imports: [
    RouterOutlet,
    RouterLink,
    RouterLinkActive
  ],
  templateUrl: './app-shell.html',
  styleUrl: './app-shell.scss'
})
export class AppShell {
  private readonly deckStore = inject(DeckStore);
  ngOnInit() {
    this.deckStore.loadDecks();
  }
}
