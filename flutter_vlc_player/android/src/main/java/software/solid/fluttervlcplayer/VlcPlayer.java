package software.solid.fluttervlcplayer;

import org.videolan.libvlc.interfaces.IMedia;
import org.videolan.libvlc.interfaces.IVLCVout;
import org.videolan.libvlc.LibVLC;
import org.videolan.libvlc.Media;
import org.videolan.libvlc.MediaPlayer;
import org.videolan.libvlc.RendererDiscoverer;
import org.videolan.libvlc.RendererItem;

import android.content.Context;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.util.Base64;
import android.view.Surface;

import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;

import java.io.ByteArrayOutputStream;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

final class VlcPlayer {

    private LibVLC libVLC;

    private MediaPlayer mediaPlayer;

    private Surface surface;

    private final TextureRegistry.SurfaceTextureEntry textureEntry;

    private QueuingEventSink eventSink = new QueuingEventSink();

    private final EventChannel eventChannel;

    private boolean isInitialized = false;

    private final VlcPlayerOptions options;

    VlcPlayer(
            Context context,
            EventChannel eventChannel,
            TextureRegistry.SurfaceTextureEntry textureEntry,
            String dataSource,
            VlcPlayerOptions options) {
        this.eventChannel = eventChannel;
        this.textureEntry = textureEntry;
        this.options = options;
        //
        libVLC = new LibVLC(context); // todo: add options
        mediaPlayer = new MediaPlayer(libVLC);
        mediaPlayer.setVideoTrackEnabled(true);
        Uri uri = Uri.parse(dataSource); // todo: add local stream file
        Media media = new Media(libVLC, uri);
        mediaPlayer.setMedia(media);
        media.release();
        mediaPlayer.play(); // todo: remove this line
        //
        setupVlcMediaPlayer(eventChannel, textureEntry);
    }

    private void setupVlcMediaPlayer(
            EventChannel eventChannel, TextureRegistry.SurfaceTextureEntry textureEntry) {

        eventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object o, EventChannel.EventSink sink) {
                        eventSink.setDelegate(sink);
                    }

