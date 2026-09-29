with open('lib/screens/common/splash_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the forced pause which causes abrupt halting
old_trigger = """  void _triggerExit() {
    if (_hasNavigated || !mounted) return;
    _videoController?.pause();
    // Navigate immediately to allow GoRouter's transition to blend smoothly
    // over the last frame of the video, avoiding any white flash.
    _navigateNext();
  }"""

new_trigger = """  void _triggerExit() {
    if (_hasNavigated || !mounted) return;
    // DO NOT PAUSE! Let the video play its final milliseconds naturally 
    // while the fade transition overlaps it. This prevents the abrupt stutter/halt.
    _navigateNext();
  }"""

content = content.replace(old_trigger, new_trigger)

# Adjust the tick threshold to start transition right as the video is finishing
old_tick = """if (duration > Duration.zero && position >= duration - const Duration(milliseconds: 200)) {"""
new_tick = """if (duration > Duration.zero && position >= duration - const Duration(milliseconds: 300)) {"""

content = content.replace(old_tick, new_tick)

with open('lib/screens/common/splash_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated splash screen")
