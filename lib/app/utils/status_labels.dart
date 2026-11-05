import 'package:flutter/material.dart';
import 'package:pune_metro_guide/app/theme/app_colors.dart';

class StatusPresentation {
  const StatusPresentation(this.label, this.color, this.explanation);

  final String label;
  final Color color;
  final String explanation;
}

StatusPresentation operationalStatus(String status) {
  switch (status) {
    case 'operational':
      return const StatusPresentation(
        'Operational',
        AppColors.success,
        'Open to passengers in the official source used for this record.',
      );
    case 'partially_operational':
      return const StatusPresentation(
        'Partly operational',
        AppColors.info,
        'The corridor has passenger service, but not every station is open.',
      );
    case 'not_open':
      return const StatusPresentation(
        'Not open',
        AppColors.warning,
        'The station exists on the route but is not marked open for passengers.',
      );
    case 'reported_open':
      return const StatusPresentation(
        'Reported open',
        AppColors.info,
        'A secondary source reported this station open. The operator list did not confirm it.',
      );
    case 'reported_closed':
      return const StatusPresentation(
        'Reported not open',
        AppColors.warning,
        'A secondary source reported this station closed. The operator list did not confirm it.',
      );
    case 'under_construction':
      return const StatusPresentation(
        'Under construction',
        AppColors.textSecondaryLight,
        'Official pages describe this section as under construction.',
      );
    case 'planned':
      return const StatusPresentation(
        'Planned',
        AppColors.textSecondaryLight,
        'Published as a project station. Not open to passengers.',
      );
    case 'suspended':
      return const StatusPresentation(
        'Suspended',
        AppColors.error,
        'Service is suspended in the stored record.',
      );
    default:
      return const StatusPresentation(
        'Status unpublished',
        AppColors.textSecondaryLight,
        'No operational status is stored for this record.',
      );
  }
}

String verificationLabel(String status) {
  switch (status) {
    case 'official':
      return 'Official';
    case 'official_inferred':
      return 'Official, inferred';
    case 'operator_published':
      return 'Operator published';
    case 'operator_map_embed':
      return 'Operator map';
    case 'secondary':
      return 'Secondary source';
    case 'historical_official':
      return 'Older official document';
    case 'unconfirmed':
      return 'Unconfirmed';
    case 'manual_review':
      return 'Manually reviewed';
    case 'mixed':
      return 'Mixed sources';
    case 'unavailable':
      return 'Unavailable';
    default:
      return status;
  }
}
