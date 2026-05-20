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

bool isSafariBrowser() {
  try {
    final ua = html.window.navigator.userAgent.toLowerCase();
    
    // Check if it's a Safari/WebKit-based browser, but NOT Chrome, Firefox, Edge, etc.
    final isSafari = ua.contains('safari') || ua.contains('applewebkit');
    final isOther = ua.contains('chrome') || 
                    ua.contains('crios') || 
                    ua.contains('chromium') || 
                    ua.contains('fxios') || 
                    ua.contains('edgios') || 
                    ua.contains('android'); // Android Chrome/WebView has 'safari' in it
                    
    return isSafari && !isOther;
  } catch (_) {}
  return false;
}
