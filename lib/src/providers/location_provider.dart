import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LocationProvider extends ChangeNotifier {
  static LocationProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<LocationProvider>(context, listen: listen);

  String placeId;
  LatLng _lastIdleLocation;

  LatLng get lastIdleLocation => _lastIdleLocation;

  void setLastIdleLocation(LatLng lastIdleLocation, {String placeID}) {
    if (_lastIdleLocation != lastIdleLocation) {
      _lastIdleLocation = lastIdleLocation;
      this.placeId = placeId;
      notifyListeners();
    }
  }
}
