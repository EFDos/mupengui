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
    public class RomListView : Gtk.Box {

        public bool valid_dir = false;
        private Gtk.ListBox list;
        private Gtk.Label dir_label;

        construct {
            list = new Gtk.ListBox();
            dir_label = new Gtk.Label("Directory:");

            dir_label.set_halign(Gtk.Align.CENTER);
            dir_label.get_style_context().add_class(Granite.STYLE_CLASS_H4_LABEL);

            this.orientation = Gtk.Orientation.VERTICAL;
            this.pack_start (dir_label, false, true, 0);
            this.pack_start (list, true, true, 0);

            list.row_selected.connect((row) => {
                if (row != null) {
                    var rom_item = row.get_child() as Views.Widgets.RomListItem;
                    Globals.CURRENT_ROM_PATH = Globals.CURRENT_ROM_DIR + "/" + rom_item.get_name();
                }
            });

            list.activate_cursor_row.connect((row) => {
                ActionManager.instance.dispatch(Actions.Rom.EXECUTION_REQUESTED);
            });
        }

        public async void populate_list(string dir_name) {

            Globals.CURRENT_ROM_PATH = null;
            this.clear_list ();

            var rom_list = yield FileSystem.list_dir_files(Globals.CURRENT_ROM_DIR);

            if (rom_list.length == 0) {
                ActionManager.instance.application_ref.grant_a_toast("No N64 Roms found in directory");
                var label = new Granite.HeaderLabel("Romless Directory");
                label.halign = Gtk.Align.CENTER;
                list.add(label);
                list.show_all();
                return;
            }

            valid_dir = true;
            foreach (string s in rom_list) {
                list.add(new Views.Widgets.RomListItem(s));
                list.add(new Gtk.Separator(Gtk.Orientation.HORIZONTAL));
                list.show_all();
            }
        }

        public bool on_valid_dir() {
            return valid_dir;
        }

        public void clear_list() {
            valid_dir = false;
            foreach (var child in list.get_children ()) {
                list.remove(child);
                child.destroy();
            }
        }

        public void set_directory_name(string dir_name) {
            //status_bar.push (0, "Directory: " + dir_name);
            dir_label.set_text("Directory: " + dir_name);
        }
    }
}
