/// Spacing tokens built on an 8-point grid.
/// Use these instead of raw double literals anywhere spacing is needed.
abstract final class AppSpacing {
  // ── Base unit ─────────────────────────────────────────────────────────────
  static const double _unit = 4.0;

  // ── Scale ─────────────────────────────────────────────────────────────────
  static const double xxs = _unit; // 4
  static const double xs = _unit * 2; // 8
  static const double sm = _unit * 3; // 12
  static const double md = _unit * 4; // 16
  static const double lg = _unit * 5; // 20
  static const double xl = _unit * 6; // 24
  static const double xxl = _unit * 8; // 32
  static const double xxxl = _unit * 10; // 40
  static const double xxxxl = _unit * 12; // 48

  // ── Named semantic aliases ─────────────────────────────────────────────────
  /// Standard horizontal padding for all screens.
  static const double screenHorizontal = xl; // 24

  /// Standard vertical padding from top of screen.
  static const double screenVertical = xxl; // 32

  /// Space between a label and its input.
  static const double labelToField = xs; // 8

  /// Standard gap between stacked form fields.
  static const double fieldGap = md; // 16

  /// Gap between cards in a grid or list.
  /// Slightly more generous for the floating card aesthetic.
  static const double cardGap = md; // 16 (was 12)

  /// Inner padding of a card.
  /// Comfortable padding for the premium card feel.
  static const double cardPadding = xl; // 24 (was 16)

  /// Height of the primary action button.
  /// Slightly taller for a more premium feel.
  static const double buttonHeight = 58.0; // was 56

  /// Height of secondary / outline button.
  static const double buttonHeightSm = 46.0; // was 44

  // Prevent instantiation
  AppSpacing._();
}
