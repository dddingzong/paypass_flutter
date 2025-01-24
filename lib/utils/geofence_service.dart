import 'package:geofence_foreground_service/constants/geofence_event_type.dart';
import 'package:geofence_foreground_service/exports.dart';
import 'package:geofence_foreground_service/geofence_foreground_service.dart';
import 'package:geofence_foreground_service/models/zone.dart';
import 'package:pay_pass/variables/globals.dart';
import 'package:latlng/latlng.dart';

@pragma('vm:entry-point')
void callbackDispatcher() async {
  GeofenceForegroundService().handleTrigger(
    backgroundTriggerHandler: (zoneID, triggerType) {
      if (triggerType == GeofenceEventType.enter) {
        print('Entered geofence: $zoneID');
      } else if (triggerType == GeofenceEventType.exit) {
        print('Exited geofence: $zoneID');
      } else if (triggerType == GeofenceEventType.dwell) {
        print('Dwelled geofence: $zoneID');
      } else {
        print('Unknown type in geofence');
      }
      return Future.value(true);
    },
  );
}

void setupGeofenceService() async {
  await GeofenceForegroundService().startGeofencingService(
    contentTitle: 'Geofencing Active',
    contentText: 'Monitoring geofence zones.',
    serviceId: 1000,
    notificationChannelId: 'com.app.geofencing_notifications_channel',
    callbackDispatcher: callbackDispatcher,
  );

  for (var station in stations) {
    final zone = Zone(
      id: station['stationNumber'].toString(),
      radius: 100, //100m
      coordinates: [
        LatLng(Angle.degree(station['latitude']),
            Angle.degree(station['longitude']))
      ],
    );

    await GeofenceForegroundService().addGeofenceZone(zone: zone);
  }
}
