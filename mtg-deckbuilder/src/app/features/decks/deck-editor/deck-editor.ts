
import { Component, computed, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { DeckStore } from '../data-access/deck.store';
import { CardCacheService } from '../../cards/data-access/card-cache';
import { take } from 'rxjs';
import { toObservable } from '@angular/core/rxjs-interop';
import { forkJoin, of, switchMap, catchError, map } from 'rxjs';
import { MtgCard } from '../../cards/models/mtg-card.model';
import { AsyncPipe } from '@angular/common';
@Component({
  selector: 'app-deck-editor',
  standalone: true,
  imports: [RouterLink, AsyncPipe],
  templateUrl: './deck-editor.html',
  styleUrl: './deck-editor.scss',
})
export class DeckEditor {
  private readonly route = inject(ActivatedRoute);
  private readonly deckStore = inject(DeckStore);
  private readonly cardCache = inject(CardCacheService);
  readonly deck = computed(() =>
    this.deckStore.decks().find(d => d.id === this.deckId)
  );

  // Convert our reactive deck signal into an Observable.
  private readonly deck$ = toObservable(this.deck);

  readonly cards$ = this.deck$.pipe(
    switchMap(deck => {
      if (!deck || deck.cards.length === 0) {
        return of([]);
      }

      return forkJoin(
        deck.cards.map(entry =>
          this.cardCache.getCard(entry.scryfallId).pipe(
            map(card => ({
              ...card,
              quantity: entry.quantity
            })),
            catchError(() => of(null))
          )
        )
      ).pipe(
        map(cards =>
          cards.filter(
            (card): card is MtgCard & { quantity: number } =>
              card !== null
          )
        )
      );
    })
  );

  readonly deckId = this.route.snapshot.paramMap.get('id');

  removeCard(scryfallId: string): void {
    if (!this.deckId) return;

    this.deckStore.removeCard(this.deckId, scryfallId);
  }


}
