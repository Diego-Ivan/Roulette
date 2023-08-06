/* Roulette.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class Roulette.SpinningRoulette : Gtk.Widget {
    private Gtk.SizeRequestMode size_request_mode = HEIGHT_FOR_WIDTH;
    private const int MIN_SIZE = 325;
    private Graphene.Rect min_bounds = Graphene.Rect () {
        origin = { 0,0 },
        size = { MIN_SIZE, MIN_SIZE }
    };

    public ColorProvider color_provider { get; set; }
    private ArcNodeFactory arc_factory;

    class construct {
        set_css_name ("roulette");
    }

    static construct {
        typeof (ResourceColorProvider).ensure ();
    }

    private ListModel _model;
    public ListModel model {
        get {
            return _model;
        }
        set {
            Type item_type = value.get_item_type ();

            if (item_type != typeof (RouletteItem)) {
                critical ("SpinningRoulette requires RouletteItem for its model");
                return;
            }

            _model = value;
            _model.items_changed.connect (on_model_changed);

            queue_draw ();
        }
    }

    private GenericArray<ArcNode> cached_arcs = new GenericArray<ArcNode> ();
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

    private void on_model_changed (uint position, uint removed, uint added) {
        debug ("Model has been changed");
        uint n_nodes = cached_arcs.length - removed + added;
        float node_angle = 360 / n_nodes;

        for (int i = 0; i < removed; i++) {
            cached_arcs.remove_index (position);
        }

        for (int i = 0; i < added; i++) {
            var new_node = new CairoArcNode (node_angle) {
                bounds = min_bounds
            };
            cached_arcs.insert ((int) position, new_node);
        }

        int n_arcs = cached_arcs.length;
        for (int i = 0; i < n_arcs; i++) {
            int @base = color_provider.n_items * (int) Math.floor (i/color_provider.n_items);
            int color_index = i - @base;

            cached_arcs[i].color = color_provider[color_index];
        }
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
        double size = get_width ();
        var midpoint = Graphene.Point () {
            x = (float) size * 0.5f,
            y = (float) size * 0.5f
        };

        float node_angle = cached_arcs[0].angle_degrees;

        for (int i = 0; i < cached_arcs.length; i++) {
            float offset = i * node_angle;
            ArcNode arc_node = cached_arcs[i];
            arc_node.bounds = Graphene.Rect () {
                origin = { 0, 0 },
                size = { (float) size * 0.95f, (float) size * 0.95f }
            };

            var transform = new Gsk.Transform ();
            transform = transform.translate (midpoint);
            transform = transform.rotate ((float) rotation + offset);

            var transform_node = new Gsk.TransformNode (arc_node.render (), transform);
            snapshot.append_node (transform_node);
        }
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return size_request_mode;
    }

    public override void realize () {
        debug ("The roulette has been realized. Compiling GL Shader");
        var shader = new Gsk.GLShader.from_resource ("/io/github/diegoivan/roulette/glsl/arc.glsl");

        arc_factory = new ArcNodeFactory (root.get_renderer ()) {
            gl_shader = shader,
            backend = CAIRO
        };

        cached_arcs = new GenericArray<ArcNode> ();
        arc_factory.angle_degrees = 360 / model.get_n_items ();

        // Fill the array of cached nodes with the desired type of Node:
        for (int i = 0; i < model.get_n_items (); i++) {
            var node = arc_factory.create_node ();

            int @base = color_provider.n_items * (int) Math.floor (i/color_provider.n_items);
            int color_index = i - @base;

            node.color = color_provider[color_index];
            cached_arcs.add (node);
        }

        base.realize ();
    }
}
