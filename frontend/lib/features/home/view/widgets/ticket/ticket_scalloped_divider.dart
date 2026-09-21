import 'package:flutter/material.dart';

/// Dashed divider with scalloped notch cutouts on the left and right edges
class TicketScallopedDivider extends StatelessWidget {
  final bool isDark;

  const TicketScallopedDivider({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: List.generate(
                (constraints.constrainWidth() / 10).floor(),
                (index) => Expanded(
                  child: Container(
                    height: 1.5,
                    color: index % 2 == 0
                        ? (isDark
                            ? const Color(0xFF2C313C)
                            : const Color(0xffE2E8F0))
                        : Colors.transparent,
                  ),
                ),
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 16,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF12161E)
                    : const Color(0xffF7F8FC),
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(16),
                ),
              ),
            ),
            Container(
              width: 16,
              height: 32,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF12161E)
                    : const Color(0xffF7F8FC),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
