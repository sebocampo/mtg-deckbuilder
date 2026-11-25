import { Component, inject, Signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DeckStore } from '../data-access/deck.store';
import { Deck } from '../models/deck.model';

interface DeckPreview {
  id: number;
  name: string;
  commander: string;
  colors: string[];
  cardCount: number;
  image: string;
}
@Component({
  selector: 'app-deck-library',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './deck-library.html',
  styleUrl: './deck-library.scss',
})
export class DeckLibrary {
  readonly deckStore = inject(DeckStore);
  readonly decks = this.deckStore.decks;
  readonly error = this.deckStore.error;

  ngOnInit() {
    this.deckStore.clearError();
    this.deckStore.loadDecks();
  }

  cardCount(deck: Deck): number {
    const fromCards = deck.cards.reduce((total, card) => total + card.quantity, 0);
    return fromCards + (deck.commanderScryfallId ? 1 : 0);
  }
}
