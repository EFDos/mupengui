/************************************************************************/
/*  DisplaySettingsPage.vala                                           */
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
using MupenGUI.Services;
using MupenGUI.Configuration;

namespace MupenGUI.Views.Settings {

    public class InputSettingsPage : Granite.SimpleSettingsPage {

        ButtonConfig[] button_list = {
            new ButtonConfig("D Right", ButtonConfig.ButtonID.DPadRight),
            new ButtonConfig("D Left", ButtonConfig.ButtonID.DPadLeft),
            new ButtonConfig("D Down", ButtonConfig.ButtonID.DPadDown),
            new ButtonConfig("D Up", ButtonConfig.ButtonID.DPadUp),
            new ButtonConfig("Start", ButtonConfig.ButtonID.Start),
            new ButtonConfig("Trigger Z", ButtonConfig.ButtonID.TriggerZ),
            new ButtonConfig("Button B", ButtonConfig.ButtonID.ButtonB),
            new ButtonConfig("Button A", ButtonConfig.ButtonID.ButtonA),
            new ButtonConfig("C Right", ButtonConfig.ButtonID.CButtonRight),
            new ButtonConfig("C Left", ButtonConfig.ButtonID.CButtonLeft),
            new ButtonConfig("C Down", ButtonConfig.ButtonID.CButtonDown),
            new ButtonConfig("C Up", ButtonConfig.ButtonID.CButtonUp),
            new ButtonConfig("Trigger R", ButtonConfig.ButtonID.ShoulderR),
            new ButtonConfig("Trigger L", ButtonConfig.ButtonID.ShoulderL),
            new ButtonConfig("Axis Left", ButtonConfig.ButtonID.AxisX),
            new ButtonConfig("Axis Up", ButtonConfig.ButtonID.AxisY)
        };
        private uint button_list_it = 0;
        private uint selected_controller = 0;
        private int selected_device = -1;

        public InputSettingsPage () {
            Object (
                //activable: true,
                description: "Configure Mupen64 Input Settings.",
                header: "Emulator",
                icon_name: "input-gaming",
                title: "Input Settings"
            );
        }

        construct {

            var controller_label = new Granite.HeaderLabel ("Emulator Controller");
            var device_label = new Granite.HeaderLabel ("Device");
            var set_controls_button = new Gtk.Button.with_label ("Set Buttons");

            var list_store = new Gtk.ListStore (2, typeof(string), typeof(uint));
		    Gtk.TreeIter iter;

		    list_store.append (out iter);
		    list_store.set (iter, 0, "Controller 1", 1, 0);
		    list_store.append (out iter);
		    list_store.set (iter, 0, "Controller 2", 1, 1);
		    list_store.append (out iter);
		    list_store.set (iter, 0, "Controller 3", 1, 2);
		    list_store.append (out iter);
		    list_store.set (iter, 0, "Controller 4", 1, 3);

            var controller_list_box = new Gtk.ComboBox.with_model (list_store);
            var renderer = new Gtk.CellRendererText ();
		    controller_list_box.pack_start (renderer, true);
		    controller_list_box.add_attribute (renderer, "text", 0);
		    controller_list_box.active = 0;

            var dlist_store = new Gtk.ListStore (2, typeof (string), typeof(int));
            Gtk.TreeIter d_iter;

            var device_list = JoystickListener.instance.get_device_list ();
            dlist_store.append(out d_iter);
            dlist_store.set (d_iter, 0, "Keyboard", 1, -1);

            var device_number = 0;
            device_list.foreach ((str) => {
                dlist_store.append(out d_iter);
                dlist_store.set (d_iter, 0, "Joystick " + str, 1, device_number);
                ++device_number;
            });

            var device_list_box = new Gtk.ComboBox.with_model (dlist_store);
            renderer = new Gtk.CellRendererText ();
            device_list_box.pack_start (renderer, true);
            device_list_box.add_attribute (renderer, "text", 0);
            device_list_box.active = 0;

            controller_list_box.changed.connect(() => {
                Value n;
                controller_list_box.get_active_iter (out iter);
                list_store.get_value (iter, 1, out n);
                selected_controller = (uint)n;
            });

            device_list_box.changed.connect (() => {
                Value n;
                device_list_box.get_active_iter (out d_iter);
                dlist_store.get_value (d_iter, 1, out n);
                selected_device = (int)n;
            });

            set_controls_button.clicked.connect (() => {
                var message_dialog = new Widgets.JoystickEventDialog.with_image_from_icon_name (
                        "Set Button " + button_list[0].name,
                        "Press a key or joystick button...",
                        "applications-development",
                        Gtk.ButtonsType.CANCEL
                );
                JoystickListener.instance.set_listening_device (selected_device);
                JoystickListener.instance.start ();
                Mupen64API.instance.set_controller_device (selected_controller, selected_device);

                /*message_dialog.key_release_event.connect ((event) => {
                    print ("keyval for %s: %u\n", button_list[button_list_it].name, event.key.hardware_keycode);
                    button_list[button_list_it].input_type = ButtonConfig.InputType.Key;
                    //Services.Mupen64API.instance.bind_controller_button (selected_controller, button_list[button_list_it], (int)event.key.keyval);
                    if (++button_list_it > button_list.length - 1) {
                        button_list_it = 0;
                        message_dialog.close ();
                    }
                    message_dialog.primary_text = "Set Button " + button_list[button_list_it].name;
                });*/

                message_dialog.joystick_event.connect ((event) => {
                    if (event.type == Widgets.JoystickEventDialog.JoyEventType.Axis) {
                        button_list[button_list_it].input_type = ButtonConfig.InputType.JoyAxis;
                        Mupen64API.instance.bind_controller_button (selected_controller,
                                                                    button_list[button_list_it],
                                                                    (int)event.id,
                                                                    (int)event.val);
                    } else if (event.type == Widgets.JoystickEventDialog.JoyEventType.Button) {
                        button_list[button_list_it].input_type = ButtonConfig.InputType.JoyButton;
                        Mupen64API.instance.bind_controller_button (selected_controller,
                                                                    button_list[button_list_it],
                                                                    (int)event.id,
                                                                    null);
                    }

                    if (++button_list_it > button_list.length - 1) {
                        message_dialog.close ();
                    }
                    message_dialog.primary_text = "Set Button " + button_list[button_list_it].name;
                });

                message_dialog.close.connect (() => {
                    button_list_it = 0;
                    Mupen64API.instance.save_current_settings ();
                    //Services.JoystickListener.instance.stop ();
                });

                message_dialog.response.connect ((response_id) => {
                    button_list_it = 0;
                    Mupen64API.instance.save_current_settings ();
                    //Services.JoystickListener.instance.stop ();
                });

                message_dialog.run ();
                message_dialog.destroy ();
            });

            content_area.attach (controller_label, 0, 0, 1, 1);
            content_area.attach (controller_list_box, 1, 0, 1, 1);
            content_area.attach (device_label, 0, 1, 1, 1);
            content_area.attach (device_list_box, 1, 1, 1, 1);
            content_area.attach (set_controls_button, 0, 2, 1, 2);
        }
    }
}
