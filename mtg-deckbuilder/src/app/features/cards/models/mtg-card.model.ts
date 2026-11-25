
export interface MtgCard {
    id: string;
    oracle_id: string;
    prints_search_uri?: string;
    name: string;
    set_name: string;
    set: string;
    collector_number: string;
    released_at: string;
    illustration_id?: string;
    finishes?: string[];
    mana_cost?: string;
    cmc: number;
    type_line: string;
    colors?: string[];
    color_identity: string[];
    image_uris?: {
        small: string;
        normal: string;
        art_crop: string;
    };
    card_faces?: {
        name: string;
        image_uris?: {
            small: string;
            normal: string;
            art_crop: string;
        };
    }[];
}

export interface ScryfallSearchResponse {
    object: 'list';
    total_cards: number;
    has_more: boolean;
    next_page?: string;
    data: MtgCard[];
}
