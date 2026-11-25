import { HttpClient, HttpParams } from "@angular/common/http";
import { inject, Injectable } from "@angular/core";
import { Observable } from "rxjs/internal/Observable";
import { Deck } from "../models/deck.model";
import { DeckFormat } from "../models/deck.format";

@Injectable({ providedIn: 'root' })
export class DeckService {
    http = inject(HttpClient)
    baseUrl = 'http://localhost:8081/api/decks'

    getDecks(): Observable<Deck[]> {
        return this.http.get<Deck[]>(this.baseUrl);
    }

    getDeckById(id: string): Observable<Deck> {
        return this.http.get<Deck>(`${this.baseUrl}/${id}`);
    }

    createDeck(name: string, format: DeckFormat, commanderId?: string): Observable<Deck> {
        return this.http.post<Deck>(this.baseUrl, { name, format, commanderId });
    }

    renameDeck(id: string, newName: string): Observable<Deck> {
        return this.http.patch<Deck>(`${this.baseUrl}/${id}`, { name: newName });
    }

    deleteDeck(id: string): Observable<void> {
        return this.http.delete<void>(`${this.baseUrl}/${id}`);
    }

    setCommander(deckId: string, commanderScryfallId: string): Observable<Deck> {
        return this.http.put<Deck>(`${this.baseUrl}/${deckId}/commander`, { commanderScryfallId });
    }

    removeCommander(deckId: string): Observable<Deck> {
        return this.http.delete<Deck>(`${this.baseUrl}/${deckId}/commander`);
    }

    // Card actions

    addCardToDeck(deckId: string, scryfallId: string, quantity: number): Observable<Deck> {
        return this.http.post<Deck>(`${this.baseUrl}/${deckId}/cards`, { scryfallId, quantity });
    }

    updateCardQuantity(deckId: string, scryfallId: string, quantity: number): Observable<Deck> {
        return this.http.patch<Deck>(`${this.baseUrl}/${deckId}/cards`, { scryfallId, quantity });
    }

    removeCardFromDeck(deckId: string, scryfallId: string): Observable<Deck> {
        return this.http.delete<Deck>(`${this.baseUrl}/${deckId}/cards/${scryfallId}`)
    }

}