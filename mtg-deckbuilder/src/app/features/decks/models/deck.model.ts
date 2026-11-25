import { DeckFormat } from "./deck.format";

export interface Deck {
  id: string;
  name: string;
  commanderScryfallId: string | null;
  format: DeckFormat;
  cards: DeckCard[];
  createdAt: string;
  updatedAt: string;
}

export interface DeckCard {
  scryfallId: string;
  oracleId: string;
  quantity: number;
}

export function deckCardCount(deck: Deck): number {
  const fromCards = deck.cards.reduce((total, card) => total + card.quantity, 0);
  return fromCards + (deck.commanderScryfallId ? 1 : 0);
}
