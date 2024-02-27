import 'dart:math' as math;
import 'package:test/test.dart';
import 'reflects.dart';

import 'package:coordtransform_dart/coordtransform_dart.dart';

void main() {
  group('CoordinateTransformUtil', () {
    setUp(() {
      print('setUp');
    });

    test('compare with coordtransform.java', () {
      final wgs84 = CoordinateTransformUtil.bd09ToWgs84(120.698967, 31.324966);
      expect(P(wgs84), P([120.68817433685123, 31.320969743354603]));

      final bd09 = CoordinateTransformUtil.wgs84ToBd09(118.3013077, 32.2719040);
      expect(P(bd09), P([118.31309502519456, 32.27614034221775]));
    });

    test('converter and reconverter', () {
      void test(
        _PointConverter converter,
        _PointConverter reconverter,
        List<double> point,
        double delta,
      ) {
        assert(point.length == 2);
        final result = converter(point[0], point[1]);
        final result2 = reconverter(result[0], result[1]);

        expect(
          P(point, delta),
          P(result2, delta),
          reason: '${converter.name} -> ${reconverter.name}, delta=$delta',
        );
      }

      void testAll(List<double> point) {
        test(
          CoordinateTransformUtil.wgs84ToBd09,
          CoordinateTransformUtil.bd09ToWgs84,
          point,
          1e-5,
        );
        test(
          CoordinateTransformUtil.wgs84ToGcj02,
          CoordinateTransformUtil.gcj02ToWgs84,
          point,
          1e-5,
        );
        test(
          CoordinateTransformUtil.bd09ToGcj02,
          CoordinateTransformUtil.gcj02ToBd09,
          point,
          1e-6,
        );
      }

      testAll([120.68817433685123, 31.320969743354603]);
      testAll([113.915547, 22.535697]);
    });
  });

  group('printUrl', () {
    test('wgs84 to bd09/gcj02', () {
      final lat = 22.634503;
      final lng = 114.035905;
      printUrl([lng, lat], 'wgs84');
      printUrl(CoordinateTransformUtil.wgs84ToBd09(lng, lat), 'bd09ll');
      printUrl(CoordinateTransformUtil.wgs84ToGcj02(lng, lat), 'gcj02');
    });
  });
}

void printUrl(List<double> point, String coord) {
  final lat = point[1];
  final lng = point[0];
  // open this url to preview location
  print(
    'http://api.map.baidu.com/marker'
    '?location=$lat,$lng'
    '&title=$coord'
    '&content=beijing'
    '&output=html'
    '&coord_type=$coord'
    '&src=test',
  );
}

typedef _PointConverter = List<double> Function(double lng, double lat);

/// 比较点是否大致相等
class P {
  const P(this.point, [this.delta = 1e-13]) : assert(point.length == 2);
  final double delta;
  final List<double> point;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    if (o is! P) return false;
    var other = o;
    final finalDelta = math.min(delta, other.delta);
    return (point[0] - other.point[0]).abs() < finalDelta &&
        (point[1] - other.point[1]).abs() < finalDelta;
  }

  @override
  int get hashCode => point.hashCode;

  @override
  String toString() => '$point';
}
