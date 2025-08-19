import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showToast(String title, ToastificationType type, {String? description}) {
  toastification.show(
    title: Text(title),
    description: description != null ? Text(description) : null,
    type: type,
    style: ToastificationStyle.flat,
    autoCloseDuration: const Duration(seconds: 3),
    alignment: Alignment.topRight,
    animationBuilder: (context, animation, alignment, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
