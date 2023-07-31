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

    class construct {
        set_css_name ("roulette");
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

            uint n_nodes = model.get_n_items ();

            // space_arcs = 0.1f * (360 / n_nodes);
            double node_angle = 360 / n_nodes;

            for (int i = 0; i < model.get_n_items (); i++) {
                var node = new ArcNode (node_angle) {
                    bounds = min_bounds,
                };
                float red = (float) Random.double_range (0, 1);
                float green = (float) Random.double_range (0, 1);
                float blue = (float) Random.double_range (0, 1);

                node.color = { red, green, blue, 1 };
                cached_arcs.add (node);
            }

            queue_draw ();
        }
    }

    private float space_arcs = 0;
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
        double node_angle = 360 / n_nodes;

        for (int i = 0; i < removed; i++) {
            cached_arcs.remove_index (position);
        }

        for (int i = 0; i < added; i++) {
            var new_node = new ArcNode (node_angle) {
                bounds = min_bounds
            };
            cached_arcs.insert ((int) position, new_node);
        }

        foreach (ArcNode arc_node in cached_arcs) {
            arc_node.angle_degrees = node_angle;
            float red = (float) Random.double_range (0, 1);
            float green = (float) Random.double_range (0, 1);
            float blue = (float) Random.double_range (0, 1);

            arc_node.color = { 1, 0, 0, 1 };
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

        float scale_factor = 0.95f * (float) size / MIN_SIZE;
        double node_angle = cached_arcs[0].angle_degrees;

        for (int i = 0; i < cached_arcs.length; i++) {
            float offset = i * ((float) node_angle);
            ArcNode arc_node = cached_arcs[i];
            arc_node.bounds = Graphene.Rect () {
                origin = { 0, 0},
                size = { (float) size * 0.95f, (float) size * 0.95f }
            };

            var transform = new Gsk.Transform ();
            transform = transform.translate (midpoint);
            // transform = transform.scale (scale_factor, scale_factor);
            transform = transform.rotate ((float) rotation + offset);

            var transform_node = new Gsk.TransformNode (arc_node.render (), transform);
            snapshot.append_node (transform_node);
        }
    }

    public override Gtk.SizeRequestMode get_request_mode () {
        return size_request_mode;
    }
}

