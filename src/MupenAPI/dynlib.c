/************************************************************************/
/*  dynlib.c                                                            */
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
#include "dynlib.h"
#include <stdio.h>
#include <dlfcn.h>

m64p_error dynlib_open(m64p_dynlib_handle* p_lib_handle, const char* p_lib_path)
{
    if (p_lib_handle == NULL || p_lib_path == NULL) {
        return M64ERR_INPUT_ASSERT;
    }

    *p_lib_handle = dlopen(p_lib_path, RTLD_NOW);

    if (*p_lib_handle == NULL)
    {
        printf("M64API Error: dlopen('%s')\n failed: %s", p_lib_path, dlerror());
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
        printf("M64API Error: dlclose()\n failed: %s", dlerror());
        return M64ERR_INTERNAL;
    }

    return M64ERR_SUCCESS;
}
