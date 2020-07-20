/// Computes travel times from `O` to `[D1,D2,D3]` in batch.
/// Requires Google Maps API Key, Google Distance Matrix API, and is subject
/// to the limitations of the Matrix API (such as maximum destinations per
/// request)
import 'package:batching_future/batching_future.dart';
import 'package:google_maps_webservice/distance.dart';
import 'package:meta/meta.dart';

/// Computes travel times from [myLocation] to [destinations] in batch using
/// Google Distance Matrix API and [apiKey].
///
/// Requires Google Maps API Key, Google Distance Matrix API, and is subject
/// to the limitations of the Matrix API (such as maximum destinations per
/// request)
Future<Map<Location, Duration>> batchTravelTimes(
        {@required Location myLocation,
        @required List<Location> destinations,
        @required String apiKey}) async =>
    (await GoogleDistanceMatrix(apiKey: apiKey)
            .distanceWithLocation([myLocation], destinations))
        .results
        .expand((row) => row.elements)
        .toList()
        .asMap()
        .map((i, location) => MapEntry(
            destinations[i], Duration(seconds: location.duration.value)));

typedef MyLocationProvider = Future<Location> Function();

/// Returns [BatchingFutureProvider] which automatically batches individual
/// ([myLocationProvider()], [destination]) requests into a single batch request
/// over 200 milliseconds or max batch size 200.
///
/// See `example/` folder for usage example.
BatchingFutureProvider<Location, Duration> batchingFutureTravelTime(
        {@required MyLocationProvider myLocationProvider,
        @required String apiKey}) =>
    createBatcher(
      (destinations) async => (await batchTravelTimes(
              apiKey: apiKey,
              myLocation: await myLocationProvider(),
              destinations: destinations))
          .values
          .toList(),
      maxBatchSize: 20,
      maxWaitDuration: Duration(milliseconds: 200),
    );
