import 'dart:ui';

import 'package:meta/meta.dart';

import 'enums/vlc_event_type.dart';

class VlcEvent {
  /// Creates an instance of [VlcEvent].
  ///
  /// The [eventType] argument is required.
  ///
  /// Depending on the [eventType], the [duration], [size]
  /// arguments can be null.
  VlcEvent({
    @required this.eventType,
    this.duration,
    this.size,
  });

  /// The type of the event.
  final VlcEventType eventType;

  /// Duration of the video.
  ///
  /// Only used if [eventType] is [VlcEventType.initialized].
  final Duration duration;

  /// Size of the video.
  ///
  /// Only used if [eventType] is [VlcEventType.initialized].
  final Size size;
}
