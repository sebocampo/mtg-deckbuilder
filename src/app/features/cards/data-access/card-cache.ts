
import { Injectable, inject } from '@angular/core';
import {
  Observable,
  catchError,
  shareReplay,
  throwError
} from 'rxjs';

import { ScryfallService } from './scryfall';
import { MtgCard } from '../models/mtg-card.model';

@Injectable({
  providedIn: 'root'
})
export class CardCacheService {
  private readonly scryfall = inject(ScryfallService);

  private readonly cache = new Map<
    string,
    Observable<MtgCard>
  >();

  getCard(id: string): Observable<MtgCard> {

    // 1. Return the existing Observable if cached.
    const cached = this.cache.get(id);

    if (cached) {
      return cached;
    }

    // 2. Otherwise, prepare a new request.
    const request$ = this.scryfall.getCard(id).pipe(
      shareReplay({
        bufferSize: 1,
        refCount: false
      }),

      // 3. Don't keep failed requests in the cache.
      catchError(error => {
        this.cache.delete(id);
        return throwError(() => error);
      })
    );

    // 4. Save the shared Observable.
    this.cache.set(id, request$);

    return request$;
  }

  clear(): void {
    this.cache.clear();
  }
}
