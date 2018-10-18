/************************************************************************/
/*  JoystickListener.vala                                               */
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
using MupenGUI.Views.Widgets;

extern bool joy_init ();
extern void joy_shutdown ();
extern uint joy_get_total ();
extern unowned string joy_get_name (uint id);
extern void joy_set_current (uint id);
extern int joy_event_loop ();

namespace MupenGUI.Services {

    class JoystickListener : Object {

        private static JoystickListener _instance = null;
        private Thread<void*> event_thread = null;
        private unowned JoystickEventDialog joy_dialog = null;
        private bool thread_run = false;

        public static JoystickListener instance {
            get {
                if (_instance == null) {
                    _instance = new JoystickListener ();
                }

                return _instance;
            }
        }

        private JoystickListener () {
        }

        ~JoystickListener () {
            joy_shutdown ();
        }

        public bool init () {
            return joy_init ();
        }

        public void start () {
            print("start called\n");
            if (event_thread != null) {
                return;
            }
            thread_run = true;
            event_thread = new Thread<void*> ("joy_event_thread", _joystick_event_func);
            print("started thread.\n");
        }

        public void stop () {
            print("stop called\n");
            if (event_thread == null) {
                return;
            }
            lock (thread_run) {
                thread_run = false;
            }
            print("waiting to join thread...\n");
            event_thread.join ();
            print("joined thread\n");
            event_thread = null;
        }

        public void set_listening_device (uint device_id) {
            joy_set_current (device_id);
        }

        public GenericArray<string> get_device_list () {
            var device_list = new GenericArray<string> ();

            for (int i = 0 ; i < joy_get_total () ; ++i) {
                device_list.add (joy_get_name (i));
            }

            return device_list;
        }

        public void register_dialog (JoystickEventDialog dialog) {
            lock (joy_dialog) {
                joy_dialog = dialog;
            }
        }

        public void unregister_dialog (JoystickEventDialog dialog) {
            lock (joy_dialog) {
                if (joy_dialog == dialog) {
                    joy_dialog = null;
                }
            }
        }

        private void* _joystick_event_func () {
            while (true) {
                var should_run = false;
                lock (thread_run) {
                    should_run = thread_run;
                }
                if (should_run) {
                    var result = joy_event_loop ();
                    if (result == -1) continue;
                    lock (joy_dialog) {
                        if (joy_dialog != null) joy_dialog.joystick_event (result);
                    }
                } else {
                    return null;
                }
            }
        }
    }
}
