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

extern bool joy_init ();
extern int joy_event_loop ();

namespace MupenGUI.Services {

    class JoystickListener : Object {

        private static JoystickListener _instance = null;
        private Thread<void*> event_thread = null;
        private unowned Views.Widgets.JoystickEventDialog joy_dialog = null;
        private bool thread_run = false;

        public static JoystickListener instance {
            get {
                if (_instance == null) {
                    _instance = new JoystickListener ();
                }

                return _instance;
            }
        }

        JoystickListener () {
        }

        public bool init () {
            return joy_init ();
        }

        public void start () {
            print("start called\n");
            if (event_thread != null) {
                return;
            }
            try {
                thread_run = true;
                event_thread = new Thread<void*> ("joy_event_thread", _joystick_event_func);
                print("started thread.\n");
            } catch (ThreadError e) {
                stderr.printf ("Error: %s", e.message);
            }
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

        public void register_dialog (Views.Widgets.JoystickEventDialog dialog) {
            lock (joy_dialog) {
                joy_dialog = dialog;
            }
        }

        public void unregister_dialog (Views.Widgets.JoystickEventDialog dialog) {
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
                    if (result >= 100) {
                        print("axis moved: %d\n", result - 100);
                        lock (joy_dialog) {
                            if (joy_dialog != null) joy_dialog.joystick_event ();
                        }
                    }
                    else {
                        print("button pressed: %d\n", result);
                        lock (joy_dialog) {
                            if (joy_dialog != null) joy_dialog.joystick_event ();
                        }
                    }
                } else {
                    return null;
                }
            }
        }
    }
}
