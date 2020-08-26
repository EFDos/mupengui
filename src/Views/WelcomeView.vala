/************************************************************************/
/*  WelcomeView.vala                                                    */
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

namespace MupenGUI.Views {
    public class WelcomeView : Granite.Widgets.Welcome {

        public WelcomeView () {
            Object (
                title: "Welcome to MupenGUI",
                subtitle: "A sexy frontend for Mupen64plus"
            );
        }

        construct {
            append ("folder-open", "Open ROM Directory", "Your N64 roms will be listed from this directory.");

            activated.connect ((index) => {
                var res = FileSystem.choose_dir ("Select Roms Directory");
                if (res != null) {
                    Globals.CURRENT_ROM_DIR = res;
                    ActionManager.instance.dispatch(Actions.Rom.DIRECTORY_CHOSEN);
                }
            });
        }
    }
}
