package software.solid.fluttervlcplayer;

import android.content.Context;
import android.os.Build;
import android.util.Log;
import android.util.LongSparseArray;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.view.TextureRegistry;
import software.solid.fluttervlcplayer.Messages.CreateMessage;
import software.solid.fluttervlcplayer.Messages.LoopingMessage;
import software.solid.fluttervlcplayer.Messages.PlaybackSpeedMessage;
import software.solid.fluttervlcplayer.Messages.PositionMessage;
import software.solid.fluttervlcplayer.Messages.TextureMessage;
import software.solid.fluttervlcplayer.Messages.VlcPlayerApi;
import software.solid.fluttervlcplayer.Messages.VolumeMessage;
import io.flutter.embedding.engine.plugins.FlutterPlugin;

/**
 * Android platform implementation of the VlcPlayerPlugin.
 */
public class VlcPlayerPlugin implements FlutterPlugin, VlcPlayerApi {
    private static final String TAG = "VlcPlayerPlugin";
    private final LongSparseArray<VlcPlayer> vlcPlayers = new LongSparseArray<>();
    private FlutterState flutterState;
    private VlcPlayerOptions options = new VlcPlayerOptions();

    /**
     * Register this with the v2 embedding for the plugin to respond to lifecycle callbacks.
     */
    public VlcPlayerPlugin() {
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @SuppressWarnings("deprecation")
    private VlcPlayerPlugin(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        this.flutterState =
                new FlutterState(
                        registrar.context(),
                        registrar.messenger(),
                        registrar::lookupKeyForAsset,
                        registrar::lookupKeyForAsset,
                        registrar.textures());
        flutterState.startListening(this, registrar.messenger());
    }

    /**
     * Registers this with the stable v1 embedding. Will not respond to lifecycle events.
     */
    @RequiresApi(api = Build.VERSION_CODES.N)
    @SuppressWarnings("deprecation")
    public static void registerWith(io.flutter.plugin.common.PluginRegistry.Registrar registrar) {
        final VlcPlayerPlugin plugin = new VlcPlayerPlugin(registrar);
        registrar.addViewDestroyListener(
                view -> {
                    plugin.onDestroy();
                    return false; // We are not interested in assuming ownership of the NativeView.
                });
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        @SuppressWarnings("deprecation") final FlutterLoader flutterLoader = FlutterLoader.getInstance();
        this.flutterState =
                new FlutterState(
                        binding.getApplicationContext(),
                        binding.getBinaryMessenger(),
                        flutterLoader::getLookupKeyForAsset,
                        flutterLoader::getLookupKeyForAsset,
                        binding.getTextureRegistry());
        flutterState.startListening(this, binding.getBinaryMessenger());
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        if (flutterState == null) {
            Log.wtf(TAG, "Detached from the engine before registering to it.");
        }
        flutterState.stopListening(binding.getBinaryMessenger());
        flutterState = null;
    }

    private void disposeAllPlayers() {
        for (int i = 0; i < vlcPlayers.size(); i++) {
            vlcPlayers.valueAt(i).dispose();
        }
        vlcPlayers.clear();
    }

    private void onDestroy() {
        disposeAllPlayers();
    }

    @Override
    public void initialize() {
        disposeAllPlayers();
    }

    @Override
    public TextureMessage create(CreateMessage arg) {

        TextureRegistry.SurfaceTextureEntry handle =
                flutterState.textureRegistry.createSurfaceTexture();
        EventChannel eventChannel =
                new EventChannel(
                        flutterState.binaryMessenger, "flutter_video_plugin/getVideoEvents_" + handle.id());

        VlcPlayer player;
        if (arg.getAsset() != null) {
            String assetLookupKey;
            if (arg.getPackageName() != null) {
                assetLookupKey =
                        flutterState.keyForAssetAndPackageName.get(arg.getAsset(), arg.getPackageName());
            } else {
                assetLookupKey = flutterState.keyForAsset.get(arg.getAsset());
            }
            player =
                    new VlcPlayer(
                            flutterState.applicationContext,
                            eventChannel,
                            handle,
                            "asset:///" + assetLookupKey,
                            options);
            vlcPlayers.put(handle.id(), player);
        } else {
            player =
                    new VlcPlayer(
                            flutterState.applicationContext,
                            eventChannel,
                            handle,
                            arg.getUri(),
                            options);
            vlcPlayers.put(handle.id(), player);
        }

        TextureMessage result = new TextureMessage();
        result.setTextureId(handle.id());
        return result;
    }

    @Override
    public void dispose(TextureMessage arg) {
        VlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.dispose();
        vlcPlayers.remove(arg.getTextureId());
    }

    @Override
    public void setLooping(LoopingMessage arg) {
        VlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setLooping(arg.getIsLooping());
    }

    @Override
    public void setVolume(VolumeMessage arg) {
        VlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setVolume(arg.getVolume());
    }

    @Override
    public void setPlaybackSpeed(PlaybackSpeedMessage arg) {
        VlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.setPlaybackSpeed(arg.getSpeed());
    }

    @Override
    public void play(TextureMessage arg) {
        VlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.play();
    }

    @Override
    public PositionMessage position(TextureMessage arg) {
        VlcPlayer player = vlcPlayers.get(arg.getTextureId());
        PositionMessage result = new PositionMessage();
        result.setPosition(player.getPosition());
        return result;
    }

    @Override
    public void seekTo(Messages.PositionMessage arg) {
        VlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.seekTo(arg.getPosition().intValue());
    }

    @Override
    public void pause(Messages.TextureMessage arg) {
        VlcPlayer player = vlcPlayers.get(arg.getTextureId());
        player.pause();
    }

    // extra helpers

    private interface KeyForAssetFn {
        String get(String asset);
    }

    private interface KeyForAssetAndPackageName {
        String get(String asset, String packageName);
    }

    private static final class FlutterState {
        private final Context applicationContext;
        private final BinaryMessenger binaryMessenger;
        private final KeyForAssetFn keyForAsset;
        private final KeyForAssetAndPackageName keyForAssetAndPackageName;
        private final TextureRegistry textureRegistry;

        FlutterState(
                Context applicationContext,
                BinaryMessenger messenger,
                KeyForAssetFn keyForAsset,
                KeyForAssetAndPackageName keyForAssetAndPackageName,
                TextureRegistry textureRegistry) {
            this.applicationContext = applicationContext;
            this.binaryMessenger = messenger;
            this.keyForAsset = keyForAsset;
            this.keyForAssetAndPackageName = keyForAssetAndPackageName;
            this.textureRegistry = textureRegistry;
        }

        @RequiresApi(api = Build.VERSION_CODES.N)
        void startListening(VlcPlayerPlugin methodCallHandler, BinaryMessenger messenger) {
            VlcPlayerApi.setup(messenger, methodCallHandler);
        }

        @RequiresApi(api = Build.VERSION_CODES.N)
        void stopListening(BinaryMessenger messenger) {
            VlcPlayerApi.setup(messenger, null);
        }
    }
}
