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
using MupenGUI.Services;

namespace MupenGUI.Views.Settings {
    public class DisplaySettingsPage : Granite.SimpleSettingsPage {
        private Gtk.Switch fullscreen_switch;
        private Gtk.Switch vsync_switch;
        private Gtk.Entry resolution_x_entry;
        private Gtk.Entry resolution_y_entry;

        public DisplaySettingsPage () {
            Object (
                //activable: true,
                description: _("Configure Mupen64 Display Settings."),
                header: _("Emulator"),
                icon_name: "video-display",
                title: _("Display Settings")
            );
        }

        construct {

            var fullscreen_label = new Gtk.Label (_("Fullscreen:"));
            fullscreen_switch = new Gtk.Switch ();

            var vsync_label = new Gtk.Label(_("VSync:"));
            vsync_switch = new Gtk.Switch ();

            var resolution_label = new Gtk.Label(_("Resolution:"));
            resolution_x_entry = new Gtk.Entry ();
            resolution_y_entry = new Gtk.Entry ();



            fullscreen_label.halign = Gtk.Align.END;
            vsync_label.halign = Gtk.Align.END;
            resolution_label.halign = Gtk.Align.END;

            fullscreen_switch.state_set.connect ((state) => {
                Mupen64API.instance.set_parameter_bool ("Video-General", "Fullscreen", state);
            });

            vsync_switch.state_set.connect ((state) => {
                Mupen64API.instance.set_parameter_bool ("Video-General", "VerticalSync", state);
            });

            resolution_x_entry.max_length = 4;
            resolution_y_entry.max_length = 4;
            resolution_x_entry.set_size_request (0, 0);
            resolution_y_entry.set_size_request (0, 0);

            resolution_x_entry.activate.connect (() => {
                Mupen64API.instance.set_parameter_int(
                    "Video-General",
                    "ScreenWidth",
                    int.parse (resolution_x_entry.text)
                );
            });

            resolution_y_entry.activate.connect (() => {
                Mupen64API.instance.set_parameter_int(
                    "Video-General",
                    "ScreenHeight",
                    int.parse (resolution_y_entry.text)
                );
            });

            content_area.column_homogeneous = false;
            content_area.attach (fullscreen_label, 0, 0, 1, 1);
            content_area.attach (fullscreen_switch, 1, 0, 1, 1);

            content_area.attach (vsync_label, 0, 1, 1, 1);
            content_area.attach (vsync_switch, 1, 1, 1, 1);

            content_area.attach (resolution_label, 0, 2, 1, 1);
            content_area.attach (resolution_x_entry, 2, 2, 1, 1);
            content_area.attach (resolution_y_entry, 3, 2, 1, 1);

            update_settings();

            Services.ActionManager.instance.get_action(MupenGUI.Actions.SettingsUpdate.MUPEN_SETTINGS_UPDATE).activate.connect(() => {
                update_settings();
            });
        }

        private void update_settings() {
            bool fullscreen_state = Mupen64API.instance.get_parameter_bool ("Video-General", "Fullscreen");
            bool vsync_state = Mupen64API.instance.get_parameter_bool ("Video-General", "VerticalSync");

            int res_x = Mupen64API.instance.get_parameter_int ("Video-General", "ScreenWidth");
            int res_y = Mupen64API.instance.get_parameter_int ("Video-General", "ScreenHeight");

            fullscreen_switch.state_set(fullscreen_state);
            vsync_switch.state_set (vsync_state);

            resolution_x_entry.text = res_x.to_string ();
            resolution_y_entry.text = res_y.to_string ();
        }
    }
}
