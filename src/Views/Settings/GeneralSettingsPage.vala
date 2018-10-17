/************************************************************************/
/*  GeneralSettingsPage.vala                                           */
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

namespace MupenGUI.Views.Settings {
    public class GeneralSettingsPage : Granite.SimpleSettingsPage {
        public GeneralSettingsPage () {
            Object (
                //activable: true,
                description: "Configure MupenGUI General Settings.",
                header: "Frontend",
                icon_name: "preferences-system",
                title: "General Settings"
            );
        }

        construct {

            var general_settings = new GeneralSettings ();

            var lib_dir_label = new Gtk.Label ("Mupen64Plus Library Directory");
            var lib_dir_entry = new Gtk.Entry ();

            lib_dir_entry.set_text (general_settings.mupen64pluslib_dir);

            lib_dir_entry.activate.connect (() => {
                general_settings.mupen64pluslib_dir = lib_dir_entry.get_text ();
                Mupen64API.instance.shutdown ();

                if (Mupen64API.instance.init (general_settings.mupen64pluslib_dir)) {
                    var message_dialog = new Granite.MessageDialog.with_image_from_icon_name (
                        "Mupen64Plus Initalized!",
                        "The Mupen64Plus core library has been found and loaded succesfully! " +
                        "This program is happy now.",
                        "face-smile-symbolic",
                        Gtk.ButtonsType.CLOSE
                    );
                    message_dialog.run ();
                    message_dialog.destroy ();
                }
            });

            content_area.attach (lib_dir_label, 0, 0, 1, 1);
            content_area.attach (lib_dir_entry, 1, 0, 1, 1);
        }
    }
}
