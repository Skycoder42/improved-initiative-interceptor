import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:lzma/lzma.dart';
import 'package:messagepack/messagepack.dart';

class _Pipe<TInput, TOutput, TInit> {
  final _Pipe<dynamic, TInput, TInit>? _parent;
  final TOutput Function(TInput) _transformer;

  static _Pipe<TInit, TInit, TInit> create<TInit>() =>
      _Pipe._withParent(null, (d) => d);

  _Pipe._withParent(this._parent, this._transformer);

  _Pipe<TOutput, TNext, TInit> pipe<TNext>(
    TNext Function(TOutput data) transformer,
  ) =>
      _Pipe._withParent(this, transformer);

  TOutput process(TInit input) => _transformer(
        _parent != null ? _parent!.process(input) : input as TInput,
      );
}

Future<void> main() async {
  final textAreaElement = (querySelector('#output')! as TextAreaElement)
    ..value = 'Loading, please wait...';

  final pipe = _Pipe.create<String>()
      .pipe(base64Url.normalize)
      .pipe(base64Url.decode)
      .pipe(lzma.decode)
      .pipe(Unpacker.fromList)
      .pipe((unpacker) => unpacker.unpackString() ?? '')
      .pipe((jsonString) => json.decode(jsonString) as Object?)
      .pipe(const JsonEncoder.withIndent('  ').convert);

  final s = UrlSearchParams(window.location.search).get('s');
  final decodedStats = await Future(() => pipe.process(s ?? ''));

  textAreaElement
    ..value = decodedStats
    ..select();

  await Future(() => textAreaElement.scrollTop = 0);
}
