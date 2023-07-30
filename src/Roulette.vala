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
        var animation = new Adw.TimedAnimation (this, 0, 360, 1000, callback_target);
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
            origin = { get_height () / 3, get_height () / 3 },
            size = { get_height () / 6, get_height () / 6 }
        };

        var rotated_snap = new Gtk.Snapshot ();

        var color = Gdk.RGBA () {
            red = 1, green = 0, blue = 0, alpha = 1
        };
        rotated_snap.append_color (color, rect);

        var node = rotated_snap.free_to_node ();

        var transform = new Gsk.Transform ();
        transform = transform.rotate ((float) rotation);
        var transformed_node = new Gsk.TransformNode (node, transform);

        snapshot.append_node (transformed_node);
    }

    private Graphene.Matrix compute_rotation_matrix (double angle_degrees) {
        double radians = angle_degrees * Math.PI * 1/180;
        var matrix = Graphene.Matrix ();
        matrix = matrix.init_from_2d (
            Math.cos (radians), -Math.sin (radians),
            Math.sin (radians), Math.cos (radians),
            0, 0
        );
        return matrix;
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return size_request_mode;
    }
}
