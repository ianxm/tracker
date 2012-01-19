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
