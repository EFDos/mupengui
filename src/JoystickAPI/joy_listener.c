/************************************************************************/
/*  joy_listener.c                                                      */
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
#include "../MupenAPI/common.h"
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/joystick.h>

#define JOY_DEV "/dev/input/js0"

int g_joy_fd = 0;
int* g_axis = NULL;
char* g_button = NULL;

struct js_event g_js;

boolean joy_init ()
{
    int num_of_axis=0, num_of_buttons=0; //, x;
	char name_of_joystick[80];

	if( ( g_joy_fd = open( JOY_DEV , O_RDONLY)) == -1 )
	{
		printf( "Couldn't open joystick\n" );
		return FALSE;
	}

	ioctl( g_joy_fd, JSIOCGAXES, &num_of_axis );
	ioctl( g_joy_fd, JSIOCGBUTTONS, &num_of_buttons );
	ioctl( g_joy_fd, JSIOCGNAME(80), &name_of_joystick );

	g_axis = (int *) calloc( num_of_axis, sizeof( int ) );
	g_button = (char *) calloc( num_of_buttons, sizeof( char ) );

    for (int i = 0 ; i < num_of_axis ; ++i) {
        g_axis[i] = 0;
    }

    for (int i = 0 ; i < num_of_buttons ; ++i) {
        g_button[i] = 0;
    }

	printf("Joystick detected: %s\n\t%d axis\n\t%d buttons\n\n"
		, name_of_joystick
		, num_of_axis
		, num_of_buttons );

	fcntl( g_joy_fd, F_SETFL, O_NONBLOCK );	/* use non-blocking mode */
    return TRUE;
}

int joy_event_loop()
{
	// read the joystick state
	read(g_joy_fd, &g_js, sizeof(struct js_event));

			// see what to do with the event
	switch (g_js.type & ~JS_EVENT_INIT)
	{
		case JS_EVENT_AXIS:
			if (g_axis[g_js.number] != 0 && g_js.value == 0) {
                g_axis[g_js.number] = 0;
                return g_js.number + 100;
            }
            g_axis[g_js.number] = g_js.value;
            break;
		case JS_EVENT_BUTTON:
			if (g_button[g_js.number] != 0 && g_js.value == 0) {
                g_button[g_js.number] = 0;
                return g_js.number;
            }
            g_button[g_js.number] = g_js.value;
            break;
        default:
            break;
	}

			// print the results
		//printf( "X: %6d  Y: %6d  ", g_axis[0], g_axis[1] );

		/*if( num_of_axis > 2 )
			printf("Z: %6d  ", axis[2] );

		if( num_of_axis > 3 )
			printf("R: %6d  ", axis[3] );

		for( x=0 ; x<num_of_buttons ; ++x )
			printf("B%d: %d  ", x, button[x] );

		printf("  \r");
		fflush(stdout);*/

	//close( joy_fd );	// too bad we never get here
	return -1;
}
