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
        private const string CUSTOM_STYLESHEET = """
            @define-color colorPrimary @BLACK_300;
            @define-color colorAccent @BLUEBERRY_500;
        """;

        public Application() {
            Object(
                application_id: "com.github.efdos.mupengui",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        ~Application() {
            Mupen64API.instance.shutdown();
            JoystickListener.instance.shutdown();
        }

        protected override void activate() {
            // Set and initialize Mupen64 from GeneralSettings
            var general_settings = new GeneralSettings();

            var mupen_api_instance = Mupen64API.instance;

            mupen_api_instance.plugins_dir = general_settings.mupen64plugin_dir;
            mupen_api_instance.video_plugin = general_settings.mupen64plugin_video;
            mupen_api_instance.audio_plugin = general_settings.mupen64plugin_audio;
            mupen_api_instance.input_plugin = general_settings.mupen64plugin_input;
            mupen_api_instance.rsp_plugin = general_settings.mupen64plugin_rsp;

            mupen_api_instance.init(general_settings.mupen64pluslib_dir);

            // Initialize JoystickListener
            JoystickListener.instance.init();

            var window = new Gtk.ApplicationWindow(this);
            var headerbar = new Views.Window.HeaderBar();
            main_view = new Views.MainView();

            FileSystem.window_ref = window;
            ActionManager.instance.application_ref = this;

            window.title = "MupenGUI";
            window.set_titlebar(headerbar);
            window.set_default_size(900, 640);
            window.add(this.main_view);
            window.show_all();

            /*var provider = new Gtk.CssProvider ();

            try {
                provider.load_from_data (CUSTOM_STYLESHEET, -1);
                Gtk.StyleContext.add_provider_for_screen (window.get_screen (), provider,
                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            } catch (Error e) {
                print("Warning: Could not create CSS Provider: %s", e.message);
            }*/
            //Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
        }

        public void grant_a_toast(string toast_msg) {
            main_view.toaster.title = toast_msg;
            main_view.toaster.send_notification();
        }

        public static int main(string[] args) {

            foreach (string arg in args) {
                if (arg == "--verbose" || arg == "-v") {
                    Mupen64API.instance.set_verbose(true);
                }
            }

            var app = new MupenGUI.Application();
            return app.run(args);
        }
    }
}
