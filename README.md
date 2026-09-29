HARVESTHUB - COMPLETE PROJECT GUIDE

==================================================

WHAT IS HARVESTHUB?

Imagine you want to buy some fresh apples. Usually, the farmer sells the apples to a middleman, the middleman sells them to a market, and you buy them from the market. Every time the apples change hands, the price goes up. 

HarvestHub is a mobile app that removes the middleman! It connects you directly with the farmer. This means farmers get paid a fair price for their hard work, and you get cheaper, fresher food. 

==================================================

WHO IS THIS APP FOR?

The app is divided into three parts:

1. THE CUSTOMER (BUYER)
This is for you and your family. You can look at pictures of fresh fruits and vegetables, read reviews from other people, put items in your shopping cart, and place an order directly with a local farmer. There is even a smart AI Chatbot inside the app that can answer your questions, like "How do I keep my tomatoes fresh?"

2. THE FARMER (SELLER)
This is for the people growing the food. They have their own special dashboard where they can upload pictures of their crops, set the prices, and see when a customer places an order. When an order comes in, the farmer can pack the food and click a button to let the customer know it is ready.

3. THE ADMINISTRATOR (MANAGER)
This is for the people who own the app. They make sure everyone is behaving nicely. If a new farmer wants to join the app, the manager looks at their profile and clicks "Approve" before the farmer is allowed to sell anything.

==================================================

HOW TO INSTALL AND RUN THE APP

Running this app on your computer is easy! Just follow these simple steps exactly as they are written below.


STEP 1: GET THE CODE
First, you need to download the app's code from the internet onto your computer. Open your computer's terminal (or command prompt) and type this exactly:

git clone https://github.com/sardarubaid-dev/Harvest_hub.git

Once it finishes downloading, you need to go inside the folder it just created. Type this:

cd Harvest_hub


STEP 2: DOWNLOAD THE BUILDING BLOCKS
The app relies on some extra pieces of code called "packages" to work properly. To download them, type this:

flutter pub get

Wait a minute or two for it to finish.


STEP 3: FILL THE APP WITH FAKE DATA
Right now, the app is empty. It has no farmers, no customers, and no fruits to buy! Let's fill it with some test data so you can play around with it. Make sure you have a program called Node.js installed on your computer first. Then, type these three commands, one by one:

npm install firebase
node seed_auth.js
node seed_firebase.js

When that finishes, your app will be fully loaded with test farmers and test products!


STEP 4: START THE APP!
You are all done setting up! Now it is time to turn the app on. Just type this:

flutter run

The app will pop up on your screen. Congratulations!

==================================================

HOW TO TEST THE APP

Since you ran the commands in Step 3, the app already has some test accounts ready for you. You don't even need to sign up. Just open the app and type in these details to see how it works!

IF YOU WANT TO SEE THE CUSTOMER APP:
Type this Email: customer@example.com
Type this Password: password123

IF YOU WANT TO SEE THE FARMER APP:
Type this Email: farmer@example.com
Type this Password: password123

IF YOU WANT TO SEE THE MANAGER APP:
Type this Email: admin@example.com
Type this Password: password123

Have fun exploring HarvestHub!
