package utils;

class Utils
{
    inline public static function dayStr( date ) :String
    {
        return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0).toString().substr(0, 10);
    }
}
