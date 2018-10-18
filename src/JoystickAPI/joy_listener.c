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
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/joystick.h>

#define JOY_DEV "/dev/input/js%d"

typedef struct
{
    int id;
    int n_axis, n_buttons;
    int* axis;
    char* button;
    char name[80];
} joy_def;

void init_joy_def(joy_def* joy)
{
    joy->id = 0;
    joy->n_axis = 0;
    joy->n_buttons = 0;
    joy->axis = NULL;
    joy->button = NULL;
    memcpy(joy->name, "undefined", 80);
}

joy_def g_joy[4];
int g_total_joys = 0;
int g_current_joy = -1;

struct js_event g_js;

boolean joy_init ()
{
    char buffer[15];
    for (int i = 0 ; i < 4 ; ++i)
    {
        init_joy_def (&g_joy[i]);
        sprintf(buffer, JOY_DEV, i);
        if ((g_joy[i].id = open(buffer, O_RDONLY)) == -1) {
            continue;
        }

        ioctl(g_joy[i].id, JSIOCGAXES, &g_joy[i].n_axis);
        ioctl(g_joy[i].id, JSIOCGBUTTONS, &g_joy[i].n_buttons);
        ioctl(g_joy[i].id, JSIOCGNAME(80), &g_joy[i].name);

        g_joy[i].axis = (int*) calloc(g_joy[i].n_axis, sizeof(int));
        g_joy[i].button = (char*) calloc(g_joy[i].n_buttons, sizeof(char));

        for (int j = 0 ; j < g_joy[i].n_axis ; ++j) {
            g_joy[i].axis[j] = 0;
        }

        for (int j = 0 ; j < g_joy[i].n_buttons ; ++j) {
            g_joy[i].button[j] = 0;
        }

        printf("JoyAPI Info: Joystick detected: %s\n\t%d axis\n\t%d buttons\n\n",
               g_joy[i].name,
               g_joy[i].n_axis,
               g_joy[i].n_buttons);

        fcntl(g_joy[i].id, F_SETFL, O_NONBLOCK); // user non-blocking mode
        ++g_total_joys;
    }

    printf("JoyAPI Info: Total joysticks detected: %d\n", g_total_joys);

    if (g_total_joys > 0) {
        return TRUE;
    } else {
        return FALSE;
    }
	/*if( ( g_joy_fd[0] = open( JOY_DEV , O_RDONLY)) == -1 )
	{
		printf( "Couldn't open joystick\n" );
		return FALSE;
	}*/

	/*ioctl( g_joy_fd, JSIOCGAXES, &num_of_axis );
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

	fcntl( g_joy_fd, F_SETFL, O_NONBLOCK );	use non-blocking mode */
}

void joy_shutdown()
{
    for (int i = 0 ; i < g_total_joys ; ++i) {
        close(g_joy[i].id);
    }
    g_total_joys = 0;
    g_current_joy = -1;
}

void joy_set_current(unsigned int id)
{
    if (id > g_total_joys - 1) {
        printf("JoyAPI Error: Device %d wasn't initialized.\n", id);
        return;
    }

    g_current_joy = id;
}

unsigned joy_get_total()
{
    return g_total_joys;
}

char* joy_get_name(unsigned int id)
{
    if (id > g_total_joys -1) {
        printf("JoyAPI Error: Device %d wasn't initialized.\n", id);
        return NULL;
    }

    return g_joy[id].name;
}

int retval[3];
int* joy_event_loop()
{
    if (g_current_joy == -1) {
        printf("JoyAPI Error: Current device wasn't set!\n"
               "Do you want me to explode??\n");
        retval[0] = -1;
        return retval;
    }
    // read the joystick state
    read(g_joy[g_current_joy].id, &g_js, sizeof(struct js_event));

		    // see what to do with the event
    switch (g_js.type & ~JS_EVENT_INIT)
    {
	    case JS_EVENT_AXIS:
		    if (g_joy[g_current_joy].axis[g_js.number] != 0 && g_js.value == 0) {
                retval[0] = 1;
                retval[1] = g_js.number;
                retval[2] = g_joy[g_current_joy].axis[g_js.number];
                g_joy[g_current_joy].axis[g_js.number] = 0;
                return retval;
            }
            g_joy[g_current_joy].axis[g_js.number] = g_js.value;
            break;
	    case JS_EVENT_BUTTON:
		    if (g_joy[g_current_joy].button[g_js.number] != 0 && g_js.value == 0) {
                retval[0] = 0;
                retval[1] = g_js.number;
                retval[2] = g_joy[g_current_joy].button[g_js.number];
                g_joy[g_current_joy].button[g_js.number] = 0;
                return retval;
            }
            g_joy[g_current_joy].button[g_js.number] = g_js.value;
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
    retval[0] = -1;
	return retval;
}
