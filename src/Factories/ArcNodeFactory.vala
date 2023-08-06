/* ArcNodeFactory.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class ArcNodeFactory : Object {
    /**
     * The GLShader to use when the backend is set. It will be compiled during the construction process
     */
    private Gsk.GLShader _gl_shader;
    public Gsk.GLShader gl_shader {
        get {
            return _gl_shader;
        }
        set {
            _gl_shader = value;
            backend = GL;
            compile_shader ();
        }
    }

    public float angle_degrees { get; set; default  = 0; }

    /**
     * The Renderer that will be used to compile the shader in case the chosen backend is GL
     */
    public unowned Gsk.Renderer renderer { get; construct; }

    /**
     * The backend that will be used to render the arcs. Either GL or Cairo
     */
    public ArcBackend backend { get; set; default = GL; }

    public ArcNodeFactory (Gsk.Renderer renderer) {
        Object (renderer: renderer);
    }

    public ArcNode create_node () {
        switch (backend) {
            case GL:
                return new GLArcNode (angle_degrees, gl_shader);
            case CAIRO:
                return new CairoArcNode (angle_degrees);
            default:
                assert_not_reached ();
        }
    }

    private void compile_shader () {
        if (backend == CAIRO) {
            return;
        }

        try {
            gl_shader.compile (renderer);
        } catch (Error e) {
            critical ("Failed to compile shader: %s. Defaulting to Cairo.", e.message);
            backend = CAIRO;
        }
    }
}

public enum ArcBackend {
    CAIRO,
    GL;
}
