import 'package:coordtransform_dart/coordtransform_dart.dart';

void main() {
  const inLngLat = [118.3013077, 32.2719040];
  final outLngLat =
      CoordinateTransformUtil.wgs84ToGcj02(inLngLat[0], inLngLat[1]);
  print('$inLngLat->$outLngLat');
}
