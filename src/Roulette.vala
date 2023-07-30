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
        var animation = new Adw.TimedAnimation (this, 0, 360 * 10, 5000, callback_target) {
            easing = EASE_IN_OUT_CUBIC
        };
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
        debug ("Taking snapshot");
        var bounds = Graphene.Rect () {
            origin = { 0,0 },
            size = { get_width (), get_height () }
        };

        var arc_node = new ArcNode (45) {
            bounds = bounds,
            color = { 1, 0.5f, 1, 1 }
        };

        var transform_rotation = new Gsk.Transform ();
        transform_rotation = transform_rotation.translate ({get_width () /2, get_height () / 2});
        transform_rotation = transform_rotation.scale (0.95f, 0.95f);
        transform_rotation = transform_rotation.rotate ((float) rotation);

        var transform_node = new Gsk.TransformNode (arc_node.render (), transform_rotation);
        snapshot.append_node (transform_node);
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return size_request_mode;
    }
}
