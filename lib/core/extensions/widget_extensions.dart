/// Widget Extension Utilities
///
/// Provides helpful extension methods for common widget operations like padding, sizing, and styling.

import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  /// Add padding to widget
  /// Example: Text('Hello').withPadding(all: 16)
  Widget withPadding({
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left > 0
            ? left
            : horizontal > 0
            ? horizontal
            : all,
        right: right > 0
            ? right
            : horizontal > 0
            ? horizontal
            : all,
        top: top > 0
            ? top
            : vertical > 0
            ? vertical
            : all,
        bottom: bottom > 0
            ? bottom
            : vertical > 0
            ? vertical
            : all,
      ),
      child: this,
    );
  }

  /// Add symmetric padding
  /// Example: Text('Hello').withSymmetricPadding(horizontal: 16, vertical: 8)
  Widget withSymmetricPadding({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Add margin to widget
  /// Example: Text('Hello').withMargin(all: 16)
  Widget withMargin({
    double all = 0,
    double horizontal = 0,
    double vertical = 0,
    double left = 0,
    double right = 0,
    double top = 0,
    double bottom = 0,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: left > 0
            ? left
            : horizontal > 0
            ? horizontal
            : all,
        right: right > 0
            ? right
            : horizontal > 0
            ? horizontal
            : all,
        top: top > 0
            ? top
            : vertical > 0
            ? vertical
            : all,
        bottom: bottom > 0
            ? bottom
            : vertical > 0
            ? vertical
            : all,
      ),
      child: this,
    );
  }

  /// Add background color
  /// Example: Text('Hello').withBackground(Colors.blue)
  Widget withBackground(Color color) {
    return Container(color: color, child: this);
  }

  /// Add border decoration
  /// Example: Text('Hello').withBorder(color: Colors.black, width: 2)
  Widget withBorder({
    Color color = Colors.black,
    double width = 1,
    double borderRadius = 0,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: width),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: this,
    );
  }

  /// Add border radius
  /// Example: Text('Hello').withBorderRadius(16)
  Widget withBorderRadius(double radius) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
  }

  /// Add shadow/elevation
  /// Example: Text('Hello').withElevation(8)
  Widget withElevation(double elevation) {
    return Material(elevation: elevation, child: this);
  }

  /// Add opacity to widget
  /// Example: Text('Hello').withOpacity(0.5)
  Widget withOpacity(double opacity) {
    return Opacity(opacity: opacity, child: this);
  }

  /// Center the widget
  /// Example: Text('Hello').center()
  Widget center() {
    return Center(child: this);
  }

  /// Set fixed width
  /// Example: Text('Hello').withWidth(200)
  Widget withWidth(double width) {
    return SizedBox(width: width, child: this);
  }

  /// Set fixed height
  /// Example: Text('Hello').withHeight(100)
  Widget withHeight(double height) {
    return SizedBox(height: height, child: this);
  }

  /// Set fixed size
  /// Example: Text('Hello').withSize(200, 100)
  Widget withSize(double width, double height) {
    return SizedBox(width: width, height: height, child: this);
  }

  /// Expand widget to fill available space
  /// Example: Text('Hello').expanded()
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }

  /// Make widget flexible
  /// Example: Text('Hello').flexible(flex: 2)
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Make widget take specific fraction of screen
  /// Example: Text('Hello').fractionOfScreen(0.5) → 50% of screen width
  Widget fractionOfScreen(double fraction) {
    return FractionallySizedBox(widthFactor: fraction, child: this);
  }

  /// Add gestures (onTap, onLongPress, etc.)
  /// Example: Text('Hello').onTap(() => print('Tapped'))
  Widget onTap(VoidCallback onPressed, {bool enabled = true}) {
    return GestureDetector(onTap: enabled ? onPressed : null, child: this);
  }

  /// Add onLongPress gesture
  /// Example: Text('Hello').onLongPress(() => print('Long pressed'))
  Widget onLongPress(VoidCallback onPressed) {
    return GestureDetector(onLongPress: onPressed, child: this);
  }

  /// Add tooltip
  /// Example: Text('Hello').withTooltip('Click me')
  Widget withTooltip(String message) {
    return Tooltip(message: message, child: this);
  }

  /// Make widget scrollable if content overflows
  /// Example: Text('Long text').scrollable()
  Widget scrollable({
    ScrollPhysics physics = const AlwaysScrollableScrollPhysics(),
  }) {
    return SingleChildScrollView(physics: physics, child: this);
  }

  /// Wrap widget in SafeArea
  /// Example: Text('Hello').safeArea()
  Widget safeArea({
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: this,
    );
  }

  /// Wrap widget in Visibility
  /// Example: Text('Hello').visibility(isVisible: isLoggedIn)
  Widget visibility({
    required bool isVisible,
    Widget replacement = const SizedBox.shrink(),
  }) {
    return isVisible ? this : replacement;
  }

  /// Add rotation to widget
  /// Example: Text('Hello').rotate(45) // 45 degrees
  Widget rotate(double angle) {
    return Transform.rotate(angle: angle, child: this);
  }

  /// Scale widget
  /// Example: Text('Hello').scale(1.5)
  Widget scale(double scale, {Alignment alignment = Alignment.center}) {
    return Transform.scale(scale: scale, alignment: alignment, child: this);
  }

  /// Translate widget
  /// Example: Text('Hello').translate(dx: 10, dy: 20)
  Widget translate({double dx = 0, double dy = 0}) {
    return Transform.translate(offset: Offset(dx, dy), child: this);
  }

  /// Add background gradient
  /// Example: Container().withGradient([Colors.blue, Colors.purple])
  Widget withGradient(
    List<Color> colors, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: begin, end: end, colors: colors),
      ),
      child: this,
    );
  }

  /// Add box shadow
  /// Example: Text('Hello').withShadow(blurRadius: 8)
  Widget withShadow({
    Color color = const Color(0x1F000000),
    double blurRadius = 3,
    double spreadRadius = 0,
    Offset offset = const Offset(0, 2),
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
            offset: offset,
          ),
        ],
      ),
      child: this,
    );
  }

  /// Add circular shape (make square widget circular)
  /// Example: Container(width: 100, height: 100).circular()
  Widget circular({Color? backgroundColor}) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: this,
    );
  }

  /// Add ripple effect
  /// Example: Text('Hello').withRipple(onTap: () => print('Tapped'))
  Widget withRipple({
    VoidCallback? onTap,
    Color? splashColor,
    Color? highlightColor,
  }) {
    return Material(
      child: InkWell(
        onTap: onTap,
        splashColor: splashColor,
        highlightColor: highlightColor,
        child: this,
      ),
    );
  }

  /// Constrain widget to specific aspect ratio
  /// Example: Image.asset('image.png').withAspectRatio(16 / 9)
  Widget withAspectRatio(double aspectRatio) {
    return AspectRatio(aspectRatio: aspectRatio, child: this);
  }

  /// Make widget half transparent (common opacity)
  Widget halfOpaque() => withOpacity(0.5);

  /// Add large padding
  Widget withLargePadding() => withPadding(all: 24);

  /// Add medium padding
  Widget withMediumPadding() => withPadding(all: 16);

  /// Add small padding
  Widget withSmallPadding() => withPadding(all: 8);
}
