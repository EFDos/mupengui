/************************************************************************/
/*  SettingsView.vala                                                   */
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
namespace MupenGUI.Views {
    public class SettingsView : Gtk.Paned {
        private Granite.HeaderLabel profile_label;
        private Gtk.Stack stack;

        construct {
            Services.SettingsProfileManager.instance.init();

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);

            stack = new Gtk.Stack();

            stack.add_named(new Views.Settings.GeneralSettingsPage (), "general_page");
            stack.add_named(new Views.Settings.DisplaySettingsPage (), "display_page");
            stack.add_named(new Views.Settings.InputSettingsPage (), "input_page");

            var settings_sidebar = new Granite.SettingsSidebar(stack);

            profile_label = new Granite.HeaderLabel("Profile: " +
                Services.SettingsProfileManager.instance.current_profile);
            profile_label.set_halign(Gtk.Align.CENTER);
            profile_label.get_style_context().add_class(Granite.STYLE_CLASS_H4_LABEL);

            box.pack_start(profile_label, false, true, 0);
            box.pack_start(stack);
            box.homogeneous = false;

            add(settings_sidebar);
            add(box);
        }

        public void on_profile_update() {
            var profile_string = Services.SettingsProfileManager.instance.current_profile;
            profile_label.label = profile_string;

            var general_page = stack.get_child_by_name("general_page") as Views.Settings.GeneralSettingsPage;
            general_page.on_profile_update();
        }
    }
}
