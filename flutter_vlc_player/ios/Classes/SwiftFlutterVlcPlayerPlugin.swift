import Flutter
import MobileVLCKit
import UIKit

public class SwiftFlutterVlcPlayerPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let factory = VLCViewFactory(registrar:  registrar)
        registrar.register(factory, withId: "flutter_video_plugin/getVideoView")
    }
    
}

public class VLCViewFactory: NSObject, FlutterPlatformViewFactory {
    
    private var registrar: FlutterPluginRegistrar
    
    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        
        let arguments = args as? NSDictionary ?? [:]
        
        let mediaEventChannel = FlutterEventChannel(
            name: "flutter_video_plugin/getVideoEvents_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        let rendererEventChannel = FlutterEventChannel(
            name: "flutter_video_plugin/getRendererEvents_\(viewId)",
            binaryMessenger: registrar.messenger()
        )
        
        var vlcViewController: VLCViewController
        vlcViewController = VLCViewController(
            parent: UIView(frame: frame),
            mediaEventChannel: mediaEventChannel,
            rendererEventChannel: rendererEventChannel,
            arguments: arguments,
            registrar: registrar
        )
        
        VlcPlayerApiSetup(registrar.messenger(), vlcViewController)
        
        return vlcViewController;
        
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
}

public class VLCViewController: NSObject, FlutterPlatformView, VlcPlayerApi {
    
    var hostedView: UIView
    var vlcMediaPlayer: VLCMediaPlayer
    var registrar: FlutterPluginRegistrar
    var mediaEventChannel: FlutterEventChannel
    let mediaEventChannelHandler: VLCPlayerEventStreamHandler
    var rendererEventChannel: FlutterEventChannel
    let rendererEventChannelHandler: VLCRendererEventStreamHandler
    var rendererdiscoverers: [VLCRendererDiscoverer] = [VLCRendererDiscoverer]()
    
    public func view() -> UIView {
        return hostedView
    }
    
    init(parent: UIView,
         mediaEventChannel: FlutterEventChannel,
         rendererEventChannel: FlutterEventChannel,
         arguments args: NSDictionary,
         registrar: FlutterPluginRegistrar) {
        
        self.hostedView = parent
        self.registrar = registrar
        self.vlcMediaPlayer = VLCMediaPlayer()
        self.mediaEventChannel = mediaEventChannel
        self.mediaEventChannelHandler = VLCPlayerEventStreamHandler()
        self.rendererEventChannel = rendererEventChannel
        self.rendererEventChannelHandler = VLCRendererEventStreamHandler()
        //
        self.mediaEventChannel.setStreamHandler(mediaEventChannelHandler)
        self.rendererEventChannel.setStreamHandler(rendererEventChannelHandler)
        self.vlcMediaPlayer.drawable = self.hostedView
        self.vlcMediaPlayer.delegate = self.mediaEventChannelHandler
    }
    
    
    public func initialize(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        return
    }
    
    public func create(_ input: CreateMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        var isAssetUrl: Bool = false
        var mediaUrl: String = ""
        
        if(DataSourceType(rawValue: Int(truncating: input.type!)) == DataSourceType.ASSET){
            var assetPath: String
            if input.packageName != nil {
                assetPath = registrar.lookupKey(forAsset: input.uri ?? "" , fromPackage: input.packageName ?? "")
            } else {
                assetPath = registrar.lookupKey(forAsset: input.uri ?? "")
            }
            mediaUrl = assetPath
            isAssetUrl = true
        }else{
            mediaUrl = input.uri ?? ""
            isAssetUrl = false
        }
        
        self.setMediaPlayerUrl(
            uri: mediaUrl,
            isAssetUrl: isAssetUrl,
            autoPlay: input.autoPlay?.boolValue ?? true,
            hwAcc: input.hwAcc?.intValue ?? HWAccellerationType.HW_ACCELERATION_AUTOMATIC.rawValue,
            options: input.options as? [String] ?? []
        )
    }
    
