import 'package:latlong2/latlong.dart';
import 'dart:math';

class MapMarker {
  final String? image;
  final String? title;
  final String? address;
  final LatLng? location;
  final int? rating;

  MapMarker({
    required this.image,
    required this.title,
    required this.address,
    required this.location,
    required this.rating,
  });
}

// Default map locations
var mapMarkers = [
  MapMarker(
    image: 'https://binpak.com/wp-content/uploads/2022/10/shoppers-drug-mart-logo.jpg',
    title: 'Shopper''s Drug Mart',
    address: '2045 Simcoe St N Rr #1, Oshawa, ON L1H 7K4, Canada',
    location: const LatLng(43.946911, -78.893997),
    rating: 2,
  ),
  MapMarker(
    image: 'https://www.exchangesolutions.com/wp-content/uploads/2019/12/logo_Sobeys_350x220-1.png',
    title: 'Sobey''s Oshawa',
    address: '1377 Wilson Rd N, Oshawa, ON L1K 2Z5, Canada',
    location: const LatLng(43.938785, -78.8585948),
    rating: 4,
  ),
  MapMarker(
    image: 'https://ww2.freelogovectors.net/wp-content/uploads/2018/08/metro-logo.png?lossy=1&resize=395%2C87&ssl=1',
    title: 'Metro Oshawa',
    address: '1265 Ritson Rd N, Oshawa, ON L1G 3V2, Canada',
    location: const LatLng(43.933037, -78.8670018),
    rating: 5,
  ),
  MapMarker(
    image: 'https://upload.wikimedia.org/wikipedia/commons/6/6c/FreshCo_logo.png',
    title: 'FreshCo Simcoe and Winchester',
    address: '2650 Simcoe St N, Oshawa, ON L1L 0R1, Canada',
    location: const LatLng(43.965199, -78.903770),
    rating: 3,
  ),
  MapMarker(
    image: 'https://d1yjjnpx0p53s8.cloudfront.net/styles/logo-thumbnail/s3/082013/logo_costco.png?itok=UdEYKvQA',
    title: 'Costco Oshawa',
    address: '100 Windfields Farm Dr E, Oshawa, ON L1L 0R8, Canada',
    location: const LatLng(43.965460, -78.897940),
    rating: 4,
  )
];

// Convert values into radians
double radians(double degrees) {
  return degrees * (pi / 180.0);
}

// Calculation using Haversine formula to determine whether
// location is within the user's radius
bool isWithinUserRadius(double userLat, double userLon, double pointLat, double pointLon, double radius) {
  // Radius of the Earth in kilometers
  const earthRadius = 6371.0;

  // Convert latitude and longitude from degrees to radians
  var userLatRad = radians(userLat);
  var userLonRad = radians(userLon);
  var pointLatRad = radians(pointLat);
  var pointLonRad = radians(pointLon);

  // Calculate differences
  var dlat = pointLatRad - userLatRad;
  var dlon = pointLonRad - userLonRad;

  // Haversine formula
  var a = pow(sin(dlat / 2), 2) +
      cos(userLatRad) * cos(pointLatRad) * pow(sin(dlon / 2), 2);
  var c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Calculate distance using Earth's radius
  var distance = earthRadius * c;

  // Check if the distance is within the specified radius
  return distance <= radius;
}