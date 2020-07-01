/************************************************************************/
/*  RomListItem.vala                                                    */
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
    class RomListItem : Gtk.Box {

        private Granite.HeaderLabel label;

        public RomListItem (string str) {
            //base (Gtk.Orientation.HORIZONTAL, 0);
            orientation = Gtk.Orientation.HORIZONTAL;
            homogeneous = true;
            halign = Gtk.Align.FILL;
            set_size_request(0, 48);

            label = new Granite.HeaderLabel(str);
            label.set_padding(4, 0);
            pack_start(label);
            var config_image = new Gtk.Image.from_icon_name("document-properties", Gtk.IconSize.LARGE_TOOLBAR);
            config_image.tooltip_text = "Create Settings Profile for this ROM";
            pack_end (config_image);
        }

        public string get_name() {
            return label.label;
        }

    }
}
