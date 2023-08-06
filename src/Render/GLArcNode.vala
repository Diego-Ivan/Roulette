/* GLArcNode.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class GLArcNode : ValidatableNode, ArcNode {
    public static Gsk.GLShader shader;
    private Bytes shader_args;
    private Gsk.GLShaderNode shader_node;

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

    public GLArcNode (float angle) {
        this.angle_degrees = angle;

        var args_builder = new Gsk.ShaderArgsBuilder (shader, null);
        var color_vector = Graphene.Vec4 ().init (
            color.red, color.green, color.blue, color.alpha
        );

        args_builder.set_vec4 (0, color_vector);
        shader_args = args_builder.to_args ();
    }

    public override Gsk.RenderNode render () {
        if (valid) {
            return shader_node;
        }

        shader_node = new Gsk.GLShaderNode (shader, bounds, shader_args, null);
        return shader_node;
    }
}
