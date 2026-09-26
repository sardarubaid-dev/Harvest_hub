class PickupSlotModel {
  final String id;
  final String marketId;
  final String? farmerId;
  final String date;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final int maxBookings;
  final int currentBookings;

  PickupSlotModel({
    required this.id,
    required this.marketId,
    this.farmerId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.maxBookings = 10,
    this.currentBookings = 0,
  });

  String get slotDisplay => '$date ($startTime - $endTime)';

  factory PickupSlotModel.fromMap(String id, Map<String, dynamic> map) {
    return PickupSlotModel(
      id: id,
      marketId: map['marketId'] ?? map['Market_Id'] ?? '',
      farmerId: map['farmerId'] ?? map['Farmer_Id'],
      date: map['date'] ?? map['Date'] ?? '',
      startTime: map['startTime'] ?? map['Start_Time'] ?? '',
      endTime: map['endTime'] ?? map['End_Time'] ?? '',
      isAvailable: map['isAvailable'] ?? map['Is_Available'] ?? true,
      maxBookings: map['maxBookings'] ?? 10,
      currentBookings: map['currentBookings'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'marketId': marketId,
      'Market_Id': marketId,
      'farmerId': farmerId,
      'Farmer_Id': farmerId,
      'date': date,
      'Date': date,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'maxBookings': maxBookings,
      'currentBookings': currentBookings,
    };
  }

  PickupSlotModel copyWith({
    String? id,
    String? marketId,
    String? farmerId,
    String? date,
    String? startTime,
    String? endTime,
    bool? isAvailable,
    int? maxBookings,
    int? currentBookings,
  }) {
    return PickupSlotModel(
      id: id ?? this.id,
      marketId: marketId ?? this.marketId,
      farmerId: farmerId ?? this.farmerId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      maxBookings: maxBookings ?? this.maxBookings,
      currentBookings: currentBookings ?? this.currentBookings,
    );
  }
}
