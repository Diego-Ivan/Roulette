/* ArcNode.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public sealed class CairoArcNode : ValidatableNode, ArcNode {
    private Gsk.CairoNode cairo_node;
    private Gsk.TransformNode transform_node;

    private Cairo.Antialias antialias = FAST;

    private Gdk.RGBA _color;
    public Gdk.RGBA color {
        get {
            return _color;
        }
        set {
            _color = value;
            valid = false;
        }
    }

    private float _angle_degrees;
    public float angle_degrees {
        get {
            return _angle_degrees;
        }
        set {
            _angle_degrees = value;
            valid = false;
        }
    }

    public CairoArcNode (float angle_degrees) {
        this.angle_degrees = angle_degrees;
    }

    public override Gsk.RenderNode render () {
        if (valid) {
            return transform_node;
        }

        cairo_node = new Gsk.CairoNode (bounds);
        Cairo.Context ctx = cairo_node.get_draw_context ();

        Graphene.Size size = bounds.size;
        double x = size.width * 0.5;
        double y = size.width * 0.5;
        double radius = size.width * 0.5;

        double angle = angle_degrees * Math.PI / 180;

        ctx.set_antialias (antialias);
        ctx.set_line_width (10);
        ctx.set_source_rgba (color.red, color.green, color.blue, color.alpha);
        ctx.line_to (x, y);
        ctx.arc (x, y, radius, 0, angle);
        ctx.line_to (x,y);
        ctx.fill ();
        ctx.stroke ();

        var transform = new Gsk.Transform ();
        transform = transform.translate ({-(float) x, -(float) y});
        transform_node = new Gsk.TransformNode (cairo_node, transform);

        valid = true;

        return transform_node;
    }
}
