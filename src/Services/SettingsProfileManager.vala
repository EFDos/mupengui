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
        private string current_profile {get; set;}
        private KeyFile key_file;

        public static SettingsProfileManager instance {
            get {
                if (_instance == null) {
                    _instance = new SettingsProfileManager();
                }
                return _instance;
            }
        }

        //HashTable<string, SettingsProfile> profiles;

        SettingsProfileManager() {
            //profiles = new HashTable<string, SettingsProfile> (str_hash, direct_equal);
            //profiles.insert ("global", new SettingsProfile("mupen64plus"));
        }

        public void init() {
            try {
                var config_dir = Path.build_filename(Environment.get_user_config_dir(),
                    Environment.get_application_name());

                // Create directory if it does't exist
                //char[] permission = {0,7,7,4};
                DirUtils.create_with_parents(config_dir, 0774);

                // Create configuration file if it doesn't exist
                if (!FileUtils.test(Path.build_filename(config_dir, "/profiles.cfg"), FileUtils.EXISTS)) {
                    File config_file = File.new_build_filename(config_dir, "/profiles.cfg");
                    config_file.create(FileCreateFlags.PRIVATE);
                }

                key_file = new KeyFile ();
                key_file.load_from_file(Path.build_filename(config_dir, "/profiles.cfg"), KeyFileFlags.NONE);

                current_profile = "global";

                if (!key_file.has_group("global")) {
                    key_file.set_string("global", "mupen-conf-file", "mupen64plus.cfg");
                    key_file.set_string("global", "video-plugin", "some_plugin");
                }
            } catch (Error e) {
                log(null, LogLevelFlags.LEVEL_ERROR, "Config File Error: " + e.message);
            }
        }

        public string get_video_plugin() {
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
    }
}
