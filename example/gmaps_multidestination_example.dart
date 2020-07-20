/// Example usage:
/// ```sh
/// pub run example/gmaps_multidestination_example.dart \
///   --api-key AIzaSyCEbW8Q_FwFdh8RqHfb0lJmC7jHTkdnmK4 \
///   --origin '37 -122'                                \
///   --destination '37.848659 -122.279075'             \
///   --destination '38.605024 -121.424152'
/// ```
///
/// Prints:
/// ```
/// {37.848659,-122.279075: 1:19:01.000000, 38.605024,-121.424152: 2:28:11.000000}
/// [1:19:01.000000, 2:28:11.000000]
/// ```
import 'package:args/args.dart';
import 'package:gmaps_multidestination/gmaps_multidestination.dart';

const apiKey = 'api-key';
const origin = 'origin';
const destination = 'destination';

void main(List<String> arguments) async {
  final parser = (ArgParser()
        ..addOption(apiKey)
        ..addOption(origin)
        ..addMultiOption(destination))
      .parse(arguments);
  final key = parser[apiKey] as String;
  final location = (parser[origin] as String).loc;
  final batcher = batchingFutureTravelTime(
      myLocationProvider: () async => location, apiKey: key);
  final destinations =
      List<String>.from(parser[destination]).map((s) => s.loc).toList();
  print(await batchTravelTimes(
      myLocation: location, destinations: destinations, apiKey: key));
  print(await Future.wait(destinations.map(batcher.submit)));
}

extension on String {
  Location get loc {
    final latLng = trim().split(' ').map(double.parse);
    return Location(latLng.first, latLng.last);
  }
}
