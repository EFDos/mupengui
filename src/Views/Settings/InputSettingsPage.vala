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

namespace MupenGUI.Views.Settings {
    public class InputSettingsPage : Granite.SimpleSettingsPage {

        string[] button_list = {
            "DPad R",
            "DPad L",
            "DPad U",
            "DPad D",
            "Start",
            "Axis U",
            "Axis L",
            "Axis U",
            "Axis D",
            "Z",
            "A",
            "B",
            "C R",
            "C L",
            "C U",
            "C D",
            "R",
            "L"
        };
        uint button_list_it = 0;

        public InputSettingsPage () {
            Object (
                //activable: true,
                description: "Configure Mupen64 Input Settings.",
                icon_name: "input-gaming",
                title: "Input Settings"
            );
        }

        construct {

            var settings = new Services.InputSettings ();

            var controller_label = new Granite.HeaderLabel ("Controller");
            var set_controls_button = new Gtk.Button.with_label ("Set Buttons");

            Gtk.ListStore list_store = new Gtk.ListStore (1, typeof (int));
		    Gtk.TreeIter iter;

		    list_store.append (out iter);
		    list_store.set (iter, 0, 1);
		    list_store.append (out iter);
		    list_store.set (iter, 0, 2);
		    list_store.append (out iter);
		    list_store.set (iter, 0, 3);
		    list_store.append (out iter);
		    list_store.set (iter, 0, 4);

            Gtk.ComboBox controller_list_box = new Gtk.ComboBox.with_model (list_store);
            Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
		    controller_list_box.pack_start (renderer, true);
		    controller_list_box.add_attribute (renderer, "text", 0);
		    controller_list_box.active = 0;

            set_controls_button.clicked.connect (() => {
                var message_dialog = new Widgets.JoystickEventDialog.with_image_from_icon_name (
                        "Set Button " + button_list[0],
                        "Press a key or joystick button...",
                        "applications-development",
                        Gtk.ButtonsType.CANCEL
                );
                Services.JoystickListener.instance.start ();

                message_dialog.key_release_event.connect ((event) => {
                    print ("keyval for %s: %u\n", button_list[button_list_it], event.key.keyval);
                    if (++button_list_it > button_list.length - 1) {
                        button_list_it = 0;
                        message_dialog.close ();
                    }
                    message_dialog.primary_text = "Set Button " + button_list[button_list_it];
                });

                message_dialog.joystick_event.connect ((event) => {
                    print ("joystick pressed, omg, I can't even believe it.\n");
                    if (++button_list_it > button_list.length - 1) {
                        message_dialog.close ();
                    }
                    message_dialog.primary_text = "Set Button " + button_list[button_list_it];
                });

                message_dialog.close.connect (() => {
                    button_list_it = 0;
                    Services.JoystickListener.instance.stop ();
                });

                message_dialog.response.connect ((response_id) => {
                    button_list_it = 0;
                    Services.JoystickListener.instance.stop ();
                });

                message_dialog.run ();
                message_dialog.destroy ();
            });

/*            fullscreen_switch.state_set (settings.fullscreen);

            fullscreen_switch.state_set.connect ((state) => {
                settings.fullscreen = state;
                print(state.to_string ());
            });*/

            content_area.attach (controller_label, 0, 0, 1, 1);
            content_area.attach (controller_list_box, 1, 0, 1, 1);
            content_area.attach (set_controls_button, 0, 2, 1, 2);
        }
    }
}
