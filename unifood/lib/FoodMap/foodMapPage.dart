import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'AppConstants.dart';
import 'GroceryMapMarker.dart';
import 'ReviewsPage.dart';
import 'package:unifood/DemoLocalizations.dart';

class FoodMapPage extends StatefulWidget
{
  const FoodMapPage({super.key});
  @override
  State<StatefulWidget> createState() => _FoodMapPageState();
}

class _FoodMapPageState extends State<FoodMapPage> with TickerProviderStateMixin
{
  final pageController = PageController();
  // variables needed for map cards
  int selectedIndex = 0;
  var currentCardLocation = AppConstants.myLocation;
  var groceryStores = List.from(mapMarkers);
  final TextEditingController _searchController = TextEditingController();

  // default user location prior to geocoding
  LatLng userLocation = const LatLng(43.945155, -78.896805);

  // options for radius in km
  final List<double> _pickerOptions = [2.5, 5.0, 10.0, 15.0, 20.0];
  // default radius in km
  double _selectedOption = 10.0;

  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _getCurrentLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DemoLocalizations.of(context).map),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context2) {
                  return AlertDialog(
                    title: Text(DemoLocalizations.of(context).howTo),
                    content: Text(DemoLocalizations.of(context).description),
                    actions: <Widget>[
                      TextButton(
                        child: Text(DemoLocalizations.of(context).ok),
                        onPressed: () {
                          Navigator.of(context2).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.green, Color.fromARGB(120, 9, 97, 25)],
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft
              )
          ),
        ),
      ),
      body: Stack(
        children: [
          // MapBox map
          FlutterMap(
                mapController: mapController,
                options: const MapOptions(
                  minZoom: 5,
                  maxZoom: 18,
                  initialZoom: 13,
                  initialCenter: AppConstants.myLocation,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    "https://api.mapbox.com/styles/v1/schen271/clont8dlb004k01nw2f8t98tb/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic2NoZW4yNzEiLCJhIjoiY2xvaXA0bmszMDRiNDJqcW94OGZsdG03YSJ9.-82qpBr3j5IqEIlekLwFNg",
                    additionalOptions: const {
                      'mapStyleId': AppConstants.mapBoxStyleId,
                      'accessToken': AppConstants.mapBoxAccessToken,
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      // adds markers onto the map
                      for (int i = 0; i < groceryStores.length; i++)
                        Marker(
                          height: 40,
                          width: 40,
                          point: groceryStores[i].location ?? AppConstants.myLocation,
                          child: GestureDetector(
                              // moves user view to see map location
                              onTap: () {
                                pageController.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                                selectedIndex = i;
                                currentCardLocation = groceryStores[i].location ??
                                    AppConstants.myLocation;
                                _animatedMapMove(currentCardLocation, 11.5);
                                setState(() {});
                              },
                              // Highlights which store currently located at
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 500),
                                scale: selectedIndex == i ? 1 : 0.7,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: selectedIndex == i ? 1 : 0.5,
                                  child: const Icon(
                                      Icons.local_grocery_store,
                                      color: Color.fromARGB(255, 48, 103, 53),
                                  ),
                                ),
                              ),
                            ),
                        ),
                      // Marker for user location using geolocation
                      Marker(
                        height: 40,
                        width: 40,
                        point: userLocation,
                        alignment: Alignment.topCenter,
                        child: const Icon(
                          Icons.person_pin_circle,
                          color: Color.fromARGB(255, 232, 0, 0),
                          size: 40,
                        ),
                      )
                    ],
                  ),
                ],
              ),
          // Grocery Store information cards
          Positioned(
            left: 0,
            right: 0,
            bottom: 2,
            height: MediaQuery.of(context).size.height * 0.3,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (value) {
                selectedIndex = value;
                currentCardLocation =
                    groceryStores[value].location ?? AppConstants.myLocation;
                _animatedMapMove(currentCardLocation, 11.5);
                setState(() {});
              },
              itemCount: groceryStores.length,
              itemBuilder: (_, index) {
                final item = groceryStores[index];
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: const Color.fromARGB(255, 34, 56, 38),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: FutureBuilder<double>(
                                  future: _getAverageRating(item.title, item.address),
                                  builder: (context, snapshot) {
                                    // Shows the rating based on the average rating from firebase
                                    // Will show text "No Reviews" if no ratings are on the store yet
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('${DemoLocalizations.of(context).error}: ${snapshot.error}');
                                    } else {
                                      if (snapshot.data == null || snapshot.data!.round() == 0) {
                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 1,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 30, left: 16),
                                              child: Text(
                                                DemoLocalizations.of(context).noReviews,
                                                style: const TextStyle(color: Colors.orange, fontSize: 20),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: snapshot.data!.round(),
                                          itemBuilder: (BuildContext context, int index) {
                                            return const Icon(
                                              Icons.attach_money,
                                              color: Colors.orange,
                                            );
                                          },
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                              // Adding store title and address to card
                              Expanded(
                                flex: 2,
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title ?? '',
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        item.address ?? '',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Adding images to card containing company logo or default image if no logo available
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                      groceryStores[index].image!
                                  ),
                                ),
                              ),
                              // Reviews button that shows all the reviews for that specific store
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ReviewsPage(
                                      title: groceryStores[index].title,
                                      address: groceryStores[index].address,
                                    )),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 12.0,
                                    textStyle: const TextStyle(color: Colors.white)),
                                child: Text(DemoLocalizations.of(context).reviews),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Search bar for finding store locations in the map
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: DemoLocalizations.of(context).mapSearch,
                    ),
                    onSubmitted: (query) {
                      _searchGroceryStores(query);
                    },
                  ),
                ),
                // Radius picker in km to adjust locations seen on map
                PopupMenuButton<double>(
                  onSelected: (value) {
                    setState(() {
                      _selectedOption = value;
                      _searchGroceryStores(_searchController.text);
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return _pickerOptions.map((double option) {
                      return PopupMenuItem<double>(
                        value: option,
                        child: Text('$option km'),
                      );
                    }).toList();
                  },
                ),
                // Can either press search icon to search stores or press Enter
                IconButton(
                  onPressed: () {
                    _searchGroceryStores(_searchController.text);
                  },
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Uses http and geocoding to find searched locations
  Future<void> _searchGroceryStores(String query) async {
    final url = Uri.parse('https://geocode.maps.co/search?q=$query');
    final response = await http.get(url);
    List<MapMarker> stores = [];

    // Response if get information back from the API
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.length != 0){
        for (int i = 0; i < data.length; i++) {
          var storeLat = double.parse(data[i]['lat']);
          var storeLong = double.parse(data[i]['lon']);
          var storeCoordinates = LatLng(
            storeLat,
            storeLong,
          );
          // Determines whether location is within chosen radius of user
          if (isWithinUserRadius(userLocation.latitude, userLocation.longitude, storeLat, storeLong, _selectedOption) == true) {
            List<String> parts = data[i]['display_name'].split(',');
            String beforeComma = parts[0].trim();
            String afterComma = parts.sublist(1).join(',').trim();

            // Finds the corresponding image from mapMarkers class
            String? storeImage;
            for (var marker in mapMarkers) {
              if (marker.title!.split(' ')[0] == beforeComma.split(' ')[0]) {
                storeImage = marker.image;
                break;
              }
            }

            // Creating map markers for searched locations; Will use default image if no logo available yet
            stores.add(MapMarker(image: storeImage ?? 'https://media-cdn.tripadvisor.com/media/photo-s/1a/ba/e9/f6/the-shed.jpg', title: beforeComma, address: afterComma, location: storeCoordinates, rating: 3));
          }
        }
      }
      // Shows the default stores if no stores can be found in the location
      if (stores.isEmpty){
        stores = List.from(mapMarkers);
      }
      setState(() {
        groceryStores = stores;
      });
    }
  }
  // Animation function for moving map to specific latitude and longitude
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These split up the transition from one location to another.
    // Splits the transition between the current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.camera.zoom, end: destZoom);

    // Creates an animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    // The animation determines what path the animation will take
    Animation<double> animation =
    CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
  // Gets user's current location using geolocation
  // Asks for permissions
  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Checks if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    // For cases where permission was denied
    // Will ask for permission again
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    // If permissions are denied forever will not let user see current location
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    // If permissions are granted then will show user current location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (mounted) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        _animatedMapMove(userLocation, 14.0);
      });
    }
  }
  // Function for calculating the average rating of each store
  // Gets the ratings from each document of store in firebase and calculates average
  Future<double> _getAverageRating(String title, String address) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(title)
        .doc(address)
        .collection('reviews')
        .get();
    // If there are no reviews will return 0 as average rating
    // Will be converted to No Reviews text in card
    if (querySnapshot.docs.isEmpty) {
      return 0.0;
    }
    // Calculates the average rating if store has reviews
    double totalRating = 0.0;
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('rating')) {
        totalRating += data['rating'];
      }
    }
    return totalRating / querySnapshot.docs.length;
  }
}