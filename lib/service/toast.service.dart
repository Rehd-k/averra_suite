import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(
  String title,
  ToastificationType type, {
  String? description,
  int? duretion,
}) {
  toastification.show(
    title: Text(title),
    description: description != null ? Text(description) : null,
    type: type,
    style: ToastificationStyle.flat,
    autoCloseDuration: Duration(seconds: duretion ?? 3),
    alignment: Alignment.topRight,
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
