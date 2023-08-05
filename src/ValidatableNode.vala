/* ValidableNode.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public abstract class ValidatableNode {
    public bool valid { get; protected set; default = false; }
    protected Graphene.Rect _bounds;
    public Graphene.Rect bounds {
        get {
            return _bounds;
        }
        set {
            if (_bounds.equal (value)) {
                return;
            }
            _bounds = value;
            valid = false;
        }
    }


    public abstract Gsk.RenderNode render ();
}
