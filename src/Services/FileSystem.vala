/************************************************************************/
/*  FileSystem.vala                                                     */
/************************************************************************/
/*                       This file is part of:                          */
/*                           MupenGUI                                   */
/*               https://github.com/efdos/mupengui                      */
/************************************************************************/
/* Copyright (c) 2018 Douglas Muratore                                  */
/*                                                                      */
/* This program is free software; you can redistribute it and/or        */
/* modify it under the terms of the GNU General Public                  */
/* License as published by the Free Software Foundation; either         */
/* version 2 of the License, or (at your option) any later version.     */
/*                                                                      */
/* This program is distributed in the hope that it will be useful,      */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of       */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU    */
/* General Public License for more details.                             */
/*                                                                      */
/* You should have received a copy of the GNU General Public            */
/* License along with this program; if not, write to the                */
/* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,     */
/* Boston, MA 02110-1301 USA                                            */
/*                                                                      */
/* Authored by: Douglas Muratore <www.sinz.com.br>                      */
/************************************************************************/

namespace MupenGUI.Services.FileSystem {

    public static Gtk.ApplicationWindow window_ref = null;

    public class BinaryRomData : Object {
        private uint8[] buffer = null;
        private long size = 0;

        public BinaryRomData (uint8[] data, long psize) {
            if (data == null || psize == 0) {
                return;
            }
            buffer = new uint8[psize];
            Memory.copy (buffer, data, psize);
            size = psize;
        }

        public uint8[] get_data () { return buffer; }
        public long get_size () { return size; }
    }

    public static BinaryRomData load_rom_file (string path) {
        try {
            File file = File.new_for_path (path);

            var file_stream = file.read ();
            var data_stream = new DataInputStream (file_stream);
            data_stream.set_byte_order (DataStreamByteOrder.LITTLE_ENDIAN);

            long rom_length = 0;
            file_stream.seek (0, SeekType.END);
            rom_length = (long)file_stream.tell ();
            file_stream.seek (0, SeekType.SET);

            uint8[] buffer = new uint8[rom_length];

            data_stream.read (buffer);

            return new BinaryRomData (buffer, rom_length);
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
            return new BinaryRomData (null, 0);
        }
    }

    public static string choose_dir (string dialog_title) {

        string return_string = "";

        var chooser = new Gtk.FileChooserDialog (
            dialog_title,
            FileSystem.window_ref,
            Gtk.FileChooserAction.SELECT_FOLDER,
            "_Cancel",
            Gtk.ResponseType.CANCEL,
            "_Open",
            Gtk.ResponseType.ACCEPT
        );

        var filter = new Gtk.FileFilter ();

        filter.add_mime_type ("inode/directory");
        filter.add_pattern ("*.n64");
        filter.add_pattern ("*.N64");
        filter.add_pattern ("*.z64");
        filter.add_pattern ("*.Z64");

        chooser.set_filter (filter);

        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
           return_string = chooser.get_filename ();
        }

        chooser.close ();

        return return_string;
    }

    public static async string[] list_dir_files (string dir_name, bool recursive = false) {

        File dir = File.new_for_path (dir_name);
        string[] files = {};

        if (!dir.query_exists ()) {
            print ("list_dir_files: Directory %s doesn't exist.\n", dir_name);
            return files;
        } else if (dir.query_file_type (0) != FileType.DIRECTORY) {
            print ("list_dir_files: %s is not a directory.\n", dir_name);
            return files;
        }

        try {
            var enumerator = yield dir.enumerate_children_async (FileAttribute.STANDARD_NAME, 0, Priority.DEFAULT);

            while (true) {

                var nfiles = yield enumerator.next_files_async (10, Priority.DEFAULT);

                if (nfiles == null) {
                    break;
                }

                foreach (var file_info in nfiles) {

                    if (file_info.get_file_type () == FileType.DIRECTORY && recursive) {

                    var file_array = yield list_dir_files (dir_name + "/" + file_info.get_name (), true);

                    foreach (string s in file_array) {
                        files += s;
                    }

                    } else if (file_info.get_file_type () == FileType.REGULAR) {

                        var fname = file_info.get_name ().down ();

                        if (fname.has_suffix (".n64") || fname.has_suffix (".z64")) {
                            files += file_info.get_name ();
                        }

                    }

                }


            }
        } catch (Error _error) {
            error ("list_dir_files: " + _error.message);
        }

        return files;
    }
}
