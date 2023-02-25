class ChartModel {
  final String? id;
  final int? analogSignal, digitalSignal, analogRefSignal, time;

  const ChartModel({
    this.id,
    this.analogSignal,
    this.analogRefSignal,
    this.digitalSignal,
    this.time,
  });

  ChartModel fromJson(Map<String, dynamic> json) => ChartModel.fromJson(json);

  factory ChartModel.fromJson(Map<String, dynamic> json) {
    return ChartModel(
      id: json['id'] as String?,
      analogSignal: json['analogSignal'] as int?,
      analogRefSignal: json['analogRefSignal'] as int?,
      digitalSignal: json['digitalSignal'] as int?,
      time: json['time'] as int?,
    );
  }

  Map<String, dynamic>? toJson() {
    return {};
  }
}
