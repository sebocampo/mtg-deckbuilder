
import { Component, inject, signal } from '@angular/core';
import { Router, RouterLink } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { DeckStore } from '../data-access/deck.store';
import { DeckFormat } from '../models/deck.format';

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

  readonly deckFormat = signal(DeckFormat);
  readonly scryfallCommanderId = signal<string | null>(null)
  protected readonly deckName = signal('');
  // defaults for now.
  protected readonly error = this.deckStore.error;

  protected readonly formats = Object.values(DeckFormat);

  createDeck(name: string, format: DeckFormat, commanderScryfallId: string | null): void {
    const trimmedName = name.trim();
    if (!trimmedName) {
      return;
    }
    this.deckStore.createDeck(trimmedName, format, commanderScryfallId, created => {
      this.router.navigate(['/decks', created.id]);
    });
  }
}