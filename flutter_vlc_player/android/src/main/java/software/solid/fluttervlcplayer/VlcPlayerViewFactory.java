//package software.solid.fluttervlcplayer;
//
//import android.content.Context;
//import android.view.View;
//
//import java.util.Map;
//
//import io.flutter.plugin.common.BinaryMessenger;
//import io.flutter.plugin.common.EventChannel;
//import io.flutter.plugin.common.StandardMessageCodec;
//import io.flutter.plugin.platform.PlatformView;
//import io.flutter.plugin.platform.PlatformViewFactory;
//import io.flutter.view.TextureRegistry;
//
//public class VlcPlayerViewFactory extends PlatformViewFactory {
//
//    private final BinaryMessenger messenger;
//
//
//    public VlcPlayerViewFactory(BinaryMessenger messenger, View containerView) {
//        super(StandardMessageCodec.INSTANCE);
//        this.messenger = messenger;
//    }
//
//    @Override
//    public PlatformView create(Context context, int viewId, Object args) {
//        Map<String, Object> params = (Map<String, Object>) args;
//        return new VlcPlayer(context,  messenger, viewId, params, containerView);
//
//
////        VlcPlayer(
////                Context context,
////                binaryMessenger,
////                TextureRegistry.SurfaceTextureEntry textureEntry,)
//    }
//}
