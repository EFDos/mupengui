/************************************************************************/
/*  JoystickEventDialog.vala                                            */
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

namespace MupenGUI.Views.Widgets {
    class JoystickEventDialog : Granite.MessageDialog {

        public signal void joystick_event (int joy_value);

        public JoystickEventDialog (string p_primary_text, string p_secondary_text, Icon p_icon, Gtk.ButtonsType p_buttons = CLOSE) {
            base (p_primary_text, p_secondary_text, p_icon, p_buttons);
            Services.JoystickListener.instance.register_dialog (this);
        }

        public JoystickEventDialog.with_image_from_icon_name (string p_primary_text, string p_secondary_text, string p_icon, Gtk.ButtonsType p_buttons = CLOSE) {
            base.with_image_from_icon_name (p_primary_text, p_secondary_text, p_icon, p_buttons);
            Services.JoystickListener.instance.register_dialog (this);
        }

        ~JoystickEventDialog () {
            Services.JoystickListener.instance.unregister_dialog (this);
        }
    }
}