    public func dispose(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func setStreamUrl(_ input: SetMediaMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        var isAssetUrl: Bool = false
        var mediaUrl: String = ""
        
        if(DataSourceType(rawValue: Int(truncating: input.type!)) == DataSourceType.ASSET){
            var assetPath: String
            if input.packageName != nil {
                assetPath = registrar.lookupKey(forAsset: input.uri ?? "" , fromPackage: input.packageName ?? "")
            } else {
                assetPath = registrar.lookupKey(forAsset: input.uri ?? "")
            }
            mediaUrl = assetPath
            isAssetUrl = true
        }else{
            mediaUrl = input.uri ?? ""
            isAssetUrl = false
        }
        self.setMediaPlayerUrl(
            uri: mediaUrl,
            isAssetUrl: isAssetUrl,
            autoPlay: input.autoPlay?.boolValue ?? true,
            hwAcc: input.hwAcc?.intValue ?? HWAccellerationType.HW_ACCELERATION_AUTOMATIC.rawValue,
            options: []
        )
    }
    
    public func play(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.play()
    }
    
    public func pause(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.pause()
    }
    
    public func stop(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.stop()
    }
    
    public func isPlaying(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> BooleanMessage? {
        
        let message: BooleanMessage = BooleanMessage()
        message.result = self.vlcMediaPlayer.isPlaying as NSNumber
        return message
    }
    
    public func setLooping(_ input: LoopingMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        // self.vlcMediaPlayer.media.addOption()
        // --loop, --no-loop
    }
    
    public func seek(to input: PositionMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.time = VLCTime(number: input.position)
    }
    
    public func position(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> PositionMessage? {
        
        let message: PositionMessage = PositionMessage()
        message.position = self.vlcMediaPlayer.time.value
        return message
    }
    
    public func duration(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DurationMessage? {
        
        let message: DurationMessage = DurationMessage()
        message.duration = self.vlcMediaPlayer.media?.length.value ?? 0
        return message
    }
    
    public func setVolume(_ input: VolumeMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.audio.volume = input.volume?.int32Value ?? 100
    }
    
    public func getVolume(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VolumeMessage? {
        
        let message: VolumeMessage = VolumeMessage()
        message.volume = NSNumber(value: self.vlcMediaPlayer.audio.volume)
        return message
    }
    
    public func setPlaybackSpeed(_ input: PlaybackSpeedMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.rate = input.speed?.floatValue ?? 1
    }
    
    public func getPlaybackSpeed(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> PlaybackSpeedMessage? {
        
        let message: PlaybackSpeedMessage = PlaybackSpeedMessage()
        message.speed = NSNumber(value: self.vlcMediaPlayer.rate)
        return message
    }
    
    public func takeSnapshot(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SnapshotMessage? {
        
        let drawable: UIView = self.vlcMediaPlayer.drawable as! UIView
        let size = drawable.frame.size
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0.0)
        let rec = drawable.frame
        drawable.drawHierarchy(in: rec, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let byteArray = (image ?? UIImage()).pngData()
        //
        let message: SnapshotMessage = SnapshotMessage()
        message.snapshot = byteArray?.base64EncodedString()
        return message
    }
    
    public func getSpuTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        
        let message: TrackCountMessage = TrackCountMessage()
        message.count = NSNumber(value: self.vlcMediaPlayer.numberOfSubtitlesTracks)
        return message
    }
    
    public func getSpuTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SpuTracksMessage? {
        
        let message: SpuTracksMessage = SpuTracksMessage()
        message.subtitles = self.vlcMediaPlayer.subtitles()
        return message
    }
    
    public func setSpuTrack(_ input: SpuTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.currentVideoSubTitleIndex = input.spuTrackNumber?.int32Value ?? 0
    }
    
    public func getSpuTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SpuTrackMessage? {
        
        let message: SpuTrackMessage = SpuTrackMessage()
        message.spuTrackNumber = NSNumber(value: self.vlcMediaPlayer.currentVideoSubTitleIndex)
        return message
    }
    
    public func setSpuDelay(_ input: DelayMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.currentVideoSubTitleDelay = input.delay?.intValue ?? 0
    }
    
    public func getSpuDelay(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DelayMessage? {
        
        let message: DelayMessage = DelayMessage()
        message.delay = NSNumber(value: self.vlcMediaPlayer.currentVideoSubTitleDelay)
        return message
    }
    
    public func addSubtitleTrack(_ input: AddSubtitleMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        // todo: check for file type
        guard let urlString = input.uri,
              let url = URL(string: urlString)
        else {
            return
        }
        self.vlcMediaPlayer.addPlaybackSlave(
            url,
            type: VLCMediaPlaybackSlaveType.subtitle,
            enforce: input.isSelected?.boolValue ?? true
        )
    }
    
    public func getAudioTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        
        let message: TrackCountMessage = TrackCountMessage()
        message.count = NSNumber(value: self.vlcMediaPlayer.numberOfAudioTracks)
        return message
    }
    
    public func getAudioTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> AudioTracksMessage? {
        
        let message: AudioTracksMessage = AudioTracksMessage()
        message.audios = self.vlcMediaPlayer.audioTracks()
        return message
    }
    
    public func setAudioTrack(_ input: AudioTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.currentAudioTrackIndex = input.audioTrackNumber?.int32Value ?? 0
    }
    
    public func getAudioTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> AudioTrackMessage? {
        
        let message: AudioTrackMessage = AudioTrackMessage()
        message.audioTrackNumber = NSNumber(value: self.vlcMediaPlayer.currentAudioTrackIndex)
        return message
    }
    
    public func setAudioDelay(_ input: DelayMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.currentAudioPlaybackDelay = input.delay?.intValue ?? 0
    }
    
    public func getAudioDelay(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DelayMessage? {
        
        let message: DelayMessage = DelayMessage()
        message.delay = NSNumber(value: self.vlcMediaPlayer.currentAudioPlaybackDelay)
        return message
    }
    
    public func addAudioTrack(_ input: AddAudioMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        // todo: check for file type
        guard let urlString = input.uri,
              let url = URL(string: urlString)
        else {
            return
        }
        self.vlcMediaPlayer.addPlaybackSlave(
            url,
            type: VLCMediaPlaybackSlaveType.audio,
            enforce: input.isSelected?.boolValue ?? true
        )
    }
    
    public func getVideoTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        
        let message: TrackCountMessage = TrackCountMessage()
        message.count = NSNumber(value: self.vlcMediaPlayer.numberOfVideoTracks)
        return message
    }
    
    public func getVideoTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoTracksMessage? {
        
        let message: VideoTracksMessage = VideoTracksMessage()
        message.videos = self.vlcMediaPlayer.videoTracks()
        return message
    }
    
    public func setVideoTrack(_ input: VideoTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.currentVideoTrackIndex = input.videoTrackNumber?.int32Value ?? 0
    }
    
    public func getVideoTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoTrackMessage? {
        
        let message: VideoTrackMessage = VideoTrackMessage()
        message.videoTrackNumber = NSNumber(value: self.vlcMediaPlayer.currentVideoTrackIndex)
        return message
    }
    
    public func setVideoScale(_ input: VideoScaleMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        self.vlcMediaPlayer.scaleFactor = input.scale?.floatValue ?? 1
    }
    
    public func getVideoScale(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoScaleMessage? {
        
        let message: VideoScaleMessage = VideoScaleMessage()
        message.scale = NSNumber(value: self.vlcMediaPlayer.scaleFactor)
        return message
    }
    
    public func setVideoAspectRatio(_ input: VideoAspectRatioMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let aspectRatio = UnsafeMutablePointer<Int8>(
            mutating: (input.aspectRatio as NSString?)?.utf8String!
        )
        self.vlcMediaPlayer.videoAspectRatio = aspectRatio
    }
    
    public func getVideoAspectRatio(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoAspectRatioMessage? {
        
        let message: VideoAspectRatioMessage = VideoAspectRatioMessage()
        message.aspectRatio = String(cString: self.vlcMediaPlayer.videoAspectRatio)
        return message
    }
    
    public func getAvailableRendererServices(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> RendererServicesMessage? {
        
        let message: RendererServicesMessage = RendererServicesMessage()
        message.services = self.vlcMediaPlayer.rendererServices()
        return message
    }
    
    public func startRendererScanning(_ input: RendererScanningMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        rendererdiscoverers.removeAll()
        rendererEventChannelHandler.renderItems.removeAll()
        // chromecast service name: "Bonjour_renderer"
        let rendererServices = self.vlcMediaPlayer.rendererServices()
        for rendererService in rendererServices{
            guard let rendererDiscoverer
                    = VLCRendererDiscoverer(name: rendererService) else {
                continue
            }
            rendererDiscoverer.delegate = self.rendererEventChannelHandler
            rendererDiscoverer.start()
            rendererdiscoverers.append(rendererDiscoverer)
        }
    }
    
    public func stopRendererScanning(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        for rendererDiscoverer in rendererdiscoverers {
            rendererDiscoverer.stop()
            rendererDiscoverer.delegate = nil
        }
        rendererdiscoverers.removeAll()
        rendererEventChannelHandler.renderItems.removeAll()
        if(self.vlcMediaPlayer.isPlaying){
            self.vlcMediaPlayer.pause()
        }
        self.vlcMediaPlayer.setRendererItem(nil)
    }
    
    public func getRendererDevices(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> RendererDevicesMessage? {
        
        var rendererDevices: [String: String] = [:]
        let rendererItems = rendererEventChannelHandler.renderItems
        for (_, item) in rendererItems.enumerated() {
            rendererDevices[item.name] = item.name
        }
        let message: RendererDevicesMessage = RendererDevicesMessage()
        message.rendererDevices = rendererDevices
        return message
    }
    
    public func cast(toRenderer input: RenderDeviceMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        if (self.vlcMediaPlayer.isPlaying){
            self.vlcMediaPlayer.pause()
        }
        let rendererItems = self.rendererEventChannelHandler.renderItems
        let rendererItem = rendererItems.first{
            $0.name.contains(input.rendererDevice ?? "")
        }
        self.vlcMediaPlayer.setRendererItem(rendererItem)
        self.vlcMediaPlayer.play()
    }
    
    
    func setMediaPlayerUrl(uri: String, isAssetUrl: Bool, autoPlay: Bool, hwAcc: Int, options: [String]){
        
        self.vlcMediaPlayer.stop()
        var media: VLCMedia
        if(isAssetUrl){
            media = VLCMedia(path: uri)
        }
        else{
            guard let url = URL(string: uri)
            else {
                return
            }
            media = VLCMedia(url: url)
        }
        
        if(!options.isEmpty){
            for option in options {
                media.addOption(option)
            }
        }
        
        switch HWAccellerationType.init(rawValue: hwAcc)
        {
        case .HW_ACCELERATION_DISABLED:
            media.addOption("--codec=avcodec")
            break
            
        case .HW_ACCELERATION_DECODING:
            media.addOption("--codec=all")
            media.addOption(":no-mediacodec-dr")
            media.addOption(":no-omxil-dr")
            break
            
        case .HW_ACCELERATION_FULL:
            media.addOption("--codec=all")
            break
            
        case .HW_ACCELERATION_AUTOMATIC:
            break
            
        case .none:
            break
        }
        
        self.vlcMediaPlayer.media = media
        if(autoPlay){
            self.vlcMediaPlayer.play()
        }
    }
}


class VLCRendererEventStreamHandler: NSObject, FlutterStreamHandler, VLCRendererDiscovererDelegate {
    
    private var rendererEventSink: FlutterEventSink?
    var renderItems:[VLCRendererItem] = [VLCRendererItem]()
    
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        rendererEventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        
        rendererEventSink = nil
        return nil
    }
    
    func rendererDiscovererItemAdded(_ rendererDiscoverer: VLCRendererDiscoverer, item: VLCRendererItem) {
        
        self.renderItems.append(item)
        
        guard let rendererEventSink = self.rendererEventSink else { return }
        rendererEventSink([
            "event": "attached",
            "id": item.name,
            "name" : item.name,
        ])
    }
    
    func rendererDiscovererItemDeleted(_ rendererDiscoverer: VLCRendererDiscoverer, item: VLCRendererItem) {
        
        if let index = renderItems.firstIndex(of: item) {
            renderItems.remove(at: index)
        }
        
        guard let rendererEventSink = self.rendererEventSink else { return }
        rendererEventSink([
            "event": "detached",
            "id": item.name,
            "name" : item.name,
        ])
    }
}


class VLCPlayerEventStreamHandler: NSObject, FlutterStreamHandler, VLCMediaPlayerDelegate  {
    
    private var mediaEventSink: FlutterEventSink?
    
    func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        
        mediaEventSink = events
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        
        mediaEventSink = nil
        return nil
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification?) {
        guard let mediaEventSink = self.mediaEventSink else { return }
        
        let player = aNotification?.object as? VLCMediaPlayer
        let media = player?.media
        
        let tracks: [Any] = media?.tracksInformation ?? [""] // [Any]
        var track: NSDictionary
        var height = 0
        var width = 0
        if (player?.currentVideoTrackIndex != nil) &&
            (player?.currentVideoTrackIndex != -1) {
            track = tracks[0] as! NSDictionary
            height = (track["height"] as? Int) ?? 0
            width = (track["width"] as? Int) ?? 0
        }
        let audioTracksCount = player?.numberOfAudioTracks ?? 0
        let activeAudioTrack = player?.currentAudioTrackIndex ?? 0
        let spuTracksCount = player?.numberOfSubtitlesTracks ?? 0
        let activeSpuTrack = player?.currentVideoSubTitleIndex ?? 0
        let duration =  media?.length.value ?? 0
        let speed = player?.rate ?? 1
        let position = player?.time?.value?.intValue ?? 0
        let buffering = 100.0
        
        switch player?.state
        {
        
        case .opening:
            mediaEventSink([
                "event":"opening",
            ])
            break
            
        case .paused:
            mediaEventSink([
                "event":"paused",
            ])
            break
            
        case .stopped:
            mediaEventSink([
                "event": "stopped",
            ])
            break
            
        case .playing:
            mediaEventSink([
                "event": "playing",
                "height": height,
                "width":  width,
                "speed": speed,
                "duration": duration,
                "audioTracksCount": audioTracksCount,
                "activeAudioTrack": activeAudioTrack,
                "spuTracksCount": spuTracksCount,
                "activeSpuTrack": activeSpuTrack,
            ])
            break
            
        case .ended:
            mediaEventSink([
                "event": "ended",
                "position": position
            ])
            break
            
        case .buffering:
            mediaEventSink([
                "event": "timeChanged",
                "position": position,
                "speed": speed,
                "buffer" : buffering,
            ])
            break
            
        case .error:
            mediaEventSink(
                FlutterError(
                    code: "500",
                    message: "Player State got an error",
                    details: nil)
            )
            break
            
        case .esAdded:
            break
            
        default:
            break
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        guard let mediaEventSink = self.mediaEventSink else { return }
        
        let player = aNotification?.object as? VLCMediaPlayer
        let speed = player?.rate ?? 1
        
        if let position = player?.time.value {
            mediaEventSink([
                "event": "timeChanged",
                "position": position,
                "speed": speed,
                "buffer": 100.0,
            ])
        }
    }
}

enum DataSourceType: Int
{
    case ASSET = 0
    case NETWORK = 1
    case FILE = 2
}

enum HWAccellerationType: Int
{
    case HW_ACCELERATION_AUTOMATIC = 0
    case HW_ACCELERATION_DISABLED = 1
    case HW_ACCELERATION_DECODING = 2
    case HW_ACCELERATION_FULL = 3
}

extension VLCMediaPlayer {
    
    func subtitles() -> [Int: String] {
        guard let indexs = videoSubTitlesIndexes as? [Int],
              let names = videoSubTitlesNames as? [String],
              indexs.count == names.count
        else {
            return [:]
        }
        
        var subtitles: [Int: String] = [:]
        
        var i = 0
        for index in indexs {
            if index >= 0 {
                let name = names[i]
                subtitles[Int(index)] = name
            }
            i = i + 1
        }
        
        return subtitles
    }
    
    func audioTracks() -> [Int: String] {
        guard let indexs = audioTrackIndexes as? [Int],
              let names = audioTrackNames as? [String],
              indexs.count == names.count
        else {
            return [:]
        }
        
        var audios: [Int: String] = [:]
        
        var i = 0
        for index in indexs {
            if index >= 0 {
                let name = names[i]
                audios[Int(index)] = name
            }
            i = i + 1
        }
        
        return audios
    }
    
    func videoTracks() -> [Int: String]{
        
        guard let indexs = videoTrackIndexes as? [Int],
              let names = videoTrackNames as? [String],
              indexs.count == names.count
        else {
            return [:]
        }
        
        var videos: [Int: String] = [:]
        
        var i = 0
        for index in indexs {
            if index >= 0 {
                let name = names[i]
                videos[Int(index)] = name
            }
            i = i + 1
        }
        
        return videos
    }
    
    func rendererServices() -> [String]{
        
        let renderers = VLCRendererDiscoverer.list()
        var services : [String] = []
        
        renderers?.forEach({ (VLCRendererDiscovererDescription) in
            services.append(VLCRendererDiscovererDescription.name)
        })
        return services
    }
    
}



