import 'package:flutter/material.dart';
import 'dart:ui';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final double blurRadius;
  final double borderWidth;
  final LinearGradient? linearGradient;
  final LinearGradient? borderGradient;
  final EdgeInsetsGeometry? padding;
  final Alignment? alignment;
  final VoidCallback? onTap;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 24,
    this.blurRadius = 20,
    this.borderWidth = 1.5,
    this.linearGradient,
    this.borderGradient,
    this.padding,
    this.alignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Default gradients if none provided
    final defaultLinearGradient = linearGradient ?? LinearGradient(
      colors: [
        colorScheme.primary.withOpacity(0.15),
        colorScheme.secondary.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final defaultBorderGradient = borderGradient ?? LinearGradient(
      colors: [
        Colors.white.withOpacity(0.5),
        Colors.white.withOpacity(0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    Widget container = Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(24),
      alignment: alignment,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: defaultLinearGradient,
        border: Border.all(
          width: borderWidth,
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.1),
            blurRadius: blurRadius,
            spreadRadius: -5,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: blurRadius,
            spreadRadius: -5,
            offset: const Offset(-4, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurRadius * 0.5,
            sigmaY: blurRadius * 0.5,
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      container = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: container,
      );
    }

    return container;
  }
} 