const { initializeApp } = require("firebase/app");
const { getAuth, createUserWithEmailAndPassword } = require("firebase/auth");
const { getFirestore, doc, setDoc } = require("firebase/firestore");

const firebaseConfig = {
  apiKey: "AIzaSyAxFgsMAXG6Uq8e6V7VRQotrG4OIPz93Ng",
  appId: "1:970168239081:web:4dea5acf961ea6a3524178",
  messagingSenderId: "970168239081",
  projectId: "harvest-hub-9ccfb",
  authDomain: "harvest-hub-9ccfb.firebaseapp.com",
  storageBucket: "harvest-hub-9ccfb.firebasestorage.app",
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

async function createTestAccount(email, password, role) {
  try {
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;
    const uid = user.uid;

    console.log(`\nCreated ${role} auth user with UID: ${uid}`);

    // Create user document
    await setDoc(doc(db, "users", uid), {
      uid: uid,
      name: `Test ${role}`,
      email: email,
      role: role,
      phone: "03000000000",
      address: "Test Address, Karachi",
      isActive: true,
      createdAt: new Date().toISOString()
    });

    if (role === "Customer") {
      await setDoc(doc(db, "customers", uid), {
        id: uid, 
        userId: uid,
        name: `Test ${role}`,
        email: email,
        phone: "03000000000",
        address: "Test Address, Karachi",
        wishlist: [],
        followedFarmers: [],
        createdAt: new Date().toISOString()
      });
    } else if (role === "Farmer") {
      await setDoc(doc(db, "farmers", uid), {
        id: uid,
        userId: uid,
        farmName: "Test Farm",
        businessName: "Test Farm",
        description: "Test Farm Description",
        location: "Karachi Region",
        contactNumber: "03000000000",
        marketId: "m1",
        rating: 5.0,
        isApproved: true,
        createdAt: new Date().toISOString()
      });
    }
    
    console.log(`Created Firestore records for ${role} (${email})`);
    return uid;
  } catch (error) {
    console.error(`Error creating ${role} (${email}):`, error.message);
  }
}

async function main() {
  console.log("Setting up Auth credentials...");
  
  // Using specific test emails so we know the credentials
  await createTestAccount("customer@example.com", "password123", "Customer");
  await createTestAccount("farmer@example.com", "password123", "Farmer");
  await createTestAccount("admin@example.com", "password123", "Admin");
  
  console.log("\nDone!");
  process.exit(0);
}

main();
