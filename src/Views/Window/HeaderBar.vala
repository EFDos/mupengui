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
using MupenGUI;
using MupenGUI.Services;

namespace MupenGUI.Views.Window {
   public class HeaderBar : Gtk.HeaderBar {

        private bool settings_open = false;

        construct {
            var button_settings = new Gtk.Button.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
            var button_rom_dir = new Gtk.Button.from_icon_name ("folder-saved-search", Gtk.IconSize.LARGE_TOOLBAR);
            var button_play_rom = new Gtk.Button.from_icon_name ("media-playback-start-symbolic", Gtk.IconSize.MENU);


            this.get_style_context ().add_class ("default-decoration");
            //css_context.add_class (Gtk.STYLE_CLASS_FLAT);
            this.show_close_button = true;
            this.pack_start (button_play_rom);
            this.pack_start (button_rom_dir);
            this.pack_end (button_settings);

            var manager = ActionManager.instance;

            button_settings.clicked.connect (() => {
                if (!settings_open) {
                    manager.dispatch (Actions.General.SETTINGS_OPEN);
                    settings_open = true;
                } else {
                    manager.dispatch (Actions.General.SETTINGS_CLOSE);
                    settings_open = false;
                }
            });

            button_rom_dir.clicked.connect (() => {
                var res = FileSystem.choose_dir ("Select Roms Directory");
                if (res != null) {
                    Globals.CURRENT_ROM_DIR = res;
                    manager.dispatch (Actions.Rom.DIRECTORY_CHOSEN);
                }
            });

            button_play_rom.clicked.connect (() => {
                if (Globals.CURRENT_ROM_PATH != null) {
                    manager.dispatch (Actions.Rom.EXECUTION_REQUESTED);
                } else {
                    manager.application_ref.grant_a_toast ("No ROM is selected.");
                }
            });
        }
    }
}
