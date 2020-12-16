import 'dart:math' as Math;

class Rectangle {
  final double west;

  final double north;

  final double east;

  final double south;

  Rectangle(double lng1, double lat1, double lng2, double lat2)
      : west = Math.min(lng1, lng2),
        north = Math.max(lat1, lat2),
        east = Math.max(lng1, lng2),
        south = Math.min(lat1, lat2);

  bool contain(double lng, double lat) {
    return this.west <= lng &&
        this.east >= lng &&
        this.north >= lat &&
        this.south <= lat;
  }
}
