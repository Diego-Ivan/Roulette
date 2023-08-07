/* GLArcNode.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class GLArcNode : ValidatableNode, ArcNode {
    private Bytes shader_args;
    private Gsk.GLShaderNode shader_node;

    private Gsk.GLShader _shader;
    public Gsk.GLShader shader {
        get {
            return _shader;
        }
        set {
            _shader = value;
            valid = false;
        }
    }

    private Gdk.RGBA _color;
    public Gdk.RGBA color {
        get {
            return _color;
        }
        set {
            _color = value;
            rebuild_args ();
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
            rebuild_args ();
            valid = false;
        }
    }

    public GLArcNode (float angle, Gsk.GLShader shader) {
        this.shader = shader;
        this.angle_degrees = angle;
    }

    private void rebuild_args () {
        var args_builder = new Gsk.ShaderArgsBuilder (shader, null);
        var color_vector = Graphene.Vec4 ().init (
            color.red, color.green, color.blue, color.alpha
        );

        args_builder.set_vec4 (0, color_vector);
        args_builder.set_float (1, angle_degrees);
        shader_args = args_builder.to_args ();
    }

    public override Gsk.RenderNode render () {
        if (valid) {
            return shader_node;
        }
        debug ("Node's no longer valid. Rebuilding");

        shader_node = new Gsk.GLShaderNode (shader, bounds, shader_args, null);
        valid = true;
        return shader_node;
    }
}
