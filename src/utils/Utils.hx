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

import neko.Lib;
import neko.Sys;
import altdate.Gregorian;

class Utils
{
    // get a dayStr (YYYY-MM-DD) from a date or string (parse the string to ensure 
    // it is properly formatted
    public static function dayStr( ?date :Date, ?str :String )
    {
        var d = if( date != null )
            dayFromDate(date);
        else
            dayFromString(str);
        return (d==null) ? null : d.toString();
    }

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

    public static function dayFromJulian( julianDay :Float )
    {
        var g = new Gregorian();
        g.value = julianDay;
        return g;
    }

    public static function today() :Gregorian
    {
        return dayFromDate(Date.now());
    }

    public static function dayFromDate( date :Date ) :Gregorian
    {
        var g = new Gregorian();
        g.set(false, null, date.getFullYear(), date.getMonth(), date.getDate());
        return g;
    }

    public static function dayToStr( date :Gregorian ) :String
    {
        return (date==null) ? null : date.toString();
    }

    public static function dayShift( date :Gregorian, days :Int )
    {
        date.day += days;
        return date;
    }

    public static function dayDelta( date1 :Gregorian, date2 :Gregorian ) :Int
    {
       return Std.int(date2.value-date1.value);
    }

    inline public static function tenths(val :Float) :Float
    {
        return Math.round(val*10)/10;
    }
}
