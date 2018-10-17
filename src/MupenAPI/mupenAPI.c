/************************************************************************/
/*  mupenAPI.c                                                          */
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
#include "common.h"
#include "dynlib.h"
#include "m64p_common.h"
#include "m64p_frontend.h"
#include "m64p_config.h"
#include <stdio.h>

typedef void (*fptr_emustop_callback)();

static fptr_emustop_callback g_emustop_callback = NULL;

static ptr_CoreStartup g_core_startup = NULL;
static ptr_CoreShutdown g_core_shutdown = NULL;
static ptr_CoreDoCommand g_core_do_command = NULL;
static ptr_CoreAttachPlugin g_core_attach_plugin = NULL;
static ptr_CoreDetachPlugin g_core_detach_plugin = NULL;

//static ptr_ConfigListSections     g_config_list_sections;
static ptr_ConfigOpenSection      g_config_open_section;
//static ptr_ConfigDeleteSection    g_config_delete_section;
static ptr_ConfigSaveSection      g_config_save_section;
//static ptr_ConfigListParameters   ConfigListParameters;
//static ptr_ConfigSaveFile         g_config_save_file;
static ptr_ConfigSetParameter     g_config_set_parameter;
//static ptr_ConfigGetParameter     ConfigGetParameter;
//static ptr_ConfigGetParameterType ConfigGetParameterType;
//static ptr_ConfigGetParameterHelp ConfigGetParameterHelp;
//static ptr_ConfigSetDefaultInt    ConfigSetDefaultInt;
//static ptr_ConfigSetDefaultFloat  ConfigSetDefaultFloat;
//static ptr_ConfigSetDefaultBool   ConfigSetDefaultBool;
//static ptr_ConfigSetDefaultString ConfigSetDefaultString;
//static ptr_ConfigGetParamInt      ConfigGetParamInt;
//static ptr_ConfigGetParamFloat    ConfigGetParamFloat;
//static ptr_ConfigGetParamBool     ConfigGetParamBool;
//static ptr_ConfigGetParamString   ConfigGetParamString;

static m64p_dynlib_handle g_core_handle            = NULL;
static m64p_dynlib_handle g_plugin_video_handle    = NULL;
static m64p_dynlib_handle g_plugin_audio_handle    = NULL;
static m64p_dynlib_handle g_plugin_input_handle    = NULL;
static m64p_dynlib_handle g_plugin_rsp_handle      = NULL;

static m64p_handle g_conf_video_handle = NULL;
static m64p_handle g_conf_inputctrl_handle[4];

static m64p_rom_settings g_current_rom_settings;
static m64p_rom_header g_current_rom_header;

static boolean g_rom_settings_loaded = FALSE;
static boolean g_rom_header_loaded = FALSE;
static boolean g_verbose = FALSE;

void m64_set_emustop_callback(fptr_emustop_callback callback)
{
    g_emustop_callback = callback;
}

void m64_debug_callback(void* context, int level, const char* message)
{
    if (level == M64MSG_ERROR) {
        printf("%s M64API Error: %s\n", (const char *) context, message);
    } else if (level == M64MSG_WARNING) {
        printf("%s M64API Warning: %s\n", (const char *) context, message);
    } else if (level == M64MSG_INFO) {
        printf("%s: %s\n", (const char *) context, message);
    } else if (level == M64MSG_STATUS) {
        printf("%s M64API Status: %s\n", (const char *) context, message);
    } else if (level == M64MSG_VERBOSE)
    {
        if (g_verbose) {
            printf("%s: %s\n", (const char *) context, message);
        }
    }
    else {
        printf("%s Unknown: %s\n", (const char *) context, message);
    }
}

void m64_state_callback(void*            context,
                        m64p_core_param  param_changed,
                        int              new_value)
{
    if (param_changed == M64CORE_EMU_STATE) {
        if (new_value == 1) {
            if (g_emustop_callback != NULL) {
                g_emustop_callback();
            }
        }
    }
}

