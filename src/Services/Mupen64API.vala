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
using MupenGUI.Configuration;

/*****************
 * Mupen64 C API *
 *****************/

delegate void callback_type(); // For when the C core needs to call Vala functions.

extern int m64_load_corelib (string libpath);
extern int m64_unload_corelib ();
extern int m64_start_corelib (string? pconfig_path, string? pdata_path);
extern int m64_shutdown_corelib ();

extern int m64_load_plugin (int type, string libpath);
extern int m64_unload_plugin (int type);

extern int m64_command (int command, int param_int = 0, void* param_ptr = null);

extern int m64_enable_ctrl_config (uint controller, bool b);
extern int m64_bind_ctrl_button (uint controller, string button_name, string value);

extern int m64_save_settings ();

extern int m64_set_ctrl_device (uint controller, int device_id);
extern void m64_set_emustop_callback (callback_type callback);
extern int m64_set_fullscreen (bool b = true);
extern void m64_set_verbose (bool b = true);

extern unowned string m64_get_rom_goodname ();

namespace MupenGUI.Services {
    class Mupen64API : Object {

        public enum m64Command {
            Nop = 0,
            RomOpen,
            RomClose,
            RomGetHeader,
            RomGetSetting,
            Execute,
            Stop,
            Pause,
            Resume,
            CoreStateQuery,
            StateLoad,
            StateSave,
            StateSetSlot,
            SendSDLKeydown,
            SendSDLKeyup,
            SetFrameCallback,
            TakeNextScreenshot,
            CoreStateSet,
            ReadScreen,
            Reset,
            AdvanceFrame
        }

        public enum m64PluginType {
            Null = 0,
            RSP = 1,
            Video,
            Audio,
            Input,
            Core
        }

        public enum m64CoreParam {
            EmuState = 1,
            VideoMode,
            SaveStateSlot,
            SpeedFactor,
            SpeedLimiter,
            VideoSize,
            AudioVolume,
            AudioMute,
            InputGameShark,
            StateLoadComplete,
            StateSaveComplete
        }

        private static Mupen64API _instance = null;

        public string plugins_dir {set; get;}
        public string video_plugin {set; get;}
        public string audio_plugin {set; get;}
        public string input_plugin {set; get;}
        public string rsp_plugin {set; get;}

        private string goodname = "";
        private bool initialized = false;
        private bool rom_loaded = false;

        public static Mupen64API instance {
            get {
                if (_instance == null) {
                    _instance = new Mupen64API ();
                }

                return _instance;
            }
        }

        // Callbacks so we can call Vala code on Mupen64's state changes
        public static void _CAPICALLBACK_emulation_stop () {
            Mupen64API.instance.on_emulation_stop();
        }

        private Mupen64API () {
            // do nothing for now
        }

        ~Mupen64API ()
        {
            shutdown ();
        }

        public bool init (string library_path) {
            var result = m64_load_corelib (library_path);
            if (result != 0) {
                stderr.printf ("Error: Failed to load Mupen64Plus Dynamic Library. Error code: %d\n", result);
                show_not_initialized_alert ();
                return false;
            }

            result = m64_start_corelib (null, null);
            if (result != 0) {
                stderr.printf ("Error: Failed to initialize Mupen64Plus Core. Error code: %d\n", result);
                show_not_initialized_alert ();
                return false;
            }

            m64_set_emustop_callback(_CAPICALLBACK_emulation_stop);

            return initialized = true;
        }

