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
