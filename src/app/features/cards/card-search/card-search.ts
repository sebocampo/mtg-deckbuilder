
import { Component, inject, signal } from '@angular/core';
import { AsyncPipe } from '@angular/common';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import {
  catchError,
  debounceTime,
  distinctUntilChanged,
  map,
  of,
  startWith,
  switchMap
} from 'rxjs';

import { ActivatedRoute, Router } from '@angular/router';
import { DeckStore } from '../../decks/data-access/deck.store';
import { ScryfallService } from '../data-access/scryfall';
import { MtgCard } from '../models/mtg-card.model';

interface SearchState {
  status: 'idle' | 'loading' | 'success' | 'error';
  cards: MtgCard[];
  message?: string;
}

@Component({
  selector: 'app-card-search',
  standalone: true,
  imports: [ReactiveFormsModule, AsyncPipe],
  templateUrl: './card-search.html',
  styleUrl: './card-search.scss'
})
export class CardSearch {
  private readonly scryfall = inject(ScryfallService);

  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly deckStore = inject(DeckStore);

  // Null means we're in the general /search page.
  readonly deckId = this.route.snapshot.paramMap.get('id');

  // True when the user is adding cards to a deck.
  readonly isDeckMode = this.deckId !== null;

  readonly currentDeck = this.deckId
    ? this.deckStore.getDeck(this.deckId)
    : undefined;

  readonly addedMessage = signal('');

  readonly searchControl = new FormControl('', {
    nonNullable: true
  });

  readonly selectedCard = signal<MtgCard | null>(null);

  readonly results$ = this.searchControl.valueChanges.pipe(
    startWith(this.searchControl.value),
    map(value => value.trim()),
    debounceTime(350),
    distinctUntilChanged(),
    switchMap(query => {
      if (query.length < 2) {
        return of<SearchState>({
          status: 'idle',
          cards: []
        });
      }

      return this.scryfall.searchCards(query).pipe(
        map(response => ({
          status: 'success' as const,
          cards: response.data
        })),
        startWith<SearchState>({
          status: 'loading',
          cards: []
        }),
        catchError(error => {
          return of<SearchState>({
            status: error.status === 404 ? 'success' : 'error',
            cards: [],
            message: error.status === 404
              ? 'No matching cards found.'
              : 'Unable to search cards. Please try again.'
          });
        })
      );
    })
  );

  getImage(card: MtgCard): string {
    return card.image_uris?.normal
      ?? card.card_faces?.find(face => face.image_uris)
        ?.image_uris?.normal
      ?? '';
  }


openPreview(card: MtgCard): void {
  this.addedMessage.set('');
  this.selectedCard.set(card);
}

closePreview(): void {
  this.selectedCard.set(null);
  this.addedMessage.set('');
}



  addCardToDeck(card: MtgCard): void {
    const deckId = this.deckId;

    if (!deckId || !this.deckStore.getDeck(deckId)) {
      return;
    }

    this.deckStore.addCard(deckId, {
      scryfallId: card.id,
      quantity: 1
    });

    this.addedMessage.set(`${card.name} added to deck!`);
  }


  backToDeck(): void {
    if (!this.deckId) return;

    void this.router.navigate(['/decks', this.deckId]);
  }


}
