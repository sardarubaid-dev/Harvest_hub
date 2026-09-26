import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/farmer_model.dart';
import '../models/product_model.dart';
import '../models/market_model.dart';
import '../models/customer_model.dart';
import '../models/category_model.dart';
import '../models/pickup_slot_model.dart';
import '../models/order_model.dart';
import '../models/notification_model.dart';
import '../models/cart_item_model.dart';

class DummyData {
  // Simulating JSON data for Categories
  static const List<Map<String, dynamic>> categories = [
    {'id': '1', 'name': 'All', 'icon': Icons.apps},
    {'id': '2', 'name': 'Fruits', 'icon': Icons.apple},
    {'id': '3', 'name': 'Vegetables', 'icon': Icons.eco},
    {'id': '4', 'name': 'Dairy', 'icon': Icons.water_drop},
    {'id': '5', 'name': 'Meat', 'icon': Icons.set_meal},
  ];

  // Simulating JSON data for Fresh Near You (Products)
  static const List<Map<String, dynamic>> freshProducts = [
    {
      'id': 'p1',
      'title': 'Fresh Tomatoes',
      'category': 'VEGETABLES',
      'farmerName': 'Green Valley Farm',
      'price': '280',
      'unit': '/ kg',
      'stockBadge': '12 kg available',
      'isFavorite': false,
      'imageColor': Color(0xFFEF9A9A),
      'imageUrl': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'p2',
      'title': 'Organic Spinach',
      'category': 'VEGETABLES',
      'farmerName': 'Indus Organic Fi...',
      'price': '140',
      'unit': '/ bunch',
      'stockBadge': '8 bunches left',
      'isFavorite': true,
      'imageColor': Color(0xFFA5D6A7),
      'imageUrl': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'p3',
      'title': 'Fresh Carrots',
      'category': 'VEGETABLES',
      'farmerName': 'Sunny Side Farm',
      'price': '150',
      'unit': '/ kg',
      'stockBadge': '20 kg available',
      'isFavorite': false,
      'imageColor': Color(0xFFFFCC80),
      'imageUrl': 'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'p4',
      'title': 'Pure Farm Cow Milk',
      'category': 'DAIRY',
      'farmerName': 'Meadow Dairy F...',
      'price': '220',
      'unit': '/ L',
      'stockBadge': '15 L available',
      'isFavorite': false,
      'imageColor': Color(0xFFD7CCC8),
      'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'p5',
      'title': 'Raw Wildflower Honey',
      'category': 'ORGANIC',
      'farmerName': 'Mountain Bee A...',
      'price': '950',
      'unit': '/ jar',
      'stockBadge': '5 jars left',
      'isFavorite': false,
      'imageColor': Color(0xFFFFE082),
      'imageUrl': 'https://images.unsplash.com/photo-1628151015968-3a4429e9ef04?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'p6',
      'title': 'Juicy Apples',
      'category': 'FRUITS',
      'farmerName': 'Orchard Valley',
      'price': '400',
      'unit': '/ kg',
      'stockBadge': '30 kg available',
      'isFavorite': true,
      'imageColor': Color(0xFFEF5350),
      'imageUrl': 'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'p7',
      'title': 'Fresh Mint',
      'category': 'HERBS',
      'farmerName': 'Green Valley Farm',
      'price': '50',
      'unit': '/ bunch',
      'stockBadge': '40 bunches left',
      'isFavorite': false,
      'imageColor': Color(0xFF81C784),
    },
    {
      'id': 'p8',
      'title': 'Wheat Grains',
      'category': 'GRAINS',
      'farmerName': 'Golden Fields',
      'price': '120',
      'unit': '/ kg',
      'stockBadge': '500 kg available',
      'isFavorite': false,
      'imageColor': Color(0xFFFFB74D),
    },
  ];

  // Simulating JSON data for Popular Farmers
  static const List<Map<String, dynamic>> popularFarmers = [
    {
      'id': 'f1',
      'name': 'Green Valley Farm',
      'rating': '4.8',
      'reviews': '120 reviews',
      'location': 'Karachi Farmers Market',
      'tags': 'Fresh Vegetables & Ber...',
      'isFollowing': false,
    },
    {
      'id': 'f2',
      'name': 'Sunshine Organics',
      'rating': '4.9',
      'reviews': '95 reviews',
      'location': 'Clifton Organic Hub',
      'tags': 'Citrus & Stone Fruits',
      'isFollowing': true,
    },
  ];

  // Simulating JSON data for Recently Restocked
  static const List<Map<String, dynamic>> recentlyRestocked = [
    {
      'id': 'p4',
      'title': 'Pure Farm Cow Milk',
      'category': 'DAIRY',
      'farmerName': 'Meadow Dairy F...',
      'price': '220',
      'unit': '/ L',
      'stockBadge': '15 L available',
      'isFavorite': false,
      'imageColor': Color(0xFFD7CCC8), 'imageUrl': 'https://images.unsplash.com/photo-1563636619-e9143da7973b?q=80&w=400&auto=format&fit=crop', // Light Brown
    },
    {
      'id': 'p5',
      'title': 'Raw Wildflower H...',
      'category': 'ORGANIC',
      'farmerName': 'Mountain Bee A...',
      'price': '950',
      'unit': '/ jar',
      'stockBadge': '5 jars left',
      'isFavorite': false,
      'imageColor': Color(0xFFFFE082), 'imageUrl': 'https://images.unsplash.com/photo-1628151015968-3a4429e9ef04?q=80&w=400&auto=format&fit=crop', // Light Amber
    },
  ];

