import 'package:latlong2/latlong.dart';

class AppConstants {
  // constants needed for accessing map box
  static const String mapBoxAccessToken = 'MAPBOX_ACCESS_TOKEN=your-new-mapbox-token';

  static const String mapBoxStyleId = 'clont8dlb004k01nw2f8t98tb';

  // default location if geocoding permissions are denied
  static const myLocation = LatLng(43.945600, -78.896800);
}
