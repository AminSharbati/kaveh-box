enum ToolCategory {
  calculation,
  finance,
  conversion,
  time,
  security,
  utility,
  text,
  measurement,
  personal,
  fun,
}

enum ToolType {
  calculator,
  percentage,
  discount,
  splitBill,
  statistics,
  unitConverter,
  temperatureConverter,
  timer,
  stopwatch,
  dateDifference,
  dateConverter,
  countdown,
  passwordGenerator,
  qrGenerator,
  qrScanner,
  textCounter,
  textCleaner,
  textCaseConverter,
  areaCalculator,
  quickNote,
  randomPicker,
}

class KavehTool {
  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final ToolCategory category;
  final ToolType type;
  final List<String> keywords;
  final bool isQuickAccess;

  const KavehTool({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.category,
    required this.type,
    this.keywords = const [],
    this.isQuickAccess = false,
  });
}