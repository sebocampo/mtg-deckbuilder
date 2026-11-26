
import { Component, computed, inject, input, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { DeckStore } from '../data-access/deck.store';
import { CardCacheService } from '../../cards/data-access/card-cache';
import { toObservable } from '@angular/core/rxjs-interop';
import { forkJoin, of, switchMap, catchError, map } from 'rxjs';
import { MtgCard } from '../../cards/models/mtg-card.model';
import { AsyncPipe } from '@angular/common';
import { Deck, deckCardCount } from '../models/deck.model';
import { DeckFormat } from '../models/deck.format';
import { FormsModule } from '@angular/forms';
import { ConfirmDialog } from '../../../shared/ui/confirm-dialog/confirm-dialog';
@Component({
  selector: 'app-deck-editor',
  standalone: true,
  imports: [RouterLink, AsyncPipe, FormsModule, ConfirmDialog],
  templateUrl: './deck-editor.html',
  styleUrl: './deck-editor.scss',
})
export class DeckEditor {
  private readonly deckStore = inject(DeckStore);
  private readonly cardCache = inject(CardCacheService);
  private readonly router = inject(Router);

  protected readonly id = input.required<string>();

  protected readonly currentDeckCardCount = deckCardCount;

  protected readonly deck = computed(() =>
    this.deckStore.getDeckById(this.id())
  );
  protected readonly isCommanderDeck = computed(() => this.deck()?.format === DeckFormat.Commander);


  protected editing = signal(false);

  protected readonly deckName = signal('');

  protected readonly error = this.deckStore.error;

  ngOnInit() {
    this.deckStore.clearError();
    this.editing.set(false);
  }

  protected readonly deckToDelete = signal<Deck | null>(null);

  confirmDelete(): void {
    const deck = this.deckToDelete();
    if (!deck) return;
    this.deckStore.deleteDeck(deck.id, () => {
      this.deckToDelete.set(null);
      this.router.navigate(['/decks']);
    });
  }

  toggleEdit(flag: boolean): void {
    this.deckStore.clearError();
    if (!flag) {
      this.deckName.set('');
    }
    this.editing.set(flag);
  }

  // Convert our reactive deck signal into an Observable.
  private readonly deck$ = toObservable(this.deck);

  protected readonly cards$ = this.deck$.pipe(
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

  removeCard(scryfallId: string): void {
    this.deckStore.removeCard(this.id(), scryfallId);
  }

  renameDeck(newName: string): void {
    // have logic for checking validation
    this.deckStore.renameDeck(this.id(), newName, () =>
      this.toggleEdit(false)
    );
  }

}
