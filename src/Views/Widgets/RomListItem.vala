/************************************************************************/
/*  RomListItem.vala                                                    */
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

namespace MupenGUI.Views.Widgets {
    class RomListItem : Gtk.Box {

        private Granite.HeaderLabel label;

        public RomListItem(string str) {
            //base (Gtk.Orientation.HORIZONTAL, 0);
            orientation = Gtk.Orientation.HORIZONTAL;
            homogeneous = true;
            halign = Gtk.Align.FILL;
            set_size_request(0, 48);

            label = new Granite.HeaderLabel(str);
            label.set_padding(4, 0);
            pack_start(label);

            var config_image = new Gtk.Button.from_icon_name("document-properties", Gtk.IconSize.LARGE_TOOLBAR);
            config_image.tooltip_text = "Create Settings Profile for this ROM";
            config_image.clicked.connect(() => {
                var profile_name = label.label;
                profile_name.strip();
                profile_name = profile_name.substring(0, profile_name.last_index_of(".z64"));
                profile_name = profile_name.substring(0, profile_name.last_index_of(".n64"));
                profile_name = profile_name.replace(" ", "");
                profile_name = profile_name.replace("[!]", "");
                profile_name = profile_name.replace(" ", "");

                var profile_manager = Services.SettingsProfileManager.instance;
                if (!profile_manager.has_profile(profile_name)) {
                    profile_manager.create_profile(profile_name);
                }
                profile_manager.current_profile = profile_name;

                print("I'VE SET CURRENT PROFILE TO BE: %s\n", profile_manager.current_profile);
                Services.ActionManager.instance.dispatch(Actions.General.SETTINGS_OPEN, true);
            });

            pack_end(config_image);
        }

        public string get_name() {
            return label.label;
        }

    }
}
