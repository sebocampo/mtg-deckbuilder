
import { Component, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { DeckStore } from '../data-access/deck.store';

@Component({
  selector: 'app-deck-create',
  standalone: true,
  imports: [FormsModule, RouterLink],
  templateUrl: './deck-create.html',
  styleUrl: './deck-create.scss',
})
export class DeckCreate {
  private readonly deckStore = inject(DeckStore);
  private readonly router = inject(Router);

  readonly deckName = signal('');

  createDeck(): void {
    const name = this.deckName().trim();

    if (!name) return;

    const deck = this.deckStore.createDeck(name);

    this.router.navigate(['/decks', deck.id]);
  }
}
