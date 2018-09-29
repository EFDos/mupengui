#include "dynlib.h"
#include <stdio.h>
#include <dlfcn.h>

m64p_error dynlib_open(m64p_dynlib_handle* p_lib_handle, const char* p_lib_path)
{
    if (p_lib_handle == NULL || p_lib_path == NULL) {
        return M64ERR_INPUT_ASSERT;
    }

    *p_lib_handle = dlopen(p_lib_path, RTLD_NOW);

    if (p_lib_path == NULL)
    {
        printf("Mupen64 Error: dlopen('%s') failed: %s", p_lib_path, dlerror());
        return M64ERR_INPUT_NOT_FOUND;
    }

    return M64ERR_SUCCESS;
}

void* dynlib_getproc(m64p_dynlib_handle p_lib_handle, const char* p_name)
{
    if (p_name == NULL)
        return NULL;

    return dlsym(p_lib_handle, p_name);
}

m64p_error dynlib_close(m64p_dynlib_handle p_lib_handle)
{
    int rval = dlclose(p_lib_handle);

    if (rval != 0)
    {
        printf("Mupen64 Error: dlclose() failed: %s", dlerror());
        return M64ERR_INTERNAL;
    }

    return M64ERR_SUCCESS;
}
