package software.solid.fluttervlcplayer;

import org.videolan.libvlc.LibVLC;
import org.videolan.libvlc.Media;
import org.videolan.libvlc.MediaPlayer;
import org.videolan.libvlc.RendererDiscoverer;
import org.videolan.libvlc.RendererItem;
import org.videolan.libvlc.interfaces.ILibVLC;
import org.videolan.libvlc.interfaces.IVLCVout;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.SurfaceTexture;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Base64;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;


import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.view.TextureRegistry;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

final class FlutterVlcPlayer implements PlatformView {

    private final Context context;

    private LibVLC libVLC;
    private MediaPlayer mediaPlayer;
    private TextureView textureView;
    private TextureRegistry.SurfaceTextureEntry textureEntry;
    private QueuingEventSink eventSink = new QueuingEventSink();
    private EventChannel eventChannel;
    private List<RendererDiscoverer> rendererDiscoverers;
    private List<RendererItem> rendererItems;
    private IVLCVout vout;
    Handler mHandler = new Handler(Looper.getMainLooper());
    private boolean playerDisposed;

    // Platform view
    @Override
    public View getView() {
        return textureView;
    }

    // VLC Player
    FlutterVlcPlayer(int viewId, Context context, BinaryMessenger binaryMessenger, TextureRegistry textureRegistry) {
        this.context = context;
        this.playerDisposed = false;
        //
        eventChannel = new EventChannel(binaryMessenger, "flutter_video_plugin/getVideoEvents_" + viewId);
        textureEntry = textureRegistry.createSurfaceTexture();
        textureView = new TextureView(context);
        textureView.setSurfaceTexture(textureEntry.surfaceTexture());
        textureView.forceLayout();
        textureView.setFitsSystemWindows(true);



    }

    private Uri getStreamUri(String streamPath, boolean isLocal) {
        return isLocal ? Uri.fromFile(new File(streamPath)) : Uri.parse(streamPath);
    }

    public void initialize() {
        libVLC = new LibVLC(context); // todo: add options
        mediaPlayer = new MediaPlayer(libVLC);
        mediaPlayer.setVideoTrackEnabled(true);
        setupVlcMediaPlayer();
    }

