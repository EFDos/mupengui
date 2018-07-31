/************************************************************************/
/*  MainView.vala                                                       */
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
    public class MainView : Gtk.Box {

        public Granite.Widgets.Toast toaster {get; construct;}

        construct {
            Gtk.Stack stack = new Gtk.Stack ();
            RomListView rom_view = new RomListView ();
            SettingsView settings_view = new SettingsView ();
            toaster = new Granite.Widgets.Toast ("Info");

            stack.add_named (rom_view, "rom_view");
            stack.add_named (settings_view, "settings_view");

            this.orientation = Gtk.Orientation.VERTICAL;
            this.add (toaster);
            this.pack_start (stack);


            var manager = Services.ActionManager.instance;

            manager.get_action (Actions.Rom.DIRECTORY_CHOSEN).activate.connect(() => {
                rom_view.set_directory_name (Globals.CURRENT_ROM_DIR);
                rom_view.populate_list (Globals.CURRENT_ROM_DIR);
            });

            manager.get_action (Actions.Rom.EXECUTION_REQUESTED).activate.connect(() => {
                if (Globals.CURRENT_ROM_PATH.length == 0) {
                    return;
                }
                var fpath = Globals.CURRENT_ROM_PATH.replace (" ", "\\ ");
                    manager.application_ref.grant_a_toast ("Launching Mupen64plus");
                Granite.Services.System.execute_command ("mupen64plus " + fpath);
            });

            manager.get_action (Actions.General.SETTINGS_OPEN).activate.connect (() => {
                //last_visible_child_name = this.get_visible_child_name ();
                stack.set_visible_child_full("settings_view", Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            });

            manager.get_action (Actions.General.SETTINGS_CLOSE).activate.connect (() => {
                //last_visible_child_name = this.get_visible_child_name ();
                stack.set_visible_child_full("rom_view", Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            });
        }
    }
}
