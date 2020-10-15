part of vlc_player_flutter;

class VlcPlayer extends StatefulWidget {
  final VlcPlayerController controller;
  final double aspectRatio;
  final Widget placeholder;

  VlcPlayer({
    Key key,

    /// The [VlcPlayerController] responsible for the video being rendered in
    /// this widget.
    @required this.controller,

    /// The aspect ratio used to display the video.
    /// This MUST be provided, however it could simply be (parentWidth / parentHeight) - where parentWidth and
    /// parentHeight are the width and height of the parent perhaps as defined by a LayoutBuilder.
    @required this.aspectRatio,

    /// Before the platform view has initialized, this placeholder will be rendered instead of the video player.
    /// This can simply be a [CircularProgressIndicator] (see the example.)
    this.placeholder,
  }) : super(key: key);

  @override
  _VlcPlayerState createState() => _VlcPlayerState();
}

class _VlcPlayerState extends State<VlcPlayer> {
  @override
  Widget build(BuildContext context) {
    return _vlcPlayerPlatform.buildView(onPlatformViewCreated);
  }

  Future<void> onPlatformViewCreated(int viewId) async {
    // we should initialize controller after view becomes ready
    if (viewId != null) widget.controller._setViewId(viewId);
  }
}
