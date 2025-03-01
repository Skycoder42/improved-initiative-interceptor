import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:lzstring/lzstring.dart';
import 'package:web/web.dart';

Future<void> main() async {
  final textAreaElement =
      (document.querySelector('#output')! as HTMLTextAreaElement)
        ..value = 'Loading, please wait...';

  final query = URLSearchParams(window.location.search.toJS);
  final source = query.get('i');
  if (source == null) {
    textAreaElement.value = 'No stats found in URL';
    return;
  }

  try {
    final decodedStats = await LZString.decompressFromEncodedURIComponent(
      source,
    );
    if (decodedStats == null) {
      textAreaElement.value = 'Failed to decode stats';
      return;
    }

    final prettyStats = const JsonEncoder.withIndent(
      '  ',
    ).convert(json.decode(decodedStats));

    textAreaElement
      ..value = prettyStats
      ..select();

    await Future(() => textAreaElement.scrollTop = 0);
  } on Exception catch (e, s) {
    textAreaElement.value = '$e\n$s';
  }
}
