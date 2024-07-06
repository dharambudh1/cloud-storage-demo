import "dart:async";
import "dart:developer";
import "dart:io";
import "dart:typed_data";

import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/services.dart";
import "package:flutter_cache_manager/flutter_cache_manager.dart";
import "package:get/get.dart";
import "package:open_file/open_file.dart";

class HomeController extends GetxController {
  Timer timer = Timer(Duration.zero, () {});

  final RxList<Reference> rxListResult = <Reference>[].obs;

  @override
  void onInit() {
    super.onInit();

    timer = Timer.periodic(
      const Duration(seconds: 4),
      (Timer timer) {
        listAllPaginated.listen(
          (ListResult event) {
            rxListResult(event.items);
          },
        );
      },
    );
  }

  @override
  void onClose() {
    super.onClose();

    timer.cancel();
  }

  Stream<ListResult> get listAllPaginated async* {
    String? pageToken;
    do {
      final ListOptions opt = ListOptions(maxResults: 10, pageToken: pageToken);
      final ListResult results = await FirebaseStorage.instance.ref().list(opt);
      yield results;
      pageToken = results.nextPageToken;
    } while (pageToken != null);
  }

  Future<Uint8List> getUint8List({required String path}) async {
    Uint8List uint8list = Uint8List(8);
    try {
      if (path.isURL) {
        final Uri uri = Uri.parse(path);
        final ByteData data = await NetworkAssetBundle(uri).load(path);
        final Int8List int8list = data.buffer.asInt8List();
        final Uint8List temp = Uint8List.fromList(int8list);
        uint8list = temp;
      } else {
        final File file = File(path);
        final Uint8List temp = await file.readAsBytes();
        uint8list = temp;
      }
    } on Exception catch (error, stackTrace) {
      log("Exception caught", error: error, stackTrace: stackTrace);
    } finally {}
    return Future<Uint8List>.value(uint8list);
  }

  Future<String> getDownloadURL({required Reference ref}) async {
    String url = "";
    try {
      url = await ref.getDownloadURL();
    } on Exception catch (error, stackTrace) {
      log("Exception caught", error: error, stackTrace: stackTrace);
    } finally {}
    return Future<String>.value(url);
  }

  Future<File> getSingleFile({required String url}) async {
    File file = File("");
    try {
      file = await DefaultCacheManager().getSingleFile(url);
    } on Exception catch (error, stackTrace) {
      log("Exception caught", error: error, stackTrace: stackTrace);
    } finally {}
    return Future<File>.value(file);
  }

  Future<OpenResult> openFile({required File file}) async {
    OpenResult openResult = OpenResult();
    try {
      openResult = await OpenFile.open(file.path);
    } on Exception catch (error, stackTrace) {
      log("openFile()", error: error, stackTrace: stackTrace);
    } finally {}
    return Future<OpenResult>.value(openResult);
  }
}
