import re

with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace(
    'Stream<List<PickupSlotModel>> streamPickupSlots(String marketId)',
    'Stream<List<PickupSlotModel>> streamPickupSlots({required String marketId, String? farmerId})'
)

c = c.replace(
    "Query query = _pickupSlotsRef.where('marketId', isEqualTo: marketId);",
    "Query query = _pickupSlotsRef.where('marketId', isEqualTo: marketId);\n    if (farmerId != null && farmerId.isNotEmpty) {\n      query = query.where('farmerId', isEqualTo: farmerId);\n    }"
)

# And because I restored database_service.dart, I need to make sure streamPickupSlots method body has `Query query` instead of direct return!
old_stream = r"Stream<List<PickupSlotModel>> streamPickupSlots\(String marketId\) \{\s*return _pickupSlotsRef\s*\.where\('marketId', isEqualTo: marketId\)\s*\.snapshots\(\)\s*\.map\(\(snapshot\) \{"
new_stream = '''Stream<List<PickupSlotModel>> streamPickupSlots({required String marketId, String? farmerId}) {
    Query query = _pickupSlotsRef.where('marketId', isEqualTo: marketId);
    if (farmerId != null && farmerId.isNotEmpty) {
      query = query.where('farmerId', isEqualTo: farmerId);
    }
    return query.snapshots().map((snapshot) {'''
c = re.sub(old_stream, new_stream, c, flags=re.DOTALL)

with open('lib/services/database_service.dart', 'w', encoding='utf-8') as f:
    f.write(c)
