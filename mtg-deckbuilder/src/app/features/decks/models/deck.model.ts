export interface Deck {
  id: string;
  name: string;
  commander: DeckCard | null;
  cards: DeckCard[];
  createdAt: string;
  updatedAt: string;
}

export interface DeckCard {
  scryfallId: string;
  quantity: number;
}
