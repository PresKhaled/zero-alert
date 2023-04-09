/*
* This file is a part of "SimpleAlert" project.
* Khaled Mohsen <pres.kbayomy@gmail.com>
* Copyrights (BSD-3-Clause), LICENSE.
*/
import 'package:flutter/material.dart';
import 'package:simple_alert/src/progress_bar.dart';

import '../simple_alert.dart';
import 'alert.dart';
import 'constants.dart';
import 'mixins/OpacityAnimationMixin.dart';
import 'mixins/WidthAnimationMixin.dart';

/// Regular alert with preset colors for some common situations.
///
/// The parameters [context], and [label] are mandatory.
class SimpleAlert with OpacityAnimationMixin, WidthAnimationMixin {
  final BuildContext context;
  final String title;
  final String? description;
  final Alignment? alignment;
  final SimpleAlertShape? shape;
  final BorderRadius? borderRadius;
  final Brightness? brightness;
  final SimpleAlertType? type;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final SimpleAlertDuration? duration;
  final Duration? customDuration;
  final Duration animatedOpacityDuration;
  final bool loading;
  final bool centerContent;
  final bool closeOnPress;
  final bool withClose;
  final bool withProgressBar;
  final List<IconButton>? actions;
  final ValueNotifier<bool>? removalSignal;

  late final ShapeBorder selectedShape;
  late final OverlayEntry _overlayEntry;
  late final Future _delayedFuture;
  late final SimpleAlertType simpleAlertType = (type ?? SimpleAlertPreferences().type);
  late final Brightness simpleAlertBrightness = (brightness ?? Theme.of(context).brightness);
  bool closing = false;

