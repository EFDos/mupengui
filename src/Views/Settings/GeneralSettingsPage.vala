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

        private Gtk.ComboBoxText video_plugin_combo;
        private Gtk.ComboBoxText audio_plugin_combo;
        private Gtk.ComboBoxText input_plugin_combo;
        private Gtk.ComboBoxText rsp_plugin_combo;

        public GeneralSettingsPage () {
            Object (
                //activable: true,
                description: _("Configure MupenGUI General Settings."),
                header: _("Frontend"),
                icon_name: "preferences-system",
                title: _("General Settings")
            );
        }

        construct {

            var ui_settings = new UISettings ();
            var general_settings = new GeneralSettings ();

            var lib_dir_label = new Gtk.Label (_("Mupen64Plus Core Library Directory:"));
            var lib_dir_entry = new Gtk.Entry ();

            var plugins_dir_label = new Gtk.Label (_("Plugins Base Directory:"));
            var plugins_dir_entry = new Gtk.Entry ();

            var video_plugin_label = new Gtk.Label (_("Video Plugin:"));
            video_plugin_combo = new Gtk.ComboBoxText ();

            var audio_plugin_label = new Gtk.Label (_("Audio Plugin:"));
            audio_plugin_combo = new Gtk.ComboBoxText ();

            var input_plugin_label = new Gtk.Label (_("Input Plugin:"));
            input_plugin_combo = new Gtk.ComboBoxText ();

            var rsp_plugin_label = new Gtk.Label (_("RSP Plugin:"));
            rsp_plugin_combo = new Gtk.ComboBoxText ();

            lib_dir_label.halign = Gtk.Align.END;
            plugins_dir_label.halign = Gtk.Align.END;
            video_plugin_label.halign = Gtk.Align.END;
            audio_plugin_label.halign = Gtk.Align.END;
            input_plugin_label.halign = Gtk.Align.END;
            rsp_plugin_label.halign = Gtk.Align.END;

            lib_dir_entry.set_text (general_settings.mupen64pluslib_dir);
            plugins_dir_entry.set_text (general_settings.mupen64plugin_dir);

            populate_plugin_combos.begin (general_settings.mupen64plugin_dir);

            lib_dir_entry.activate.connect (() => {
                general_settings.mupen64pluslib_dir = lib_dir_entry.get_text ();
                Mupen64API.instance.shutdown ();

                if (Mupen64API.instance.init (general_settings.mupen64pluslib_dir)) {
                    var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                        _("Mupen64Plus Initalized!",
                        "The Mupen64Plus core library has been found and loaded succesfully! ",
                        "This program is happy now.",
                        "face-smile-symbolic"),
                        Gtk.ButtonsType.CLOSE
                    );
                    message_dialog.run ();
                    message_dialog.destroy ();
                }
            });

            plugins_dir_entry.activate.connect (() => {
                if (!plugins_dir_entry.get_text ().has_suffix ("/")) {
                    var str = plugins_dir_entry.get_text ().concat ("/");
                    plugins_dir_entry.set_text (str);
                }
                Mupen64API.instance.plugins_dir = general_settings.mupen64plugin_dir = plugins_dir_entry.get_text ();
                populate_plugin_combos.begin (plugins_dir_entry.get_text ());
            });

            video_plugin_combo.changed.connect (() => {
                if (video_plugin_combo.get_active_text () == "") {
                    return;
                }
                Mupen64API.instance.video_plugin = general_settings.mupen64plugin_video =
                        video_plugin_combo.get_active_text ();
            });

            audio_plugin_combo.changed.connect (() => {
                if (audio_plugin_combo.get_active_text () == "") {
                    return;
                }
                Mupen64API.instance.audio_plugin = general_settings.mupen64plugin_audio =
                        audio_plugin_combo.get_active_text ();
            });

            input_plugin_combo.changed.connect (() => {
                if (input_plugin_combo.get_active_text () == "") {
                    return;
                }
                Mupen64API.instance.input_plugin = general_settings.mupen64plugin_input =
                        input_plugin_combo.get_active_text ();
            });

            rsp_plugin_combo.changed.connect (() => {
                if (rsp_plugin_combo.get_active_text () == "") {
                    return;
                }
                Mupen64API.instance.rsp_plugin = general_settings.mupen64plugin_rsp =
                        rsp_plugin_combo.get_active_text ();
            });

            var mode_switch = new Granite.ModeSwitch.from_icon_name ("display-brightness-symbolic",
                    "weather-clear-night-symbolic");

            var gtk_settings = Gtk.Settings.get_default ();

            mode_switch.primary_icon_tooltip_text = _("Light Mode");
            mode_switch.secondary_icon_tooltip_text = _("Dark Mode");
            mode_switch.valign = Gtk.Align.CENTER;
            mode_switch.bind_property ("active", gtk_settings, "gtk_application_prefer_dark_theme");

            mode_switch.active = ui_settings.dark_mode;

            mode_switch.button_release_event.connect (() => {
                ui_settings.dark_mode = mode_switch.active;
            });

            content_area.attach (mode_switch, 0, 0, 1, 1);
            content_area.attach (lib_dir_label, 0, 1, 1, 1);
            content_area.attach (lib_dir_entry, 1, 1, 1, 1);
            content_area.attach (plugins_dir_label, 0, 2, 1, 1);
            content_area.attach (plugins_dir_entry, 1, 2, 1, 1);
            content_area.attach (video_plugin_label, 0, 3, 1, 1);
            content_area.attach (video_plugin_combo, 1, 3, 1, 1);
            content_area.attach (audio_plugin_label, 0, 4, 1, 1);
            content_area.attach (audio_plugin_combo, 1, 4, 1, 1);
            content_area.attach (input_plugin_label, 0, 5, 1, 1);
            content_area.attach (input_plugin_combo, 1, 5, 1, 1);
            content_area.attach (rsp_plugin_label, 0, 6, 1, 1);
            content_area.attach (rsp_plugin_combo, 1, 6, 1, 1);
        }

        private async void populate_plugin_combos (string plugins_dir) {
            var files_list = yield FileSystem.list_dir_files (plugins_dir, FileSystem.FilterType.SharedLib);
            var general_settings = new GeneralSettings ();

            video_plugin_combo.remove_all ();
            audio_plugin_combo.remove_all ();
            input_plugin_combo.remove_all ();
            rsp_plugin_combo.remove_all ();

            int v_active_id = 0, v_it = 0;
            int a_active_id = 0, a_it = 0;
            int i_active_id = 0, i_it = 0;
            int r_active_id = 0, r_it = 0;

            foreach (var file in files_list) {
                if (file.has_prefix ("mupen64plus-video")) {
                    if (file == general_settings.mupen64plugin_video) {
                        v_active_id = v_it;
                    }
                    video_plugin_combo.append_text (file);
                    ++v_it;
                }
                if (file.has_prefix ("mupen64plus-rsp")) {
                    if (file == general_settings.mupen64plugin_rsp) {
                        r_active_id = r_it;
                    }
                    rsp_plugin_combo.append_text (file);
                    ++r_it;
                }
                if (file.has_prefix ("mupen64plus-input")) {
                    if (file == general_settings.mupen64plugin_input) {
                        i_active_id = i_it;
                    }
                    input_plugin_combo.append_text (file);
                    ++i_it;
                }
                if (file.has_prefix ("mupen64plus-audio")) {
                    if (file == general_settings.mupen64plugin_audio) {
                        a_active_id = a_it;
                    }
                    audio_plugin_combo.append_text (file);
                    ++a_it;
                }
            }
            video_plugin_combo.active = v_active_id;
            audio_plugin_combo.active = a_active_id;
            input_plugin_combo.active = i_active_id;
            rsp_plugin_combo.active = r_active_id;
        }
    }
}
