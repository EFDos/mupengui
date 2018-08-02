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
    public class DisplaySettingsPage : Granite.SimpleSettingsPage {
        public DisplaySettingsPage () {
            Object (
                //activable: true,
                description: "Configure Mupen64 Display Settings.",
                header: "General",
                icon_name: "video-display",
                title: "Display Settings"
            );
        }

        construct {
            /*var modal = new Granite.Widgets.ModeButton ();
            modal.append_text ("Fullscreen");
            modal.append_text ("Windowed");*/

            var settings = new Services.DisplaySettings ();

            var fullscreen_label = new Gtk.Label ("Fullscreen");
            var fullscreen_switch = new Gtk.Switch ();

            fullscreen_switch.state_set.connect ((state) => {
              //  settings.fullscreen = state;
                print(state.to_string ());
            });

            content_area.attach (fullscreen_label, 0, 0, 1, 1);
            content_area.attach (fullscreen_switch, 1, 0, 1, 1);
        }
    }
}
