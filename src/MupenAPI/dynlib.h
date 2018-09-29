#ifndef MUPENGUI_C_API_DYNLIB
#define MUPENGUI_C_API_DYNLIB

#include "m64p_common.h"

m64p_error dynlib_open(m64p_dynlib_handle* p_lib_handle, const char* p_lib_path);

void* dynlib_getproc(m64p_dynlib_handle p_lib_handle, const char* p_name);

m64p_error dynlib_close(m64p_dynlib_handle p_lib_handle);

#endif
