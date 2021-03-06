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

        private Gtk.Entry lib_path_entry;
        private Gtk.Entry plugins_dir_entry;

        private Gtk.ComboBoxText profiles_combo;

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

            var settings_profile_manager = SettingsProfileManager.instance;

            var ui_settings = new UISettings();

            var profiles_label = new Gtk.Label(_("Settings Profiles:"));
            profiles_combo = new Gtk.ComboBoxText();

            var lib_path_label = new Gtk.Label(_("Mupen64Plus Core Library Path:"));
            lib_path_entry = new Gtk.Entry();

            var plugins_dir_label = new Gtk.Label(_("Plugins Base Directory:"));
            plugins_dir_entry = new Gtk.Entry();

            var video_plugin_label = new Gtk.Label(_("Video Plugin:"));
            video_plugin_combo = new Gtk.ComboBoxText();

            var audio_plugin_label = new Gtk.Label(_("Audio Plugin:"));
            audio_plugin_combo = new Gtk.ComboBoxText();

            var input_plugin_label = new Gtk.Label(_("Input Plugin:"));
            input_plugin_combo = new Gtk.ComboBoxText();

            var rsp_plugin_label = new Gtk.Label(_("RSP Plugin:"));
            rsp_plugin_combo = new Gtk.ComboBoxText();

            profiles_label.halign = Gtk.Align.END;
            lib_path_label.halign = Gtk.Align.END;
            plugins_dir_label.halign = Gtk.Align.END;
            video_plugin_label.halign = Gtk.Align.END;
            audio_plugin_label.halign = Gtk.Align.END;
            input_plugin_label.halign = Gtk.Align.END;
            rsp_plugin_label.halign = Gtk.Align.END;

            // Connect Widgets
            profiles_combo.changed.connect(() => {
                if (profiles_combo.get_active_text() == null) {
                    return;
                }
                settings_profile_manager.current_profile = profiles_combo.get_active_text();
                lib_path_entry.set_text(settings_profile_manager.get_mupen64lib_path());
                lib_path_entry.activate();
                plugins_dir_entry.set_text(settings_profile_manager.get_plugins_dir());
                plugins_dir_entry.activate();
            });

            lib_path_entry.activate.connect (() => {
                string mupen64pluslib_path = lib_path_entry.get_text();
                print("mupen64pluslib_path " + mupen64pluslib_path);
                settings_profile_manager.set_mupen64lib_path(mupen64pluslib_path);
                Mupen64API.instance.shutdown();

                Mupen64API.instance.init(mupen64pluslib_path, settings_profile_manager.get_mupen64cfg_path());
            });

            plugins_dir_entry.activate.connect(() => {
                if (!plugins_dir_entry.get_text().has_suffix("/")) {
                    var str = plugins_dir_entry.get_text().concat("/");
                    plugins_dir_entry.set_text(str);
                }
                Mupen64API.instance.plugins_dir = plugins_dir_entry.get_text();
                populate_plugin_combos.begin(plugins_dir_entry.get_text());
            });

            video_plugin_combo.changed.connect(() => {
                if (video_plugin_combo.get_active_text() == "") {
                    return;
                }
                Mupen64API.instance.video_plugin = video_plugin_combo.get_active_text();
                settings_profile_manager.set_video_plugin(video_plugin_combo.get_active_text());
            });

            audio_plugin_combo.changed.connect(() => {
                if (audio_plugin_combo.get_active_text() == "") {
                    return;
                }
                Mupen64API.instance.audio_plugin = audio_plugin_combo.get_active_text();
                settings_profile_manager.set_audio_plugin(audio_plugin_combo.get_active_text());
            });

            input_plugin_combo.changed.connect(() => {
                if (input_plugin_combo.get_active_text() == "") {
                    return;
                }
                Mupen64API.instance.input_plugin = input_plugin_combo.get_active_text();
                settings_profile_manager.set_input_plugin(input_plugin_combo.get_active_text());
            });

            rsp_plugin_combo.changed.connect(() => {
                if (rsp_plugin_combo.get_active_text() == "") {
                    return;
                }
                Mupen64API.instance.rsp_plugin = rsp_plugin_combo.get_active_text();
                settings_profile_manager.set_rsp_plugin(rsp_plugin_combo.get_active_text());
            });

            // Populate Profiles Combo
            on_profile_update();

            var mode_switch = new Granite.ModeSwitch.from_icon_name("display-brightness-symbolic",
                    "weather-clear-night-symbolic");

            var gtk_settings = Gtk.Settings.get_default();

            mode_switch.primary_icon_tooltip_text = _("Light Mode");
            mode_switch.secondary_icon_tooltip_text = _("Dark Mode");
            mode_switch.valign = Gtk.Align.CENTER;
            mode_switch.bind_property("active", gtk_settings, "gtk_application_prefer_dark_theme");

            mode_switch.active = ui_settings.dark_mode;

            mode_switch.button_release_event.connect(() => {
                ui_settings.dark_mode = mode_switch.active;
            });

            content_area.attach(mode_switch,        0, 0, 1, 1);
            content_area.attach(profiles_label,     0, 1, 1, 1);
            content_area.attach(profiles_combo,     1, 1, 1, 1);
            content_area.attach(lib_path_label,     0, 2, 1, 1);
            content_area.attach(lib_path_entry,     1, 2, 1, 1);
            content_area.attach(plugins_dir_label,  0, 3, 1, 1);
            content_area.attach(plugins_dir_entry,  1, 3, 1, 1);
            content_area.attach(video_plugin_label, 0, 4, 1, 1);
            content_area.attach(video_plugin_combo, 1, 4, 1, 1);
            content_area.attach(audio_plugin_label, 0, 5, 1, 1);
            content_area.attach(audio_plugin_combo, 1, 5, 1, 1);
            content_area.attach(input_plugin_label, 0, 6, 1, 1);
            content_area.attach(input_plugin_combo, 1, 6, 1, 1);
            content_area.attach(rsp_plugin_label,   0, 7, 1, 1);
            content_area.attach(rsp_plugin_combo,   1, 7, 1, 1);
        }

        public void on_profile_update() {
            var settings_profile_manager = SettingsProfileManager.instance;

            profiles_combo.remove_all();
            int i = 0;
            int profile_idx = 0;
            foreach (var profile in settings_profile_manager.available_profiles()) {
                profiles_combo.append_text(profile);
                if (profile == settings_profile_manager.current_profile) {
                    profile_idx = i;
                }
                ++i;
            }

            profiles_combo.active = profile_idx;
        }

        private async void populate_plugin_combos(string plugins_dir) {
            var files_list = yield FileSystem.list_dir_files (plugins_dir, FileSystem.FilterType.SharedLib);

            video_plugin_combo.remove_all();
            audio_plugin_combo.remove_all();
            input_plugin_combo.remove_all();
            rsp_plugin_combo.remove_all();

            int v_active_id = 0, v_it = 0;
            int a_active_id = 0, a_it = 0;
            int i_active_id = 0, i_it = 0;
            int r_active_id = 0, r_it = 0;

            foreach (var file in files_list) {
                if (file.has_prefix("mupen64plus-video")) {
                    if (file == SettingsProfileManager.instance.get_video_plugin()) {
                        v_active_id = v_it;
                    }
                    video_plugin_combo.append_text(file);
                    ++v_it;
                }
                if (file.has_prefix("mupen64plus-rsp")) {
                    if (file == SettingsProfileManager.instance.get_rsp_plugin()) {
                        r_active_id = r_it;
                    }
                    rsp_plugin_combo.append_text(file);
                    ++r_it;
                }
                if (file.has_prefix("mupen64plus-input")) {
                    if (file == SettingsProfileManager.instance.get_input_plugin()) {
                        i_active_id = i_it;
                    }
                    input_plugin_combo.append_text(file);
                    ++i_it;
                }
                if (file.has_prefix("mupen64plus-audio")) {
                    if (file == SettingsProfileManager.instance.get_audio_plugin()) {
                        a_active_id = a_it;
                    }
                    audio_plugin_combo.append_text(file);
                    ++a_it;
                }
            }
            video_plugin_combo.active = v_active_id;
            //video_plugin_combo.changed();
            audio_plugin_combo.active = a_active_id;
            //audio_plugin_combo.changed();
            input_plugin_combo.active = i_active_id;
            rsp_plugin_combo.active = r_active_id;
        }
    }
}
