const { initializeApp } = require("firebase/app");
const { getFirestore, doc, setDoc, collection } = require("firebase/firestore");

const firebaseConfig = {
  apiKey: "AIzaSyAxFgsMAXG6Uq8e6V7VRQotrG4OIPz93Ng",
  appId: "1:970168239081:web:4dea5acf961ea6a3524178",
  messagingSenderId: "970168239081",
  projectId: "harvest-hub-9ccfb",
  authDomain: "harvest-hub-9ccfb.firebaseapp.com",
  storageBucket: "harvest-hub-9ccfb.firebasestorage.app",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

const now = new Date().toISOString();

const users = [
  { uid: "u1", name: "Ali Raza", email: "ali@example.com", role: "Customer", phone: "03001234561", address: "DHA Phase 1, Karachi", isActive: true, createdAt: "2026-01-01T00:00:00.000" },
  { uid: "u2", name: "Zainab Ahmed", email: "zainab@example.com", role: "Customer", phone: "03001234562", address: "DHA Phase 2, Karachi", isActive: true, createdAt: "2026-01-02T00:00:00.000" },
  { uid: "u3", name: "Hassan Khan", email: "hassan@example.com", role: "Customer", phone: "03001234563", address: "DHA Phase 3, Karachi", isActive: true, createdAt: "2026-01-03T00:00:00.000" },
  { uid: "u4", name: "Fatima Malik", email: "fatima@example.com", role: "Customer", phone: "03001234564", address: "DHA Phase 4, Karachi", isActive: true, createdAt: "2026-01-04T00:00:00.000" },
  { uid: "u5", name: "Usman Ali", email: "usman@example.com", role: "Customer", phone: "03001234565", address: "DHA Phase 5, Karachi", isActive: true, createdAt: "2026-01-05T00:00:00.000" },
  { uid: "u6", name: "Ayesha Tariq", email: "ayesha@example.com", role: "Customer", phone: "03001234566", address: "DHA Phase 6, Karachi", isActive: true, createdAt: "2026-01-06T00:00:00.000" },
  { uid: "u7", name: "Bilal Hussain", email: "bilal@example.com", role: "Customer", phone: "03001234567", address: "DHA Phase 7, Karachi", isActive: true, createdAt: "2026-01-07T00:00:00.000" },
  { uid: "u8", name: "Sara Shah", email: "sara@example.com", role: "Customer", phone: "03001234568", address: "DHA Phase 8, Karachi", isActive: true, createdAt: "2026-01-08T00:00:00.000" },
  { uid: "u9", name: "Omar Farooq", email: "omar@example.com", role: "Customer", phone: "03001234569", address: "Clifton Block 2, Karachi", isActive: true, createdAt: "2026-01-09T00:00:00.000" },
  { uid: "u10", name: "Sana Javed", email: "sana@example.com", role: "Customer", phone: "03001234560", address: "Clifton Block 4, Karachi", isActive: true, createdAt: "2026-01-10T00:00:00.000" },
  { uid: "u11", name: "Farmer Ali", email: "farmer11@example.com", role: "Farmer", phone: "03111223341", address: "Malir Farms 1, Karachi", isActive: true, createdAt: "2026-02-01T00:00:00.000" },
  { uid: "u12", name: "Farmer Zain", email: "farmer12@example.com", role: "Farmer", phone: "03111223342", address: "Malir Farms 2, Karachi", isActive: true, createdAt: "2026-02-02T00:00:00.000" },
  { uid: "u13", name: "Farmer Qasim", email: "farmer13@example.com", role: "Farmer", phone: "03111223343", address: "Malir Farms 3, Karachi", isActive: true, createdAt: "2026-02-03T00:00:00.000" },
  { uid: "u14", name: "Farmer Tariq", email: "farmer14@example.com", role: "Farmer", phone: "03111223344", address: "Malir Farms 4, Karachi", isActive: true, createdAt: "2026-02-04T00:00:00.000" },
  { uid: "u15", name: "Farmer Bilal", email: "farmer15@example.com", role: "Farmer", phone: "03111223345", address: "Malir Farms 5, Karachi", isActive: true, createdAt: "2026-02-05T00:00:00.000" },
  { uid: "u16", name: "Farmer Dawood", email: "farmer16@example.com", role: "Farmer", phone: "03111223346", address: "Malir Farms 6, Karachi", isActive: true, createdAt: "2026-02-06T00:00:00.000" },
  { uid: "u17", name: "Farmer Raza", email: "farmer17@example.com", role: "Farmer", phone: "03111223347", address: "Malir Farms 7, Karachi", isActive: true, createdAt: "2026-02-07T00:00:00.000" },
  { uid: "u18", name: "Farmer Yasir", email: "farmer18@example.com", role: "Farmer", phone: "03111223348", address: "Malir Farms 8, Karachi", isActive: true, createdAt: "2026-02-08T00:00:00.000" },
  { uid: "u19", name: "Admin Sameer", email: "admin19@example.com", role: "Admin", phone: "03339988779", address: "Admin House 1, Karachi", isActive: true, createdAt: "2026-03-01T00:00:00.000" },
  { uid: "u20", name: "Admin Nida", email: "admin20@example.com", role: "Admin", phone: "03339988770", address: "Admin House 2, Karachi", isActive: true, createdAt: "2026-03-02T00:00:00.000" },
];

const customers = [
  { id: "c1", userId: "u1", name: "Ali Raza", email: "ali@example.com", phone: "03001234561", address: "DHA Phase 1, Karachi", wishlist: ["p1","p2"], followedFarmers: ["f1","f2"], createdAt: "2026-01-01T00:00:00.000" },
  { id: "c2", userId: "u2", name: "Zainab Ahmed", email: "zainab@example.com", phone: "03001234562", address: "DHA Phase 2, Karachi", wishlist: ["p3","p4"], followedFarmers: ["f3","f4"], createdAt: "2026-01-02T00:00:00.000" },
  { id: "c3", userId: "u3", name: "Hassan Khan", email: "hassan@example.com", phone: "03001234563", address: "DHA Phase 3, Karachi", wishlist: ["p5","p6"], followedFarmers: ["f5","f6"], createdAt: "2026-01-03T00:00:00.000" },
  { id: "c4", userId: "u4", name: "Fatima Malik", email: "fatima@example.com", phone: "03001234564", address: "DHA Phase 4, Karachi", wishlist: ["p7","p8"], followedFarmers: ["f7","f8"], createdAt: "2026-01-04T00:00:00.000" },
  { id: "c5", userId: "u5", name: "Usman Ali", email: "usman@example.com", phone: "03001234565", address: "DHA Phase 5, Karachi", wishlist: ["p9","p10"], followedFarmers: ["f1","f3"], createdAt: "2026-01-05T00:00:00.000" },
  { id: "c6", userId: "u6", name: "Ayesha Tariq", email: "ayesha@example.com", phone: "03001234566", address: "DHA Phase 6, Karachi", wishlist: ["p11","p12"], followedFarmers: ["f2","f4"], createdAt: "2026-01-06T00:00:00.000" },
  { id: "c7", userId: "u7", name: "Bilal Hussain", email: "bilal@example.com", phone: "03001234567", address: "DHA Phase 7, Karachi", wishlist: ["p13","p14"], followedFarmers: ["f5","f7"], createdAt: "2026-01-07T00:00:00.000" },
  { id: "c8", userId: "u8", name: "Sara Shah", email: "sara@example.com", phone: "03001234568", address: "DHA Phase 8, Karachi", wishlist: ["p15","p16"], followedFarmers: ["f6","f8"], createdAt: "2026-01-08T00:00:00.000" },
  { id: "c9", userId: "u9", name: "Omar Farooq", email: "omar@example.com", phone: "03001234569", address: "Clifton Block 2, Karachi", wishlist: ["p17","p18"], followedFarmers: ["f1","f5"], createdAt: "2026-01-09T00:00:00.000" },
  { id: "c10", userId: "u10", name: "Sana Javed", email: "sana@example.com", phone: "03001234560", address: "Clifton Block 4, Karachi", wishlist: ["p19","p20"], followedFarmers: ["f2","f6"], createdAt: "2026-01-10T00:00:00.000" },
];

const farmers = [
  { id: "f1", userId: "u11", farmName: "Green Valley Farm", businessName: "Green Valley Farm", description: "Fresh produce from Green Valley Farm.", location: "Karachi Region", contactNumber: "03111223341", marketId: "m1", rating: 4.8, isApproved: true, createdAt: "2026-02-01T00:00:00.000" },
  { id: "f2", userId: "u12", farmName: "Sunshine Organics", businessName: "Sunshine Organics", description: "Fresh produce from Sunshine Organics.", location: "Karachi Region", contactNumber: "03111223342", marketId: "m2", rating: 4.9, isApproved: true, createdAt: "2026-02-02T00:00:00.000" },
  { id: "f3", userId: "u13", farmName: "Sindh Agri Co", businessName: "Sindh Agri Co", description: "Fresh produce from Sindh Agri Co.", location: "Karachi Region", contactNumber: "03111223343", marketId: "m3", rating: 4.6, isApproved: true, createdAt: "2026-02-03T00:00:00.000" },
  { id: "f4", userId: "u14", farmName: "Punjab Farms", businessName: "Punjab Farms", description: "Fresh produce from Punjab Farms.", location: "Karachi Region", contactNumber: "03111223344", marketId: "m4", rating: 4.7, isApproved: true, createdAt: "2026-02-04T00:00:00.000" },
  { id: "f5", userId: "u15", farmName: "Ali Poultry Farm", businessName: "Ali Poultry Farm", description: "Fresh produce from Ali Poultry Farm.", location: "Karachi Region", contactNumber: "03111223345", marketId: "m5", rating: 4.5, isApproved: false, createdAt: "2026-02-05T00:00:00.000" },
  { id: "f6", userId: "u16", farmName: "Meadow Dairy", businessName: "Meadow Dairy", description: "Fresh produce from Meadow Dairy.", location: "Karachi Region", contactNumber: "03111223346", marketId: "m1", rating: 4.9, isApproved: true, createdAt: "2026-02-06T00:00:00.000" },
  { id: "f7", userId: "u17", farmName: "Chaudhry Sugars", businessName: "Chaudhry Sugars", description: "Fresh produce from Chaudhry Sugars.", location: "Karachi Region", contactNumber: "03111223347", marketId: "m2", rating: 4.8, isApproved: true, createdAt: "2026-02-07T00:00:00.000" },
  { id: "f8", userId: "u18", farmName: "Haji Cattle Farm", businessName: "Haji Cattle Farm", description: "Fresh produce from Haji Cattle Farm.", location: "Karachi Region", contactNumber: "03111223348", marketId: "m3", rating: 4.4, isApproved: false, createdAt: "2026-02-08T00:00:00.000" },
];

const categories = [
  { id: "1", name: "All", iconName: "apps", itemCount: "48 items" },
  { id: "2", name: "Vegetables", iconName: "eco", itemCount: "18 items" },
  { id: "3", name: "Fruits", iconName: "apple", itemCount: "12 items" },
  { id: "4", name: "Dairy & Eggs", iconName: "water_drop", itemCount: "8 items" },
  { id: "5", name: "Farm Honey", iconName: "hive", itemCount: "5 items" },
  { id: "6", name: "Organic Herbs", iconName: "local_florist", itemCount: "9 items" },
  { id: "7", name: "Cold Pressed Oils", iconName: "opacity", itemCount: "4 items" },
  { id: "8", name: "Grains & Pulses", iconName: "grass", itemCount: "11 items" },
  { id: "9", name: "Meat & Poultry", iconName: "set_meal", itemCount: "6 items" },
];

const farmersMarkets = [
  { id: "m1", name: "Karachi Farmers Market", address: "Main Khayaban-e-Ittehad, DHA", gpsCoordinates: "24.8103, 67.0543", operatingHours: "Sun: 8:00 AM - 1:00 PM", activeStatus: true, description: "The largest weekly farmers market in Karachi." },
  { id: "m2", name: "Clifton Organic Hub", address: "Clifton Block 4 Park", gpsCoordinates: "24.8214, 67.0311", operatingHours: "Sat: 9:00 AM - 2:00 PM", activeStatus: true, description: "Premium organic produce." },
  { id: "m3", name: "Malir Cantt Market", address: "Cantt Bazaar Area", gpsCoordinates: "24.9351, 67.1952", operatingHours: "Fri: 7:00 AM - 12:00 PM", activeStatus: true, description: "Fresh farm arrivals every Friday." },
  { id: "m4", name: "DHA Phase 8 Market", address: "Creek Club Road", gpsCoordinates: "24.7901, 67.0712", operatingHours: "Sun: 4:00 PM - 9:00 PM", activeStatus: true, description: "Evening organic market by the sea." },
  { id: "m5", name: "Gulshan Weekly Bazaar", address: "Gulshan Block 13-C", gpsCoordinates: "24.9192, 67.0984", operatingHours: "Tue: 8:00 AM - 5:00 PM", activeStatus: true, description: "Affordable wholesale farmers market." },
];

const products = [
  { id: "p1", farmerId: "f1", categoryId: "2", categoryName: "Vegetables", name: "Fresh Tomatoes", description: "Quality Fresh Tomatoes fresh from the farm.", price: 280, unit: "kg", quantity: 12, isAvailable: true, isOrganic: false, farmerName: "Green Valley Farm", createdAt: "2026-04-01T00:00:00.000" },
  { id: "p2", farmerId: "f1", categoryId: "2", categoryName: "Vegetables", name: "Organic Spinach", description: "Quality Organic Spinach fresh from the farm.", price: 140, unit: "bunch", quantity: 8, isAvailable: true, isOrganic: true, farmerName: "Green Valley Farm", createdAt: "2026-04-02T00:00:00.000" },
  { id: "p3", farmerId: "f1", categoryId: "2", categoryName: "Vegetables", name: "Fresh Carrots", description: "Quality Fresh Carrots fresh from the farm.", price: 150, unit: "kg", quantity: 20, isAvailable: true, isOrganic: false, farmerName: "Green Valley Farm", createdAt: "2026-04-03T00:00:00.000" },
  { id: "p4", farmerId: "f6", categoryId: "4", categoryName: "Dairy & Eggs", name: "Pure Farm Cow Milk", description: "Quality Pure Farm Cow Milk fresh from the farm.", price: 220, unit: "L", quantity: 15, isAvailable: true, isOrganic: false, farmerName: "Meadow Dairy", createdAt: "2026-04-04T00:00:00.000" },
  { id: "p5", farmerId: "f2", categoryId: "5", categoryName: "Farm Honey", name: "Raw Wildflower Honey", description: "Quality Raw Wildflower Honey fresh from the farm.", price: 950, unit: "jar", quantity: 5, isAvailable: true, isOrganic: true, farmerName: "Sunshine Organics", createdAt: "2026-04-05T00:00:00.000" },
  { id: "p6", farmerId: "f2", categoryId: "3", categoryName: "Fruits", name: "Juicy Apples", description: "Quality Juicy Apples fresh from the farm.", price: 400, unit: "kg", quantity: 30, isAvailable: true, isOrganic: false, farmerName: "Sunshine Organics", createdAt: "2026-04-06T00:00:00.000" },
  { id: "p7", farmerId: "f1", categoryId: "6", categoryName: "Organic Herbs", name: "Fresh Mint", description: "Quality Fresh Mint fresh from the farm.", price: 50, unit: "bunch", quantity: 40, isAvailable: true, isOrganic: true, farmerName: "Green Valley Farm", createdAt: "2026-04-07T00:00:00.000" },
  { id: "p8", farmerId: "f4", categoryId: "8", categoryName: "Grains & Pulses", name: "Wheat Grains", description: "Quality Wheat Grains fresh from the farm.", price: 120, unit: "kg", quantity: 500, isAvailable: true, isOrganic: false, farmerName: "Punjab Farms", createdAt: "2026-04-08T00:00:00.000" },
  { id: "p9", farmerId: "f3", categoryId: "2", categoryName: "Vegetables", name: "Red Onions", description: "Quality Red Onions fresh from the farm.", price: 180, unit: "kg", quantity: 50, isAvailable: true, isOrganic: false, farmerName: "Sindh Agri Co", createdAt: "2026-04-09T00:00:00.000" },
  { id: "p10", farmerId: "f4", categoryId: "2", categoryName: "Vegetables", name: "Potatoes", description: "Quality Potatoes fresh from the farm.", price: 120, unit: "kg", quantity: 100, isAvailable: true, isOrganic: false, farmerName: "Punjab Farms", createdAt: "2026-04-10T00:00:00.000" },
  { id: "p11", farmerId: "f5", categoryId: "4", categoryName: "Dairy & Eggs", name: "Desi Eggs", description: "Quality Desi Eggs fresh from the farm.", price: 450, unit: "dozen", quantity: 20, isAvailable: true, isOrganic: false, farmerName: "Ali Poultry Farm", createdAt: "2026-04-11T00:00:00.000" },
  { id: "p12", farmerId: "f7", categoryId: "5", categoryName: "Farm Honey", name: "Pure Jaggery", description: "Quality Pure Jaggery fresh from the farm.", price: 350, unit: "kg", quantity: 15, isAvailable: true, isOrganic: false, farmerName: "Chaudhry Sugars", createdAt: "2026-04-12T00:00:00.000" },
  { id: "p13", farmerId: "f4", categoryId: "8", categoryName: "Grains & Pulses", name: "Whole Wheat Atta", description: "Quality Whole Wheat Atta fresh from the farm.", price: 160, unit: "kg", quantity: 200, isAvailable: true, isOrganic: false, farmerName: "Punjab Farms", createdAt: "2026-04-13T00:00:00.000" },
  { id: "p14", farmerId: "f8", categoryId: "9", categoryName: "Meat & Poultry", name: "Fresh Beef Gosht", description: "Quality Fresh Beef Gosht fresh from the farm.", price: 1200, unit: "kg", quantity: 30, isAvailable: true, isOrganic: false, farmerName: "Haji Cattle Farm", createdAt: "2026-04-14T00:00:00.000" },
  { id: "p15", farmerId: "f3", categoryId: "6", categoryName: "Organic Herbs", name: "Raw Turmeric", description: "Quality Raw Turmeric fresh from the farm.", price: 400, unit: "kg", quantity: 10, isAvailable: true, isOrganic: true, farmerName: "Sindh Agri Co", createdAt: "2026-04-15T00:00:00.000" },
  { id: "p16", farmerId: "f4", categoryId: "7", categoryName: "Cold Pressed Oils", name: "Mustard Oil", description: "Quality Mustard Oil fresh from the farm.", price: 600, unit: "L", quantity: 25, isAvailable: true, isOrganic: false, farmerName: "Punjab Farms", createdAt: "2026-04-16T00:00:00.000" },
  { id: "p17", farmerId: "f1", categoryId: "2", categoryName: "Vegetables", name: "Fresh Garlic", description: "Quality Fresh Garlic fresh from the farm.", price: 450, unit: "kg", quantity: 20, isAvailable: true, isOrganic: false, farmerName: "Green Valley Farm", createdAt: "2026-04-17T00:00:00.000" },
  { id: "p18", farmerId: "f3", categoryId: "2", categoryName: "Vegetables", name: "Ginger", description: "Quality Ginger fresh from the farm.", price: 650, unit: "kg", quantity: 12, isAvailable: true, isOrganic: false, farmerName: "Sindh Agri Co", createdAt: "2026-04-18T00:00:00.000" },
  { id: "p19", farmerId: "f6", categoryId: "4", categoryName: "Dairy & Eggs", name: "Desi Ghee", description: "Quality Desi Ghee fresh from the farm.", price: 2200, unit: "kg", quantity: 5, isAvailable: true, isOrganic: false, farmerName: "Meadow Dairy", createdAt: "2026-04-19T00:00:00.000" },
  { id: "p20", farmerId: "f4", categoryId: "8", categoryName: "Grains & Pulses", name: "Basmati Rice", description: "Quality Basmati Rice fresh from the farm.", price: 380, unit: "kg", quantity: 100, isAvailable: true, isOrganic: false, farmerName: "Punjab Farms", createdAt: "2026-04-20T00:00:00.000" },
];

const pickupSlots = [
  { id: "ps1", marketId: "m1", farmerId: "f1", date: "2026-10-15", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 10, currentBookings: 2 },
  { id: "ps2", marketId: "m2", farmerId: "f2", date: "2026-10-16", startTime: "10:00 AM", endTime: "12:00 PM", isAvailable: true, maxBookings: 10, currentBookings: 5 },
  { id: "ps3", marketId: "m3", farmerId: "f3", date: "2026-10-17", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 12, currentBookings: 8 },
  { id: "ps4", marketId: "m4", farmerId: "f4", date: "2026-10-18", startTime: "04:00 PM", endTime: "06:00 PM", isAvailable: true, maxBookings: 15, currentBookings: 15 },
  { id: "ps5", marketId: "m5", farmerId: "f5", date: "2026-10-19", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 8, currentBookings: 2 },
  { id: "ps6", marketId: "m1", farmerId: "f6", date: "2026-10-20", startTime: "10:00 AM", endTime: "12:00 PM", isAvailable: true, maxBookings: 5, currentBookings: 1 },
  { id: "ps7", marketId: "m2", farmerId: "f7", date: "2026-10-21", startTime: "12:00 PM", endTime: "02:00 PM", isAvailable: true, maxBookings: 10, currentBookings: 4 },
  { id: "ps8", marketId: "m3", farmerId: "f8", date: "2026-10-22", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 14, currentBookings: 10 },
  { id: "ps9", marketId: "m4", farmerId: "f1", date: "2026-10-23", startTime: "04:00 PM", endTime: "06:00 PM", isAvailable: true, maxBookings: 10, currentBookings: 0 },
  { id: "ps10", marketId: "m5", farmerId: "f2", date: "2026-10-24", startTime: "10:00 AM", endTime: "12:00 PM", isAvailable: true, maxBookings: 6, currentBookings: 2 },
  { id: "ps11", marketId: "m1", farmerId: "f3", date: "2026-10-25", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 10, currentBookings: 7 },
  { id: "ps12", marketId: "m2", farmerId: "f4", date: "2026-10-26", startTime: "10:00 AM", endTime: "12:00 PM", isAvailable: true, maxBookings: 12, currentBookings: 11 },
  { id: "ps13", marketId: "m3", farmerId: "f5", date: "2026-10-27", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 15, currentBookings: 3 },
  { id: "ps14", marketId: "m4", farmerId: "f6", date: "2026-10-28", startTime: "04:00 PM", endTime: "06:00 PM", isAvailable: true, maxBookings: 5, currentBookings: 5 },
  { id: "ps15", marketId: "m5", farmerId: "f7", date: "2026-10-29", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 10, currentBookings: 1 },
  { id: "ps16", marketId: "m1", farmerId: "f8", date: "2026-10-30", startTime: "10:00 AM", endTime: "12:00 PM", isAvailable: true, maxBookings: 10, currentBookings: 6 },
  { id: "ps17", marketId: "m2", farmerId: "f1", date: "2026-10-31", startTime: "12:00 PM", endTime: "02:00 PM", isAvailable: true, maxBookings: 8, currentBookings: 8 },
  { id: "ps18", marketId: "m3", farmerId: "f2", date: "2026-11-01", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 10, currentBookings: 4 },
  { id: "ps19", marketId: "m4", farmerId: "f3", date: "2026-11-02", startTime: "04:00 PM", endTime: "06:00 PM", isAvailable: true, maxBookings: 10, currentBookings: 0 },
  { id: "ps20", marketId: "m5", farmerId: "f4", date: "2026-11-03", startTime: "08:00 AM", endTime: "10:00 AM", isAvailable: true, maxBookings: 15, currentBookings: 10 },
];

const orders = [
  { id: "o1", customerId: "c1", customerName: "Ali Raza", customerPhone: "03001234561", farmerId: "f1", items: [{ productId: "p1", farmerId: "f1", productName: "Fresh Tomatoes", price: 280, quantity: 2, unit: "kg" }], totalAmount: 560, pickupSlotId: "ps1", pickupSlotTime: "08:00 AM - 10:00 AM", marketId: "m1", status: "Pending", paymentMethod: "Cash on Pickup", createdAt: "2026-09-20T00:00:00.000" },
  { id: "o2", customerId: "c2", customerName: "Zainab Ahmed", customerPhone: "03001234562", farmerId: "f2", items: [{ productId: "p2", farmerId: "f2", productName: "Organic Spinach", price: 140, quantity: 3, unit: "bunch" }], totalAmount: 420, pickupSlotId: "ps2", pickupSlotTime: "10:00 AM - 12:00 PM", marketId: "m2", status: "Confirmed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-21T00:00:00.000" },
  { id: "o3", customerId: "c3", customerName: "Hassan Khan", customerPhone: "03001234563", farmerId: "f3", items: [{ productId: "p3", farmerId: "f3", productName: "Fresh Carrots", price: 150, quantity: 1, unit: "kg" }], totalAmount: 150, pickupSlotId: "ps3", pickupSlotTime: "08:00 AM - 10:00 AM", marketId: "m3", status: "Ready for Pickup", paymentMethod: "Cash on Pickup", createdAt: "2026-09-22T00:00:00.000" },
  { id: "o4", customerId: "c4", customerName: "Fatima Malik", customerPhone: "03001234564", farmerId: "f4", items: [{ productId: "p4", farmerId: "f4", productName: "Pure Farm Cow Milk", price: 220, quantity: 5, unit: "L" }], totalAmount: 1100, pickupSlotId: "ps4", pickupSlotTime: "04:00 PM - 06:00 PM", marketId: "m4", status: "Completed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-23T00:00:00.000" },
  { id: "o5", customerId: "c5", customerName: "Usman Ali", customerPhone: "03001234565", farmerId: "f5", items: [{ productId: "p5", farmerId: "f5", productName: "Raw Wildflower Honey", price: 950, quantity: 2, unit: "jar" }], totalAmount: 1900, pickupSlotId: "ps5", pickupSlotTime: "08:00 AM - 10:00 AM", marketId: "m5", status: "Cancelled", paymentMethod: "Cash on Pickup", cancellationReason: "Customer changed mind", createdAt: "2026-09-24T00:00:00.000" },
  { id: "o6", customerId: "c6", customerName: "Ayesha Tariq", customerPhone: "03001234566", farmerId: "f6", items: [{ productId: "p6", farmerId: "f6", productName: "Juicy Apples", price: 400, quantity: 2, unit: "kg" }], totalAmount: 800, pickupSlotId: "ps6", pickupSlotTime: "10:00 AM - 12:00 PM", marketId: "m1", status: "Pending", paymentMethod: "Cash on Pickup", createdAt: "2026-09-25T00:00:00.000" },
  { id: "o7", customerId: "c7", customerName: "Bilal Hussain", customerPhone: "03001234567", farmerId: "f7", items: [{ productId: "p7", farmerId: "f7", productName: "Fresh Mint", price: 50, quantity: 4, unit: "bunch" }], totalAmount: 200, pickupSlotId: "ps7", pickupSlotTime: "12:00 PM - 02:00 PM", marketId: "m2", status: "Confirmed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-26T00:00:00.000" },
  { id: "o8", customerId: "c8", customerName: "Sara Shah", customerPhone: "03001234568", farmerId: "f8", items: [{ productId: "p8", farmerId: "f8", productName: "Wheat Grains", price: 120, quantity: 10, unit: "kg" }], totalAmount: 1200, pickupSlotId: "ps8", pickupSlotTime: "08:00 AM - 10:00 AM", marketId: "m3", status: "Ready for Pickup", paymentMethod: "Cash on Pickup", createdAt: "2026-09-27T00:00:00.000" },
  { id: "o9", customerId: "c9", customerName: "Omar Farooq", customerPhone: "03001234569", farmerId: "f1", items: [{ productId: "p9", farmerId: "f1", productName: "Red Onions", price: 180, quantity: 3, unit: "kg" }], totalAmount: 540, pickupSlotId: "ps9", pickupSlotTime: "04:00 PM - 06:00 PM", marketId: "m4", status: "Completed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-28T00:00:00.000" },
  { id: "o10", customerId: "c10", customerName: "Sana Javed", customerPhone: "03001234560", farmerId: "f2", items: [{ productId: "p10", farmerId: "f2", productName: "Potatoes", price: 120, quantity: 5, unit: "kg" }], totalAmount: 600, pickupSlotId: "ps10", pickupSlotTime: "10:00 AM - 12:00 PM", marketId: "m5", status: "Cancelled", paymentMethod: "Cash on Pickup", cancellationReason: "Stock unavailable", createdAt: "2026-09-28T00:00:00.000" },
  { id: "o11", customerId: "c1", customerName: "Ali Raza", customerPhone: "03001234561", farmerId: "f3", items: [{ productId: "p11", farmerId: "f3", productName: "Desi Eggs", price: 450, quantity: 2, unit: "dozen" }], totalAmount: 900, pickupSlotId: "ps11", pickupSlotTime: "08:00 AM - 10:00 AM", marketId: "m1", status: "Pending", paymentMethod: "Cash on Pickup", createdAt: "2026-09-20T00:00:00.000" },
  { id: "o12", customerId: "c2", customerName: "Zainab Ahmed", customerPhone: "03001234562", farmerId: "f4", items: [{ productId: "p12", farmerId: "f4", productName: "Pure Jaggery", price: 350, quantity: 1, unit: "kg" }], totalAmount: 350, pickupSlotId: "ps12", pickupSlotTime: "10:00 AM - 12:00 PM", marketId: "m2", status: "Confirmed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-21T00:00:00.000" },
  { id: "o13", customerId: "c3", customerName: "Hassan Khan", customerPhone: "03001234563", farmerId: "f5", items: [{ productId: "p13", farmerId: "f5", productName: "Whole Wheat Atta", price: 160, quantity: 10, unit: "kg" }], totalAmount: 1600, pickupSlotId: "ps13", pickupSlotTime: "08:00 AM - 10:00 AM", marketId: "m3", status: "Ready for Pickup", paymentMethod: "Cash on Pickup", createdAt: "2026-09-22T00:00:00.000" },
  { id: "o14", customerId: "c4", customerName: "Fatima Malik", customerPhone: "03001234564", farmerId: "f6", items: [{ productId: "p14", farmerId: "f6", productName: "Fresh Beef Gosht", price: 1200, quantity: 2, unit: "kg" }], totalAmount: 2400, pickupSlotId: "ps14", pickupSlotTime: "04:00 PM - 06:00 PM", marketId: "m4", status: "Completed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-23T00:00:00.000" },
  { id: "o15", customerId: "c5", customerName: "Usman Ali", customerPhone: "03001234565", farmerId: "f7", items: [{ productId: "p15", farmerId: "f7", productName: "Raw Turmeric", price: 400, quantity: 1, unit: "kg" }], totalAmount: 400, pickupSlotId: "ps15", pickupSlotTime: "08:00 AM - 10:00 AM", marketId: "m5", status: "Pending", paymentMethod: "Cash on Pickup", createdAt: "2026-09-24T00:00:00.000" },
  { id: "o16", customerId: "c6", customerName: "Ayesha Tariq", customerPhone: "03001234566", farmerId: "f8", items: [{ productId: "p16", farmerId: "f8", productName: "Mustard Oil", price: 600, quantity: 3, unit: "L" }], totalAmount: 1800, pickupSlotId: "ps16", pickupSlotTime: "10:00 AM - 12:00 PM", marketId: "m1", status: "Confirmed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-25T00:00:00.000" },
  { id: "o17", customerId: "c7", customerName: "Bilal Hussain", customerPhone: "03001234567", farmerId: "f1", items: [{ productId: "p17", farmerId: "f1", productName: "Fresh Garlic", price: 450, quantity: 2, unit: "kg" }], totalAmount: 900, pickupSlotId: "ps17", pickupSlotTime: "12:00 PM - 02:00 PM", marketId: "m2", status: "Ready for Pickup", paymentMethod: "Cash on Pickup", createdAt: "2026-09-26T00:00:00.000" },
  { id: "o18", customerId: "c8", customerName: "Sara Shah", customerPhone: "03001234568", farmerId: "f2", items: [{ productId: "p18", farmerId: "f2", productName: "Ginger", price: 650, quantity: 1, unit: "kg" }], totalAmount: 650, pickupSlotId: "ps18", pickupSlotTime: "08:00 AM - 10:00 AM", marketId: "m3", status: "Completed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-27T00:00:00.000" },
  { id: "o19", customerId: "c9", customerName: "Omar Farooq", customerPhone: "03001234569", farmerId: "f3", items: [{ productId: "p19", farmerId: "f3", productName: "Desi Ghee", price: 2200, quantity: 2, unit: "kg" }], totalAmount: 4400, pickupSlotId: "ps19", pickupSlotTime: "04:00 PM - 06:00 PM", marketId: "m4", status: "Pending", paymentMethod: "Cash on Pickup", createdAt: "2026-09-28T00:00:00.000" },
  { id: "o20", customerId: "c10", customerName: "Sana Javed", customerPhone: "03001234560", farmerId: "f4", items: [{ productId: "p20", farmerId: "f4", productName: "Basmati Rice", price: 380, quantity: 5, unit: "kg" }], totalAmount: 1900, pickupSlotId: "ps20", pickupSlotTime: "10:00 AM - 12:00 PM", marketId: "m5", status: "Confirmed", paymentMethod: "Cash on Pickup", createdAt: "2026-09-28T00:00:00.000" },
];

const reviews = [
  { id: "r1", customerId: "c1", customerName: "Ali Raza", targetId: "f1", targetType: "farmer", rating: 4.5, comment: "Excellent quality and fresh.", createdAt: "2026-08-01T00:00:00.000" },
  { id: "r2", customerId: "c2", customerName: "Zainab Ahmed", targetId: "p2", targetType: "product", rating: 5.0, comment: "Very green and healthy spinach.", createdAt: "2026-08-02T00:00:00.000" },
  { id: "r3", customerId: "c3", customerName: "Hassan Khan", targetId: "f3", targetType: "farmer", rating: 4.0, comment: "Good farmer, nice attitude.", createdAt: "2026-08-03T00:00:00.000" },
  { id: "r4", customerId: "c4", customerName: "Fatima Malik", targetId: "p4", targetType: "product", rating: 4.8, comment: "Real pure milk.", createdAt: "2026-08-04T00:00:00.000" },
  { id: "r5", customerId: "c5", customerName: "Usman Ali", targetId: "f5", targetType: "farmer", rating: 4.2, comment: "On time delivery.", createdAt: "2026-08-05T00:00:00.000" },
  { id: "r6", customerId: "c6", customerName: "Ayesha Tariq", targetId: "p6", targetType: "product", rating: 4.9, comment: "Sweetest apples.", createdAt: "2026-08-06T00:00:00.000" },
  { id: "r7", customerId: "c7", customerName: "Bilal Hussain", targetId: "f7", targetType: "farmer", rating: 4.7, comment: "Very clean produce.", createdAt: "2026-08-07T00:00:00.000" },
  { id: "r8", customerId: "c8", customerName: "Sara Shah", targetId: "p8", targetType: "product", rating: 4.1, comment: "Clean wheat.", createdAt: "2026-08-08T00:00:00.000" },
  { id: "r9", customerId: "c9", customerName: "Omar Farooq", targetId: "f1", targetType: "farmer", rating: 5.0, comment: "My favorite farmer in Karachi.", createdAt: "2026-08-09T00:00:00.000" },
  { id: "r10", customerId: "c10", customerName: "Sana Javed", targetId: "p10", targetType: "product", rating: 4.5, comment: "Good size potatoes.", createdAt: "2026-08-10T00:00:00.000" },
  { id: "r11", customerId: "c1", customerName: "Ali Raza", targetId: "f3", targetType: "farmer", rating: 4.6, comment: "Highly recommended.", createdAt: "2026-08-11T00:00:00.000" },
  { id: "r12", customerId: "c2", customerName: "Zainab Ahmed", targetId: "p12", targetType: "product", rating: 4.8, comment: "Very sweet jaggery.", createdAt: "2026-08-12T00:00:00.000" },
  { id: "r13", customerId: "c3", customerName: "Hassan Khan", targetId: "f5", targetType: "farmer", rating: 4.3, comment: "Fresh eggs always.", createdAt: "2026-08-13T00:00:00.000" },
  { id: "r14", customerId: "c4", customerName: "Fatima Malik", targetId: "p14", targetType: "product", rating: 4.9, comment: "Tender beef.", createdAt: "2026-08-14T00:00:00.000" },
  { id: "r15", customerId: "c5", customerName: "Usman Ali", targetId: "f7", targetType: "farmer", rating: 4.7, comment: "Best sugar products.", createdAt: "2026-08-15T00:00:00.000" },
  { id: "r16", customerId: "c6", customerName: "Ayesha Tariq", targetId: "p16", targetType: "product", rating: 4.4, comment: "Good aroma.", createdAt: "2026-08-16T00:00:00.000" },
  { id: "r17", customerId: "c7", customerName: "Bilal Hussain", targetId: "f1", targetType: "farmer", rating: 4.8, comment: "Very organic.", createdAt: "2026-08-17T00:00:00.000" },
  { id: "r18", customerId: "c8", customerName: "Sara Shah", targetId: "p18", targetType: "product", rating: 4.2, comment: "Fresh ginger.", createdAt: "2026-08-18T00:00:00.000" },
  { id: "r19", customerId: "c9", customerName: "Omar Farooq", targetId: "f3", targetType: "farmer", rating: 4.9, comment: "Great quality.", createdAt: "2026-08-19T00:00:00.000" },
  { id: "r20", customerId: "c10", customerName: "Sana Javed", targetId: "p20", targetType: "product", rating: 4.5, comment: "Aromatic rice.", createdAt: "2026-08-20T00:00:00.000" },
];

async function seedCollection(collectionName, data, idField) {
  console.log(`Seeding ${collectionName}...`);
  for (const item of data) {
    const docId = item[idField];
    const docData = { ...item };
    await setDoc(doc(db, collectionName, docId), docData);
  }
  console.log(`  ${data.length} records added to ${collectionName}`);
}

async function main() {
  try {
    await seedCollection("users", users, "uid");
    await seedCollection("customers", customers, "id");
    await seedCollection("farmers", farmers, "id");
    await seedCollection("categories", categories, "id");
    await seedCollection("farmers_markets", farmersMarkets, "id");
    await seedCollection("products", products, "id");
    await seedCollection("pickup_slots", pickupSlots, "id");
    await seedCollection("orders", orders, "id");
    await seedCollection("reviews", reviews, "id");
    console.log("\nAll data seeded successfully!");
    process.exit(0);
  } catch (error) {
    console.error("Error seeding data:", error);
    process.exit(1);
  }
}

main();
