/************************************************************************/
/*  ButtonConfig.vala                                                   */
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
namespace MupenGUI.Configuration {
    public class ButtonConfig : Object {

        public enum ButtonID {
            DPadRight,
            DPadLeft,
            DPadDown,
            DPadUp,
            Start,
            TriggerZ,
            ButtonB,
            ButtonA,
            CButtonRight,
            CButtonLeft,
            CButtonDown,
            CButtonUp,
            ShoulderR,
            ShoulderL,
            MempakSwitch,
            RumblepakSwitch,
            AxisX,
            AxisY
        }

        public enum InputType {
            Key,
            JoyButton,
            JoyAxis
        }

        public string name {construct; get;}
        public InputType input_type {construct set; get;}
        public ButtonID button_id {construct; get;}
        public int value {set; get;}

        public ButtonConfig(string p_name, ButtonID p_button_id) {
            Object(
                name: p_name,
                input_type: InputType.Key,
                button_id: p_button_id
            );
        }

        public void sdl_value_remap () {
            switch ((uint)value) {
                case Gdk.Key.Up:
                    value = 273;
                    return;
                case Gdk.Key.Down:
                    value = 274;
                    return;
                case Gdk.Key.Right:
                    value = 275;
                    return;
                case Gdk.Key.Left:
                    value = 276;
                    return;
                case Gdk.Key.space:
                    value = 32;
                    return;
                case Gdk.Key.Alt_L:
                    value = 308;
                    return;
                case Gdk.Key.Control_L:
                    value = 306;
                    return;
                case Gdk.Key.Shift_L:
                    value = 304;
                    return;
                case Gdk.Key.Return:
                    value = 13;
                    return;
                case Gdk.Key.Tab:
                    value = 9;
                    return;
                default: return;
            }
        }
    }
}
