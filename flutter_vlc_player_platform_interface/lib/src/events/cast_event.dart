import '../enums/cast_event_type.dart';
import 'package:meta/meta.dart';

class VlcCastEvent {
  /// Creates an instance of [VlcCastEvent].
  ///
  /// The [eventType] argument is required.
  ///
  /// Depending on the [eventType], the [castDeviceId], [castDeviceName]
  VlcCastEvent({
    @required this.eventType,
    this.castDeviceId,
    this.castDeviceName,
  });

  /// The type of the event.
  final VlcCastEventType eventType;

  /// The identifier of cast device
  final String castDeviceId;

  /// The name of cast device
  final String castDeviceName;
}
