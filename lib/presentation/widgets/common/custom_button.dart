import 'package:flutter/material.dart';

enum ButtonSize { small, medium, large }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size;
  final bool isOutlined;
  final bool isDisabled;
  final IconData? icon;
  final bool isLoading;
  final Color? color;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.size = ButtonSize.medium,
    this.isOutlined = false,
    this.isDisabled = false,
    this.icon,
    this.isLoading = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define sizes
    final Map<ButtonSize, double> heights = {
      ButtonSize.small: 36.0,
      ButtonSize.medium: 48.0,
      ButtonSize.large: 56.0,
    };

    final Map<ButtonSize, EdgeInsets> paddings = {
      ButtonSize.small: const EdgeInsets.symmetric(horizontal: 16.0),
      ButtonSize.medium: const EdgeInsets.symmetric(horizontal: 24.0),
      ButtonSize.large: const EdgeInsets.symmetric(horizontal: 32.0),
    };

    final Map<ButtonSize, double> fontSizes = {
      ButtonSize.small: 14.0,
      ButtonSize.medium: 16.0,
      ButtonSize.large: 18.0,
    };

    // Determine button style based on type
    ButtonStyle style;
    if (isOutlined) {
      style = OutlinedButton.styleFrom(
        side: BorderSide(color: isDisabled ? theme.disabledColor : (color ?? theme.primaryColor)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      );
    } else {
      style = ElevatedButton.styleFrom(
        backgroundColor: color ?? theme.primaryColor,
        disabledBackgroundColor: theme.disabledColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      );
    }

    // Content
    Widget content;
    if (isLoading) {
      content = SizedBox(
        height: fontSizes[size],
        width: fontSizes[size],
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            isOutlined ? (color ?? theme.primaryColor) : Colors.white,
          ),
        ),
      );
    } else {
      // Text with optional icon
      if (icon != null) {
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: fontSizes[size]! * 1.2,
              color: isOutlined ? (color ?? theme.primaryColor) : Colors.white,
            ),
            const SizedBox(width: 8.0),
            Text(
              text,
              style: TextStyle(
                fontSize: fontSizes[size],
                color: isOutlined ? (color ?? theme.primaryColor) : Colors.white,
              ),
            ),
          ],
        );
      } else {
        content = Text(
          text,
          style: TextStyle(
            fontSize: fontSizes[size],
            color: isOutlined ? (color ?? theme.primaryColor) : Colors.white,
          ),
        );
      }
    }

    // Build button based on type
    if (isOutlined) {
      return SizedBox(
        height: heights[size],
        child: OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: style,
          child: Padding(
            padding: paddings[size]!,
            child: content,
          ),
        ),
      );
    } else {
      return SizedBox(
        height: heights[size],
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: style,
          child: Padding(
            padding: paddings[size]!,
            child: content,
          ),
        ),
      );
    }
  }
}