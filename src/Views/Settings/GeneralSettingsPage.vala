/************************************************************************/
/*  GeneralSettingsPage.vala                                           */
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
    public class GeneralSettingsPage : Granite.SimpleSettingsPage {
        public GeneralSettingsPage () {
            Object (
                //activable: true,
                description: "Configure MupenGUI General Settings.",
                header: "Frontend",
                icon_name: "preferences-system",
                title: "General Settings"
            );
        }

        construct {

            var general_settings = new GeneralSettings ();

            var lib_dir_label = new Gtk.Label ("Mupen64Plus Core Library Directory:");
            var lib_dir_entry = new Gtk.Entry ();

            var plugins_dir_label = new Gtk.Label ("Plugins Base Directory:");
            var plugins_dir_entry = new Gtk.Entry ();

            var video_plugin_label = new Gtk.Label ("Video Plugin:");
            var video_plugin_entry = new Gtk.Entry ();

            var audio_plugin_label = new Gtk.Label ("Audio Plugin:");
            var audio_plugin_entry = new Gtk.Entry ();

            var input_plugin_label = new Gtk.Label ("Input Plugin:");
            var input_plugin_entry = new Gtk.Entry ();

            var rsp_plugin_label = new Gtk.Label ("RSP Plugin:");
            var rsp_plugin_entry = new Gtk.Entry ();

            lib_dir_label.halign = Gtk.Align.END;
            plugins_dir_label.halign = Gtk.Align.END;
            video_plugin_label.halign = Gtk.Align.END;
            audio_plugin_label.halign = Gtk.Align.END;
            input_plugin_label.halign = Gtk.Align.END;
            rsp_plugin_label.halign = Gtk.Align.END;

            lib_dir_entry.set_text (general_settings.mupen64pluslib_dir);
            plugins_dir_entry.set_text (general_settings.mupen64plugin_dir);
            video_plugin_entry.set_text (general_settings.mupen64plugin_video);
            audio_plugin_entry.set_text (general_settings.mupen64plugin_audio);
            input_plugin_entry.set_text (general_settings.mupen64plugin_input);
            rsp_plugin_entry.set_text (general_settings.mupen64plugin_rsp);

            lib_dir_entry.activate.connect (() => {
                general_settings.mupen64pluslib_dir = lib_dir_entry.get_text ();
                Mupen64API.instance.shutdown ();

                if (Mupen64API.instance.init (general_settings.mupen64pluslib_dir)) {
                    var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                        "Mupen64Plus Initalized!",
                        "The Mupen64Plus core library has been found and loaded succesfully! " +
                        "This program is happy now.",
                        "face-smile-symbolic",
                        Gtk.ButtonsType.CLOSE
                    );
                    message_dialog.run ();
                    message_dialog.destroy ();
                }
            });

            plugins_dir_entry.activate.connect (() => {
               Mupen64API.instance.plugins_dir = general_settings.mupen64plugin_dir = plugins_dir_entry.get_text ();
            });

            video_plugin_entry.activate.connect (() => {
                Mupen64API.instance.video_plugin = general_settings.mupen64plugin_video =
                        video_plugin_entry.get_text ();
            });

            audio_plugin_entry.activate.connect (() => {
                Mupen64API.instance.audio_plugin = general_settings.mupen64plugin_audio =
                        audio_plugin_entry.get_text ();
            });

            input_plugin_entry.activate.connect (() => {
                Mupen64API.instance.input_plugin = general_settings.mupen64plugin_input =
                        input_plugin_entry.get_text ();
            });

            rsp_plugin_entry.activate.connect (() => {
                Mupen64API.instance.rsp_plugin = general_settings.mupen64plugin_rsp =
                        rsp_plugin_entry.get_text ();
            });

            content_area.attach (lib_dir_label, 0, 0, 1, 1);
            content_area.attach (lib_dir_entry, 1, 0, 1, 1);
            content_area.attach (plugins_dir_label, 0, 1, 1, 1);
            content_area.attach (plugins_dir_entry, 1, 1, 1, 1);
            content_area.attach (video_plugin_label, 0, 2, 1, 1);
            content_area.attach (video_plugin_entry, 1, 2, 1, 1);
            content_area.attach (audio_plugin_label, 0, 3, 1, 1);
            content_area.attach (audio_plugin_entry, 1, 3, 1, 1);
            content_area.attach (input_plugin_label, 0, 4, 1, 1);
            content_area.attach (input_plugin_entry, 1, 4, 1, 1);
            content_area.attach (rsp_plugin_label, 0, 5, 1, 1);
            content_area.attach (rsp_plugin_entry, 1, 5, 1, 1);
        }
    }
}
