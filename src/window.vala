/* window.vala
 *
 * Copyright 2023 Diego Iván
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

namespace Roulette {
    [GtkTemplate (ui = "/io/github/diegoivan/roulette/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned SpinningRoulette roulette;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            var model = new ListStore (typeof (RouletteItem));
            for (int i = 0; i < 10; i++) {
                model.append (new RouletteItem ());
            }

            roulette.model = model;
        }

        [GtkCallback]
        private void on_animation_button_clicked () {
            roulette.run_animation ();
        }

        [GtkCallback]
        private async void on_save_node_button_clicked () {
            var snapshot = new Gtk.Snapshot ();
            roulette.snapshot (snapshot);

            Gsk.RenderNode node = snapshot.free_to_node ();
            try {
                var file_dialog = new Gtk.FileDialog ();
                File save_file = yield file_dialog.save (this, null);
                node.write_to_file (save_file.get_path ());
            }
            catch (Error e) {
                critical (e.message);
            }
        }
    }
}
