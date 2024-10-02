import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? text;
  final Color? textColor;

  const LoadingWidget({
    super.key,
    this.size,
    this.color,
    this.text,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: size ?? 25,
            width: size ?? 25,
            child: Align(
              alignment: Alignment.center,
              child: Platform.isIOS
                  ? FractionalTranslation(
                translation: const Offset(0, 0.30),
                child: CupertinoActivityIndicator(
                  color: color ?? Theme.of(context).primaryColor,
                ),
              )
                  : FractionalTranslation(
                translation: const Offset(0, 0.30),
                child: CupertinoActivityIndicator(
                  color: color ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (text != null)
            Text(
              "$text\nPlease Wait...",
              textAlign: TextAlign.center,

            )
          else
            const SizedBox.shrink()
        ],
      ),
    );
  }
}
