package utils;

import neko.Lib;
import neko.Sys;

class Utils
{
    // get a dayStr (YYYY-MM-DD) from a date or string (parse the string to ensure 
    // it is properly formatted
    public static function dayStr( ?date :Date, ?str :String ) :String
    {
        var date = day(str, date);
        return (date==null) ? null : date.toString().substr(0, 10);
    }

    public static function day( ?str :String, ?date :Date ) :Date
    {
        if( date==null && day==null )
            return null;
        if ( str!=null )
        {
            if( str=="" )
                return null;
            try {
                date = Date.fromString(str);
            } catch ( e:Dynamic ) {
                Lib.println("ERROR: date must be YYYY-MM-DD");
                Sys.exit(1);
            }
        }
        return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0);
    }

    inline public static function dayToStr( date :Date ) :String
    {
        return (date==null) ? null : date.toString().substr(0, 10);
    }

    inline public static function dayShift( date :Date, days :Int )
    {
        return DateTools.delta(date, days*1000*60*60*24.0);
    }

    inline public static function dayDelta( date1 :Date, date2 :Date ) :Int
    {
        return Std.int((date2.getTime()-date1.getTime())/(1000*60*60*24));
    }

    public static function zeroFill( num :Int, width :Int ) :String
    {
        var str = Std.string(num);
        var buf = new StringBuf();
        for( ii in 0...(width-str.length) )
            buf.add("0");
        return buf.toString()+str;
    }

    public static function spaceFill( str :String, width :Int ) :String
    {
        var buf = new StringBuf();
        for( ii in 0...(width-str.length) )
            buf.add(" ");
        return buf.toString()+str;
    }

    inline public static function tenths(val :Float) :Float
    {
        return Math.round(val*10)/10;
    }
}
