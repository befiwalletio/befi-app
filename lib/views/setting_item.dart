import 'package:cube/utils/utils_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SettingItem extends StatelessWidget {
  final Widget left;
  final Widget right;
  final VoidCallback onPressed;

  const SettingItem({Key key, this.left, this.right, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color background = Get.isDarkMode ? Colors.black : Colors.white;
    return Material(
      color: background,
      child: InkWell(
        onTap: () {
          if (onPressed != null) {
            onPressed();
          }
        },
        child: Container(
          padding: SizeUtil.padding(all: 15),
          child: Row(
            children: [
              left ??
                  SizedBox(
                    width: 0,
                    height: 0,
                  ),
              Spacer(),
              right ??
                  SizedBox(
                    width: 0,
                    height: 0,
                  )
            ],
          ),
        ),
      ),
    );
  }
}