  SimpleAlert({
    required this.context,
    required this.title,
    this.description,
    this.alignment,
    this.shape,

    /// Has the priority over [shape].
    this.borderRadius,
    this.brightness,
    this.type,

    /// Has the priority over [type].
    this.backgroundColor,

    /// Has the priority over [SimpleAlertPreferences().titleStyle] and [SimpleAlertPreferences().descriptionStyle].
    this.foregroundColor,
    this.duration,
    this.customDuration,
    this.animatedOpacityDuration = const Duration(milliseconds: 300),

    /// Has the priority over the icon.
    this.loading = false,
    this.centerContent = false,
    this.closeOnPress = true,
    this.withClose = false,
    /// Has the priority over [withClose].
    this.withProgressBar = false,
    this.actions,
    this.removalSignal,
  }) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Alert(
        child: _build(context),
        animationController: opacityAnimationController,
        animatedOpacityDuration: animatedOpacityDuration,
      ),
    );

    Overlay.of(context).insert(_overlayEntry);

    // Wait for initializing.
    opacityAnimationController.addListener(() {
      final AnimationController? controller = opacityAnimationController.value;

      if (controller != null) controller.forward();
    });

    // Wait for initializing.
    widthAnimationController.addListener(() {
      final AnimationController? controller = widthAnimationController.value;

      if (controller != null) controller.forward();
    });

    _delayedFuture = Future.delayed(_getDuration()).whenComplete(() => _close());

    if (removalSignal != null) {
      removalSignal!.addListener(() {
        if (_overlayEntry.mounted && removalSignal!.value) {
          _close();
        }
      });
    }
  }

  SimpleAlert.loading({
    required BuildContext context,
    required String title,
    SimpleAlertShape? shape,
    BorderRadius? borderRadius,
    ValueNotifier<bool>? removalSignal,
  }) : this(
          context: context,
          shape: shape,
          borderRadius: borderRadius,
          title: title,
          loading: true,
          closeOnPress: false,
          removalSignal: removalSignal,
        );

  Widget _build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final double _alertWidth = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Align(
        alignment: (alignment ?? SimpleAlertPreferences().alignment),
        child: Container(
          width: _alertWidth,
          margin: const EdgeInsets.symmetric(vertical: 41.0),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ClipRRect(
            borderRadius: _getBorderRadius(),
            child: Material(
              color: _getBackgroundColor(),
              /*textStyle: const TextStyle(
                color: Colors.white,
              ),*/
              child: InkWell(
                onTap: ((closeOnPress && !withProgressBar) ? () => _close() : null),
                splashColor: ((closeOnPress && !withProgressBar) ? null : Colors.transparent),
                focusColor: ((closeOnPress && !withProgressBar) ? null : Colors.transparent),
                child: GestureDetector(
                  onTapDown: (withProgressBar
                      ? (TapDownDetails tapDownDetails) {
                          if (widthAnimationController.hasListeners && widthAnimationController.value != null) {
                            widthAnimationController.value!.stop(canceled: false);
                          }
                        }
                      : null),
                  onTapUp: (withProgressBar
                      ? (TapUpDetails tapUpDetails) {
                          if (widthAnimationController.hasListeners && widthAnimationController.value != null) {
                            widthAnimationController.value!.forward();
                          }
                        }
                      : null),
                  child: Padding(
                    padding: const EdgeInsets.all(11.0),
                    child: Theme(
                      data: themeData.copyWith(
                        iconTheme: themeData.iconTheme.copyWith(color: _getForegroundColor()),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                // Loading
                                if (loading)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 9.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.white70,
                                      child: SizedBox(
                                        width: 17.0,
                                        height: 17.0,
                                        child: CircularProgressIndicator(
                                          color: _getBackgroundColor(),
                                          strokeWidth: 2.0,
                                        ),
                                      ),
                                      radius: 15.0,
                                    ),
                                  ),

                                // Icon
                                if (!loading)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 9.0),
                                    child: _getIcon(),
                                  ),

                                // Texts
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Title and description.
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              (centerContent ? CrossAxisAlignment.center : CrossAxisAlignment.start),
                                          children: [
                                            Text(
                                              title,
                                              style: (SimpleAlertPreferences().titleStyle as TextStyle).copyWith(
                                                color: _getForegroundColor(),
                                              ),
                                            ),
                                            if (description != null) SizedBox(height: 5.0),
                                            if (description != null)
                                              Text(
                                                description!,
                                                style:
                                                    (SimpleAlertPreferences().descriptionStyle as TextStyle).copyWith(
                                                  color: _getForegroundColor(),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Actions
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 92.0),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (actions != null) ...actions!,

                                              // Close
                                              if (withClose)
                                                IconButton(
                                                  onPressed: () => _close(),
                                                  icon: Icon(SimpleAlertPreferences().icons.close),
                                                  splashRadius: ICON_BUTTON_SPLASH_RADIUS,
                                                  tooltip: SimpleAlertPreferences().closeTooltip,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (withProgressBar)
                            Flexible(
                              child: ProgressBar(
                                animationController: widthAnimationController,
                                alertWidth: _alertWidth,
                                alertDuration: _getDuration(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Get the specified duration.
  ///
  /// Note: [customDuration] has the priority over the [duration].
  Duration _getDuration() {
    if (customDuration != null) return customDuration!;

    final SimpleAlertDuration simpleAlertDuration = (duration ?? SimpleAlertPreferences().duration);

    switch (simpleAlertDuration) {
      case SimpleAlertDuration.quick:
        return const Duration(seconds: 3);

      case SimpleAlertDuration.long:
        return const Duration(seconds: 7);

      case SimpleAlertDuration.day:
        return const Duration(days: 1);

      case SimpleAlertDuration.medium:
      default:
        return const Duration(seconds: 5);
    }
  }

  /// Get the appropriate shadow values based on the current [Brightness].
  /*Map<String, dynamic> _getShadowValues() {
    final Brightness currentContextBrightness = Theme.of(context).brightness;
    const double elevation = 7.0;
    const Color shadowLightColor = Colors.black45;
    const Color shadowDarkColor = Colors.black26;

    switch (brightness) {
      case SimpleAlertBrightness.dark:
        return {
          'shadowColor': shadowDarkColor,
          'elevation': elevation,
        };

      case SimpleAlertBrightness.light:
        return {
          'shadowColor': shadowLightColor,
          'elevation': elevation,
        };

      case SimpleAlertBrightness.system:
      default:
        return {
          'shadowColor': (currentContextBrightness == Brightness.light) ? shadowLightColor : shadowDarkColor,
          'elevation': elevation,
        };
    }
  }*/

  /// Get the alert background color.
  Color _getBackgroundColor() {
    if (backgroundColor != null) return backgroundColor!;

    final bool light = (simpleAlertBrightness == Brightness.light);

    switch (simpleAlertType) {
      case SimpleAlertType.normal:
        return (light ? const Color.fromRGBO(105, 105, 105, 1.0) : const Color.fromRGBO(229, 228, 226, 1.0));

      case SimpleAlertType.success:
        return (light ? const Color.fromRGBO(46, 139, 87, 1.0) : const Color.fromRGBO(80, 200, 120, 1.0));

      case SimpleAlertType.warning:
        return (light ? const Color.fromRGBO(239, 155, 15, 1.0) : const Color.fromRGBO(255, 191, 0, 1.0));

      case SimpleAlertType.danger:
        return (light ? const Color.fromRGBO(197, 30, 58, 1.0) : const Color.fromRGBO(251, 96, 127, 1.0));

      case SimpleAlertType.info:
      default:
        return (light ? const Color.fromRGBO(34, 76, 152, 1.0) : const Color.fromRGBO(135, 206, 250, 1.0));
    }
  }

  /// Get the alert foreground color.
  Color _getForegroundColor() {
    if (foregroundColor != null) return foregroundColor!;

    switch (simpleAlertBrightness) {
      case Brightness.dark:
        return Colors.black;

      case Brightness.light:
      default:
        return Colors.white;
    }
  }

  /// Get the alert border radius.
  ///
  /// Note: [borderRadius] has the priority over the [shape].
  BorderRadius _getBorderRadius() {
    final BorderRadius? simpleAlertBorderRadius = (borderRadius ?? SimpleAlertPreferences().borderRadius);

    if (simpleAlertBorderRadius != null) return simpleAlertBorderRadius;

    final SimpleAlertShape simpleAlertShape = (shape ?? SimpleAlertPreferences().shape);

    switch (simpleAlertShape) {
      case SimpleAlertShape.defaultRadius:
        return BorderRadius.circular(BORDER_RADIUS);

      case SimpleAlertShape.sharp:
        return BorderRadius.zero;

      case SimpleAlertShape.rounded:
      default:
        return BorderRadius.circular(255.0);
    }
  }

  /// Get the appropriate alert icon according to its type.
  Icon _getIcon() {
    final SimpleAlertIcons icons = SimpleAlertPreferences().icons;
    final double size = SimpleAlertPreferences().iconsSize;

    switch (simpleAlertType) {
      case SimpleAlertType.normal:
        return Icon(
          icons.normal,
          size: size,
        );

      case SimpleAlertType.success:
        return Icon(
          icons.success,
          size: size,
        );

      case SimpleAlertType.warning:
        return Icon(
          icons.warning,
          size: size,
        );

      case SimpleAlertType.danger:
        return Icon(
          icons.danger,
          size: size,
        );

      case SimpleAlertType.info:
      default:
        return Icon(
          icons.info,
          size: size,
        );
    }
  }

  /// Close the alert.
  void _close() {
     // The close button or the alarm can be pressed more than once because the degree of opacity (animation) is constantly changing, which will cause the function to run more than once and cause errors.
    if (closing) return;

    closing = true;

    widthAnimationController.value?.removeListener(() {});
    widthAnimationController.value?.dispose();
    widthAnimationController.removeListener(() {});
    widthAnimationController.dispose();

    opacityAnimationController.value!.reverse().whenComplete(() {
      opacityAnimationController.value!.removeListener(() {});
      opacityAnimationController.value!.dispose();
      opacityAnimationController.removeListener(() {});
      opacityAnimationController.dispose();

      _delayedFuture.ignore();

      _overlayEntry.remove();
    });
  }
}
