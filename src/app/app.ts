
import { Component } from '@angular/core';

interface DeckPreview {
  id: number;
  name: string;
  commander: string;
  colors: string[];
  cardCount: number;
  image: string;
}

@Component({
  selector: 'app-root',
  standalone: true,
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App {
  decks: DeckPreview[] = [
    {
      id: 1,
      name: 'The Endless March',
      commander: 'Atraxa, Praetors’ Voice',
      colors: ['W', 'U', 'B', 'G'],
      cardCount: 100,
      image:
        'https://api.scryfall.com/cards/named?exact=Atraxa%2C%20Praetors%27%20Voice&format=image&version=art_crop',
    },
    {
      id: 2,
      name: 'Goblin Mayhem',
      commander: 'Krenko, Mob Boss',
      colors: ['R'],
      cardCount: 92,
      image:
        'https://api.scryfall.com/cards/named?exact=Krenko%2C%20Mob%20Boss&format=image&version=art_crop',
    },
    {
      id: 3,
      name: 'Angelic Ascension',
      commander: 'Giada, Font of Hope',
      colors: ['W'],
      cardCount: 78,
      image:
        'https://api.scryfall.com/cards/named?exact=Giada%2C%20Font%20of%20Hope&format=image&version=art_crop',
    },
  ];
}