m64p_error m64_load_corelib(const char* path)
{
    m64p_error open_result = dynlib_open(&g_core_handle, path);

    if (open_result != M64ERR_SUCCESS) {
        return open_result;
    }

    printf("M64API Info: Loading Core functions.\n");
    g_core_startup = dynlib_getproc(g_core_handle, "CoreStartup");
    g_core_shutdown = dynlib_getproc(g_core_handle, "CoreShutdown");
    g_core_do_command = dynlib_getproc(g_core_handle, "CoreDoCommand");
    g_core_attach_plugin = dynlib_getproc(g_core_handle, "CoreAttachPlugin");
    g_core_detach_plugin = dynlib_getproc(g_core_handle, "CoreDetachPlugin");

    printf("M64API Info: Loading Config functions.\n");
    g_config_open_section = dynlib_getproc(g_core_handle, "ConfigOpenSection");
    g_config_save_section = dynlib_getproc(g_core_handle, "ConfigSaveSection");
    g_config_set_parameter = dynlib_getproc(g_core_handle, "ConfigSetParameter");

    return M64ERR_SUCCESS;
}

m64p_error m64_start_corelib(char* config_path, char* data_path)
{
    m64p_error retval = (*g_core_startup)(0x020001,
                                          config_path,
                                          data_path,
                                          "CoreDebug", m64_debug_callback,
                                          "CoreState", m64_state_callback);

    printf("M64API Info: Opening Config handles\n");
    (*g_config_open_section)("Video-General", &g_conf_video_handle);
    (*g_config_open_section)("Input-SDL-Control1", &g_conf_inputctrl_handle[0]);
    (*g_config_open_section)("Input-SDL-Control2", &g_conf_inputctrl_handle[1]);
    (*g_config_open_section)("Input-SDL-Control3", &g_conf_inputctrl_handle[2]);
    (*g_config_open_section)("Input-SDL-Control4", &g_conf_inputctrl_handle[3]);

    return retval;
}

m64p_error m64_shutdown_corelib()
{
    return (*g_core_shutdown)();
}

m64p_error m64_unload_corelib()
{
    if (g_core_handle == NULL) {
        return M64ERR_INVALID_STATE;
    }

    g_core_startup = NULL;

    dynlib_close (g_core_handle);

    g_core_handle = NULL;

    return M64ERR_SUCCESS;
}

