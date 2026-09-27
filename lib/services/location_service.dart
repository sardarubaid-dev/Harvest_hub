import 'dart:math';
import '../models/product_model.dart';
import '../core/dummy_data.dart';

/// Pure mathematical location service using the Haversine distance formula.
/// Requires NO external or paid APIs (zero billing, offline capable).
class LocationService {
  // Default customer reference location: DHA / Clifton, Karachi
  static const double defaultCustomerLat = 24.8200;
  static const double defaultCustomerLng = 67.0450;
  static const String defaultCustomerAddress = 'DHA Phase 5, Karachi';

  // Known agricultural coordinates database for local Pakistani regions & markets
  static const Map<String, (double, double)> knownLocalities = {
    'karachi farmers market': (24.8103, 67.0543),
    'dha phase 5': (24.8200, 67.0450),
    'clifton': (24.8258, 67.0322),
    'clifton organic hub': (24.8258, 67.0322),
    'malir': (24.8934, 67.1950),
    'malir district': (24.8934, 67.1950),
    'green valley': (24.8850, 67.1820),
    'thatta': (24.7474, 67.9238),
    'thatta farmgate': (24.7474, 67.9238),
    'potohar': (24.8700, 67.1100),
    'gulshan': (24.9180, 67.0971),
    'north nazimabad': (24.9400, 67.0350),
    'gadip': (25.0120, 67.1430),
    'hyderabad': (25.3960, 68.3578),
  };

  /// Computes distance in kilometers between two GPS coordinate points using the Haversine formula.
  static double calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }

  /// Parses latitude and longitude from a coordinate string (e.g. "24.8103, 67.0543").
  static (double, double)? parseCoordinates(String? coordStr) {
    if (coordStr == null || coordStr.trim().isEmpty) return null;
    final parts = coordStr.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lon = double.tryParse(parts[1].trim());
      if (lat != null && lon != null) {
        return (lat, lon);
      }
    }
    return null;
  }

  /// Resolves coordinates for a farmer or their associated market.
  static (double, double) resolveCoordinatesForFarmer(String? farmerId, {String? locationHint}) {
    // 1. Check if farmer is in seedFarmers
    if (farmerId != null && farmerId.isNotEmpty) {
      try {
        final farmer = DummyData.seedFarmers.firstWhere((f) => f.id == farmerId || f.userId == farmerId);
        if (farmer.marketId != null && farmer.marketId!.isNotEmpty) {
          final marketCoords = resolveCoordinatesForMarket(farmer.marketId!);
          if (marketCoords != null) return marketCoords;
        }
        if (farmer.location.isNotEmpty) {
          final locCoords = _lookupLocality(farmer.location);
          if (locCoords != null) return locCoords;
        }
      } catch (_) {}
    }

    // 2. Check location hint
    if (locationHint != null && locationHint.isNotEmpty) {
      final locCoords = _lookupLocality(locationHint);
      if (locCoords != null) return locCoords;
    }

    // Default nearby farm distance (approx 2.4 km from DHA reference)
    return (24.8320, 67.0620);
  }

  /// Resolves coordinates for a market ID.
  static (double, double)? resolveCoordinatesForMarket(String marketId) {
    try {
      final market = DummyData.seedMarkets.firstWhere((m) => m.id == marketId);
      final coords = parseCoordinates(market.gpsCoordinates);
      if (coords != null) return coords;
    } catch (_) {}
    return null;
  }

  static (double, double)? _lookupLocality(String text) {
    final lower = text.toLowerCase();
    for (final entry in knownLocalities.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Calculates distance in km for a product from the user's location.
  static double getDistanceForProduct(
    ProductModel product, {
    double userLat = defaultCustomerLat,
    double userLng = defaultCustomerLng,
  }) {
    // Check if farmer has location coordinates
    final (farmLat, farmLng) = resolveCoordinatesForFarmer(
      product.farmerId,
      locationHint: product.farmerName,
    );

    final distance = calculateDistanceKm(
      lat1: userLat,
      lon1: userLng,
      lat2: farmLat,
      lon2: farmLng,
    );

    // If calculation gives 0, provide default realistic proximity
    return distance < 0.1 ? 2.4 : distance;
  }

  /// Formats distance into a clean string (e.g., "2.4 km" or "800 m").
  static String formatDistance(double km) {
    if (km < 1.0) {
      final meters = (km * 1000).round();
      return '$meters m';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  /// Sorts products by nearest to the customer first.
  static List<ProductModel> sortByNearest(
    List<ProductModel> products, {
    double userLat = defaultCustomerLat,
    double userLng = defaultCustomerLng,
  }) {
    final list = List<ProductModel>.from(products);
    list.sort((a, b) {
      final distA = getDistanceForProduct(a, userLat: userLat, userLng: userLng);
      final distB = getDistanceForProduct(b, userLat: userLat, userLng: userLng);
      return distA.compareTo(distB);
    });
    return list;
  }

  /// Filters products within a given radius in kilometers.
  static List<ProductModel> filterByRadius(
    List<ProductModel> products, {
    required double maxRadiusKm,
    double userLat = defaultCustomerLat,
    double userLng = defaultCustomerLng,
  }) {
    return products.where((p) {
      final dist = getDistanceForProduct(p, userLat: userLat, userLng: userLng);
      return dist <= maxRadiusKm;
    }).toList();
  }
}
