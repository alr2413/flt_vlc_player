package software.solid.fluttervlcplayer;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

public class FlutterVlcPlayerPlugin implements FlutterPlugin, ActivityAware {

    public FlutterVlcPlayerPlugin() {
        // All Android plugin classes must support a no-args
        // constructor. A no-arg constructor is provided by
        // default without declaring one, but we include it here for
        // clarity.
        //
        // At this point your plugin is instantiated, but it
        // isn't attached to any Flutter experience. You should not
        // attempt to do any work here that is related to obtaining
        // resources or manipulating Flutter.
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {

//        BinaryMessenger messenger = binding.getBinaryMessenger();
//        binding
//                .getPlatformViewRegistry()
//                .registerViewFactory(
//                        "flutter_video_plugin/getVideoView",
//                        new FlutterVideoViewFactory(messenger, binding.getTextureRegistry()));

        // Your plugin is now attached to a Flutter experience
        // represented by the given FlutterEngine.
        //
        // You can obtain the associated FlutterEngine with
        // binding.getFlutterEngine()
        //
        // You can obtain a BinaryMessenger with
        // binding.getBinaryMessenger()
        //
        // You can obtain the Application context with
        // binding.getApplicationContext()
        //
        // You cannot access an Activity here because this
        // FlutterEngine is not necessarily displayed within an
        // Activity. See the ActivityAware interface for more info.
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        // Your plugin is no longer attached to a Flutter experience.
        // You need to clean up any resources and references that you
        // established in onAttachedToFlutterEngine().
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        // Your plugin is now associated with an Android Activity.
        //
        // If this method is invoked, it is always invoked after
        // onAttachedToFlutterEngine().
        //
        // You can obtain an Activity reference with
        // binding.getActivity()
        //
        // You can listen for Lifecycle changes with
        // binding.getLifecycle()
        //
        // You can listen for Activity results, new Intents, user
        // leave hints, and state saving callbacks by using the
        // appropriate methods on the binding.
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        // The Activity your plugin was associated with has been
        // destroyed due to config changes. It will be right back
        // but your plugin must clean up any references to that
        // Activity and associated resources.
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        // Your plugin is now associated with a new Activity instance
        // after config changes took place. You may now re-establish
        // a reference to the Activity and associated resources.
    }

    @Override
    public void onDetachedFromActivity() {
        // Your plugin is no longer associated with an Activity.
        // You must clean up all resources and references. Your
        // plugin may, or may not ever be associated with an Activity
        // again.
    }
}