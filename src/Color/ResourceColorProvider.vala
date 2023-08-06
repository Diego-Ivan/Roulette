/* ResourceColorProvider.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

/**
 * A color provider that obtains the colors from a text file in a resource path. The file must be
 * a plain text file, with the colors separated by a line break. For instance:
 *
 * red
 * green
 * rgb(32,35,98)
 *
 * It accepts formats accepted by Gdk.RGBA.parse (), which are:
 *
 * * Standard name representation (CSS)
 * * Hexadecimal values
 * * rgb(r,g,b) and rgba(r,g,b,a) formats
 * * HSL colors in the form hsl(h,s,l)
 * * HSLA colors in the form hsla(h,s,l,a);
 */
public class ResourceColorProvider : ColorProvider, Object {
    private GenericArray<Gdk.RGBA?> color_array = new GenericArray<Gdk.RGBA?> ();

    public override int n_items {
        get {
            return color_array.length;
        }
    }

    private string _resource_path;
    public string resource_path {
        get {
            return _resource_path;
        }
        construct {
            _resource_path = value;
            var resource_file = File.new_for_uri (@"resource://$value");
            read_color_file (resource_file);
        }
    }

    private void read_color_file (File file) {
        try {
            FileInfo file_info = file.query_info ("standard::*", NOFOLLOW_SYMLINKS, null);
            string? content_type = file_info.get_content_type ();

            if (content_type != "text/plain") {
                critical ("File type not accepted! The file must be a plain text file");
                return;
            }

            var stream = new DataInputStream (file.read ());
            string? line;

            // Reading file while there are lines
            int n_line = 1;
            while ((line = stream.read_line ()) != null) {
                var color = Gdk.RGBA ();
                bool success = color.parse (line);

                if (success) {
                    color_array.add (color);
                }
                else {
                    warning (@"Color $line in line $n_line is not a valid color for Gdk.RGBA");
                }
                n_line++;
            }
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    public new Gdk.RGBA @get (int index)
        requires (index < color_array.length)
    {
        return color_array[index];
    }

    public ColorProviderIterator iterator () {
        return new ResourceColorIterator (color_array);
    }

    private class ResourceColorIterator : ColorProviderIterator {
        public GenericArray<Gdk.RGBA?> colors { get; set; }
        private int current_index = 0;

        public ResourceColorIterator (GenericArray<Gdk.RGBA?> array) {
            this.colors = array;
        }

        public bool next () {
            return current_index < colors.length;
        }

        public Gdk.RGBA @get () {
            Gdk.RGBA retval = colors[current_index];
            current_index++;

            return retval;
        }
    }
}
