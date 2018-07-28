/************************************************************************/
/*  HeaderBar.vala                                                      */
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
using Granite;
using Granite.Widgets;
using MupenGUI;
using MupenGUI.Services;

namespace MupenGUI.Views.Window {
    class HeaderBar : Gtk.HeaderBar {
        construct {
            var button_settings = new Gtk.Button
                    .from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);

            Gtk.Button button_rom_dir = new Gtk.Button
                    .from_icon_name ("folder-saved-search",
                                     Gtk.IconSize.LARGE_TOOLBAR);


            this.get_style_context ().add_class ("default-decoration");
            //css_context.add_class (Gtk.STYLE_CLASS_FLAT);
            this.show_close_button = true;
            this.pack_start (button_rom_dir);
            this.pack_end (button_settings);

            button_rom_dir.clicked.connect (() => {
                var res = FileSystem.choose_directory ("Select Roms Directory");
                if (res != null) {
                    Globals.CURRENT_ROM_DIR = res;
                    ActionManager.instance
                            .dispatch (Actions.Rom.ROM_DIRECTORY_CHOSEN);
                }
            });
        }
    }
}
