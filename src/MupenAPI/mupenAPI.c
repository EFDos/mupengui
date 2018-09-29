#include "common.h"
#include "dynlib.h"
#include "m64p_frontend.h"
#include <stdio.h>

ptr_CoreStartup g_core_startup = NULL;
m64p_dynlib_handle g_core_handle = NULL;

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

int m64_start_corelib(char* config_path, char* data_path)
{
    m64p_error open_result = dynlib_open(&g_core_handle, "/usr/lib/x86_64-linux-gnu/libmupen64plus.so.2");

    if (open_result != M64ERR_SUCCESS) {
        return open_result;
    }

    g_core_startup = dynlib_getproc (g_core_handle, "CoreStartup");

    m64p_error startup_result = (*g_core_startup)(0x020001, config_path, data_path, "Core", m64_debug_callback, NULL, NULL);

    return startup_result;
}

int m64_shutdown_corelib()
{
    if (g_core_handle == NULL)
        return M64ERR_INVALID_STATE;

    g_core_startup = NULL;

    dynlib_close (g_core_handle);

    g_core_handle = NULL;

    return M64ERR_SUCCESS;
}
