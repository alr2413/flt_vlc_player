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

        
        let channel = FlutterEventChannel(name: "flutter_video_plugin/getVideoEvents_\(viewId)", binaryMessenger: registrar.messenger())
        
        
        var vlcViewController: VLCViewController
        vlcViewController = VLCViewController(
            parent: UIView(frame: frame),
            channel: channel,
            arguments: arguments,
            registrar: registrar)
        
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
     var eventChannel: FlutterEventChannel
     var eventChannelHandler: VLCPlayerEventStreamHandler


    
    public func view() -> UIView {
        return hostedView
    }
    
    init(parent: UIView, channel: FlutterEventChannel, arguments args: NSDictionary, registrar: FlutterPluginRegistrar) {
        self.hostedView = parent
        self.registrar = registrar
        self.vlcMediaPlayer = VLCMediaPlayer()
        self.eventChannel = channel
        eventChannelHandler = VLCPlayerEventStreamHandler()
        eventChannel.setStreamHandler(eventChannelHandler)
        
        
    }
    
//    public func setMediaUrlHelper(newUrl:String, isAssetUrl:Bool,  autoPlay:Bool,  hwAcc:Int)
//    {
//        var media:VLCMedia
//
////        guard let urlString = newUrl,
////              let url = URL(string: urlString)
////        else {
////
////            return
////        }
//        if ( isAssetUrl )
//        {
//
//        }
//
//        var assetPath: String?
//
//        if(DataSourceType(rawValue: Int(truncating: input.type!)) == DataSourceType.ASSET)
//        {
//            if input.packageName != nil {
//                assetPath = registrar.lookupKey(forAsset: urlString, fromPackage: input.packageName!)
//            } else {
//                assetPath = registrar.lookupKey(forAsset: urlString)
//            }
//            media = VLCMedia(path: assetPath ?? "")
//
//        }
//        else{
//            media = VLCMedia(url: url)
//        }
//
//
//
//        self.vlcMediaPlayer.media = media
//        self.vlcMediaPlayer.drawable = self.hostedView
//
//        let options = input.options as? [String] ?? []
//        for option in options {
//            media.addOption(option)
//        }
//
//
//        let hardwareAccellerationType = input.hwAcc
//
//        switch HWAccellerationType.init(rawValue: hardwareAccellerationType as! Int)
//        {
//        case .HW_ACCELERATION_DISABLED:
//            media.addOption("--codec=avcodec")
//
//        case .HW_ACCELERATION_DECODING:
//            media.addOption("--codec=all")
//            media.addOption(":no-mediacodec-dr")
//            media.addOption(":no-omxil-dr")
//
//        case .HW_ACCELERATION_FULL:
//            media.addOption("--codec=all")
//
//        case .HW_ACCELERATION_AUTOMATIC:
//            break
//        case .none:
//            break
//        }
//
//
//
//
//
//        if((input.autoPlay) != nil)
//        {
//        self.vlcMediaPlayer.play()
//        }
//
//    }
    
    public func initialize(_ error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func create(_ input: CreateMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        var media:VLCMedia
        
        guard let urlString = input.uri,
              let url = URL(string: urlString)
        else {
            
            return
        }
        
        var assetPath: String?
        
        if(DataSourceType(rawValue: Int(truncating: input.type!)) == DataSourceType.ASSET)
        {
            if input.packageName != nil {
                assetPath = registrar.lookupKey(forAsset: urlString, fromPackage: input.packageName!)
            } else {
                assetPath = registrar.lookupKey(forAsset: urlString)
            }
            media = VLCMedia(path: assetPath ?? "")
            
        }
        else{
            media = VLCMedia(url: url)
        }
        
        
        
        self.vlcMediaPlayer.media = media
        self.vlcMediaPlayer.drawable = self.hostedView
        
        let options = input.options as? [String] ?? []
        for option in options {
            media.addOption(option)
        }
        
        
        let hardwareAccellerationType = input.hwAcc
        
        switch HWAccellerationType.init(rawValue: hardwareAccellerationType as! Int)
        {
        case .HW_ACCELERATION_DISABLED:
            media.addOption("--codec=avcodec")
            
        case .HW_ACCELERATION_DECODING:
            media.addOption("--codec=all")
            media.addOption(":no-mediacodec-dr")
            media.addOption(":no-omxil-dr")
            
        case .HW_ACCELERATION_FULL:
            media.addOption("--codec=all")
            
        case .HW_ACCELERATION_AUTOMATIC:
            break
        case .none:
            break
        }
        
        
        
        
        
        if((input.autoPlay) != nil)
        {
        self.vlcMediaPlayer.play()
        }
        
        
    }
    
    public func dispose(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func setStreamUrl(_ input: SetMediaMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
        let isPlaying = self.vlcMediaPlayer.isPlaying
        self.vlcMediaPlayer.stop()
        
        
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
        
    }
    
    public func seek(to input: PositionMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func position(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> PositionMessage? {
        return nil;
    }
    
    public func duration(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DurationMessage? {
        return nil
    }
    
    public func setVolume(_ input: VolumeMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getVolume(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VolumeMessage? {
        return nil;
    }
    
    public func setPlaybackSpeed(_ input: PlaybackSpeedMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getPlaybackSpeed(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> PlaybackSpeedMessage? {
        return nil;
    }
    
    public func takeSnapshot(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SnapshotMessage? {
        return nil;
    }
    
    public func getSpuTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        return nil;
    }
    
    public func getSpuTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SpuTracksMessage? {
        return nil;
    }
    
    public func setSpuTrack(_ input: SpuTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getSpuTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> SpuTrackMessage? {
        return nil;
    }
    
    public func setSpuDelay(_ input: DelayMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getSpuDelay(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DelayMessage? {
        return nil;
    }
    
    public func addSubtitleTrack(_ input: AddSubtitleMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getAudioTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        return nil;
        
    }
    
    public func getAudioTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> AudioTracksMessage? {
        return nil;
    }
    
    public func setAudioTrack(_ input: AudioTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getAudioTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> AudioTrackMessage? {
        return nil;
    }
    
    public func setAudioDelay(_ input: DelayMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getAudioDelay(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> DelayMessage? {
        return nil;
    }
    
    public func addAudioTrack(_ input: AddAudioMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getVideoTracksCount(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> TrackCountMessage? {
        return nil;
    }
    
    public func getVideoTracks(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoTracksMessage? {
        return nil;
    }
    
    public func setVideoTrack(_ input: VideoTrackMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getVideoTrack(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoTrackMessage? {
        return nil;
    }
    
    public func setVideoScale(_ input: VideoScaleMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getVideoScale(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoScaleMessage? {
        return nil;
    }
    
    public func setVideoAspectRatio(_ input: VideoAspectRatioMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getVideoAspectRatio(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> VideoAspectRatioMessage? {
        return nil;
    }
    
    public func getAvailableRendererServices(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> RendererServicesMessage? {
        return nil;
    }
    
    public func startRendererScanning(_ input: RendererScanningMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func stopRendererScanning(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
    public func getRendererDevices(_ input: TextureMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) -> RendererDevicesMessage? {
        return nil;
    }
    
    public func cast(toRenderer input: RenderDeviceMessage, error: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        
    }
    
}





class VLCPlayerEventStreamHandler: NSObject, FlutterStreamHandler, VLCMediaPlayerDelegate, VLCRendererDiscovererDelegate {
    
    var renderItems:[VLCRendererItem] = [VLCRendererItem]()
    
    func getRenderItems() -> [VLCRendererItem]
    {
        return renderItems
    }
    
    func rendererDiscovererItemAdded(_ rendererDiscoverer: VLCRendererDiscoverer, item: VLCRendererItem) {
        renderItems.append(item)
        //
        guard let eventSink = self.eventSink else { return }
        eventSink([
            "name": "castItemAdded",
            "value": item.name,
            "displayName" : item.name
        ])
    }
    
    func rendererDiscovererItemDeleted(_ rendererDiscoverer: VLCRendererDiscoverer, item: VLCRendererItem) {
        if let index = renderItems.firstIndex(of: item) {
            renderItems.remove(at: index)
        }
        //
        guard let eventSink = self.eventSink else { return }
        eventSink([
            "name": "castItemDeleted",
            "value": item.name,
            "displayName" : item.name
        ])
    }
    
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments _: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments _: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    func mediaPlayerStateChanged(_ aNotification: Notification?) {
        guard let eventSink = self.eventSink else { return }
        
        let player = aNotification?.object as? VLCMediaPlayer
        let media = player?.media
        let tracks: [Any] = media?.tracksInformation ?? [""] // [Any]
        var track: NSDictionary
        
        var ratio = Float(0.0)
        var height = 0
        var width = 0
        
        let audioTracksCount = player?.numberOfAudioTracks ?? 0
        let activeAudioTrack = player?.currentAudioTrackIndex ?? 0
        let spuTracksCount = player?.numberOfSubtitlesTracks ?? 0
        let activeSpuTrack = player?.currentVideoSubTitleIndex ?? 0
        
        if player?.currentVideoTrackIndex != -1 {
            if (player?.currentVideoTrackIndex) != nil {
                track = tracks[0] as! NSDictionary
                height = (track["height"] as? Int) ?? 0
                width = (track["width"] as? Int) ?? 0
                
                if height != 0, width != 0 {
                    ratio = Float(width / height)
                }
            }
        }
        
        let rate = player?.rate ?? 1
        let time = player?.time?.value?.intValue ?? 0
        
        switch player?.state {
        case .esAdded:
            return
            
        case .opening:
            eventSink([
                "name": "buffering",
                "value": NSNumber(value: true),
            ])
            return
            
        case .playing:
            eventSink([
                "name": "buffering",
                "value": NSNumber(value: false),
            ])
            if let value = media?.length.value {
                eventSink([
                    "name": "playing",
                    "value": NSNumber(value: true),
                    "ratio": NSNumber(value: ratio),
                    "height": height,
                    "width": width,
                    "length": value,
                    "audioTracksCount": audioTracksCount,
                    "activeAudioTrack": activeAudioTrack,
                    "spuTracksCount": spuTracksCount,
                    "activeSpuTrack": activeSpuTrack,
                ])
            }
            return
        case .ended:
            eventSink([
                "name": "ended",
            ])
            eventSink([
                "name": "playing",
                "value": NSNumber(value: false),
                "reason": "EndReached",
            ])
            return
            
        case .buffering:
            eventSink([
                "name": "timeChanged",
                "value": NSNumber(value: time),
                "speed": NSNumber(value: rate),
            ])
            return
            
        case .error:
            eventSink(FlutterError(code: "500",
                                   message: "Player State got an error",
                                   details: nil)
            )
            
            return
            
        case .paused:
            eventSink([
                "name": "paused",
                "value": NSNumber(value: true),
            ])
            return
            
        case .stopped:
            eventSink([
                "name": "stopped",
                "value": NSNumber(value: true),
            ])
            return
            
        default:
            break
        }
    }
    
    func mediaPlayerTimeChanged(_ aNotification: Notification!) {
        let player = aNotification?.object as? VLCMediaPlayer
        
        if let value = player?.time.value {
            eventSink?([
                "name": "timeChanged",
                "value": value,
                "speed": NSNumber(value: player?.rate ?? 1.0),
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
    case  HW_ACCELERATION_DECODING = 2
    case HW_ACCELERATION_FULL = 3
}



enum FlutterMethodCallOption: String {
    case initialize
    case dispose
    case changeURL
    case getSnapshot
    case setPlaybackState
    case isPlaying
    case setPlaybackSpeed
    case getPlaybackSpeed
    case setTime
    case getTime
    case getDuration
    case setVolume
    case getVolume
    case getSpuTracksCount
    case getSpuTracks
    case setSpuTrack
    case getSpuTrack
    case setSpuDelay
    case getSpuDelay
    case addSubtitleTrack
    case getAudioTracksCount
    case getAudioTracks
    case getAudioTrack
    case setAudioTrack
    case setAudioDelay
    case getAudioDelay
    case getVideoTracksCount
    case getVideoTracks
    case getCurrentVideoTrack
    case getVideoTrack
    case setVideoScale
    case getVideoScale
    case setVideoAspectRatio
    case getVideoAspectRatio
    case startCastDiscovery
    case stopCastDiscovery
    case getCastDevices
    case startCasting
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
    
}



