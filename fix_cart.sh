#!/bin/bash
sed -i 's/import '\''..\/..\/core\/dummy_data.dart'\'';/import '\''..\/..\/providers\/cart_provider.dart'\'';\nimport '\''..\/..\/providers\/auth_provider.dart'\'';\nimport '\''..\/..\/services\/database_service.dart'\'';\nimport '\''..\/..\/models\/order_model.dart'\'';\nimport '\''package:provider\/provider.dart'\'';/' lib/screens/customer/cart_screen.dart
