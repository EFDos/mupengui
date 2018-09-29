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

        private string last_visible_child_name;
        private Gtk.Stack stack;
        private UISettings ui_settings;
        private RomListView rom_view;

        construct {
            var welcome_view = new WelcomeView ();
            var settings_view = new SettingsView ();

            stack = new Gtk.Stack ();
            rom_view = new RomListView ();
            ui_settings = new UISettings ();

            toaster = new Granite.Widgets.Toast ("Info");

            if (ui_settings.rom_dir.length == 0 || ui_settings.rom_dir == null) {
                stack.add_named (welcome_view, "welcome_view");
            } else {
                Globals.CURRENT_ROM_DIR = ui_settings.rom_dir;
                update ();
            }

            stack.add_named (rom_view, "rom_view");
            stack.add_named (settings_view, "settings_view");

            this.orientation = Gtk.Orientation.VERTICAL;
            this.add (toaster);
            this.pack_start (stack);

            var manager = ActionManager.instance;

            manager.get_action (Actions.Rom.DIRECTORY_CHOSEN).activate.connect(() => {
                update ();
            });

            manager.get_action (Actions.Rom.EXECUTION_REQUESTED).activate.connect(() => {
                if (Globals.CURRENT_ROM_PATH.length == 0) {
                    return;
                }

                var display_settings = new DisplaySettings ();
                var rom_data = Services.FileSystem.load_rom_file (Globals.CURRENT_ROM_PATH);

                if (Mupen64API.instance.run_command (Mupen64API.m64Command.ROM_OPEN,
                                                      (int) rom_data.get_size (),
                                                      rom_data.get_buffer ()))
                {
                    manager.application_ref.grant_a_toast ("Executing Rom: " + Mupen64API.instance.get_rom_goodname ());
                    Mupen64API.instance.start_emulation.begin ();
                } else {
                    manager.application_ref.grant_a_toast ("Error loading Rom File: " + Globals.CURRENT_ROM_PATH);
                }
            });

            manager.get_action (Actions.General.SETTINGS_OPEN).activate.connect (() => {
                last_visible_child_name = stack.get_visible_child_name ();
                stack.set_visible_child_full("settings_view", Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            });

            manager.get_action (Actions.General.SETTINGS_CLOSE).activate.connect (() => {
                stack.set_visible_child_full(last_visible_child_name, Gtk.StackTransitionType.SLIDE_LEFT_RIGHT);
            });
        }

        public void update () {
            rom_view.set_directory_name (Globals.CURRENT_ROM_DIR);
            rom_view.populate_list.begin (Globals.CURRENT_ROM_DIR);

            ui_settings.rom_dir = Globals.CURRENT_ROM_DIR;

            stack.set_visible_child_full ("rom_view", Gtk.StackTransitionType.CROSSFADE);
        }
    }
}
