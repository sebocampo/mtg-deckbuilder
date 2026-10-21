
import { Component, computed, inject } from '@angular/core';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { DeckStore } from '../data-access/deck.store';

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
}
