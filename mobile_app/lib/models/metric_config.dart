class MetricConfig {
  final double min;
  final double max;
  final String unit;
  final int divisions;

  final bool showValue;
  final bool showRange;
  final int decimals;

  const MetricConfig({
    required this.min,
    required this.max,
    required this.unit,
    required this.divisions,
    this.showValue = true,
    this.showRange = false,
    this.decimals = 0,
  });
}

const metricConfigs = {
  /// =========================
  /// HEALTH
  /// =========================

  "Nhịp tim": MetricConfig(
    min: 40,
    max: 200,
    unit: "bpm",
    divisions: 4,
    showRange: true,
  ),

  "Nhịp tim nghỉ": MetricConfig(
    min: 40,
    max: 120,
    unit: "bpm",
    divisions: 4,
    showRange: true,
  ),

  "HRV": MetricConfig(
    min: 0,
    max: 200,
    unit: "ms",
    divisions: 4,
    showRange: true,
  ),

  "Huyết áp": MetricConfig(
    min: 60,
    max: 180,
    unit: "mmHg",
    divisions: 4,
    showRange: true,
  ),

  "SpO2": MetricConfig(
    min: 80,
    max: 100,
    unit: "%",
    divisions: 4,
    showRange: true,
  ),

  "Độ bão hòa oxy": MetricConfig(
    min: 80,
    max: 100,
    unit: "%",
    divisions: 4,
    showRange: true,
  ),

  "Nhiệt độ cơ thể": MetricConfig(
    min: 35,
    max: 40,
    unit: "°C",
    divisions: 5,
    decimals: 1,
    showRange: true,
  ),

  "Nhịp thở": MetricConfig(
    min: 10,
    max: 30,
    unit: "rpm",
    divisions: 4,
    showRange: true,
  ),

  "Đường huyết": MetricConfig(
    min: 70,
    max: 200,
    unit: "mg/dL",
    divisions: 4,
    showRange: true,
  ),

  "Cholesterol": MetricConfig(
    min: 100,
    max: 300,
    unit: "mg/dL",
    divisions: 4,
    showRange: true,
  ),

  "Chỉ số BMI": MetricConfig(
    min: 15,
    max: 40,
    unit: "",
    divisions: 5,
    decimals: 1,
    showRange: true,
  ),

  "Mỡ cơ thể": MetricConfig(
    min: 5,
    max: 50,
    unit: "%",
    divisions: 5,
    decimals: 1,
    showRange: true,
  ),

  "Khối lượng cơ": MetricConfig(
    min: 20,
    max: 60,
    unit: "kg",
    divisions: 4,
    decimals: 1,
    showRange: true,
  ),

  "Nước cơ thể": MetricConfig(
    min: 30,
    max: 70,
    unit: "%",
    divisions: 4,
    decimals: 1,
    showRange: true,
  ),

  "Mật độ xương": MetricConfig(
    min: 1,
    max: 3,
    unit: "g/cm³",
    divisions: 4,
    decimals: 2,
    showRange: true,
  ),

  "VO2 Max": MetricConfig(
    min: 20,
    max: 70,
    unit: "ml/kg/min",
    divisions: 5,
    showRange: true,
  ),

  "Mức độ căng thẳng": MetricConfig(
    min: 0,
    max: 100,
    unit: "%",
    divisions: 4,
    showRange: true,
  ),

  "Chỉ số hồi phục": MetricConfig(
    min: 0,
    max: 100,
    unit: "%",
    divisions: 4,
    showRange: true,
  ),

  "Tuổi sinh học": MetricConfig(
    min: 10,
    max: 100,
    unit: "tuổi",
    divisions: 4,
  ),

  "Mức hydrat hóa": MetricConfig(
    min: 0,
    max: 100,
    unit: "%",
    divisions: 4,
    showRange: true,
  ),

  /// =========================
  /// ACTIVITY
  /// =========================

  "Số bước chân": MetricConfig(
    min: 0,
    max: 20000,
    unit: "steps",
    divisions: 5,
  ),

  "Quãng đường": MetricConfig(
    min: 0,
    max: 20,
    unit: "km",
    divisions: 5,
    decimals: 2,
  ),

  "Calo tiêu thụ": MetricConfig(
    min: 0,
    max: 4000,
    unit: "kcal",
    divisions: 4,
  ),

  "Calo khi nghỉ": MetricConfig(
    min: 0,
    max: 2000,
    unit: "kcal",
    divisions: 4,
  ),

  "Calo khi vận động": MetricConfig(
    min: 0,
    max: 3000,
    unit: "kcal",
    divisions: 4,
  ),

  "Thời gian vận động": MetricConfig(
    min: 0,
    max: 180,
    unit: "min",
    divisions: 6,
  ),

  "Thời gian đứng": MetricConfig(
    min: 0,
    max: 24,
    unit: "h",
    divisions: 6,
  ),

  "Số tầng cầu thang": MetricConfig(
    min: 0,
    max: 100,
    unit: "floors",
    divisions: 5,
  ),

  "Tốc độ trung bình": MetricConfig(
    min: 0,
    max: 20,
    unit: "km/h",
    divisions: 5,
    decimals: 1,
  ),

  "Tốc độ tối đa": MetricConfig(
    min: 0,
    max: 30,
    unit: "km/h",
    divisions: 5,
    decimals: 1,
  ),

  "Nhịp bước chạy": MetricConfig(
    min: 100,
    max: 220,
    unit: "spm",
    divisions: 4,
  ),

  "Quãng đường chạy": MetricConfig(
    min: 0,
    max: 20,
    unit: "km",
    divisions: 5,
    decimals: 2,
  ),

  "Quãng đường đi bộ": MetricConfig(
    min: 0,
    max: 20,
    unit: "km",
    divisions: 5,
    decimals: 2,
  ),

  "Thời gian chạy": MetricConfig(
    min: 0,
    max: 180,
    unit: "min",
    divisions: 6,
  ),

  "Thời gian đạp xe": MetricConfig(
    min: 0,
    max: 180,
    unit: "min",
    divisions: 6,
  ),

  "Quãng đường đạp xe": MetricConfig(
    min: 0,
    max: 100,
    unit: "km",
    divisions: 5,
    decimals: 2,
  ),

  "Thời gian bơi": MetricConfig(
    min: 0,
    max: 120,
    unit: "min",
    divisions: 6,
  ),

  "Số vòng bơi": MetricConfig(
    min: 0,
    max: 200,
    unit: "laps",
    divisions: 4,
  ),

  /// =========================
  /// SLEEP
  /// =========================

  "Thời gian ngủ": MetricConfig(
    min: 0,
    max: 12,
    unit: "h",
    divisions: 6,
    decimals: 1,
  ),

  "Chất lượng giấc ngủ": MetricConfig(
    min: 0,
    max: 100,
    unit: "%",
    divisions: 4,
  ),

  "Thời gian ngủ sâu": MetricConfig(
    min: 0,
    max: 5,
    unit: "h",
    divisions: 5,
    decimals: 1,
  ),

  "Thời gian ngủ REM": MetricConfig(
    min: 0,
    max: 4,
    unit: "h",
    divisions: 4,
    decimals: 1,
  ),

  "Thời gian thức": MetricConfig(
    min: 0,
    max: 3,
    unit: "h",
    divisions: 3,
    decimals: 1,
  ),

  "Số lần thức giấc": MetricConfig(
    min: 0,
    max: 20,
    unit: "lần",
    divisions: 4,
  ),
};
