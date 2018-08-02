/************************************************************************/
/*  DisplaySettings.vala                                                */
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

namespace MupenGUI.Services {

    public class UISettings : Granite.Services.Settings {
        public string rom_dir {get; set;}

        public UISettings () {
            base ("com.github.efdos.mupen-gui.ui");
        }

        protected override void verify (string key) {
            switch (key) {
                case "rom-dir":
                    if (rom_dir == null) {
                        rom_dir = "";
                    }
                break;
            }
        }
    }

    public class DisplaySettings : Granite.Services.Settings {
        public bool fullscreen {get; set;}

        public DisplaySettings () {
            base ("com.github.efdos.mupen-gui.display");
        }

    }
}
