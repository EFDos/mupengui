/************************************************************************/
/*  DisplaySettingsPage.vala                                           */
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

namespace MupenGUI.Views.Settings {
    public class InputSettingsPage : Granite.SimpleSettingsPage {
        public InputSettingsPage () {
            Object (
                //activable: true,
                description: "Configure Mupen64 Input Settings.",
                icon_name: "input-gaming",
                title: "Input Settings"
            );
        }

        construct {

            var settings = new Services.InputSettings ();

            var device_label = new Gtk.Label ("Input Device");
            var device_name_box = new Gtk.ListBox ();

            var keyboard_entry = new Gtk.Entry ();
            keyboard_entry.set_text("keyboard");

            device_name_box.insert(keyboard_entry, 0);
            /*fullscreen_switch.state_set (settings.fullscreen);

            fullscreen_switch.state_set.connect ((state) => {
                settings.fullscreen = state;
                print(state.to_string ());
            });*/

            content_area.attach (device_label, 0, 0, 1, 1);
            content_area.attach (device_name_box, 1, 0, 1, 1);
        }
    }
}
