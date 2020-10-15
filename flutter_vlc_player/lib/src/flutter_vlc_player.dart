part of vlc_player_flutter;

class VlcPlayer extends StatefulWidget {
  final VlcPlayerController controller;
  final double aspectRatio;
  final bool autoInitialize;
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

    /// Initialize vlc player when the platform is ready automatically
    this.autoInitialize = true,

    /// Before the platform view has initialized, this placeholder will be rendered instead of the video player.
    /// This can simply be a [CircularProgressIndicator] (see the example.)
    this.placeholder,
  }) : super(key: key);

  @override
  _VlcPlayerState createState() => _VlcPlayerState();
}

class _VlcPlayerState extends State<VlcPlayer> {
  _VlcPlayerState() {
    _listener = () {
      final bool isInitialized = widget.controller.value.initialized;
      if (isInitialized != _initialized) {
        setState(() {
          _initialized = isInitialized;
        });
      }
    };
  }

  VoidCallback _listener;
  bool _initialized;

  @override
  void initState() {
    super.initState();
    _initialized = widget.controller.value.initialized;
    // Need to listen for initialization events since the actual texture ID
    // becomes available after asynchronous initialization finishes.
    widget.controller.addListener(_listener);
  }

  @override
  void didUpdateWidget(VlcPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_listener);
      _initialized = widget.controller.value.initialized;
      widget.controller.addListener(_listener);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: <Widget>[
          Offstage(
            offstage: _initialized,
            child: widget.placeholder ?? Container(),
          ),
          Offstage(
            offstage: !_initialized,
            child: _vlcPlayerPlatform.buildView(onPlatformViewCreated),
          ),
        ],
      ),
    );
  }

  Future<void> onPlatformViewCreated(int viewId) async {
    // we should initialize controller after view becomes ready
    if (viewId == null) return;
    widget.controller._setViewId(viewId);
    if (widget.autoInitialize) {
      await widget.controller.initialize();
    }
  }
}
