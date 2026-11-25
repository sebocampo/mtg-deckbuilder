
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

  readonly deckName = signal('');
  // defaults for now.
  readonly deckFormat = signal(DeckFormat.Commander);
  readonly commanderId = signal('');

  createDeck(name: string, format: DeckFormat, commanderId: string): void {
    const trimmedName = name.trim();
    if (!trimmedName) {
      return;
    }
    this.deckStore.createDeck(trimmedName, format, commanderId);
    this.router.navigate(['/decks']);
  }
}
