import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/banner_model.dart';
import 'package:harvest_hub/models/offer_model.dart';
import 'package:harvest_hub/models/app_config_model.dart';

class AdminManageTab extends StatefulWidget {
  const AdminManageTab({super.key});

  @override
  State<AdminManageTab> createState() => _AdminManageTabState();
}

class _AdminManageTabState extends State<AdminManageTab> {
  final _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8), // Very light green-grey background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Hub',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Platform Configurations',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialSettings(),
            const SizedBox(height: 32),
            _buildOffersSection(),
            const SizedBox(height: 32),
            _buildBannersSection(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // --- Financial Settings ---
  Widget _buildFinancialSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Global Financials',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Edit'),
              onPressed: _showFinancialsDialog,
            )
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<AppConfigModel?>(
          stream: _dbService.streamAppConfig(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final config = snapshot.data ?? AppConfigModel(lastUpdated: DateTime.now());
            
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricNode('Platform Fee', '${config.platformFeePercentage}%'),
                  _buildDivider(),
                  _buildMetricNode('Tax Rate', '${config.taxPercentage}%'),
                  _buildDivider(),
                  _buildMetricNode('Delivery', 'Rs. ${config.defaultDeliveryFee}'),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3));
  }

  Widget _buildMetricNode(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9))),
      ],
    );
  }

  void _showFinancialsDialog() async {
    final doc = await _dbService.streamAppConfig().first;
    final config = doc ?? AppConfigModel(lastUpdated: DateTime.now());
    
    final pFeeCtrl = TextEditingController(text: config.platformFeePercentage.toString());
    final taxCtrl = TextEditingController(text: config.taxPercentage.toString());
    final devFeeCtrl = TextEditingController(text: config.defaultDeliveryFee.toString());

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Update Financials', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: pFeeCtrl,
                decoration: InputDecoration(labelText: 'Platform Fee (%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: taxCtrl,
                decoration: InputDecoration(labelText: 'Tax Rate (%)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: devFeeCtrl,
                decoration: InputDecoration(labelText: 'Default Delivery Fee (Rs.)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    final newConfig = AppConfigModel(
                      platformFeePercentage: double.tryParse(pFeeCtrl.text) ?? 0.0,
                      taxPercentage: double.tryParse(taxCtrl.text) ?? 0.0,
                      defaultDeliveryFee: double.tryParse(devFeeCtrl.text) ?? 0.0,
                      lastUpdated: DateTime.now(),
                    );
                    await _dbService.updateAppConfig(newConfig);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // --- Offers Section ---
  Widget _buildOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Promotions & Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add New'),
              onPressed: () => _showOfferDialog(null),
            )
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<OfferModel>>(
          stream: _dbService.streamOffers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final offers = snapshot.data ?? [];
            if (offers.isEmpty) return const Text('No offers available. Create one to boost sales!', style: TextStyle(color: Colors.grey));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offers.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (c, i) {
                final offer = offers[i];
                return InkWell(
                  onTap: () => _showOfferDialog(offer),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: offer.isActive ? AppColors.primaryContainer.withOpacity(0.1) : Colors.grey.shade100, shape: BoxShape.circle),
                          child: Icon(Icons.local_offer, color: offer.isActive ? AppColors.primaryContainer : Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offer.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('${offer.discountPercentage}% OFF • Audience: ${offer.targetAudience.toUpperCase()}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        Switch(
                          value: offer.isActive,
                          activeColor: AppColors.primaryContainer,
                          onChanged: (val) {
                            if (val) {
                              _dbService.makeOfferLive(offer);
                            } else {
                              _dbService.updateOffer(offer.copyWith(isActive: false));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showOfferDialog(OfferModel? offer) {
    final titleCtrl = TextEditingController(text: offer?.title ?? '');
    final descCtrl = TextEditingController(text: offer?.description ?? '');
    final discCtrl = TextEditingController(text: offer?.discountPercentage.toString() ?? '');
    String audience = offer?.targetAudience ?? 'all';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(offer == null ? 'Create Offer' : 'Edit Offer', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (offer != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () {
                              _dbService.deleteOffer(offer.id);
                              Navigator.pop(context);
                            },
                          )
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 16),
                    TextFormField(controller: descCtrl, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), maxLines: 2),
                    const SizedBox(height: 16),
                    TextFormField(controller: discCtrl, decoration: InputDecoration(labelText: 'Discount %', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: audience,
                      decoration: InputDecoration(labelText: 'Target Audience', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'customers', child: Text('Customers Only')),
                        DropdownMenuItem(value: 'farmers', child: Text('Farmers Only')),
                      ],
                      onChanged: (val) => setStateSB(() => audience = val!),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          final newOffer = OfferModel(
                            id: offer?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleCtrl.text,
                            description: descCtrl.text,
                            discountPercentage: double.tryParse(discCtrl.text) ?? 0.0,
                            isActive: offer?.isActive ?? false,
                            targetAudience: audience,
                            createdAt: offer?.createdAt ?? DateTime.now(),
                          );
                          if (offer == null) {
                            await _dbService.addOffer(newOffer);
                          } else {
                            await _dbService.updateOffer(newOffer);
                          }
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Save Offer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  // --- Banners Section ---
  Widget _buildBannersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('App Home Sliders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(
              icon: const Icon(Icons.add_photo_alternate, size: 16),
              label: const Text('Add Slider'),
              onPressed: () => _showBannerDialog(null),
            )
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<BannerModel>>(
          stream: _dbService.streamBanners(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final banners = snapshot.data ?? [];
            if (banners.isEmpty) return const Text('No banners available.', style: TextStyle(color: Colors.grey));

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: banners.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (c, i) {
                final banner = banners[i];
                return InkWell(
                  onTap: () => _showBannerDialog(banner),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (banner.imageUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: _buildBannerImage(banner.imageUrl),
                          )
                        else
                          Container(
                            height: 140, 
                            decoration: const BoxDecoration(color: Color(0xFFEEEEEE), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                            child: const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(banner.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('Link: ${banner.linkType.toUpperCase()} | Dur: ${banner.durationSeconds}s', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: banner.isActive,
                                activeColor: AppColors.primaryContainer,
                                onChanged: (val) {
                                  _dbService.updateBanner(banner.copyWith(isActive: val));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBannerImage(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      // It's a base64 image
      final commaIndex = imageUrl.indexOf(',');
      if (commaIndex != -1) {
        final base64String = imageUrl.substring(commaIndex + 1);
        try {
          final decodedBytes = base64Decode(base64String);
          return Image.memory(decodedBytes, height: 160, width: double.infinity, fit: BoxFit.cover);
        } catch (e) {
          return Container(height: 160, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.error)));
        }
      }
    }
    // Network image fallback
    return Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_,__,___) => Container(height: 160, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image))));
  }

  void _showBannerDialog(BannerModel? banner) {
    final titleCtrl = TextEditingController(text: banner?.title ?? '');
    final durCtrl = TextEditingController(text: banner?.durationSeconds.toString() ?? '5');
    final targetCtrl = TextEditingController(text: banner?.linkTarget ?? '');
    String linkType = banner?.linkType ?? 'none';
    String? currentImage = banner?.imageUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 24, right: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(banner == null ? 'Create Banner' : 'Edit Banner', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (banner != null)
                          IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.error),
                            onPressed: () {
                              _dbService.deleteBanner(banner.id);
                              Navigator.pop(context);
                            },
                          )
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Image Picker Section
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70); // compress
                        if (picked != null) {
                          final bytes = await picked.readAsBytes();
                          setStateSB(() {
                            currentImage = 'data:image/jpeg;base64,${base64Encode(bytes)}';
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                        ),
                        child: currentImage != null && currentImage!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: _buildBannerImage(currentImage!),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text('Tap to select image', style: TextStyle(color: Colors.grey.shade500)),
                                ],
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    TextFormField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Banner Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 16),
                    TextFormField(controller: durCtrl, decoration: InputDecoration(labelText: 'Duration (Seconds)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: linkType,
                      decoration: InputDecoration(labelText: 'On Click Action (Link Type)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                      items: const [
                        DropdownMenuItem(value: 'none', child: Text('No Action')),
                        DropdownMenuItem(value: 'category', child: Text('Open Category ID')),
                        DropdownMenuItem(value: 'search', child: Text('Search Filter (e.g. Farmer Name or Product)')),
                      ],
                      onChanged: (val) => setStateSB(() => linkType = val!),
                    ),
                    const SizedBox(height: 16),
                    if (linkType != 'none')
                      TextFormField(controller: targetCtrl, decoration: InputDecoration(labelText: linkType == 'search' ? 'Search Query' : 'Target ID', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () async {
                          final newBanner = BannerModel(
                            id: banner?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            title: titleCtrl.text,
                            imageUrl: currentImage ?? '',
                            linkType: linkType,
                            linkTarget: linkType == 'none' ? null : targetCtrl.text,
                            durationSeconds: int.tryParse(durCtrl.text) ?? 5,
                            isActive: banner?.isActive ?? true,
                            createdAt: banner?.createdAt ?? DateTime.now(),
                          );
                          if (banner == null) {
                            await _dbService.addBanner(newBanner);
                          } else {
                            await _dbService.updateBanner(newBanner);
                          }
                          if (mounted) Navigator.pop(context);
                        },
                        child: const Text('Save Banner', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}
