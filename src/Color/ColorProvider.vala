/* ColorProvider.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/**
 * A class that contains the colors that the roulette can use
 */
public interface ColorProvider : Object {
    public abstract int n_items { get; }
    public abstract new Gdk.RGBA @get (int index);
    public abstract ColorProviderIterator iterator ();
}

public interface ColorProviderIterator {
    public abstract Gdk.RGBA @get ();
    public abstract bool next ();
}
