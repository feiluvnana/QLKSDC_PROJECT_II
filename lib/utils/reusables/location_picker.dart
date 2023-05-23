import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'dart:html' as html;

class LocationPicker extends StatelessWidget {
  final void Function(String?)? onSaved, onChanged;
  final String? initialValue;
  const LocationPicker(
      {super.key, this.onSaved, this.onChanged, this.initialValue});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: onSaved,
      onChanged: onChanged,
      initialValue: initialValue,
      decoration: InputDecoration(
          label: const Text("Thông tin vị trí"),
          border: const OutlineInputBorder(),
          suffix: FittedBox(
              child: InkWell(
                  onTap: () async {
                    await showDialog(
                        context: context,
                        builder: (context) => SizedBox.expand(
                            child: Center(
                                child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    child: const MyGoogleMaps()))),
                        barrierDismissible: false);
                  },
                  child: const FaIcon(FontAwesomeIcons.map)))),
    );
  }
}

class MyGoogleMaps extends StatefulWidget {
  const MyGoogleMaps({super.key});

  @override
  State<MyGoogleMaps> createState() => _MyGoogleMapsState();
}

class _MyGoogleMapsState extends State<MyGoogleMaps> {
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  final MarkerController _markerController = MarkerController();
  String _searchLocation = "Tìm kiếm vị trí";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(
                    "(${(await InfoFetcher.calculate(_markerController)).values.first.toStringAsPrecision(3)}) ${(await InfoFetcher.calculate(_markerController)).keys.first}");
              },
              child: const Text("Xác nhận địa chỉ"),
            ),
          ),
          InkWell(
            onTap: () async {
              var place = await PlacesAutocomplete.show(
                  context: context,
                  apiKey: "AIzaSyCzOQKlQHhrVmZ7FTtCiK-hElGk1E3ysLk",
                  mode: Mode.overlay,
                  strictbounds: false,
                  components: [Component(Component.country, "vn")],
                  radius: 50000,
                  location:
                      Location(lat: 21.01763228200625, lng: 105.80723002709553),
                  proxyBaseUrl:
                      "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/");

              if (place != null) {
                setState(() {
                  _searchLocation = place.description.toString();
                });

                final plist = GoogleMapsPlaces(
                  apiKey: "AIzaSyCzOQKlQHhrVmZ7FTtCiK-hElGk1E3ysLk",
                  baseUrl:
                      "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/",
                  apiHeaders: await const GoogleApiHeaders().getHeaders(),
                  //from google_api_headers package
                );
                String placeid = place.placeId ?? "0";
                final detail = await plist.getDetailsByPlaceId(placeid);
                final geometry = detail.result.geometry!;
                final lat = geometry.location.lat;
                final lang = geometry.location.lng;
                var newlatlang = LatLng(lat, lang);

                //move map camera to selected place with animation
                (await _mapController.future).animateCamera(
                    CameraUpdate.newCameraPosition(
                        CameraPosition(target: newlatlang, zoom: 17)));
                _markerController.addMarker(newlatlang);
                setState(() {});
              }
            },
            child: Card(
              child: Container(
                padding: EdgeInsets.zero,
                child: ListTile(
                  title: Text(
                    _searchLocation,
                    style: const TextStyle(fontSize: 18),
                  ),
                  trailing: const Icon(Icons.search),
                  dense: true,
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              markers: Set<Marker>.of(_markerController.markersList.values),
              mapType: MapType.normal,
              initialCameraPosition: const CameraPosition(
                  target: LatLng(21.01763228200625, 105.80723002709553),
                  zoom: 17,
                  tilt: 60,
                  bearing: 60),
              onMapCreated: (controller) => _mapController.complete(controller),
              onTap: (latLng) async {
                print("tapped");
                GoogleMapController controller = await _mapController.future;
                controller.getZoomLevel().then((value) => print(value));
                print(latLng.toJson());
                controller.animateCamera(CameraUpdate.newLatLng(latLng));
              },
              onLongPress: (latLng) {
                print("longPressed");
                _markerController.addMarker(latLng);
                setState(() {});
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class MarkerController {
  Map<MarkerId, Marker> markersList = {
    const MarkerId("0"): Marker(
        markerId: const MarkerId("0"),
        infoWindow: const InfoWindow(title: "Dứa con"),
        position: const LatLng(21.01763228200625, 105.80723002709553),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose)),
  };

  void addMarker(LatLng latLng) {
    Marker marker = Marker(
        markerId: const MarkerId("1"),
        infoWindow: const InfoWindow(title: "Marker 1"),
        position: latLng);
    markersList.remove("1");
    markersList.addAll({const MarkerId("1"): marker});
  }
}

class InfoFetcher {
  static Future<Map<String, double>> calculate(
      MarkerController controller) async {
    double distance = 0;
    String address = "";
    await html.HttpRequest.getString(
            "https://cors-anywhere.herokuapp.com/https://maps.googleapis.com/maps/api/directions/json?origin=${controller.markersList[const MarkerId("0")]!.position.latitude}%2C${controller.markersList[const MarkerId("0")]!.position.longitude}&destination=${controller.markersList[const MarkerId("1")]!.position.latitude}%2C${controller.markersList[const MarkerId("1")]!.position.longitude}&mode=driving&avoidHighways=false&avoidFerries=true&avoidTolls=false&key=AIzaSyCzOQKlQHhrVmZ7FTtCiK-hElGk1E3ysLk")
        .then((value) {
      distance = jsonDecode(value)["routes"][0]["legs"][0]["distance"]["value"];
      address = jsonDecode(value)["routes"][0]["legs"][0]["end_address"];
    });
    distance = distance / 1000;
    return {address: distance};
  }
}
