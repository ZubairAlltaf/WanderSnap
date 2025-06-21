import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class RoundButton extends StatelessWidget {
  final String title;
  final bool loading;
  final VoidCallback onTap;
  final Color? color; // Add this
  final TextStyle? textStyle; // Add this

  const RoundButton({
    super.key,
    required this.title,
    required this.loading,
    required this.onTap,
    this.color,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.deepPurple, // Default color
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: loading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
        title,
        style: textStyle ?? const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}