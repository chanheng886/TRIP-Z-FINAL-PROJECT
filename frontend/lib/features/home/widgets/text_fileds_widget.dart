import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TextFiledsWidget extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subTitle;
  final IconButton? btn;
  final Widget? page;
  const TextFiledsWidget({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subTitle,
    this.btn,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (page != null) {
          Get.to(() => page!);
        }
      },
      child: Card(
        color: Color(0xffF4F4F7),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xffD4F3E2),
            child: Icon(leadingIcon, size: 20, color: Color(0xff4FD18B)),
          ),
          title: Text(title, style: GoogleFonts.dmSans(fontSize: 14)),
          subtitle: TextField(
            cursorHeight: 15,
            readOnly: true,
            enabled: false,
            cursorColor: Color(0xff4FD18B),
            style: GoogleFonts.dmSans(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: subTitle,
              hintStyle: GoogleFonts.dmSans(
                fontSize: 14,
                color: Color(0xff64748B),
              ),
              isDense: true,
            ),
          ),
          trailing: btn,
        ),
      ),
    );
  }
}
