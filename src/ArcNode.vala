/* ArcNode.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public interface ArcNode : ValidatableNode {
    public abstract Gdk.RGBA color { get; set; }
    public abstract float angle_degrees { get; set; }
}
