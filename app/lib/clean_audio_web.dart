// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

void cleanWebAudio() {
  try {
    final audioElements = html.document.getElementsByTagName('audio');
    for (final element in audioElements) {
      if (element is html.AudioElement) {
        element.pause();
        element.remove();
      }
    }
  } catch (_) {
    // Ignore errors silently on unsupported environments
  }
}
