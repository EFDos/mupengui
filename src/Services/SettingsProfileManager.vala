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

        public static SettingsProfileManager instance {
            get {
                if (_instance == null) {
                    _instance = new SettingsProfileManager();
                }
                return _instance;
            }
        }

        HashTable<string, SettingsProfile> profiles;

        SettingsProfileManager () {
            profiles = new HashTable<string, SettingsProfile> (str_hash, direct_equal);
            profiles.insert ("global", new SettingsProfile("mupen64plus"));

            try {
                var config_dir = Path.build_path (Environment.get_user_config_dir (),
                    Environment.get_application_name ());
                // Create directory if it does't exist
                DirUtils.create_with_parents (config_dir, 0664);

                // Create configuration file if it doesn't exist
                File config_file = File.new_for_path (Path.build_path (config_dir, "profiles.conf"));

                if (!config_file.query_exists ()) {
                    config_file.create (FileCreateFlags.NONE);
                }

                KeyFile key_file = new KeyFile ();
                key_file.load_from_file (Path.build_path (config_dir, "profiles.conf"), KeyFileFlags.NONE);

                if (!key_file.has_group ("global")) {
                    key_file.set_string ("global", "mupen-conf-file", "mupen64plus.cfg");
                }
            } catch (Error e) {
                stderr.printf ("Config File Error: %s\n", e.message);
            }
        }

        public void do_something() {}
    }
}