    private void setupVlcMediaPlayer() {
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
        //
        vout = mediaPlayer.getVLCVout();
        mediaPlayer.getVLCVout().setVideoSurface(new Surface(textureView.getSurfaceTexture()), null);

        textureView.setSurfaceTextureListener(new TextureView.SurfaceTextureListener() {

            boolean wasPlaying = false;

            private final Runnable mRunnable = new Runnable() {
                @Override
                public void run() {
                    if (vout == null) return;
                    vout.setVideoSurface(new Surface(textureView.getSurfaceTexture()), null);
                    vout.attachViews();
                    textureView.forceLayout();
                    mediaPlayer.play();
                    wasPlaying = false;
                }
            };

            @Override
            public void onSurfaceTextureAvailable(SurfaceTexture surface, int width, int height) {
                mHandler.removeCallbacks(mRunnable);
                mHandler.postDelayed(mRunnable, 1000);
            }

            @Override
            public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {

            }

            @Override
            public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
                if (playerDisposed) {
                    if (mediaPlayer != null) {
                        mediaPlayer.stop();
                        mediaPlayer.setEventListener(null);
                        mediaPlayer.getVLCVout().detachViews();
                        mediaPlayer.release();
                        libVLC.release();
                        libVLC = null;
                        mediaPlayer = null;
                        vout = null;
                    }
                    return true;
                } else {
                    if (mediaPlayer != null && vout != null) {
                        wasPlaying = mediaPlayer.isPlaying();
                        mediaPlayer.pause();
                        vout.detachViews();
                    }
                    return true;
                }
            }

            @Override
            public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            //TODO implement vlc width and height changes here 
            }

        });


        mediaPlayer.getVLCVout().attachViews();




        //
        mediaPlayer.setEventListener(
                new MediaPlayer.EventListener() {

                    private int mWidth = 0;
                    private int mHeight = 0;

                    @Override
                    public void onEvent(MediaPlayer.Event event) {
                        HashMap<String, Object> eventObject = new HashMap<>();
                        switch (event.type) {

                            case MediaPlayer.Event.Opening:
                                eventObject.put("event", "opening");
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Paused:
                                eventObject.put("event", "paused");
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Stopped:
                                eventObject.put("event", "stopped");
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Playing:
                                // Now send playing info:
                                int height = 0;
                                int width = 0;
                                Media.VideoTrack currentVideoTrack = mediaPlayer.getCurrentVideoTrack();
                                if (currentVideoTrack != null) {
                                    height = currentVideoTrack.height;
                                    width = currentVideoTrack.width;
                                    // set surface width & height on media change
                                    if ((mWidth != width) && (mHeight != height)) {
                                        textureEntry.surfaceTexture().setDefaultBufferSize(width, height);
                                        mWidth = width;
                                        mHeight = height;
                                    }
                                }
                                eventObject.put("event", "playing");
                                eventObject.put("height", height);
                                eventObject.put("width", width);
                                eventObject.put("speed", mediaPlayer.getRate());
                                eventObject.put("duration", mediaPlayer.getLength());
                                eventObject.put("audioTracksCount", mediaPlayer.getAudioTracksCount());
                                eventObject.put("activeAudioTrack", mediaPlayer.getAudioTrack());
                                eventObject.put("spuTracksCount", mediaPlayer.getSpuTracksCount());
                                eventObject.put("activeSpuTrack", mediaPlayer.getSpuTrack());
                                eventSink.success(eventObject.clone());
                                break;

                            case MediaPlayer.Event.Vout:
                                mediaPlayer.updateVideoSurfaces();
                                break;

                            case MediaPlayer.Event.EndReached:
                                mediaPlayer.stop();
                                eventObject.put("event", "ended");
                                eventObject.put("position", mediaPlayer.getTime());
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.Buffering:
                            case MediaPlayer.Event.TimeChanged:
                                eventObject.put("event", "timeChanged");
                                eventObject.put("position", mediaPlayer.getTime());
                                eventObject.put("speed", mediaPlayer.getRate());
                                eventObject.put("buffer", event.getBuffering());
                                eventSink.success(eventObject);
                                break;

                            case MediaPlayer.Event.EncounteredError:
                                eventSink.error("vlc_error", "A VLC error occurred.", null);
                                break;

                            case MediaPlayer.Event.LengthChanged:
                            case MediaPlayer.Event.MediaChanged:
                            case MediaPlayer.Event.ESAdded:
                            case MediaPlayer.Event.ESDeleted:
                            case MediaPlayer.Event.ESSelected:
                            case MediaPlayer.Event.PausableChanged:
                            case MediaPlayer.Event.RecordChanged:
                            case MediaPlayer.Event.SeekableChanged:
                            case MediaPlayer.Event.PositionChanged:
                            default:
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

    void setStreamUrl(String url) {
        boolean wasPlaying = mediaPlayer.isPlaying();
        mediaPlayer.stop();
        //
        Uri uri = Uri.parse(url);
        Media media = new Media(libVLC, uri);
        mediaPlayer.setMedia(media);
        media.release();
//        if (wasPlaying)
        mediaPlayer.play();
    }

    void setLooping(boolean value) {
        //todo: implement it
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

    long getDuration() {
        return mediaPlayer.getLength();
    }

    int getSpuTracksCount() {
        return mediaPlayer.getSpuTracksCount();
    }

    HashMap<Integer, String> getSpuTracks() {
        MediaPlayer.TrackDescription[] spuTracks = mediaPlayer.getSpuTracks();
        HashMap<Integer, String> subtitles = new HashMap<>();
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

    void addSubtitleTrack(String uri, boolean isLocal, boolean isSelected) {
        mediaPlayer.addSlave(Media.Slave.Type.Subtitle, uri, isSelected);
    }

    int getAudioTracksCount() {
        return mediaPlayer.getAudioTracksCount();
    }

    HashMap<Integer, String> getAudioTracks() {
        MediaPlayer.TrackDescription[] audioTracks = mediaPlayer.getAudioTracks();
        HashMap<Integer, String> audios = new HashMap<>();
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

    HashMap<Integer, String> getVideoTracks() {
        MediaPlayer.TrackDescription[] videoTracks = mediaPlayer.getVideoTracks();
        HashMap<Integer, String> videos = new HashMap<>();
        if (videoTracks != null)
            for (MediaPlayer.TrackDescription trackDescription : videoTracks) {
                if (trackDescription.id >= 0)
                    videos.put(trackDescription.id, trackDescription.name);
            }
        return videos;
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

    void startRendererScanning(String rendererService) {

        //
        //  android -> chromecast -> "microdns"
        //  ios -> chromecast -> "Bonjour_renderer"
        //
        rendererDiscoverers = new ArrayList<>();
        rendererItems = new ArrayList<>();
        //
        //todo: check for duplicates
        RendererDiscoverer.Description[] renderers = RendererDiscoverer.list(libVLC);
        for (RendererDiscoverer.Description renderer : renderers) {
            RendererDiscoverer rendererDiscoverer = new RendererDiscoverer(libVLC, renderer.name);
            try {
                rendererDiscoverer.setEventListener(new RendererDiscoverer.EventListener() {
                    @Override
                    public void onEvent(RendererDiscoverer.Event event) {
                        HashMap<String, Object> eventObject = new HashMap<>();
                        RendererItem item = event.getItem();
                        switch (event.type) {
                            case RendererDiscoverer.Event.ItemAdded:
                                rendererItems.add(item);
                                eventObject.put("event", "rendererDiscovererItemAttached");
                                eventObject.put("name", item.name);
                                eventObject.put("displayName", item.displayName);
                                eventSink.success(eventObject);
                                break;

                            case RendererDiscoverer.Event.ItemDeleted:
                                rendererItems.remove(item);
                                eventObject.put("event", "rendererDiscovererItemDetached");
                                eventObject.put("name", item.name);
                                eventObject.put("displayName", item.displayName);
                                eventSink.success(eventObject);
                                break;

                            default:
                                break;
                        }
                    }
                });
                rendererDiscoverer.start();
                rendererDiscoverers.add(rendererDiscoverer);
            } catch (Exception ex) {
                rendererDiscoverer.setEventListener(null);
            }

        }

    }

    void stopRendererScanning() {
        for (RendererDiscoverer rendererDiscoverer : rendererDiscoverers) {
            rendererDiscoverer.stop();
            rendererDiscoverer.setEventListener(null);

        }
        rendererDiscoverers.clear();
        rendererItems.clear();
        //
        // return back to default output
        if (mediaPlayer != null) {
            mediaPlayer.pause();
            mediaPlayer.setRenderer(null);
            mediaPlayer.play();
        }
    }

    ArrayList<String> getAvailableRendererServices() {
        RendererDiscoverer.Description[] renderers = RendererDiscoverer.list(libVLC);
        ArrayList<String> availableRendererServices = new ArrayList<>();
        for (RendererDiscoverer.Description renderer : renderers) {
            availableRendererServices.add(renderer.name);
        }
        return availableRendererServices;
    }

    HashMap<String, String> getRendererDevices() {
        HashMap<String, String> renderers = new HashMap<>();
        if (rendererItems != null)
            for (RendererItem rendererItem : rendererItems) {
                renderers.put(rendererItem.name, rendererItem.displayName);
            }
        return renderers;
    }

    void castToRenderer(String rendererDevice) {
        boolean isPlaying = mediaPlayer.isPlaying();
        if (isPlaying)
            mediaPlayer.pause();

        // if you set it to null, it will start to render normally (i.e. locally) again
        RendererItem rendererItem = null;
        for (RendererItem item : rendererItems) {
            if (item.name.equals(rendererDevice)) {
                rendererItem = item;
                break;
            }
        }
        mediaPlayer.setRenderer(rendererItem);

        // start the playback
        mediaPlayer.play();
    }

    String getSnapshot() {
        Bitmap bitmap = textureView.getBitmap();
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
        return Base64.encodeToString(outputStream.toByteArray(), Base64.DEFAULT);
    }

    public void dispose() {
        playerDisposed = true;
        textureEntry.release();
        eventChannel.setStreamHandler(null);
        if (mediaPlayer != null) {
            mediaPlayer.stop();
            mediaPlayer.release();
        }
        if (libVLC != null)
            libVLC.release();
    }


}