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

        var cairo_node = new Gsk.CairoNode (bounds);
        var context = cairo_node.get_draw_context ();
        draw_triangle (context, bounds);

        var transform = new Gsk.Transform ();
        transform = transform.rotate (-(float) rotation);

        var translation = new Gsk.Transform ();
        translation = translation.translate ( {get_height () / 2, get_height () / 2} );

        transform = translation.transform (transform);

        var transform_node = new Gsk.TransformNode (cairo_node, transform);

        snapshot.append_node (transform_node);
    }

    private void draw_triangle (Cairo.Context ctx, Graphene.Rect bounds) {
        Graphene.Size size = bounds.size;

        double x = bounds.origin.x;
        double y = bounds.origin.y;

        double radius = size.width * 0.5 * 0.95;
        double angle1 = 23 * Math.PI / 180;

        ctx.set_line_width (1);
        ctx.set_source_rgba (1, 0, 0, 1);
        ctx.line_to (x, y);
        ctx.arc_negative (x, y, radius, angle1, 0);
        ctx.line_to (x,y);
        ctx.fill ();
        ctx.stroke ();
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return size_request_mode;
    }
}
