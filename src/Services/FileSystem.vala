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
            error ("list_dir_files: Directory %s doesn't exist.\n", dir_name);
        } else if (dir.query_file_type (0) != FileType.DIRECTORY) {
            error ("list_dir_files: %s is not a directory.\n", dir_name);
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

                        files += file_info.get_name ();
                    }

                }


            }
        } catch (Error _error) {
            error ("list_dir_files: " + _error.message);
        }

        return files;
    }
}