m64p_error m64_load_plugin(m64p_plugin_type type, const char* path)
{
    if (path == NULL) {
        return M64ERR_INPUT_INVALID;
    }

    m64p_error err = M64ERR_SUCCESS;
    ptr_PluginStartup plugin_startup = NULL;

    switch (type)
    {
        case M64PLUGIN_RSP:
            if (g_plugin_rsp_handle != NULL) {
                return M64ERR_INVALID_STATE;
            }

            err = dynlib_open(&g_plugin_rsp_handle, path);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to load RSP plugin: %s\n", path);
                return err;
            }

            plugin_startup = dynlib_getproc (g_plugin_rsp_handle, "PluginStartup");
            if (plugin_startup == NULL) {
                printf("M64API Error: library '%s' broken.  No PluginStartup() function found.", path);
                return M64ERR_PLUGIN_FAIL;
            }

            err = (*plugin_startup)(g_core_handle, "RSP_PLUGIN", m64_debug_callback);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: RSP plugin library '%s' failed to start.", path);
                return err;
            }

            err = (*g_core_attach_plugin)(type, g_plugin_rsp_handle);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to attach RSP plugin: %s\n", path);
                return err;
            }
            break;
        case M64PLUGIN_GFX:
            if (g_plugin_video_handle != NULL) {
                return M64ERR_INVALID_STATE;
            }

            err = dynlib_open(&g_plugin_video_handle, path);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to load Video plugin: %s\n", path);
                return err;
            }

            plugin_startup = dynlib_getproc (g_plugin_video_handle, "PluginStartup");
            if (plugin_startup == NULL) {
                printf("M64API Error: library '%s' broken.  No PluginStartup() function found.", path);
                return M64ERR_PLUGIN_FAIL;
            }

            err = (*plugin_startup)(g_core_handle, "GFX_PLUGIN", m64_debug_callback);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Video plugin library '%s' failed to start.", path);
                return err;
            }

            err = (*g_core_attach_plugin)(type, g_plugin_video_handle);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to attach Video plugin: %s\n", path);
                return err;
            }
            break;
        case M64PLUGIN_AUDIO:
            if (g_plugin_audio_handle != NULL) {
                return M64ERR_INVALID_STATE;
            }

            err = dynlib_open(&g_plugin_audio_handle, path);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to load Audio plugin: %s\n", path);
                return err;
            }

            plugin_startup = dynlib_getproc (g_plugin_audio_handle, "PluginStartup");
            if (plugin_startup == NULL) {
                printf("M64API Error: library '%s' broken.  No PluginStartup() function found.", path);
                return M64ERR_PLUGIN_FAIL;
            }

            err = (*plugin_startup)(g_core_handle, "AUDIO_PLUGIN", m64_debug_callback);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Audio plugin library '%s' failed to start.", path);
                return err;
            }

            err = (*g_core_attach_plugin)(type, g_plugin_audio_handle);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to attach Audio plugin: %s\n", path);
                return err;
            }
            break;
        case M64PLUGIN_INPUT:
            if (g_plugin_input_handle != NULL) {
                return M64ERR_INVALID_STATE;
            }

            err = dynlib_open(&g_plugin_input_handle, path);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to load Input plugin: %s\n", path);
                return err;
            }

            plugin_startup = dynlib_getproc (g_plugin_input_handle, "PluginStartup");
            if (plugin_startup == NULL) {
                printf("M64API Error: library '%s' broken.  No PluginStartup() function found.", path);
                return M64ERR_PLUGIN_FAIL;
            }

            err = (*plugin_startup)(g_core_handle, "INPUT_PLUGIN", m64_debug_callback);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Input plugin library '%s' failed to start.", path);
                return err;
            }

            err = (*g_core_attach_plugin)(type, g_plugin_input_handle);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to attach Input plugin: %s\n", path);
                return err;
            }
            break;
        default:
            break;
    }

    return err;
}

m64p_error m64_unload_plugin(m64p_plugin_type type)
{
    m64p_error err = M64ERR_SUCCESS;

    switch (type)
    {
        case M64PLUGIN_RSP:
            if (g_plugin_rsp_handle == NULL) {
                return M64ERR_INVALID_STATE;
            }

            err = (*g_core_detach_plugin)(type);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to detach RSP plugin.\n");
                return err;
            }

            err = dynlib_close(g_plugin_rsp_handle);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to unload RSP plugin.\n");
                return err;
            }

            g_plugin_rsp_handle = NULL;
            break;
        case M64PLUGIN_GFX:
            if (g_plugin_video_handle == NULL) {
                return M64ERR_INVALID_STATE;
            }

            err = (*g_core_detach_plugin)(type);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to detach Video plugin.\n");
                return err;
            }

            err = dynlib_close(g_plugin_video_handle);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to unload Video plugin.\n");
                return err;
            }

            g_plugin_video_handle = NULL;
            break;
        case M64PLUGIN_AUDIO:
            if (g_plugin_audio_handle == NULL) {
                return M64ERR_INVALID_STATE;
            }

            err = (*g_core_detach_plugin)(type);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to detach Audio plugin.\n");
                return err;
            }

            err = dynlib_close(g_plugin_audio_handle);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to unload Audio plugin.\n");
                return err;
            }

            g_plugin_audio_handle = NULL;
            break;
        case M64PLUGIN_INPUT:
            if (g_plugin_input_handle == NULL) {
                return M64ERR_INVALID_STATE;
            }

            err = (*g_core_detach_plugin)(type);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to detach Input plugin.\n");
                return err;
            }

            err = dynlib_close(g_plugin_input_handle);
            if (err != M64ERR_SUCCESS) {
                printf("M64API Error: Failed to unload Input plugin.\n");
                return err;
            }

            g_plugin_input_handle = NULL;
            break;
        default:
            break;
    }

    return err;
}

