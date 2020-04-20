import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class LocationProvider extends ChangeNotifier {
  static LocationProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<LocationProvider>(context, listen: listen);

  String placeId;
  String formatted_address;
  LatLng _lastIdleLocation;

  LatLng get lastIdleLocation => _lastIdleLocation;

  void setLastIdleLocation(LatLng lastIdleLocation, {String placeID, String formatted_address}) {
    if (_lastIdleLocation != lastIdleLocation) {
      _lastIdleLocation = lastIdleLocation;
      this.placeId = placeId;
      this.formatted_address = formatted_address;
      notifyListeners();
    }
  }
}