        public void shutdown () {
            if (!initialized) {
                show_not_initialized_alert ();
                return;
            }

            m64_unload_plugin (m64PluginType.RSP);
            m64_unload_plugin (m64PluginType.Video);
            m64_unload_plugin (m64PluginType.Audio);
            m64_unload_plugin (m64PluginType.Input);

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
            if (!initialized) {
                show_not_initialized_alert ();
                return false;
            }
            var result = m64_command (command, param_int, param_ptr);
            if (result != 0) {
                stderr.printf ("Error: Failed to run command: %d (%d, %p)\n", command, param_int, param_ptr);
                stderr.printf ("Error code: %d", result);
                return false;
            }

            if (command == m64Command.RomOpen) {
                goodname = m64_get_rom_goodname ();
                if (goodname != null) {
                    rom_loaded = true;
                }

                var err = 0;
                err = m64_load_plugin (m64PluginType.Video, plugins_dir + video_plugin);
                if (err != 0) { stderr.printf ("Error code: %d\n", err); }
                err = m64_load_plugin (m64PluginType.Audio, plugins_dir + audio_plugin);
                if (err != 0) { stderr.printf ("Error code: %d\n", err); }
                err = m64_load_plugin (m64PluginType.Input, plugins_dir + input_plugin);
                if (err != 0) { stderr.printf ("Error code: %d\n", err); }
                err = m64_load_plugin (m64PluginType.RSP, plugins_dir + rsp_plugin);
                if (err != 0) { stderr.printf ("Error code: %d\n", err); }
            }

            return true;
        }

        public async void start_emulation () {
            if (!initialized) {
                show_not_initialized_alert ();
                return;
            }
            if (!initialized || !rom_loaded) {
                stderr.printf ("Error: Mupen64 needs to be initialized and a ROM needs to be loaded " +
                               "before starting emulation.\n");
            }

            m64_command (m64Command.Execute);
        }

        public void set_verbose (bool b = true) {
            m64_set_verbose (b);
        }

        public void set_fullscreen (bool b = true) {
            if (!initialized) {
                show_not_initialized_alert ();
                return;
            }
            var err = m64_set_fullscreen (b);
            if (err != 0) {
                stderr.printf ("Error code: %d\n", err);
            }
        }

        public void set_controller_device (uint controller, int device_id) {
            if (!initialized) {
                show_not_initialized_alert ();
                return;
            }
            int retval = m64_enable_ctrl_config (controller, true);
            if (retval != 0) {
                stderr.printf("Error: Failed to enable controller for configuration. Error code: %d\n", retval);
            }

            retval = m64_set_ctrl_device (controller, device_id);
            if (retval != 0) {
                stderr.printf("Error: Failed to set controller device. Error code: %d\n", retval);
            }
        }

        public void bind_controller_button (uint controller, ButtonConfig button, int? axis_mod) {
            if (!initialized) {
                show_not_initialized_alert ();
                return;
            }
            string button_string = "";
            string key_string = "";
            switch (button.button_id)
            {
                case DPadRight:
                    button_string = "DPad R";
                    break;
                case DPadLeft:
                    button_string = "DPad L";
                    break;
                case DPadDown:
                    button_string = "DPad D";
                    break;
                case DPadUp:
                    button_string = "DPad U";
                    break;
                case Start:
                    button_string = "Start";
                    break;
                case TriggerZ:
                    button_string = "Z Trig";
                    break;
                case ButtonB:
                    button_string = "B Button";
                    break;
                case ButtonA:
                    button_string = "A Button";
                    break;
                case CButtonRight:
                    button_string = "C Button R";
                    break;
                case CButtonLeft:
                    button_string = "C Button L";
                    break;
                case CButtonDown:
                    button_string = "C Button D";
                    break;
                case CButtonUp:
                    button_string = "C Button U";
                    break;
                case ShoulderR:
                    button_string = "R Trig";
                    break;
                case ShoulderL:
                    button_string = "L Trig";
                    break;
                case MempakSwitch:
                    button_string = "Mempak switch";
                    break;
                case RumblepakSwitch:
                    button_string = "Rumblepak switch";
                    break;
                default:
                    stderr.printf ("Error: Invalid Button Id. Use bind_controller_axis() instead.\n");
                    return;
            }

            switch (button.input_type)
            {
                case Key:
                    button.sdl_value_remap ();
                    key_string = "key(" + button.value.to_string () + ")";
                    break;
                case JoyButton:
                    key_string = "button(" + button.value.to_string () + ")";
                    break;
                case JoyAxis:
                    if (axis_mod == null) {
                        stderr.printf ("Error: Unknown axis binding direction.\n");
                        return;
                    } else {
                        if (axis_mod >= 0) {
                            key_string = "axis(" + button.value.to_string () + "+)";
                        } else {
                            key_string = "axis(" + button.value.to_string () + "-)";
                        }
                    }
                    break;
            }

            int retval = m64_bind_ctrl_button (controller, button_string, key_string);
            if (retval != 0) {
                stderr.printf ("Error: Failed to bind button %s. Error code: %d\n", button_string, retval);
            }
        }

