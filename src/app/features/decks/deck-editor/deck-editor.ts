
import { Component, computed, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { DeckStore } from '../data-access/deck.store';
import { ScryfallService } from '../../cards/data-access/scryfall';
import { take } from 'rxjs';


@Component({
  selector: 'app-deck-editor',
  standalone: true,
  imports: [RouterLink],
  templateUrl: './deck-editor.html',
  styleUrl: './deck-editor.scss',
})
export class DeckEditor {
  private readonly route = inject(ActivatedRoute);
  private readonly deckStore = inject(DeckStore);

  readonly deckId = this.route.snapshot.paramMap.get('id');

  readonly deck = computed(() =>
    this.deckStore.decks().find(d => d.id === this.deckId)
  );


  private readonly scryfall = inject(ScryfallService);

  testScryfall(): void {
    this.scryfall.searchCards('sol ring')
      .pipe(take(1))
      .subscribe({
        next: response => {
          console.log(
            'Scryfall returned:',
            response.total_cards,
            'cards'
          );

          console.log('First card:', response.data[0]);
        },
        error: error => {
          console.error('Scryfall request failed:', error);
        }
      });
  }

}
