import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DeckStore } from '../data-access/deck.store';
import { deckCardCount } from '../models/deck.model';
@Component({
  selector: 'app-deck-library',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './deck-library.html',
  styleUrl: './deck-library.scss',
})
export class DeckLibrary {
  private readonly deckStore = inject(DeckStore);
  protected readonly decks = this.deckStore.decks;
  protected readonly error = this.deckStore.error;
  protected readonly deckCardCount = deckCardCount;

  ngOnInit() {
    this.deckStore.clearError();
    this.deckStore.loadDecks();
  }
}
