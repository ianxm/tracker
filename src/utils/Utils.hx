/*
 Copyright (c) 2012, Ian Martins (ianxm@jhu.edu)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/
package utils;

import altdate.Gregorian;

class Utils
{
    public static function dayFromString( str :String ) :Gregorian
    {
        var date;
        if( str == null || str == "" )
            return null;
        try {
            date = Date.fromString(str);
        } catch ( e:Dynamic ) {
            throw "date must be YYYY-MM-DD";
        }
        return dayFromDate(date);
    }

    inline public static function dayFromJulian( julianDay :Float )
    {
        var g = new Gregorian();
        g.value = julianDay;
        return g;
    }

    inline public static function today() :Gregorian
    {
        return dayFromDate(Date.now());
    }

    inline public static function dayFromDate( date :Date ) :Gregorian
    {
        var g = new Gregorian();
        g.set(false, null, date.getFullYear(), date.getMonth(), date.getDate());
        return g;
    }

    inline public static function now() :Gregorian
    {
        var g = new Gregorian();
        var date = Date.now();
        g.set(true, null, date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds());
        return g;
    }

    // copies and shifts
    inline public static function dayShift( date :Gregorian, days :Int )
    {
        var g = new Gregorian();
        g.set(false, null, date.year, date.month, date.day+days);
        return g;
    }

    inline public static function tenths(val :Float) :Float
    {
        return Math.round(val*10)/10;
    }
}
