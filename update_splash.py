with open('lib/screens/common/splash_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace _triggerExit to navigate immediately without fading out to white
old_trigger = """  void _triggerExit() {
    if (_hasNavigated || !mounted) return;
    _videoController?.pause();
    _exitController.forward().then((_) => _navigateNext());
  }"""

new_trigger = """  void _triggerExit() {
    if (_hasNavigated || !mounted) return;
    _videoController?.pause();
    // Navigate immediately to allow GoRouter's transition to blend smoothly
    // over the last frame of the video, avoiding any white flash.
    _navigateNext();
  }"""

content = content.replace(old_trigger, new_trigger)

# Remove the AnimatedBuilder wrapping the VideoPlayer (which caused the fade to white)
old_video_build = """          if (_isVideoReady && controller != null)
            AnimatedBuilder(
              animation: _exitOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _exitOpacity.value,
                  child: child,
                );
              },
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
              ),
            ),"""

new_video_build = """          if (_isVideoReady && controller != null)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),"""

content = content.replace(old_video_build, new_video_build)

with open('lib/screens/common/splash_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated splash screen exit logic")
