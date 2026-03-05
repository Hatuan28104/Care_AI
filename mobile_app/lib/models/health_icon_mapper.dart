import 'package:flutter/material.dart';

class HealthIcon {
  final IconData icon;
  final Color color;

  const HealthIcon(this.icon, this.color);
}

final Map<String, HealthIcon> healthIconMap = {
  // ===== HEALTH =====
  'Nhịp tim': HealthIcon(Icons.favorite, Colors.red),
  'Huyết áp': HealthIcon(Icons.bloodtype, Colors.redAccent),
  'SpO2': HealthIcon(Icons.monitor_heart, Colors.blue),
  'Nhiệt độ cơ thể': HealthIcon(Icons.thermostat, Colors.orange),
  'Chỉ số BMI': HealthIcon(Icons.fitness_center, Colors.purple),
  'Nhịp thở': HealthIcon(Icons.air, Colors.blueGrey),
  'Nhịp tim nghỉ': HealthIcon(Icons.favorite_outline, Colors.red),
  'HRV': HealthIcon(Icons.monitor_heart_outlined, Colors.indigo),
  'Đường huyết': HealthIcon(Icons.water_drop, Colors.redAccent),
  'Cholesterol': HealthIcon(Icons.opacity, Colors.orange),
  'Mỡ cơ thể': HealthIcon(Icons.accessibility, Colors.purple),
  'Khối lượng cơ': HealthIcon(Icons.sports_gymnastics, Colors.deepPurple),
  'Nước cơ thể': HealthIcon(Icons.water, Colors.blue),
  'Mật độ xương': HealthIcon(Icons.health_and_safety, Colors.grey),
  'VO2 Max': HealthIcon(Icons.speed, Colors.green),
  'Mức độ căng thẳng': HealthIcon(Icons.psychology, Colors.deepOrange),
  'Chỉ số hồi phục': HealthIcon(Icons.healing, Colors.green),
  'Độ bão hòa oxy': HealthIcon(Icons.bubble_chart, Colors.blueAccent),
  'Tuổi sinh học': HealthIcon(Icons.person, Colors.indigo),
  'Mức hydrat hóa': HealthIcon(Icons.water_drop_outlined, Colors.blue),

  // ===== ACTIVITY =====
  'Số bước chân': HealthIcon(Icons.directions_walk, Colors.red),
  'Quãng đường': HealthIcon(Icons.route, Colors.orange),
  'Calo tiêu thụ': HealthIcon(Icons.local_fire_department, Colors.deepOrange),
  'Thời gian vận động': HealthIcon(Icons.fitness_center, Colors.purple),
  'Thời gian đứng': HealthIcon(Icons.accessibility_new, Colors.blue),
  'Số tầng cầu thang': HealthIcon(Icons.stairs, Colors.brown),
  'Thời gian chạy': HealthIcon(Icons.directions_run, Colors.red),
  'Tốc độ trung bình': HealthIcon(Icons.speed, Colors.orange),
  'Tốc độ tối đa': HealthIcon(Icons.speed_outlined, Colors.deepOrange),
  'Nhịp bước chạy': HealthIcon(Icons.multiline_chart, Colors.indigo),
  'Quãng đường chạy': HealthIcon(Icons.directions_run_outlined, Colors.red),
  'Quãng đường đi bộ': HealthIcon(Icons.hiking, Colors.green),
  'Thời gian đạp xe': HealthIcon(Icons.directions_bike, Colors.blue),
  'Quãng đường đạp xe': HealthIcon(Icons.pedal_bike, Colors.blueAccent),
  'Thời gian bơi': HealthIcon(Icons.pool, Colors.cyan),
  'Số vòng bơi': HealthIcon(Icons.water, Colors.cyan),
  'Thời gian ngủ': HealthIcon(Icons.bedtime, Colors.indigo),
  'Chất lượng giấc ngủ': HealthIcon(Icons.auto_graph, Colors.deepPurple),
  'Thời gian ngủ sâu': HealthIcon(Icons.nightlight, Colors.indigo),
  'Thời gian ngủ REM': HealthIcon(Icons.dark_mode, Colors.deepPurple),
  'Thời gian thức': HealthIcon(Icons.wb_sunny, Colors.orange),
  'Số lần thức giấc': HealthIcon(Icons.notifications_active, Colors.red),
  'Thời gian tập luyện': HealthIcon(Icons.sports_gymnastics, Colors.purple),
  'Calo khi nghỉ':
      HealthIcon(Icons.local_fire_department_outlined, Colors.orange),
  'Calo khi vận động':
      HealthIcon(Icons.local_fire_department, Colors.deepOrange),
  'Cường độ vận động': HealthIcon(Icons.show_chart, Colors.red),
  'Thời gian yoga': HealthIcon(Icons.self_improvement, Colors.purple),
  'Thời gian gym': HealthIcon(Icons.fitness_center, Colors.deepPurple),
  'Thời gian thiền': HealthIcon(Icons.spa, Colors.green),
  'Đi bộ nhanh': HealthIcon(Icons.directions_walk, Colors.green),
  'Số lần tập luyện': HealthIcon(Icons.repeat, Colors.blue),
  'Quãng đường leo núi': HealthIcon(Icons.terrain, Colors.brown),
  'Thời gian leo núi': HealthIcon(Icons.landscape, Colors.brown),
  'Thời gian nghỉ': HealthIcon(Icons.hotel, Colors.grey),
  'Chỉ số hoạt động': HealthIcon(Icons.insights, Colors.blue),
  'Thời gian đứng lâu nhất': HealthIcon(Icons.accessibility_new, Colors.indigo),
  'Thời gian ngồi': HealthIcon(Icons.event_seat, Colors.grey),
  'Thời gian di chuyển': HealthIcon(Icons.directions_walk, Colors.blue),
  'Thời gian vận động mạnh': HealthIcon(Icons.flash_on, Colors.red),
  'Thời gian vận động nhẹ': HealthIcon(Icons.directions_walk, Colors.green),
};

HealthIcon getHealthIcon(String name) {
  return healthIconMap[name] ??
      const HealthIcon(Icons.monitor_heart, Colors.blue);
}
