/************************************************************************/
/*  Actions.vala                                                        */
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

namespace MupenGUI.Actions {
    namespace Rom {
        public const string DIRECTORY_CHOSEN = "MupenGUI.Actions.RDC";
        public const string CURSOR_CHANGED = "MupenGUI.Action.RCC";
        public const string EXECUTION_REQUESTED = "MupenGUI.Action.RER";
    }

    namespace General {
        public const string SETTINGS_OPEN = "MupenGUI.Action.GSO";
        public const string SETTINGS_CLOSE = "MupenGUI.Action.GSC";
    }

    namespace SettingsUpdate {
        public const string SETTINGS_PROFILE_UPDATE = "MupenGUI.Action.SPU";
        public const string MUPEN_SETTINGS_UPDATE = "MupenGUI.Action.MSU";
    }
}
