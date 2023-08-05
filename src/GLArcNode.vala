/* GLArcNode.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class GLArcNode : ValidatableNode, ArcNode {
    private Gsk.Renderer renderer;
    private Gsk.GLShader shader;
    private string shader_resource;

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

    public GLArcNode (float angle, Gsk.Renderer renderer, string resource_path) {
        this.angle_degrees = angle;
        this.renderer = renderer;
        this.shader_resource = resource_path;

        shader = new Gsk.GLShader.from_resource (shader_resource);
    }

    public override Gsk.RenderNode render () {
        assert_not_reached ();
    }
}
