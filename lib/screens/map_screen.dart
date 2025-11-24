import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _pickedLocation = LatLng(19.0760, 72.8777); // Default: Mumbai
  final _addressController = TextEditingController();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _addressController.text = "Tap on map to select location";
  }

  void _onMapTap(LatLng position) async {
    setState(() {
      _pickedLocation = position;
      _addressController.text = "Fetching address...";
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _addressController.text =
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}";
        });
      }
    } catch (e) {
      setState(() {
        _addressController.text = "Could not fetch address details";
      });
    }
  }

  void _confirmLocation() {
    Navigator.pop(context, {
      'lat': _pickedLocation.latitude,
      'lng': _pickedLocation.longitude,
      'address': _addressController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Location")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pickedLocation,
                zoom: 14,
              ),
              onTap: _onMapTap,
              markers: {
                Marker(markerId: MarkerId('m1'), position: _pickedLocation),
              },
              onMapCreated: (controller) => _mapController = controller,
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _confirmLocation,
                  child: Text("Confirm Location"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