        public void bind_controller_axis (uint controller,
                                          ButtonConfig axis1,
                                          ButtonConfig axis2,
                                          int? mod1,
                                          int? mod2)
        {
            if (!initialized) {
                show_not_initialized_alert ();
                return;
            }
            if (axis1.button_id != axis2.button_id || axis1.input_type != axis2.input_type) {
                stderr.printf ("Error: Both axis values should match value and id\n");
                return;
            }
            string axis_string = "";
            string key_string = "";

            switch (axis1.button_id) {
                case AxisX:
                    axis_string = "X Axis";
                    break;
                case AxisY:
                    axis_string = "Y Axis";
                    break;
                default:
                    stderr.printf("Error: Invalid axis Id. Use bind_controller_button() instead.\n");
                    return;
            }

            switch (axis1.input_type) {
                case Key:
                    axis1.sdl_value_remap ();
                    axis2.sdl_value_remap ();
                    key_string = "key(" + axis1.value.to_string () + "," + axis2.value.to_string () + ")";
                    break;
                case JoyButton:
                    key_string = "button(" + axis1.value.to_string () + "," + axis2.value.to_string () + ")";
                    break;
                case JoyAxis:
                    if (mod1 == null || mod2 == null) {
                        stderr.printf ("Error: Unknown axis binding direction.\n");
                        return;
                    } else {
                        if (mod1 >= 0) {
                            key_string = "axis(" + axis1.value.to_string () + "+,";
                        } else {
                            key_string = "axis(" + axis1.value.to_string () + "-,";
                        }

                        if (mod2 >= 0) {
                            key_string = key_string.concat (axis2.value.to_string () + "+)");
                        } else {
                            key_string = key_string.concat (axis2.value.to_string () + "-)");
                        }
                    }
                    break;
            }

            int retval = m64_bind_ctrl_button (controller, axis_string, key_string);
            if (retval != 0) {
                stderr.printf ("Error: Failed to bind axis %s. Error code: %d\n", axis_string, retval);
            }
        }

        public void save_current_settings () {
            if (!initialized) {
                show_not_initialized_alert ();
                return;
            }

            int retval = m64_save_settings ();
            if (retval != 0) {
                stderr.printf("Error: Failed to save settings. Error code: %d\n", retval);
            }
        }

        public string get_rom_goodname () {
            return goodname;
        }

        public void on_emulation_stop() {
            m64_command (m64Command.RomClose);
            m64_unload_plugin (m64PluginType.RSP);
            m64_unload_plugin (m64PluginType.Video);
            m64_unload_plugin (m64PluginType.Audio);
            m64_unload_plugin (m64PluginType.Input);
            rom_loaded = false;
            save_current_settings ();
        }

        private void show_not_initialized_alert() {
            var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                    "Mupen64Plus Not Initalized",
                    "The library libmupen64plus.so.2 could not be loaded. It might not have been found or it could be" +
                    " either corrupted or incompatible. You can manually set the correct file on the settings page." +
                    "Most functionalities of this program can not be run on this state.",
                    "dialog-error",
                    Gtk.ButtonsType.CLOSE
            );
            message_dialog.run ();
            message_dialog.destroy ();
        }
    }
}
