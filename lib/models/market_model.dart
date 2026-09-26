class MarketModel {
  final String id;
  final String name;
  final String address;
  final String gpsCoordinates;
  final String operatingHours;
  final bool activeStatus;
  final String? description;

  MarketModel({
    required this.id,
    required this.name,
    required this.address,
    required this.gpsCoordinates,
    required this.operatingHours,
    this.activeStatus = true,
    this.description,
  });

  factory MarketModel.fromMap(String id, Map<String, dynamic> map) {
    return MarketModel(
      id: id,
      name: map['name'] ?? map['Market_Name'] ?? map['marketName'] ?? '',
      address: map['address'] ?? map['Address'] ?? '',
      gpsCoordinates:
          map['gpsCoordinates'] ??
          map['GPS_Coordinates'] ??
          map['location'] ??
          '',
      operatingHours:
          map['operatingHours'] ??
          map['Operating_Hours'] ??
          '8:00 AM - 6:00 PM',
      activeStatus: map['activeStatus'] ?? map['Active_Status'] ?? true,
      description: map['description'] ?? map['Description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'Market_Name': name,
      'address': address,
      'Address': address,
      'gpsCoordinates': gpsCoordinates,
      'GPS_Coordinates': gpsCoordinates,
      'operatingHours': operatingHours,
      'Operating_Hours': operatingHours,
      'activeStatus': activeStatus,
      'Active_Status': activeStatus,
      'description': description,
    };
  }

  MarketModel copyWith({
    String? id,
    String? name,
    String? address,
    String? gpsCoordinates,
    String? operatingHours,
    bool? activeStatus,
    String? description,
  }) {
    return MarketModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
      operatingHours: operatingHours ?? this.operatingHours,
      activeStatus: activeStatus ?? this.activeStatus,
      description: description ?? this.description,
    );
  }
}
