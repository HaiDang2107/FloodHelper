import 'package:flutter/material.dart';

import '../../theme/authority_theme.dart';

class NewAnnouncementOverview extends StatelessWidget {
  const NewAnnouncementOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE1E6F4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 46,
              color: AuthorityTheme.brandBlue.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 12),
            Text(
              'Compose a new announcement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Fill title, caption, and attach a file before publishing to the ward audience.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF667085),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
