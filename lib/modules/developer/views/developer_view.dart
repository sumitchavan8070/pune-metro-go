import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pune_metro_guide/app/theme/app_dimensions.dart';
import 'package:pune_metro_guide/app/utils/formatters.dart';
import 'package:pune_metro_guide/app/utils/status_labels.dart';
import 'package:pune_metro_guide/modules/developer/controllers/developer_controller.dart';

class DeveloperView extends GetView<DeveloperController> {
  const DeveloperView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data management')),
      body: Obx(() {
        final audit = controller.audit.value;
        return ListView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          children: [
            const Text('This screen is outside the passenger tabs. It reviews sources and does not invent missing facts.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: controller.busy.value ? null : controller.checkSources,
                  child: const Text('Check public pages'),
                ),
                OutlinedButton(
                  onPressed: controller.busy.value ? null : controller.checkDocuments,
                  child: const Text('Check document links'),
                ),
                OutlinedButton(
                  onPressed: controller.busy.value ? null : controller.importFile,
                  child: const Text('Import JSON'),
                ),
              ],
            ),
            if (controller.message.value != null) ...[
              const SizedBox(height: 12),
              Text(controller.message.value!),
            ],
            const SizedBox(height: 16),
            Text('Audit', style: Theme.of(context).textTheme.titleMedium),
            if (audit == null)
              const Text('Audit is loading.')
            else ...[
              Text('${audit.stationCount} stations, ${audit.operationalCount} open or reported open.'),
              Text('${audit.fareRows} fare rows. ${audit.openConflicts} open conflicts.'),
              Text('Missing coordinates: ${audit.missingCoordinates.isEmpty ? 'none' : audit.missingCoordinates.join(', ')}'),
              Text('Same normalised names: ${audit.duplicateNames.isEmpty ? 'none' : audit.duplicateNames.join('; ')}'),
              Text('Sequence issues: ${audit.sequenceIssues.isEmpty ? 'none' : audit.sequenceIssues.join('; ')}'),
              const Text('Fare coverage is empty until a verified matrix is imported. The calculator says so instead of guessing.'),
            ],
            const SizedBox(height: 16),
            Text('Sources', style: Theme.of(context).textTheme.titleMedium),
            for (final source in controller.sources)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(source.sourceName),
                subtitle: Text(
                  '${verificationLabel(source.verificationStatus)} · extracted ${formatDate(source.extractedAt)}\n${source.sourceUrl ?? ''}\n${source.notes ?? ''}',
                ),
              ),
            const SizedBox(height: 8),
            Text('Page checks', style: Theme.of(context).textTheme.titleMedium),
            if (controller.checks.isEmpty)
              const Text('No page check has been run in this session.')
            else
              for (final check in controller.checks)
                Text(
                  '${check.sourceKey}: ${check.matches ? 'still matches' : 'needs review'}'
                  '${check.missingTerms.isEmpty ? '' : ' missing ${check.missingTerms.join(', ')}'}'
                  '${check.message == null ? '' : ' ${check.message}'}',
                ),
            const SizedBox(height: 12),
            Text('Conflicts', style: Theme.of(context).textTheme.titleMedium),
            for (final conflict in controller.conflicts)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${conflict.entityKey} · ${conflict.fieldName} · ${conflict.status}'),
                      Text(conflict.valueA ?? ''),
                      Text(conflict.valueB ?? ''),
                      if (conflict.notes != null) Text(conflict.notes!),
                      if (conflict.status != 'reviewed')
                        TextButton(
                          onPressed: () => controller.review(conflict.id),
                          child: const Text('Mark reviewed'),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text('Manual correction', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Station code, for example MM-RNG'),
              onChanged: (value) => controller.stationCode.value = value,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: controller.status.value,
              decoration: const InputDecoration(labelText: 'Operational status'),
              items: const [
                DropdownMenuItem(value: 'operational', child: Text('Operational')),
                DropdownMenuItem(value: 'not_open', child: Text('Not open')),
                DropdownMenuItem(value: 'reported_open', child: Text('Reported open')),
                DropdownMenuItem(value: 'reported_closed', child: Text('Reported not open')),
                DropdownMenuItem(value: 'under_construction', child: Text('Under construction')),
                DropdownMenuItem(value: 'planned', child: Text('Planned')),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.status.value = value;
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(labelText: 'Why this correction is being made'),
              onChanged: (value) => controller.note.value = value,
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: controller.saveCorrection, child: const Text('Save correction')),
            const SizedBox(height: 16),
            Text('Documents not imported as current data', style: Theme.of(context).textTheme.titleMedium),
            for (final document in controller.documents)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(document.title),
                subtitle: Text(
                  '${document.reason}\n${document.url}'
                  '${document.reachable == null ? '' : document.reachable! ? '\nLink responded.' : '\nLink did not respond.'}',
                ),
              ),
            const SizedBox(height: 12),
            Text('Import log', style: Theme.of(context).textTheme.titleMedium),
            for (final log in controller.logs)
              Text('${formatDate(log.createdAt)} · ${log.level}: ${log.message}'),
          ],
        );
      }),
    );
  }
}
