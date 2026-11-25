import { Injectable, signal, computed, inject } from '@angular/core';
import { Deck, DeckCard } from '../models/deck.model';
import { DeckService } from './deck.service';
import { DeckFormat } from '../models/deck.format';

@Injectable({
    providedIn: 'root'
})
export class DeckStore {

    private readonly deckService = inject(DeckService);
    private readonly _decks = signal<Deck[]>([]);
    readonly decks = this._decks.asReadonly();
    readonly deckCount = computed(() => this._decks().length);

    private readonly _error = signal<string | null>(null);
    readonly error = this._error.asReadonly();

    loadDecks(): void {
        this.deckService.getDecks().subscribe({
            next: decks => {
                this._decks.set(decks);
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error retrieving decks');
            }
        })
    }

    getDeckById(id: string): Deck | undefined {
        return this._decks().find(deck => deck.id === id);
    }

    createDeck(name: string, format: DeckFormat, commanderId: string): void {
        this.deckService.createDeck(name, format, commanderId).subscribe({
            next: deck => {
                this._decks.update(decks => [...decks, deck]);
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error creating deck');
            }
        });
    }

    renameDeck(id: string, newName: string): void {
        const updatedName = newName.trim();
        if (!updatedName) {
            this._error.set('Deck name cannot be empty');
            return;
        }

        this.deckService.renameDeck(id, updatedName).subscribe({
            next: updatedDeck => {
                this._decks.update(decks => decks.map(deck => deck.id === id ? updatedDeck : deck));
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error renaming deck');
            }
        });
    }

    deleteDeck(id: string): void {
        this.deckService.deleteDeck(id).subscribe({
            next: () => {
                this._decks.update(decks => decks.filter(deck => deck.id !== id));
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error deleting deck');
            }
        });
    }

    setCommander(deckId: string, commanderScryfallId: string): void {
        this.deckService.setCommander(deckId, commanderScryfallId).subscribe({
            next: updatedDeck => {
                this._decks.update(decks => decks.map(deck => deck.id === deckId ? updatedDeck : deck));
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error setting commander');
            }
        });
    }

    removeCommander(deckId: string): void {
        this.deckService.removeCommander(deckId).subscribe({
            next: updatedDeck => {
                this._decks.update(decks => decks.map(deck => deck.id === deckId ? updatedDeck : deck));
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error removing commander');
            }
        });
    }

    addCardToDeck(deckId: string, card: DeckCard): void {
        this.deckService.addCardToDeck(deckId, card.scryfallId, card.quantity).subscribe({
            next: updatedDeck => {
                this._decks.update(decks => decks.map(deck => deck.id === deckId ? updatedDeck : deck));
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error adding card to deck');
            }
        });
    }

    updateCardQuantity(deckId: string, card: DeckCard): void {
        this.deckService.updateCardQuantity(deckId, card.scryfallId, card.quantity).subscribe({
            next: updatedDeck => {
                this._decks.update(decks => decks.map(deck => deck.id === deckId ? updatedDeck : deck));
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error updating card quantity');
            }
        });
    }

    removeCard(deckId: string, scryfallId: string): void {
        this.deckService.removeCardFromDeck(deckId, scryfallId).subscribe({
            next: updatedDeck => {
                this._decks.update(decks => decks.map(deck => deck.id === deckId ? updatedDeck : deck));
                this._error.set(null);
            },
            error: err => {
                this._error.set(err.error?.detail ?? 'Error removing card from deck');
            }
        });
    }

}