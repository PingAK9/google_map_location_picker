import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_map_location_picker/generated/i18n.dart';
import 'package:google_map_location_picker/src/map.dart';
import 'package:google_map_location_picker/src/providers/location_provider.dart';
import 'package:google_map_location_picker/src/rich_suggestion.dart';
import 'package:google_map_location_picker/src/search_input.dart';
import 'package:google_map_location_picker/src/utils/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'model/auto_comp_iete_item.dart';
import 'model/location_result.dart';
import 'model/nearby_place.dart';
import 'utils/location_utils.dart';

class LocationPicker extends StatefulWidget {
  LocationPicker(
    this.apiKey, {
    Key key,
    this.initialCenter,
    this.requiredGPS,
    this.myLocationButtonEnabled,
    this.layersButtonEnabled,
    this.automaticallyAnimateToCurrentLocation,
    this.mapStylePath,
    this.appBarColor,
    this.searchBarBoxDecoration,
    this.hintText,
    this.resultCardConfirmWidget,
    this.resultCardAlignment,
    this.resultCardDecoration,
    this.resultCardPadding,
  });

  final String apiKey;

  final LatLng initialCenter;

  final bool requiredGPS;
  final bool myLocationButtonEnabled;
  final bool layersButtonEnabled;
  final bool automaticallyAnimateToCurrentLocation;

  final String mapStylePath;

  final Color appBarColor;
  final BoxDecoration searchBarBoxDecoration;
  final String hintText;
  final Widget resultCardConfirmWidget;
  final Alignment resultCardAlignment;
  final Decoration resultCardDecoration;
  final EdgeInsets resultCardPadding;

  @override
  LocationPickerState createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  /// Result returned after user completes selection
  LocationResult locationResult;

  /// Overlay to display autocomplete suggestions
  OverlayEntry overlayEntry;

  List<NearbyPlace> nearbyPlaces = List();

  /// Session token required for autocomplete API call
  String sessionToken = Uuid().generateV4();

  var mapKey = GlobalKey<MapPickerState>();

  var appBarKey = GlobalKey();

  var searchInputKey = GlobalKey<SearchInputState>();

  bool hasSearchTerm = false;

  /// Hides the autocomplete overlay
  void clearOverlay() {
    if (overlayEntry != null) {
      overlayEntry.remove();
      overlayEntry = null;
    }
  }

  /// Begins the search process by displaying a "wait" overlay then
  /// proceeds to fetch the autocomplete list. The bottom "dialog"
  /// is hidden so as to give more room and better experience for the
  /// autocomplete list overlay.
  void searchPlace(String place) {
    if (context == null) return;

    clearOverlay();

    setState(() => hasSearchTerm = place.length > 0);

    if (place.length < 1) return;

    final RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;

    final RenderBox appBarBox = appBarKey.currentContext.findRenderObject();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: appBarBox.size.height,
        width: size.width,
        child: Material(
          elevation: 1,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              children: <Widget>[
                SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                SizedBox(width: 24),
                Expanded(
                  child: Text(
                    S.of(context)?.finding_place ?? 'Finding place...',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    autoCompleteSearch(place);
  }

  /// Fetches the place autocomplete list with the query [place].
  void autoCompleteSearch(String place) {
    place = place.replaceAll(" ", "+");
    var endpoint =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?" +
            "key=${widget.apiKey}&" +
            "input={$place}&sessiontoken=$sessionToken";

    if (locationResult != null) {
      endpoint += "&location=${locationResult.latLng.latitude}," +
          "${locationResult.latLng.longitude}";
    }
    LocationUtils.getAppHeaders()
        .then((headers) => http.get(endpoint, headers: headers))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> predictions = data['predictions'];

        List<RichSuggestion> suggestions = [];

        if (predictions.isEmpty) {
          AutoCompleteItem aci = AutoCompleteItem();
          aci.text = S.of(context)?.no_result_found ?? 'No result found';
          aci.offset = 0;
          aci.length = 0;

          suggestions.add(RichSuggestion(aci, () {}));
        } else {
          for (dynamic t in predictions) {
            AutoCompleteItem aci = AutoCompleteItem();

            aci.id = t['place_id'];
            aci.text = t['description'];
            aci.offset = t['matched_substrings'][0]['offset'];
            aci.length = t['matched_substrings'][0]['length'];

            suggestions.add(RichSuggestion(aci, () {
              decodeAndSelectPlace(aci);
            }));
          }
        }

        displayAutoCompleteSuggestions(suggestions);
      }
    }).catchError((error) {
      print(error);
    });
  }

  /// To navigate to the selected place from the autocomplete list to the map,
  /// the lat,lng is required. This method fetches the lat,lng of the place and
  /// proceeds to moving the map to that location.
  void decodeAndSelectPlace(AutoCompleteItem item) {
    clearOverlay();

    String endpoint =
        "https://maps.googleapis.com/maps/api/place/details/json?key=${widget.apiKey}" +
            "&placeid=${item.id}";

    LocationUtils.getAppHeaders()
        .then((headers) => http.get(endpoint, headers: headers))
        .then((response) {
      if (response.statusCode == 200) {
        Map<String, dynamic> location =
            jsonDecode(response.body)['result']['geometry']['location'];

        final LatLng latLng = LatLng(location['lat'], location['lng']);
        LocationProvider.of(_locationContext, listen: false)
            .setLastIdleLocation(latLng,
                placeID: item.id, formatted_address: item.text);
        moveToLocation(latLng);
      }
    }).catchError((error) {
      print(error);
    });
  }

  /// Display autocomplete suggestions with the overlay.
  void displayAutoCompleteSuggestions(List<RichSuggestion> suggestions) {
    final RenderBox renderBox = context.findRenderObject();
    Size size = renderBox.size;

    final RenderBox appBarBox = appBarKey.currentContext.findRenderObject();

    clearOverlay();

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        top: appBarBox.size.height,
        child: Material(
          elevation: 1,
          child: Column(
            children: suggestions,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  /// Moves the camera to the provided location and updates other UI features to
  /// match the location.
  void moveToLocation(LatLng latLng) {
    mapKey.currentState.mapController.future.then((controller) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 16,
          ),
        ),
      );
    });
  }

