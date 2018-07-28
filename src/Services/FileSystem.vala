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

    public static string choose_directory (string dialog_title) {

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

        chooser.set_filter (filter);

        if (chooser.run () == Gtk.ResponseType.ACCEPT) {
           return_string = chooser.get_filename ();
        }

        chooser.close ();

        return return_string;
    }
}