  // Simulating Cart Data
  static List<Map<String, dynamic>> cart = [];

  // Simulating Orders Data
  static List<Map<String, dynamic>> orders = [];

  // --- Seed Data Based on Models ---

  // 1. Users (3 users)
  static List<UserModel> seedUsers = [
    UserModel(
      uid: 'u1',
      name: 'Ali Raza',
      email: 'ali@example.com',
      role: 'customer',
      phone: '03001234567',
      address: '123 Main St, Karachi',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    UserModel(
      uid: 'u2',
      name: 'Ahmad Hassan',
      email: 'ahmad@example.com',
      role: 'farmer',
      phone: '03111223344',
      address: 'Green Valley, Malir',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    UserModel(
      uid: 'u3',
      name: 'Zain Abbas',
      email: 'zain@example.com',
      role: 'admin',
      phone: '03339988776',
      address: 'DHA Phase 6, Karachi',
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
  ];

  // 2. Customers
  static List<CustomerModel> seedCustomers = [
    CustomerModel(
      id: 'c1',
      userId: 'u1',
      name: 'Ali Raza',
      email: 'ali@example.com',
      phone: '03001234567',
      address: '123 Main St, Karachi',
      wishlist: ['p1', 'p2'],
      followedFarmers: ['f1'],
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  // 3. Markets
  static List<MarketModel> seedMarkets = [
    MarketModel(
      id: 'm1',
      name: 'Karachi Farmers Market',
      address: 'Main Khayaban-e-Ittehad, DHA',
      gpsCoordinates: '24.8103, 67.0543',
      operatingHours: 'Sun: 8:00 AM - 1:00 PM',
      activeStatus: true,
      description: 'The largest weekly farmers market in Karachi.',
    ),
  ];

  // 4. Farmers
  static List<FarmerModel> seedFarmers = [
    FarmerModel(
      id: 'f1',
      userId: 'u2',
      farmName: 'Green Valley Farm',
      description: 'Organic vegetables and fruits fresh from the farm.',
      location: 'Karachi Farmers Market',
      contactNumber: '03111223344',
      marketId: 'm1',
      rating: 4.8,
      isApproved: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  // 5. Products
  static List<ProductModel> seedProducts = [
    ProductModel(
      id: 'p1',
      farmerId: 'f1',
      categoryId: '3',
      categoryName: 'Vegetables',
      name: 'Fresh Tomatoes',
      description: 'Red, juicy, and farm-fresh tomatoes.',
      price: 280,
      unit: 'kg',
      quantity: 12,
      isAvailable: true,
      farmerName: 'Green Valley Farm',
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'p2',
      farmerId: 'f1',
      categoryId: '3',
      categoryName: 'Vegetables',
      name: 'Organic Spinach',
      description: 'Pesticide-free leafy spinach.',
      price: 140,
      unit: 'bunch',
      quantity: 8,
      isAvailable: true,
      farmerName: 'Green Valley Farm',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ProductModel(
      id: 'p3',
      farmerId: 'f1',
      categoryId: '2',
      categoryName: 'Fruits',
      name: 'Juicy Apples',
      description: 'Crisp and sweet apples from our orchards.',
      price: 400,
      unit: 'kg',
      quantity: 30,
      isAvailable: true,
      farmerName: 'Green Valley Farm',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  // 6. Categories
  static List<CategoryModel> seedCategories = [
    CategoryModel(id: '1', name: 'All'),
    CategoryModel(id: '2', name: 'Fruits'),
    CategoryModel(id: '3', name: 'Vegetables'),
    CategoryModel(id: '4', name: 'Dairy'),
    CategoryModel(id: '5', name: 'Meat'),
  ];

  // 7. Pickup Slots
  static List<PickupSlotModel> seedPickupSlots = [
    PickupSlotModel(
      id: 'ps1',
      marketId: 'm1',
      farmerId: 'f1',
      date: '2026-10-15',
      startTime: '08:00 AM',
      endTime: '10:00 AM',
      isAvailable: true,
      maxBookings: 10,
      currentBookings: 2,
    ),
    PickupSlotModel(
      id: 'ps2',
      marketId: 'm1',
      farmerId: 'f1',
      date: '2026-10-15',
      startTime: '10:00 AM',
      endTime: '12:00 PM',
      isAvailable: true,
      maxBookings: 10,
      currentBookings: 5,
    ),
  ];

  // 8. Orders
  static List<OrderModel> seedOrders = [
    OrderModel(
      id: 'o1',
      customerId: 'c1',
      customerName: 'Ali Raza',
      customerPhone: '03001234567',
      farmerId: 'f1',
      items: [
        OrderItem(
          productId: 'p1',
          farmerId: 'f1',
          productName: 'Fresh Tomatoes',
          price: 280,
          quantity: 2,
          unit: 'kg',
        ),
      ],
      totalAmount: 560,
      pickupSlotId: 'ps1',
      pickupSlotTime: '08:00 AM - 10:00 AM',
      marketId: 'm1',
      status: 'Pending',
      paymentMethod: 'Cash on Delivery',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  // 9. Notifications
  static List<NotificationModel> seedNotifications = [
    NotificationModel(
      id: 'n1',
      userId: 'u1',
      title: 'Order Confirmed',
      message: 'Your order for Fresh Tomatoes has been confirmed.',
      type: 'order',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  // 10. Cart Items
  static List<CartItemModel> get seedCartItems => [
    CartItemModel(product: seedProducts[0], quantity: 2),
  ];
}