  void onSearchPlaceByName(String name) {
    clearOverlay();

    String endpoint =
        "https://maps.googleapis.com/maps/api/geocode/json?address=${name.replaceAll(' ', '+')}&key=${widget.apiKey}";

    LocationUtils.getAppHeaders()
        .then((headers) => http.get(endpoint, headers: headers))
        .then((response) {
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body)['results'][0];
        Map<String, dynamic> location = result['geometry']['location'];

        final LatLng latLng = LatLng(location['lat'], location['lng']);
        final String placeID = result['place_id'];
        LocationProvider.of(_locationContext, listen: false)
            .setLastIdleLocation(latLng,
                placeID: placeID, formatted_address: name);
        moveToLocation(latLng);
      }
    }).catchError((error) {
      print(error);
    });
  }

  @override
  void dispose() {
    clearOverlay();
    super.dispose();
  }

  BuildContext _locationContext;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: Builder(builder: (context) {
        _locationContext = context;
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            elevation: 0,
            backgroundColor: widget.appBarColor,
            key: appBarKey,
            title: SearchInput(
              searchPlace,
              onDone: onSearchPlaceByName,
              key: searchInputKey,
              boxDecoration: widget.searchBarBoxDecoration,
            ),
          ),
          body: MapPicker(
            widget.apiKey,
            initialCenter: widget.initialCenter,
            requiredGPS: widget.requiredGPS,
            myLocationButtonEnabled: widget.myLocationButtonEnabled,
            layersButtonEnabled: widget.layersButtonEnabled,
            automaticallyAnimateToCurrentLocation:
                widget.automaticallyAnimateToCurrentLocation,
            mapStylePath: widget.mapStylePath,
            appBarColor: widget.appBarColor,
            searchBarBoxDecoration: widget.searchBarBoxDecoration,
            hintText: widget.hintText,
            resultCardConfirmWidget: widget.resultCardConfirmWidget,
            resultCardAlignment: widget.resultCardAlignment,
            resultCardDecoration: widget.resultCardDecoration,
            resultCardPadding: widget.resultCardPadding,
            key: mapKey,
          ),
        );
      }),
    );
  }
}

/// Returns a [LatLng] object of the location that was picked.
///
/// The [apiKey] argument API key generated from Google Cloud Console.
/// You can get an API key [here](https://cloud.google.com/maps-platform/)
///
/// [initialCenter] The geographical location that the camera is pointing
/// until the current user location is know if you want to change this
/// set [automaticallyAnimateToCurrentLocation] to false.
///
///
Future<LocationResult> showLocationPicker(
  BuildContext context,
  String apiKey, {
  LatLng initialCenter = const LatLng(45.521563, -122.677433),
  bool requiredGPS = true,
  bool myLocationButtonEnabled = false,
  bool layersButtonEnabled = false,
  bool automaticallyAnimateToCurrentLocation = true,
  String mapStylePath,
  Color appBarColor = Colors.transparent,
  BoxDecoration searchBarBoxDecoration,
  String hintText,
  Widget resultCardConfirmWidget,
  AlignmentGeometry resultCardAlignment,
  EdgeInsetsGeometry resultCardPadding,
  Decoration resultCardDecoration,
}) async {
  final results = await Navigator.of(context).push(
    MaterialPageRoute<dynamic>(
      builder: (BuildContext context) {
        return LocationPicker(
          apiKey,
          initialCenter: initialCenter,
          requiredGPS: requiredGPS,
          myLocationButtonEnabled: myLocationButtonEnabled,
          layersButtonEnabled: layersButtonEnabled,
          automaticallyAnimateToCurrentLocation:
              automaticallyAnimateToCurrentLocation,
          mapStylePath: mapStylePath,
          appBarColor: appBarColor,
          hintText: hintText,
          searchBarBoxDecoration: searchBarBoxDecoration,
          resultCardConfirmWidget: resultCardConfirmWidget,
          resultCardAlignment: resultCardAlignment,
          resultCardPadding: resultCardPadding,
          resultCardDecoration: resultCardDecoration,
        );
      },
    ),
  );

  if (results != null && results.containsKey('location')) {
    return results['location'];
  } else {
    return null;
  }
}
