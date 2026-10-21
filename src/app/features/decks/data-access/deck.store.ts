import { Injectable, signal, computed } from '@angular/core';
import { Deck, DeckCard } from '../models/deck.model';

@Injectable({
    providedIn: 'root'
})
export class DeckStore {

    private readonly _decks = signal<Deck[]>([]);

    readonly decks = this._decks.asReadonly();

    readonly deckCount = computed(() => this._decks().length);

    createDeck(name: string): Deck {
        const now = new Date().toISOString();

        const newDeck: Deck = {
            id: crypto.randomUUID(),
            name: name.trim(),
            commander: null,
            cards: [],
            createdAt: now,
            updatedAt: now
        };

        this._decks.update(decks => [...decks, newDeck]);

        return newDeck;
    }

    getDeck(id: string): Deck | undefined {
        return this._decks().find(deck => deck.id === id);
    }

    renameDeck(id: string, name: string): void {
        const updatedName = name.trim();

        if (!updatedName) return;

        this._decks.update(decks =>
            decks.map(deck =>
                deck.id === id
                    ? {
                        ...deck,
                        name: updatedName,
                        updatedAt: new Date().toISOString()
                    }
                    : deck
            )
        );
    }

    deleteDeck(id: string): void {
        this._decks.update(decks =>
            decks.filter(deck => deck.id !== id)
        );
    }

    addCard(deckId: string, card: DeckCard): void {
        if (card.quantity <= 0) return;

        this._decks.update(decks =>
            decks.map(deck => {
                if (deck.id !== deckId) return deck;

                const existing = deck.cards.find(
                    c => c.scryfallId === card.scryfallId
                );

                const cards = existing
                    ? deck.cards.map(c =>
                        c.scryfallId === card.scryfallId
                            ? { ...c, quantity: c.quantity + card.quantity }
                            : c
                    )
                    : [...deck.cards, card];

                return {
                    ...deck,
                    cards,
                    updatedAt: new Date().toISOString()
                };
            })
        );
    }

    removeCard(deckId: string, scryfallId: string): void {
        this._decks.update(decks =>
            decks.map(deck => {
                if (deck.id !== deckId) return deck;

                const cards = deck.cards
                    .map(card =>
                        card.scryfallId === scryfallId
                            ? { ...card, quantity: card.quantity - 1 }
                            : card
                    )
                    .filter(card => card.quantity > 0);

                return {
                    ...deck,
                    cards,
                    updatedAt: new Date().toISOString()
                };
            })
        );
    }

    setCommander(deckId: string, commander: DeckCard | null): void {
        this._decks.update(decks =>
            decks.map(deck =>
                deck.id === deckId
                    ? {
                        ...deck,
                        commander,
                        updatedAt: new Date().toISOString()
                    }
                    : deck
            )
        );
    }

}