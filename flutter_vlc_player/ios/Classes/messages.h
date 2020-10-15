// Autogenerated from Pigeon (v0.1.12), do not edit directly.
// See also: https://pub.dev/packages/pigeon
#import <Foundation/Foundation.h>
@protocol FlutterBinaryMessenger;
@class FlutterError;
@class FlutterStandardTypedData;

NS_ASSUME_NONNULL_BEGIN

@class CreateMessage;
@class TextureMessage;
@class SetMediaMessage;
@class BooleanMessage;
@class LoopingMessage;
@class PositionMessage;
@class DurationMessage;
@class VolumeMessage;
@class PlaybackSpeedMessage;
@class SnapshotMessage;
@class TrackCountMessage;
@class SpuTracksMessage;
@class SpuTrackMessage;
@class DelayMessage;
@class AddSubtitleMessage;
@class AudioTracksMessage;
@class AudioTrackMessage;
@class VideoTracksMessage;
@class VideoTrackMessage;
@class VideoScaleMessage;
@class VideoAspectRatioMessage;
@class RendererServicesMessage;
@class RendererScanningMessage;
@class RendererDevicesMessage;
@class RenderDeviceMessage;

@interface CreateMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, copy, nullable) NSString * uri;
@property(nonatomic, strong, nullable) NSNumber * isLocalMedia;
@property(nonatomic, strong, nullable) NSNumber * autoPlay;
@property(nonatomic, strong, nullable) NSNumber * hwAcc;
@property(nonatomic, strong, nullable) NSArray * options;
@end

@interface TextureMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@end

@interface SetMediaMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, copy, nullable) NSString * uri;
@property(nonatomic, strong, nullable) NSNumber * isLocalMedia;
@end

@interface BooleanMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * result;
@end

@interface LoopingMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * isLooping;
@end

@interface PositionMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * position;
@end

@interface DurationMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * duration;
@end

@interface VolumeMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * volume;
@end

@interface PlaybackSpeedMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * speed;
@end

@interface SnapshotMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, copy, nullable) NSString * snapshot;
@end

@interface TrackCountMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * count;
@end

@interface SpuTracksMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSDictionary * subtitles;
@end

@interface SpuTrackMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * spuTrackNumber;
@end

@interface DelayMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * delay;
@end

@interface AddSubtitleMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, copy, nullable) NSString * uri;
@property(nonatomic, strong, nullable) NSNumber * isLocal;
@property(nonatomic, strong, nullable) NSNumber * isSelected;
@end

@interface AudioTracksMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSDictionary * audios;
@end

@interface AudioTrackMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * audioTrackNumber;
@end

@interface VideoTracksMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSDictionary * videos;
@end

@interface VideoTrackMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * videoTrackNumber;
@end

@interface VideoScaleMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSNumber * scale;
@end

@interface VideoAspectRatioMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, copy, nullable) NSString * aspectRatio;
@end

@interface RendererServicesMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSArray * services;
@end

@interface RendererScanningMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, copy, nullable) NSString * rendererService;
@end

@interface RendererDevicesMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, strong, nullable) NSDictionary * rendererDevices;
@end

@interface RenderDeviceMessage : NSObject
@property(nonatomic, strong, nullable) NSNumber * textureId;
@property(nonatomic, copy, nullable) NSString * rendererDevice;
@end

@protocol VlcPlayerApi
-(void)initialize:(FlutterError *_Nullable *_Nonnull)error;
-(void)create:(CreateMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)dispose:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setStreamUrl:(SetMediaMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)play:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)pause:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)stop:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable BooleanMessage *)isPlaying:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setLooping:(LoopingMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)seekTo:(PositionMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable PositionMessage *)position:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable DurationMessage *)duration:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setVolume:(VolumeMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VolumeMessage *)getVolume:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setPlaybackSpeed:(PlaybackSpeedMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable PlaybackSpeedMessage *)getPlaybackSpeed:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable SnapshotMessage *)takeSnapshot:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable TrackCountMessage *)getSpuTracksCount:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable SpuTracksMessage *)getSpuTracks:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setSpuTrack:(SpuTrackMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable SpuTrackMessage *)getSpuTrack:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setSpuDelay:(DelayMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable DelayMessage *)getSpuDelay:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)addSubtitleTrack:(AddSubtitleMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable TrackCountMessage *)getAudioTracksCount:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable AudioTracksMessage *)getAudioTracks:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setAudioTrack:(AudioTrackMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable AudioTrackMessage *)getAudioTrack:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setAudioDelay:(DelayMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable DelayMessage *)getAudioDelay:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable TrackCountMessage *)getVideoTracksCount:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VideoTracksMessage *)getVideoTracks:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setVideoTrack:(VideoTrackMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VideoTrackMessage *)getVideoTrack:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setVideoScale:(VideoScaleMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VideoScaleMessage *)getVideoScale:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)setVideoAspectRatio:(VideoAspectRatioMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable VideoAspectRatioMessage *)getVideoAspectRatio:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable RendererServicesMessage *)getAvailableRendererServices:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)startRendererScanning:(RendererScanningMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)stopRendererScanning:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(nullable RendererDevicesMessage *)getRendererDevices:(TextureMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
-(void)castToRenderer:(RenderDeviceMessage*)input error:(FlutterError *_Nullable *_Nonnull)error;
@end

extern void VlcPlayerApiSetup(id<FlutterBinaryMessenger> binaryMessenger, id<VlcPlayerApi> _Nullable api);

NS_ASSUME_NONNULL_END
