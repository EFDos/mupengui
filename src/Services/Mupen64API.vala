/************************************************************************/
/*  Mupen64API.vala                                                     */
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

/*****************
 * Mupen64 C API *
 *****************/
extern int m64_load_corelib (char* libpath);
extern int m64_unload_corelib ();
extern int m64_start_corelib (char* pconfig_path, char* pdata_path);
extern int m64_shutdown_corelib ();

extern int m64_load_plugin (int type, char* libpath);
extern int m64_unload_plugin (int type);

extern int m64_command (int command, int param_int, void* param_ptr);

extern void m64_set_verbose (bool b);

extern char* m64_get_rom_goodname ();

namespace MupenGUI.Services {
    class Mupen64API : Object {

        public enum m64Command {
            NOP = 0,
            ROM_OPEN,
            ROM_CLOSE,
            ROM_GET_HEADER,
            ROM_GET_SETTINGS,
            EXECUTE,
            STOP,
            PAUSE,
            RESUME,
            CORE_STATE_QUERY,
            STATE_LOAD,
            STATE_SAVE,
            STATE_SET_SLOT,
            SEND_SDL_KEYDOWN,
            SEND_SDL_KEYUP,
            SET_FRAME_CALLBACK,
            TAKE_NEXT_SCREENSHOT,
            CORE_STATE_SET,
            READ_SCREEN,
            RESET,
            ADVANCE_FRAME
        }

        public enum m64PluginType{
            NULL = 0,
            RSP = 1,
            VIDEO,
            AUDIO,
            INPUT,
            CORE
        }

        private static Mupen64API _instance = null;
        private bool initialized = false;
        private string goodname = "";

        public static Mupen64API instance {
            get {
                if (_instance == null) {
                    _instance = new Mupen64API ();
                }

                return _instance;
            }
        }

        private Mupen64API () {
            // do nothing for now
        }

        ~Mupen64API ()
        {
            shutdown ();
        }

        public bool init () {
            var result = m64_load_corelib ("/usr/lib/x86_64-linux-gnu/libmupen64plus.so.2");
            if (result == 0) {
                stderr.printf ("Info: Mupen64Plus Dynamic Library Loaded.\n");
            } else {
                stderr.printf ("Error: Failed to load Mupen64Plus Dynamic Library. Error code: %d\n", result);
                return false;
            }

            result = m64_start_corelib (null, null);
            if (result == 0) {
                stderr.printf ("Info: Mupen64Plus Core Initialized.\n");
            } else {
                stderr.printf ("Error: Failed to initialize Mupen64Plus Core. Error code: %d\n", result);
                return false;
            }

            return initialized = true;
        }

        public void shutdown () {
            m64_unload_plugin (m64PluginType.RSP);
            m64_unload_plugin (m64PluginType.VIDEO);
            m64_unload_plugin (m64PluginType.AUDIO);
            m64_unload_plugin (m64PluginType.INPUT);

            var result = m64_shutdown_corelib ();
            if (result != 0) {
                stderr.printf ("Error: Failed to shut down Mupen64Plus Core. Error code: %d\n", result);
            }

            result = m64_unload_corelib ();
            if (result != 0) {
                stderr.printf ("Error: Failed to unload Mupen64Plus Dynamic Library. Error code: %d\n", result);
            }

            initialized = false;
        }

        public bool run_command (m64Command command, int param_int = 0, void* param_ptr = null) {
            var result = m64_command (command, param_int, param_ptr);
            if (result != 0) {
                stderr.printf ("Error: Failed to run command: %d (%d, %p)\n", command, param_int, param_ptr);
                stderr.printf ("Error code: %d", result);
                return false;
            }

            if (command == m64Command.ROM_OPEN) {
                var builder = new StringBuilder ();
                char* c_string = m64_get_rom_goodname ();
                if (c_string != null) {
                    char c = c_string[0];
                    int it = 0;
                    while (c != '\0') {
                        builder.append_c (c);
                        c = c_string[it++];
                    }
                    builder.erase(0, 1);
                    goodname = builder.str;
                }

                var err = 0;
                err = m64_load_plugin (m64PluginType.VIDEO, "/usr/lib/x86_64-linux-gnu/mupen64plus/mupen64plus-video-z64.so");
                if (err != 0) { stderr.printf ("Error code: %d\n", err); }
                err = m64_load_plugin (m64PluginType.AUDIO, "/usr/lib/x86_64-linux-gnu/mupen64plus/mupen64plus-audio-sdl.so");
                if (err != 0) { stderr.printf ("Error code: %d\n", err); }
                err = m64_load_plugin (m64PluginType.INPUT, "/usr/lib/x86_64-linux-gnu/mupen64plus/mupen64plus-input-sdl.so");
                if (err != 0) { stderr.printf ("Error code: %d\n", err); }
                err = m64_load_plugin (m64PluginType.RSP, "/usr/lib/x86_64-linux-gnu/mupen64plus/mupen64plus-rsp-z64.so");
                if (err != 0) { stderr.printf ("Error code: %d\n", err); }
            }

            return true;
        }

        public void set_verbose (bool b) {
            m64_set_verbose (b);
        }

        public string get_rom_goodname () {
            return goodname;
        }
    }
}
