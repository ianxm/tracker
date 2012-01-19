package utils;

class Utils
{
    inline public static function dayStr( date :Date ) :String
    {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0).toString().substr(0, 10);
    }

    inline public static function day( date :Date ) :Date
    {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0);
    }

    inline public static function dayToStr( date :Date ) :String
    {
        return date.toString().substr(0, 10);
    }

    inline public static function dayShift( date :Date, days :Int )
    {
        return DateTools.delta(date, days*1000*60*60*24);
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

    inline public static function tenths(val :Float) :Float
    {
        return Math.round(val*10)/10;
    }
}