                    @Override
                    public void onCancel(Object o) {
                        eventSink.setDelegate(null);
                    }
                });

        surface = new Surface(textureEntry.surfaceTexture());
        mediaPlayer.getVLCVout().setVideoSurface(surface, null);
        mediaPlayer.getVLCVout().attachViews();

        // todo: update isInitialized
        mediaPlayer.setEventListener(
                new MediaPlayer.EventListener() {
                    @Override
                    public void onEvent(MediaPlayer.Event event) {
                        HashMap<String, Object> eventObject = new HashMap<>();
                        switch (event.type) {
                            case MediaPlayer.Event.Opening:
                                eventObject.put("name", "buffering");
                                eventObject.put("value", true);
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Paused:
                                eventObject.clear();
                                eventObject.put("name", "paused");
                                eventObject.put("value", true);
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Stopped:
                                eventObject.clear();
                                eventObject.put("name", "stopped");
                                eventObject.put("value", true);
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Playing:
                                eventObject.put("name", "buffering");
                                eventObject.put("value", false);
                                eventSink.success(eventObject.clone());
                                eventObject.clear();

                                // Now send playing info:
                                int height = 0;
                                int width = 0;

                                Media.VideoTrack currentVideoTrack = (Media.VideoTrack) mediaPlayer.getMedia().getTrack(
                                        mediaPlayer.getVideoTrack()
                                );
                                if (currentVideoTrack != null) {
                                    height = currentVideoTrack.height;
                                    width = currentVideoTrack.width;
                                }

                                eventObject.put("name", "playing");
                                eventObject.put("value", true);
                                eventObject.put("ratio", height > 0 ? (double) width / (double) height : 0D);
                                eventObject.put("height", height);
                                eventObject.put("width", width);
                                eventObject.put("length", mediaPlayer.getLength());
                                // add support for changing audio tracks and subtitles
                                eventObject.put("audioTracksCount", mediaPlayer.getAudioTracksCount());
                                eventObject.put("activeAudioTrack", mediaPlayer.getAudioTrack());
                                eventObject.put("spuTracksCount", mediaPlayer.getSpuTracksCount());
                                eventObject.put("activeSpuTrack", mediaPlayer.getSpuTrack());
                                //
                                eventSink.success(eventObject.clone());
                                break;

                            case MediaPlayer.Event.Vout:
                                mediaPlayer.updateVideoSurfaces();
                                break;

                            case MediaPlayer.Event.EndReached:
                                mediaPlayer.stop();
                                eventObject.put("name", "ended");
                                eventSink.success(eventObject);

                                eventObject.clear();
                                eventObject.put("name", "playing");
                                eventObject.put("value", false);
                                eventObject.put("reason", "EndReached");
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Buffering:
                            case MediaPlayer.Event.TimeChanged:
                                eventObject.put("name", "timeChanged");
                                eventObject.put("value", mediaPlayer.getTime());
                                eventObject.put("speed", mediaPlayer.getRate());
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.EncounteredError:
                                eventSink.error("VideoError", "A VLC error occurred.", null);
                                break;
                        }
                    }
                }
        );
    }

    void play() {
        mediaPlayer.play();
    }

    void pause() {
        mediaPlayer.pause();
    }

    void stop() {
        mediaPlayer.stop();
    }

    boolean isPlaying() {
        return mediaPlayer.isPlaying();
    }

    void changeUrl(String url) {
        boolean wasPlaying = mediaPlayer.isPlaying();
        mediaPlayer.stop();
        //
        Uri uri = Uri.parse(url);
        Media media = new Media(libVLC, url);
        mediaPlayer.setMedia(media);
        media.release();
        if (wasPlaying)
            mediaPlayer.play();
    }

    void setLooping(boolean value) {
    }

    void setVolume(long value) {
        long bracketedValue = Math.max(0, Math.min(100, value));
        mediaPlayer.setVolume((int) bracketedValue);
    }

    int getVolume() {
        return mediaPlayer.getVolume();
    }

    void setPlaybackSpeed(double value) {
        mediaPlayer.setRate((float) value);
    }

    float getPlaybackSpeed() {
        return mediaPlayer.getRate();
    }

    void seekTo(int location) {
        mediaPlayer.setTime(location);
    }

    long getPosition() {
        return mediaPlayer.getTime();
    }

    void setTime(int location) {
        mediaPlayer.setTime(location);
    }

    long getTime() {
        return mediaPlayer.getTime();
    }

    long getDuration() {
        return mediaPlayer.getLength();
    }

    int getSpuTracksCount() {
        return mediaPlayer.getSpuTracksCount();
    }

    Map<Integer, String> getSpuTracks() {
        MediaPlayer.TrackDescription[] spuTracks = mediaPlayer.getSpuTracks();
        Map<Integer, String> subtitles = new HashMap<>();
        if (spuTracks != null)
            for (MediaPlayer.TrackDescription trackDescription : spuTracks) {
                if (trackDescription.id >= 0)
                    subtitles.put(trackDescription.id, trackDescription.name);
            }
        return subtitles;
    }

    void setSpuTrack(int index) {
        mediaPlayer.setSpuTrack(index);
    }

    int getSpuTrack() {
        return mediaPlayer.getSpuTrack();
    }

    void setSpuDelay(long delay) {
        mediaPlayer.setSpuDelay(delay);
    }

    long getSpuDelay() {
        return mediaPlayer.getSpuDelay();
    }

    void addSubtitleTrack(String subtitleUrl, boolean selected) {
        mediaPlayer.addSlave(Media.Slave.Type.Subtitle, subtitleUrl, selected);
    }

    int getAudioTracksCount() {
        return mediaPlayer.getAudioTracksCount();
    }

    Map<Integer, String> getAudioTracks() {
        MediaPlayer.TrackDescription[] audioTracks = mediaPlayer.getAudioTracks();
        Map<Integer, String> audios = new HashMap<>();
        if (audioTracks != null)
            for (MediaPlayer.TrackDescription trackDescription : audioTracks) {
                if (trackDescription.id >= 0)
                    audios.put(trackDescription.id, trackDescription.name);
            }
        return audios;
    }

    void setAudioTrack(int index) {
        mediaPlayer.setAudioTrack(index);
    }

    int getAudioTrack() {
        return mediaPlayer.getAudioTrack();
    }

    void setAudioDelay(long delay) {
        mediaPlayer.setAudioDelay(delay);
    }

    long getAudioDelay() {
        return mediaPlayer.getAudioDelay();
    }

    int getVideoTracksCount() {
        return mediaPlayer.getVideoTracksCount();
    }

    Map<Integer, String> getVideoTracks() {
        MediaPlayer.TrackDescription[] videoTracks = mediaPlayer.getVideoTracks();
        Map<Integer, String> videos = new HashMap<>();
        if (videoTracks != null)
            for (MediaPlayer.TrackDescription trackDescription : videoTracks) {
                if (trackDescription.id >= 0)
                    videos.put(trackDescription.id, trackDescription.name);
            }
        return videos;
    }

    IMedia.VideoTrack getCurrentVideoTrack() {
        return mediaPlayer.getCurrentVideoTrack();
    }

    void setVideoTrack(int index) {
        mediaPlayer.setVideoTrack(index);
    }

    int getVideoTrack() {
        return mediaPlayer.getVideoTrack();
    }

    void setVideoScale(float scale) {
        mediaPlayer.setScale(scale);
    }

    float getVideoScale() {
        return mediaPlayer.getScale();
    }

    void setVideoAspectRatio(String aspectRatio) {
        mediaPlayer.setAspectRatio(aspectRatio);
    }

    String getVideoAspectRatio() {
        return mediaPlayer.getAspectRatio();
    }

    // todo: implement cast to devices
    void discoverRenderers() {

    }

    void stopCastDiscovery() {

    }

    Map<String, String> getCastDevices() {
        Map<String, String> casts = new HashMap<>();
//        if (rendererItems != null)
//            for (RendererItem item : rendererItems) {
//                casts.put(item.name, item.displayName);
//            }
        return casts;
    }

    void startCasting(String device) {

    }

    String getSnapshot() {
//        Bitmap bitmap = .getBitmap();
//        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
//        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
//        return Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT);
        return "";
    }

    void dispose() {
        if (isInitialized) {
            mediaPlayer.stop();
        }
        textureEntry.release();
        eventChannel.setStreamHandler(null);
        if (surface != null) {
            surface.release();
        }
        if (mediaPlayer != null) {
            mediaPlayer.release();
        }
        if (libVLC != null)
            libVLC.release();
    }
}