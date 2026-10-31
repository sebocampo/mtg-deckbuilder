
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';

import {
    MtgCard,
    ScryfallSearchResponse
} from '../models/mtg-card.model';

@Injectable({
    providedIn: 'root'
})
export class ScryfallService {
    private readonly http = inject(HttpClient);

    private readonly baseUrl = 'https://api.scryfall.com';

    searchCards(query: string): Observable<ScryfallSearchResponse> {
        const params = new HttpParams()
            .set('q', query)
            .set('unique', 'cards');

        return this.http.get<ScryfallSearchResponse>(
            `${this.baseUrl}/cards/search`,
            { params }
        );
    }

    getCard(id: string): Observable<MtgCard> {
        return this.http.get<MtgCard>(
            `${this.baseUrl}/cards/${encodeURIComponent(id)}`
        );
    }
}
