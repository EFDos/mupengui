/************************************************************************/
/*  Application.vala                                                    */
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

namespace MupenGUI {
    public class Application : Granite.Application {

        public Application () {
            Object(
                application_id: "com.github.efdos.mupen-gui",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate () {
            var window = new Gtk.ApplicationWindow (this);

            FileSystem.window_ref = window;

            var main = new Views.RomListView ();
            var headerbar = new Views.Window.HeaderBar ();

            ActionManager.instance.get_action (Actions.Rom.ROM_DIRECTORY_CHOSEN)
                    .activate.connect(() => {
                        print("change dir action received");
                        print("current rom dir: %s", Globals.CURRENT_ROM_DIR);
                        main.set_directory_name (Globals.CURRENT_ROM_DIR);
                });

            window.set_titlebar (headerbar);
            window.title = "MupenGUI";
            window.set_default_size (900, 640);
            window.add (main);
            window.show_all ();
        }

        public static int main (string[] args) {

            var app = new MupenGUI.Application ();
            return app.run (args);
        }
    }
}
