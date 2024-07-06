import "dart:developer";
import "dart:io";

import "package:cloud_storage_demo/controller/home_controller.dart";
import "package:firebase_storage/firebase_storage.dart";
import "package:firebase_ui_storage/firebase_ui_storage.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:mime/mime.dart";
import "package:mimecon/mimecon.dart";
import "package:open_file/open_file.dart";

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cloud Storage Demo")),
      floatingActionButton: uploadButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(child: Obx(listView)),
    );
  }

  Widget listView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: controller.rxListResult.length,
      physics: const ScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (BuildContext context, int index) {
        final Reference reference = controller.rxListResult[index];
        return listViewAdapter(reference);
      },
    );
  }

  Widget listViewAdapter(Reference ref) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: ListTile(
        dense: true,
        leading: SizedBox(
          height: 32,
          width: 32,
          child: ref.name.isImageFileName
              ? StorageImage(ref: ref)
              : Mimecon(mimetype: lookupMimeType(ref.name) ?? ""),
        ),
        title: Text(ref.name),
        subtitle: const Text("Tap to open"),
        trailing: IconButton(
          onPressed: () async {
            await ref.delete();

            const GetSnackBar snackBar = GetSnackBar(
              message: "File Deleted Successfully",
              duration: Duration(seconds: 4),
              backgroundColor: Colors.green,
            );
            Get.showSnackbar(snackBar);
          },
          icon: const Icon(Icons.delete_outline),
        ),
        onTap: () async {
          final String url = await controller.getDownloadURL(ref: ref);
          final File file = await controller.getSingleFile(url: url);
          final OpenResult openResult = await controller.openFile(file: file);

          log("openResult.message: ${openResult.message}");
        },
      ),
    );
  }

  Widget uploadButton() {
    return UploadButton(
      onUploadStarted: (UploadTask task) {},
      onUploadComplete: (Reference ref) {
        const GetSnackBar snackBar = GetSnackBar(
          message: "File Added Successfully",
          duration: Duration(seconds: 4),
          backgroundColor: Colors.green,
        );
        Get.showSnackbar(snackBar);
      },
      onError: (Object? error, StackTrace? stackTrace) {
        final GetSnackBar snackBar = GetSnackBar(
          message: error.toString(),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.red,
        );
        Get.showSnackbar(snackBar);
      },
    );
  }
}
