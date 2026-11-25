
import { Component, computed, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { DeckStore } from '../data-access/deck.store';
import { CardCacheService } from '../../cards/data-access/card-cache';
import { toObservable } from '@angular/core/rxjs-interop';
import { forkJoin, of, switchMap, catchError, map } from 'rxjs';
import { MtgCard } from '../../cards/models/mtg-card.model';
import { AsyncPipe } from '@angular/common';
import { deckCardCount } from '../models/deck.model';
import { DeckFormat } from '../models/deck.format';
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
  readonly deckCardCount = deckCardCount;
  readonly deck = computed(() =>
    this.deckStore.getDeckById(this.route.snapshot.paramMap.get('id')!)
  );
  readonly isCommanderDeck = computed(() => this.deck()?.format === DeckFormat.Commander);

  // Convert our reactive deck signal into an Observable.
  private readonly deck$ = toObservable(this.deck);

  readonly cards$ = this.deck$.pipe(
    switchMap(deck => {
      if (!deck || deck.cards.length === 0) {
        return of([]);
      }

      return forkJoin(
        deck.cards.map((entry: { scryfallId: string; quantity: any; }) =>
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
