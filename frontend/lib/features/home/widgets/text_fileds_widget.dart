import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFiledsWidget extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subTitle;
  final IconButton? btn;
  const TextFiledsWidget({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subTitle,
    this.btn,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: isDarkMode ? const Color(0xFF2C313C) : const Color(0xffF4F4F7),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isDarkMode
              ? const Color(0xFF1E3A2F)
              : const Color(0xffD4F3E2),
          child: Icon(leadingIcon, size: 20, color: const Color(0xff4FD18B)),
        ),
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: isDarkMode ? const Color(0xFF94A3B8) : Colors.black87,
          ),
        ),
        subtitle: TextField(
          cursorHeight: 15,
          readOnly: true,
          enabled: false,
          cursorColor: const Color(0xff4FD18B),
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: subTitle,
            hintStyle: GoogleFonts.dmSans(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : const Color(0xff64748B),
            ),
            isDense: true,
          ),
        ),
        trailing: btn,
      ),
    );
  }
}
