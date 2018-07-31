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

        private Views.MainView main_view;

        public Application () {
            Object(
                application_id: "com.github.efdos.mupen-gui",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate () {
            var window = new Gtk.ApplicationWindow (this);
            var headerbar = new Views.Window.HeaderBar ();
            main_view = new Views.MainView ();

            FileSystem.window_ref = window;
            ActionManager.instance.application_ref = this;

            window.set_titlebar (headerbar);
            window.title = "MupenGUI";
            window.set_default_size (900, 640);
            window.add (this.main_view);
            window.show_all ();
        }

        public void grant_a_toast (string toast_msg) {
            main_view.toaster.title = toast_msg;
            main_view.toaster.send_notification ();
        }

        public static int main (string[] args) {

            var app = new MupenGUI.Application ();
            return app.run (args);
        }
    }
}
