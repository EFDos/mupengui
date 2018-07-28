/************************************************************************/
/*  RomListView.vala                                                    */
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

using MupenGUI.Services;

namespace MupenGUI.Views {
    class RomListView : Gtk.Box {

        private Gtk.ListBox list;
        private Granite.HeaderLabel dir_label;

        construct {
            list = new Gtk.ListBox ();
            dir_label = new Granite.HeaderLabel ("Directory");
            dir_label.set_padding(4, 0);
            this.orientation = Gtk.Orientation.VERTICAL;
            this.pack_start (dir_label, false, false, 2);
            this.pack_start (list, true, true, 0);
        }

        public async void populate_list (string dir_name) {

            this.clear_list ();

            var rom_list = yield FileSystem.list_dir_files (Globals.CURRENT_ROM_DIR, true);

            foreach (string s in rom_list) {
                print("%s\n", s);
                var label = new Gtk.Label (s);
                label.halign = Gtk.Align.START;
                label.set_padding(4, 0);
                list.add (label);
                list.show_all ();
            }
        }

        public void clear_list () {
            foreach (var child in list.get_children ()) {
                //child.destroy ();
                list.remove (child);
                child.destroy ();
            }
        }

        public void set_directory_name (string dir_name) {
            dir_label.label = dir_name;
        }
    }
}
