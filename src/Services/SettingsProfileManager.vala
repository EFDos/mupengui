/************************************************************************/
/*  SettingsProfileManager.vala                                         */
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

namespace MupenGUI.Services {
    public class SettingsProfileManager {
        private static SettingsProfileManager _instance = null;
        private string cached_path;
        private KeyFile key_file;

        public string current_profile {get; set;}

        public static SettingsProfileManager instance {
            get {
                if (_instance == null) {
                    _instance = new SettingsProfileManager();
                }
                return _instance;
            }
        }

        SettingsProfileManager() {
        }

        public void init() {
            try {
                var config_dir = Path.build_filename(Environment.get_user_config_dir(),
                    Environment.get_application_name());

                // Create directory if it does't exist
                //char[] permission = {0,7,7,4};
                DirUtils.create_with_parents(config_dir, 0774);

                cached_path = Path.build_filename(config_dir, "/profiles.cfg");

                // Create configuration file if it doesn't exist
                if (!FileUtils.test(cached_path, FileTest.EXISTS)) {
                    File config_file = File.new_build_filename(config_dir, "/profiles.cfg");
                    config_file.create(FileCreateFlags.PRIVATE);
                }

                key_file = new KeyFile ();
                key_file.load_from_file(cached_path, KeyFileFlags.NONE);

                current_profile = "Global";

                if (!key_file.has_group("Global")) {
                    // /usr/lib/x86_64-linux-gnu/libmupen64plus.so.2
                    create_profile("Global");
                }
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Config File Error: " + e.message);
            }
        }

        public void shutdown() {
            log(null, LogLevelFlags.LEVEL_INFO, "Saving profiles");
            try {
                key_file.save_to_file(cached_path);
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error saving profiles.cfg: " + e.message);
            }
        }

        public string[] available_profiles() {
            return key_file.get_groups();
        }

        public bool has_profile(string name) {
            return key_file.has_group(name);
        }

        public void create_profile(string name) {
            delete_profile(name);
            key_file.set_string(name, "mupen-conf-file", "mupen64plus.cfg");
            key_file.set_string(name, "video-plugin", "");
            key_file.set_string(name, "audio-plugin", "");
            key_file.set_string(name, "input-plugin", "");
            key_file.set_string(name, "rsp-plugin", "");
            key_file.set_string(name, "mupen64lib-path", "/usr/lib/x86_64-linux-gnu/libmupen64plus.so.2");
            key_file.set_string(name, "plugins-dir", "/usr/lib/x86_64-linux-gnu/mupen64plus/");
        }

        public void delete_profile(string name) {
            if (key_file.has_group(name)) {
                try {
                    key_file.remove_group(name);
                } catch (Error e) {
                    log(null, LogLevelFlags.LEVEL_ERROR, "Error deleting profile " + name + ": " + e.message);
                }
            }
        }

        public void set_mupen64lib_path(string path) {
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return;
            }
            key_file.set_string(current_profile, "mupen64lib-path", path);
        }

        public void set_plugins_dir(string dir) {
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return;
            }
            key_file.set_string(current_profile, "plugins-dir", dir);
        }

        public void set_video_plugin(string? plugin_name) {
            if (plugin_name == null) {
                return;
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return;
            }
            key_file.set_string(current_profile, "video-plugin", plugin_name);
        }

        public void set_audio_plugin(string? plugin_name) {
            if (plugin_name == null) {
                return;
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return;
            }
            key_file.set_string(current_profile, "audio-plugin", plugin_name);
        }

        public void set_input_plugin(string? plugin_name) {
            if (plugin_name == null) {
                return;
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return;
            }
            key_file.set_string(current_profile, "input-plugin", plugin_name);

        }

        public void set_rsp_plugin(string? plugin_name) {
            if (plugin_name == null) {
                return;
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return;
            }
            key_file.set_string(current_profile, "rsp-plugin", plugin_name);
        }

        public string get_video_plugin() {
            if (current_profile == null) {
                return "";
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return "";
            }
            try {
                return key_file.get_string(current_profile, "video-plugin");
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error: " + e.message);
                return "";
            }
        }

        public string get_audio_plugin() {
            if (current_profile == null) {
                return "";
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return "";
            }
            try {
                return key_file.get_string(current_profile, "audio-plugin");
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error: " + e.message);
                return "";
            }
        }

        public string get_input_plugin() {
            if (current_profile == null) {
                return "";
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return "";
            }
            try {
                return key_file.get_string(current_profile, "input-plugin");
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error: " + e.message);
                return "";
            }
        }

        public string get_rsp_plugin() {
            if (current_profile == null) {
                return "";
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return "";
            }
            try {
                return key_file.get_string(current_profile, "rsp-plugin");
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error: " + e.message);
                return "";
            }
        }

        public string get_mupen64lib_path() {
            if (current_profile == null) {
                return "";
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return "";
            }
            try {
                return key_file.get_string(current_profile, "mupen64lib-path");
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error: " + e.message);
                return "";
            }
        }

        public string get_plugins_dir() {
            if (current_profile == null) {
                return "";
            }
            if (key_file == null) {
                log(null, LogLevelFlags.LEVEL_ERROR, "SettingsProfileManager was not correctly initialized.");
                return "";
            }
            try {
                return key_file.get_string(current_profile, "plugins-dir");
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Error: " + e.message);
                return "";
            }
        }
    }
}
