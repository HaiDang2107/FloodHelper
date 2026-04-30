import 'package:flutter/material.dart';

import '../theme/authority_theme.dart';

class AuthorityReviewFrame extends StatelessWidget { // Tạo layout tổng thể, chia làm 2 cột: danh sách và chi tiết
  const AuthorityReviewFrame({
    super.key,
    required this.title,
    required this.filters,
    required this.listContent,
    required this.detailPanel,
  });

  final String title;
  final List<Widget> filters;
  final Widget listContent;
  final Widget detailPanel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AuthorityTheme.textDark,
                    ),
              ),
              if (filters.isNotEmpty) ...[
                const Spacer(),
                ...filters,
              ],
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 1100;
                final listPanel = Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE1E6F4)),
                  ),
                  child: listContent,
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      Expanded(child: listPanel),
                      const SizedBox(height: 16),
                      Expanded(child: detailPanel),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 3, child: listPanel),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: detailPanel),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AuthorityFilterChip extends StatelessWidget {
  const AuthorityFilterChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => onTap(),
        selectedColor: AuthorityTheme.brandBlue,
        labelStyle: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF344054),
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE1E6F4)),
        ),
      ),
    );
  }
}
