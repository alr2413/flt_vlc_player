import 'package:flutter/material.dart';

import 'flutter_vlc_player.dart';
import 'vlc_progress_colors.dart';
import 'vlc_scrubber.dart';

/// Displays the play/buffering status of the video controlled by [controller].
///
/// If [allowScrubbing] is true, this widget will detect taps and drags and
/// seek the video accordingly.
///
/// [padding] allows to specify some extra padding around the progress indicator
/// that will also detect the gestures.
class VlcProgressIndicator extends StatefulWidget {
  /// Construct an instance that displays the play/buffering status of the video
  /// controlled by [controller].
  ///
  /// Defaults will be used for everything except [controller] if they're not
  /// provided. [allowScrubbing] defaults to false, and [padding] will default
  /// to `top: 5.0`.
  VlcProgressIndicator(
    this.controller, {
    VlcProgressColors colors,
    this.allowScrubbing,
    this.padding = const EdgeInsets.only(top: 5.0),
  }) : colors = colors ?? VlcProgressColors();

  /// The [VlcPlayerController] that actually associates a video with this
  /// widget.
  final VlcPlayerController controller;

  /// The default colors used throughout the indicator.
  ///
  /// See [VideoProgressColors] for default values.
  final VlcProgressColors colors;

  /// When true, the widget will detect touch input and try to seek the video
  /// accordingly. The widget ignores such input when false.
  ///
  /// Defaults to false.
  final bool allowScrubbing;

  /// This allows for visual padding around the progress indicator that can
  /// still detect gestures via [allowScrubbing].
  ///
  /// Defaults to `top: 5.0`.
  final EdgeInsets padding;

  @override
  _VlcProgressIndicatorState createState() => _VlcProgressIndicatorState();
}

class _VlcProgressIndicatorState extends State<VlcProgressIndicator> {
  _VlcProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  VoidCallback listener;

  VlcPlayerController get controller => widget.controller;

  VlcProgressColors get colors => widget.colors;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void deactivate() {
    controller.removeListener(listener);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.initialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      // int maxBuffering = 0;
      // for (DurationRange range in controller.value.buffered) {
      //   final int end = range.end.inMilliseconds;
      //   if (end > maxBuffering) {
      //     maxBuffering = end;
      //   }
      // }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          // LinearProgressIndicator(
          //   value: maxBuffering / duration,
          //   valueColor: AlwaysStoppedAnimation<Color>(colors.bufferedColor),
          //   backgroundColor: colors.backgroundColor,
          // ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        value: null,
        valueColor: AlwaysStoppedAnimation<Color>(colors.playedColor),
        backgroundColor: colors.backgroundColor,
      );
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    if (widget.allowScrubbing) {
      return VlcScrubber(
        child: paddedProgressIndicator,
        controller: controller,
      );
    } else {
      return paddedProgressIndicator;
    }
  }
}