m64p_error m64_command(m64p_command command, int param_int, void* param_ptr)
{
    m64p_error retval = (*g_core_do_command)(command, param_int, param_ptr);

    switch (command)
    {
        case M64CMD_ROM_OPEN:
            if ((*g_core_do_command)(M64CMD_ROM_GET_SETTINGS, sizeof(m64p_rom_settings), &g_current_rom_settings) !=
                    M64ERR_SUCCESS)
            {
                printf("M64API Error: Failed to load ROM settings.\n");
            }
            g_rom_settings_loaded = TRUE;
            if ((*g_core_do_command)(M64CMD_ROM_GET_HEADER, sizeof(m64p_rom_header), &g_current_rom_header) !=
                    M64ERR_SUCCESS)
            {
                printf("M64API Error: Failed to load ROM header.\n");
            }
            g_rom_header_loaded = TRUE;
            break;
        case M64CMD_ROM_CLOSE:
            g_rom_settings_loaded = FALSE;
            g_rom_header_loaded = FALSE;
            break;
        case M64CMD_CORE_STATE_SET:
            if (param_int == M64CORE_VIDEO_MODE) {
                printf("M64API Info: Trying to set video mode to: %d\n", *(int*)param_ptr);
            }
        default:
            break;
    }

    return retval;
}


void m64_set_verbose(boolean b)
{
    g_verbose = b;
}

m64p_error m64_set_fullscreen(boolean b)
{
    int v = b ? 1 : 0;
    m64p_error retval = (*g_config_set_parameter)(g_conf_video_handle, "Fullscreen", M64TYPE_BOOL, &v);

    if (retval != M64ERR_SUCCESS) {
        printf("M64API Error: Failed to set parameter \'Fullscreen\'.\n");
        return retval;
    }
    printf("M64API Info: Set Fullscreen: %s\n", b ? "true" : "false");

    return retval;
}

m64p_error m64_set_ctrl_device(unsigned int controller, int device_id)
{
    m64p_error retval = (*g_config_set_parameter)(g_conf_inputctrl_handle[controller],
                                                  "device",
                                                  M64TYPE_INT,
                                                  &device_id);
    if (retval != M64ERR_SUCCESS) {
        printf("M64API Error: Failed to set parameter \'device\'.\n");
        return retval;
    }
    printf("M64API Info: Set device on controller: %u. %u\n", controller, device_id);

    return retval;
}

m64p_error m64_enable_ctrl_config(unsigned int controller, boolean b)
{
    int value = b ? 0 : 2;
    m64p_error retval = (*g_config_set_parameter)(g_conf_inputctrl_handle[controller],
                                                  "mode",
                                                  M64TYPE_INT,
                                                  &value);
    if (retval != M64ERR_SUCCESS) {
        printf("M64API Error: Failed to set parameter \'mode\'.\n");
        return retval;
    }
    printf("M64API Info: Set enable configuration on controller: %u. %s\n", controller, b ? "true" : "false");

    return retval;
}

m64p_error m64_bind_ctrl_button(unsigned int controller, const char* button_name, const char* value)
{
    m64p_error retval = (*g_config_set_parameter)(g_conf_inputctrl_handle[controller],
                                                  button_name,
                                                  M64TYPE_STRING, value);

    if (retval != M64ERR_SUCCESS) {
        printf("M64API Error: Failed to set parameter \'%s\'.\n", button_name);
        return retval;
    }
    printf("M64API Info: Set button on controller: %u. {%s, %s}\n", controller, button_name, value);

    return retval;
}

char* m64_get_rom_goodname ()
{
    if (!g_rom_settings_loaded) {
        return NULL;
    }

    return g_current_rom_settings.goodname;
}
