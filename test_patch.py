import re

file_path = r'lib\screens\customer\customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace the calls inside _buildHomeTab
old_calls = '''          _buildHarvestHubGuaranteeSection(primaryGreen, darkText, greyText),

          const SizedBox(height: 28),

          _buildCommunityStatsSection(primaryGreen, darkText, greyText),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2FDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF81C784),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.energy_savings_leaf,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Direct-from-Farm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your orders directly empower sustainable regional farmers and promote organic soil revitalization.',
                          style: TextStyle(
                            fontSize: 12,
                            color: greyText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),'''

new_calls = '''          _buildHarvestHubPromiseSection(darkText, greyText),'''

content = content.replace(old_calls, new_calls)

# 2. Append the new methods right before the last closing brace (or just replace the old methods)
# The old methods are _buildHarvestHubGuaranteeSection, _buildCommunityStatsSection, _buildStatItem
# I will use a regex to remove them, but they are at the end of the file, so it's easier to find _buildHarvestHubGuaranteeSection and replace everything after it.
# Let's verify if _buildStatItem is the last method.
