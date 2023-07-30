/* ArcNode.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public sealed class ArcNode : ValidableNode {
    private Gsk.CairoNode cairo_node;

    private Gdk.RGBA _color;
    public Gdk.RGBA color {
        get {
            return _color;
        }
        set {
            if (_color.equal (value)) {
                return;
            }
            _color = value;
            valid = false;
        }
    }

    private double _angle_degrees;
    public double angle_degrees {
        get {
            return _angle_degrees;
        }
        set {
            _angle_degrees = value;
            valid = false;
        }
    }

    public ArcNode (double angle_degrees) {
        this.angle_degrees = angle_degrees;
    }

    public override Gsk.RenderNode render () {
        if (valid) {
            return cairo_node;
        }

        debug ("Node out of date! Rebuilding");

        cairo_node = new Gsk.CairoNode (bounds);
        Cairo.Context ctx = cairo_node.get_draw_context ();

        Graphene.Size size = bounds.size;
        double x = bounds.origin.x;
        double y = bounds.origin.y;
        double radius = size.width * 0.5;

        double angle = angle_degrees * Math.PI / 180;

        ctx.set_line_width (1);
        ctx.set_source_rgba (color.red, color.green, color.blue, color.alpha);
        ctx.line_to (x, y);
        ctx.arc (x, y, radius, 0, angle);
        ctx.line_to (x,y);
        ctx.fill ();
        ctx.stroke ();

        return cairo_node;
    }
}
