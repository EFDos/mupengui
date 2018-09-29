#include "common.h"
#include "dynlib.h"
#include "m64p_frontend.h"
#include <stdio.h>

ptr_CoreStartup g_core_startup = NULL;
ptr_CoreShutdown g_core_shutdown = NULL;
ptr_CoreDoCommand g_core_do_command = NULL;
m64p_dynlib_handle g_core_handle = NULL;

m64p_rom_settings g_current_rom_settings;
m64p_rom_header g_current_rom_header;

boolean g_rom_settings_loaded = FALSE;
boolean g_rom_header_loaded = FALSE;
boolean g_verbose = FALSE;

void m64_set_verbose(boolean b)
{
    g_verbose = b;
}

void m64_debug_callback(void* context, int level, const char* message)
{
    if (level == M64MSG_ERROR) {
        printf("%s Error: %s\n", (const char *) context, message);
    } else if (level == M64MSG_WARNING) {
        printf("%s Warning: %s\n", (const char *) context, message);
    } else if (level == M64MSG_INFO) {
        printf("%s: %s\n", (const char *) context, message);
    } else if (level == M64MSG_STATUS) {
        printf("%s Status: %s\n", (const char *) context, message);
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

int m64_load_corelib()
{
    m64p_error open_result = dynlib_open(&g_core_handle, "/usr/lib/x86_64-linux-gnu/libmupen64plus.so.2");

    if (open_result != M64ERR_SUCCESS) {
        return open_result;
    }

    g_core_startup = dynlib_getproc (g_core_handle, "CoreStartup");
    g_core_shutdown = dynlib_getproc(g_core_handle, "CoreShutdown");
    g_core_do_command = dynlib_getproc(g_core_handle, "CoreDoCommand");

    return M64ERR_SUCCESS;
}

int m64_start_corelib(char* config_path, char* data_path)
{
    return (*g_core_startup)(0x020001, config_path, data_path, "Core", m64_debug_callback, NULL, NULL);
}

int m64_shutdown_corelib()
{
    return (*g_core_shutdown)();
}

int m64_unload_corelib()
{
    if (g_core_handle == NULL)
        return M64ERR_INVALID_STATE;

    g_core_startup = NULL;

    dynlib_close (g_core_handle);

    g_core_handle = NULL;

    return M64ERR_SUCCESS;
}

int m64_command(m64p_command command, int param_int, void* param_ptr)
{
    int retval = (*g_core_do_command)(command, param_int, param_ptr);

    switch (command)
    {
        case M64CMD_ROM_OPEN:
            if ((*g_core_do_command)(M64CMD_ROM_GET_SETTINGS, sizeof(m64p_rom_settings), &g_current_rom_settings) !=
                    M64ERR_SUCCESS)
            {
                printf("Error: Failed to load ROM settings.\n");
            }
            g_rom_settings_loaded = TRUE;
            if ((*g_core_do_command)(M64CMD_ROM_GET_HEADER, sizeof(m64p_rom_header), &g_current_rom_header) !=
                    M64ERR_SUCCESS)
            {
                printf("Error: Failed to load ROM header.\n");
            }
            g_rom_header_loaded = TRUE;
            break;
        case M64CMD_ROM_CLOSE:
            g_rom_settings_loaded = FALSE;
            g_rom_header_loaded = FALSE;
            break;
        default:
            break;
    }

    return retval;
}

char* m64_get_rom_goodname ()
{
    if (!g_rom_settings_loaded) {
        return NULL;
    }

    return g_current_rom_settings.goodname;
}
