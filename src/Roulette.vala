/* Roulette.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Roulette.SpinningRoulette : Gtk.Widget {
    private Gtk.SizeRequestMode size_request_mode = HEIGHT_FOR_WIDTH;
    class construct {
        set_css_name ("roulette");
    }

    private const int MIN_SIZE = 325;

    double rotation = 0;

    public void run_animation () {
        var callback_target = new Adw.CallbackAnimationTarget ((value) => {
            rotation = value;
            this.queue_draw ();
        });
        var animation = new Adw.TimedAnimation (this, 0, 1, 400, callback_target);
        animation.play ();
        animation.done.connect (() => {
            rotation = 0;
        });
    }

    public override void measure (
        Gtk.Orientation orientation,
        int for_size,
        out int min,
        out int natural,
        out int min_baseline,
        out int natural_baseline
    ) {
        debug (@"Measuring for $orientation");
        min = MIN_SIZE;
        natural = for_size < MIN_SIZE ? MIN_SIZE : for_size;

        min_baseline = natural_baseline = -1;
        debug (@"min: $min, natural: $natural");
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        debug ("Taking Snapshot...");
        var rect = Graphene.Rect () {
            origin = {0, 0},
            size = { get_height(), get_height () }
        };
        var second_rect = Graphene.Rect () {
            origin = { get_height() / 3, get_height () / 3},
            size = { get_height () / 3, get_height () / 3 }
        };

        snapshot.append_color ({0, 1, 0, 1}, rect);
        snapshot.append_color ( {1, (float) rotation, 0, 1}, second_rect);

        var snap = new Gtk.Snapshot ();
        var third_rect = Graphene.Rect () {
            origin = { 0, 0 },
            size = { get_height () / 4, get_height () / 4 }
        };
        snap.append_color ({0, 0, 1, 1}, third_rect);

        snapshot.append_node (snap.free_to_node ());
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return size_request_mode;
    }
}
