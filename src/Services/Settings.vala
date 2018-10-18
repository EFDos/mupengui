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

    public class GeneralSettings : Granite.Services.Settings {
        public string mupen64pluslib_dir {get; set;}
        public string mupen64plugin_dir {get; set;}
        public string mupen64plugin_video {get; set;}
        public string mupen64plugin_audio {get; set;}
        public string mupen64plugin_input {get; set;}
        public string mupen64plugin_rsp {get; set;}

        public GeneralSettings () {
            base ("com.github.efdos.mupen-gui.general");
        }

        protected override void verify (string key) {
            switch (key) {
                case "mupen64pluslib-dir":
                    if (mupen64pluslib_dir == null) {
                        mupen64pluslib_dir = "";
                    }
                break;
                case "mupen64plugin-dir":
                    if (mupen64plugin_dir == null) {
                        mupen64plugin_dir = "";
                    }
                break;
                case "mupen64plugin-video":
                    if (mupen64plugin_video == null) {
                        mupen64plugin_video = "";
                    }
                break;
                case "mupen64plugin-audio":
                    if (mupen64plugin_audio == null) {
                        mupen64plugin_audio = "";
                    }
                break;
                case "mupen64plugin-input":
                    if (mupen64plugin_input == null) {
                        mupen64plugin_input = "";
                    }
                break;
                case "mupen64plugin-rsp":
                    if (mupen64plugin_rsp == null) {
                        mupen64plugin_rsp = "";
                    }
                break;
            }
        }
    }
}
