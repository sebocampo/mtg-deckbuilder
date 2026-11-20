package com.cartas.backend.decks.model;

public enum DeckFormat {
/**
 * Format rules. Constructor arguments, in order:
 * maxCopies     – most copies of one card (counted by oracle_id) the format allows
 * mainboardSize – deck size for the mainboard
 * exactSize     – true: mainboardSize is exact (Commander 100);
 *                 false: mainboardSize is a minimum (Standard/Pauper 60+)
 * sideboardMax  – most cards allowed in the sideboard (0 = no sideboard)
 */

    COMMANDER(1, 100, true, 0),
    STANDARD(4, 60, false, 15),
    PAUPER(4, 60, false, 15);

    private final int maxCopies;
    private final int mainboardSize;
    private final boolean exactSize;
    private final int sideboardMax;

    DeckFormat(int maxCopies, int mainboardSize, boolean exactSize, int sideboardSize) {
        this.maxCopies = maxCopies;
        this.mainboardSize = mainboardSize;
        this.exactSize = exactSize;
        this.sideboardMax = sideboardSize;
    }

    public int maxCopies() {
        return maxCopies;
    }

    public int mainboardSize() {
        return mainboardSize;
    }

    public boolean exactSize() {
        return exactSize;
    }

    public int sideboardSize() {
        return sideboardMax;
    }
}
