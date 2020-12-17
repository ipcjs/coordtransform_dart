import './rectangle.dart';
import 'dart:math' as Math;
import 'package:meta/meta.dart';

/**
 * 百度坐标（BD09）、国测局坐标（火星坐标，GCJ02）、和WGS84坐标系之间的转换的工具
 * <p>
 * 参考<a href="https://github.com/wandergis/coordtransform">wandergis/coordtransform</a>实现的Java版本
 * @author geosmart
 */
class CoordinateTransformUtil {
    CoordinateTransformUtil._();

    //China region - raw data
    static final List<Rectangle> REGION = [
            new Rectangle(79.446200, 49.220400, 96.330000, 42.889900),
            new Rectangle(109.687200, 54.141500, 135.000200, 39.374200),
            new Rectangle(73.124600, 42.889900, 124.143255, 29.529700),
            new Rectangle(82.968400, 29.529700, 97.035200, 26.718600),
            new Rectangle(97.025300, 29.529700, 124.367395, 20.414096),
            new Rectangle(107.975793, 20.414096, 111.744104, 17.871542),
    ];

    //China excluded region - raw data
    static final List<Rectangle> EXCLUDE = [
            new Rectangle(119.921265, 25.398623, 122.497559, 21.785006),
            new Rectangle(101.865200, 22.284000, 106.665000, 20.098800),
            new Rectangle(106.452500, 21.542200, 108.051000, 20.487800),
            new Rectangle(109.032300, 55.817500, 119.127000, 50.325700),
            new Rectangle(127.456800, 55.817500, 137.022700, 49.557400),
            new Rectangle(131.266200, 44.892200, 137.022700, 42.569200),
            new Rectangle(73.124600, 35.398637, 77.948114, 29.529700),
    ];

    @internal static double X_PI = 3.14159265358979324 * 3000.0 / 180.0;

    // π
    @internal static double PI = 3.1415926535897932384626;

    // 长半轴
    @internal static double A = 6378245.0;

    // 扁率
    @internal static double EE = 0.00669342162296594323;

    @internal static bool isInChina(double lng, double lat) {
        for (Rectangle region in REGION) {
            if (region.contain(lng, lat)) {
                for (Rectangle exclude in EXCLUDE) {
                    if (exclude.contain(lng, lat)) {
                        return false;
                    }
                }
                return true;
            }
        }
        return false;
    }

    /**
     * WGS84转GCJ02(火星坐标系)
     * @param lng WGS84坐标系的经度
     * @param lat WGS84坐标系的纬度
     * @return 火星坐标数组
     */
    static List<double> wgs84ToGcj02(double lng, double lat) {
        if (!isInChina(lng, lat)) {
            return [lng, lat];
        }
        return transform(lng, lat);
    }

    /**
     * GCJ02(火星坐标系)转WGS84
     * @param lng 火星坐标系的经度
     * @param lat 火星坐标系纬度
     * @return WGS84坐标数组
     */
    static List<double> gcj02ToWgs84(double lng, double lat) {
        if (!isInChina(lng, lat)) {
            return [lng, lat];
        }
        List<double> out = transform(lng, lat);
        return [lng * 2 - out[0], lat * 2 - out[1]];
    }

    /**
     * 火星坐标系(GCJ-02)转百度坐标系(BD-09)
     * @param lng 火星坐标经度
     * @param lat 火星坐标纬度
     * @return 百度坐标数组
     * @info 谷歌、高德——>百度
     */
    static List<double> gcj02ToBd09(double lng, double lat) {
        double z = Math.sqrt(lng * lng + lat * lat) + 0.00002 * Math.sin(lat * X_PI);
        double theta = Math.atan2(lat, lng) + 0.000003 * Math.cos(lng * X_PI);
        double bd_lng = z * Math.cos(theta) + 0.0065;
        double bd_lat = z * Math.sin(theta) + 0.006;
        return [bd_lng, bd_lat];
    }

    /**
     * 百度坐标系(BD-09)转火星坐标系(GCJ-02)
     * @param bd_lng 百度坐标纬度
     * @param bd_lat 百度坐标经度
     * @return 火星坐标数组
     * @info 百度——>谷歌、高德
     */
    static List<double> bd09ToGcj02(double bd_lng, double bd_lat) {
        double x = bd_lng - 0.0065;
        double y = bd_lat - 0.006;
        double z = Math.sqrt(x * x + y * y) - 0.00002 * Math.sin(y * X_PI);
        double theta = Math.atan2(y, x) - 0.000003 * Math.cos(x * X_PI);
        double gg_lng = z * Math.cos(theta);
        double gg_lat = z * Math.sin(theta);
        return [gg_lng, gg_lat];
    }

    /**
     * WGS坐标转百度坐标系(BD-09)
     * @param lng WGS84坐标系的经度
     * @param lat WGS84坐标系的纬度
     * @return 百度坐标数组
     */
    static List<double> wgs84ToBd09(double lng, double lat) {
        List<double> gcj = wgs84ToGcj02(lng, lat);
        List<double> bd09 = gcj02ToBd09(gcj[0], gcj[1]);
        return bd09;
    }

    /**
     * 百度坐标系(BD-09)转WGS坐标
     * @param lng 百度坐标纬度
     * @param lat 百度坐标经度
     * @return WGS84坐标数组
     */
    static List<double> bd09ToWgs84(double lng, double lat) {
        List<double> gcj = bd09ToGcj02(lng, lat);
        List<double> wgs84 = gcj02ToWgs84(gcj[0], gcj[1]);
        return wgs84;
    }

    @internal static List<double> transform(final double lng, final double lat) {
        double dlat = transformLat(lng - 105.0, lat - 35.0);
        double dlng = transformLng(lng - 105.0, lat - 35.0);
        double radlat = lat / 180.0 * PI;
        double magic = Math.sin(radlat);
        magic = 1 - EE * magic * magic;
        double sqrtmagic = Math.sqrt(magic);
        dlat = (dlat * 180.0) / ((A * (1 - EE)) / (magic * sqrtmagic) * PI);
        dlng = (dlng * 180.0) / (A / sqrtmagic * Math.cos(radlat) * PI);
        return [lng + dlng, lat + dlat];
    }

    /**
     * 纬度转换
     */
    @internal static double transformLat(double lng, double lat) {
        double ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat + 0.1 * lng * lat + 0.2 * Math
                .sqrt(lng.abs());
        ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(lat * PI) + 40.0 * Math.sin(lat / 3.0 * PI)) * 2.0 / 3.0;
        ret += (160.0 * Math.sin(lat / 12.0 * PI) + 320 * Math.sin(lat * PI / 30.0)) * 2.0 / 3.0;
        return ret;
    }

    /**
     * 经度转换
     */
    @internal static double transformLng(double lng, double lat) {
        double ret = 300.0 + lng + 2.0 * lat + 0.1 * lng * lng + 0.1 * lng * lat + 0.1 * Math
                .sqrt(lng.abs());
        ret += (20.0 * Math.sin(6.0 * lng * PI) + 20.0 * Math.sin(2.0 * lng * PI)) * 2.0 / 3.0;
        ret += (20.0 * Math.sin(lng * PI) + 40.0 * Math.sin(lng / 3.0 * PI)) * 2.0 / 3.0;
        ret += (150.0 * Math.sin(lng / 12.0 * PI) + 300.0 * Math.sin(lng / 30.0 * PI)) * 2.0 / 3.0;
        return ret;
    }
}
