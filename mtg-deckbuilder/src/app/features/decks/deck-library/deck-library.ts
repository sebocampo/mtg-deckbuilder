import { Component, inject } from '@angular/core';
import { RouterLink } from '@angular/router';
import { DeckStore } from '../data-access/deck.store';

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
}
