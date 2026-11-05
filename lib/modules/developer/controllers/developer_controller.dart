import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/data/repositories/admin_repository.dart';
import 'package:pune_metro_guide/data/services/import_service.dart';
import 'package:pune_metro_guide/data/services/pdf_extraction_service.dart';
import 'package:pune_metro_guide/data/services/web_extraction_service.dart';
import 'package:pune_metro_guide/models/data_source_model.dart';

class DeveloperController extends GetxController {
  final sources = <DataSourceModel>[].obs;
  final conflicts = <DataConflictModel>[].obs;
  final logs = <ImportLogModel>[].obs;
  final audit = Rxn<AuditSummary>();
  final checks = <SourceCheckResult>[].obs;
  final documents = <RejectedDocument>[].obs;
  final busy = false.obs;
  final message = RxnString();
  final stationCode = ''.obs;
  final status = 'operational'.obs;
  final note = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    final admin = Get.find<AdminRepository>();
    sources.assignAll(await admin.sources());
    conflicts.assignAll(await admin.conflicts());
    logs.assignAll(await admin.logs());
    audit.value = await admin.audit();
    final asset = await Get.find<ImportService>().loadAsset();
    documents.assignAll(
      Get.find<PdfExtractionService>().describe(
        (asset['rejected_documents'] as List).cast<Map>().map(Map<String, dynamic>.from).toList(),
      ),
    );
  }

  Future<void> checkSources() async {
    busy.value = true;
    message.value = 'Checking public pages. Stored rows are not being overwritten.';
    try {
      final asset = await Get.find<ImportService>().loadAsset();
      final rows = (asset['source_checks'] as List).cast<Map>().map(Map<String, dynamic>.from).toList();
      checks.assignAll(await Get.find<WebExtractionService>().checkPublishedPages(rows));
      final failed = checks.where((check) => !check.matches).length;
      await Get.find<AdminRepository>().addLog(
        failed == 0 ? 'info' : 'warning',
        'Source check finished. $failed page(s) did not match the expected phrases.',
      );
      message.value = failed == 0
          ? 'Every checked page still contains the expected phrases.'
          : '$failed page(s) differed or could not be read. The database was not changed.';
      await load();
    } catch (caught) {
      message.value = 'Source check failed. $caught';
    } finally {
      busy.value = false;
    }
  }

  Future<void> checkDocuments() async {
    busy.value = true;
    try {
      documents.assignAll(await Get.find<PdfExtractionService>().checkHeaders(documents));
      message.value = 'Document headers were checked. Their contents were not imported.';
    } finally {
      busy.value = false;
    }
  }

  Future<void> importFile() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    busy.value = true;
    try {
      final report = await Get.find<ImportService>().importJson(utf8.decode(bytes), origin: 'developer import');
      message.value = 'Imported ${report.datasetVersion}. Manual rows skipped: ${report.skippedManual}.';
      await load();
    } catch (caught) {
      message.value = 'Import rejected.\n$caught';
    } finally {
      busy.value = false;
    }
  }

  Future<void> review(int id) async {
    await Get.find<AdminRepository>().markConflictReviewed(id);
    await load();
  }

  Future<void> saveCorrection() async {
    if (stationCode.value.trim().isEmpty || note.value.trim().isEmpty) {
      message.value = 'A station code and a note are required before a manual correction is saved.';
      return;
    }
    await Get.find<AdminRepository>().correctStationStatus(
      stationCode: stationCode.value.trim(),
      operationalStatus: status.value,
      note: note.value.trim(),
    );
    message.value = 'Correction saved and marked manual. Later imports will not overwrite it.';
    await load();
  }
}
