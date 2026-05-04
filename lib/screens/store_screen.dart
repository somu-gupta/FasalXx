import 'package:flutter/material.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _query = '';
  int _cartCount = 0;

  static const _categories = ['All', 'Seeds', 'Fertilizers', 'Pesticides', 'Tools'];
  static const _products = [
    _Product(
      name: 'Hybrid Wheat Seeds',
      category: 'Seeds',
      quantity: '10 kg',
      price: 'Rs 1,250',
      icon: Icons.grass_rounded,
      color: Color(0xFF16823A),
      description: 'High germination wheat seeds suitable for rabi season.',
      compatibility: 'Wheat',
      usage: 'Use 40-45 kg per acre after soil preparation.',
      brand: 'AgriGrow',
      rating: '4.7',
      stock: 'Available nearby',
      tag: 'Best for Your Crop',
      discount: '8% off',
    ),
    _Product(
      name: 'DAP Fertilizer',
      category: 'Fertilizers',
      quantity: '45 kg',
      price: 'Rs 1,350',
      icon: Icons.science_outlined,
      color: Color(0xFF2563EB),
      description: 'Phosphorus-rich fertilizer for strong root development.',
      compatibility: 'Wheat, Gram, Mustard',
      usage: 'Apply as basal dose as advised by soil test.',
      brand: 'KrishiCare',
      rating: '4.5',
      stock: 'Delivery in 2 days',
      tag: 'AI Suggested',
      discount: 'Subsidy eligible',
    ),
    _Product(
      name: 'Neem Pesticide',
      category: 'Pesticides',
      quantity: '1 litre',
      price: 'Rs 420',
      icon: Icons.bug_report_outlined,
      color: Color(0xFFF59E0B),
      description: 'Botanical pest control for common sucking pests.',
      compatibility: 'Vegetables, Soyabean',
      usage: 'Mix as per label and spray in morning/evening.',
      brand: 'BioShield',
      rating: '4.4',
      stock: 'Available nearby',
      tag: 'Low chemical',
      discount: '',
    ),
    _Product(
      name: 'Spray Pump',
      category: 'Tools',
      quantity: '16 litre',
      price: 'Rs 2,100',
      icon: Icons.handyman_outlined,
      color: Color(0xFF7C3AED),
      description: 'Manual sprayer for pesticides and micronutrients.',
      compatibility: 'All crops',
      usage: 'Clean tank after each spray and use safety mask.',
      brand: 'FarmTool',
      rating: '4.6',
      stock: 'Limited stock',
      tag: 'Popular',
      discount: '5% off',
    ),
    _Product(
      name: 'Zinc Micronutrient',
      category: 'Fertilizers',
      quantity: '5 kg',
      price: 'Rs 680',
      icon: Icons.eco_outlined,
      color: Color(0xFF0F766E),
      description: 'Helps correct zinc deficiency and improves crop growth.',
      compatibility: 'Wheat, Rice, Maize',
      usage: 'Apply after deficiency symptoms or soil recommendation.',
      brand: 'NutriFarm',
      rating: '4.3',
      stock: 'Delivery available',
      tag: 'Recommended',
      discount: '',
    ),
    _Product(
      name: 'Soyabean Seeds',
      category: 'Seeds',
      quantity: '30 kg',
      price: 'Rs 3,250',
      icon: Icons.spa_outlined,
      color: Color(0xFF65A30D),
      description: 'Certified seeds for kharif sowing with stable yield.',
      compatibility: 'Soyabean',
      usage: 'Use treated seed and maintain proper spacing.',
      brand: 'SeedPlus',
      rating: '4.5',
      stock: 'Available nearby',
      tag: 'MP farmers pick',
      discount: '6% off',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Product> get _filteredProducts {
    return _products.where((product) {
      final matchesCategory = _selectedCategory == 'All' || product.category == _selectedCategory;
      final lowerQuery = _query.toLowerCase();
      final matchesSearch = lowerQuery.isEmpty ||
          product.name.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery) ||
          product.compatibility.toLowerCase().contains(lowerQuery);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF4),
      appBar: AppBar(
        title: const Text('FasalX Store', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFFF7FAF4),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          _CartButton(count: _cartCount),
          const SizedBox(width: 12),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchBar(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 14),
                  _CategoryFilters(
                    categories: _categories,
                    selected: _selectedCategory,
                    onSelected: (category) => setState(() => _selectedCategory = category),
                  ),
                  const SizedBox(height: 18),
                  const _RecommendedBanner(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Text(
                        'Products',
                        style: TextStyle(
                          color: Color(0xFF17251A),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: const Text('Sort'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF16823A),
                          textStyle: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 176),
            sliver: products.isEmpty
                ? const SliverToBoxAdapter(child: _EmptyStoreState())
                : SliverGrid.builder(
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _ProductCard(
                        product: product,
                        onTap: () => _showProductDetails(product),
                        onAdd: () {
                          setState(() => _cartCount++);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${product.name} added to cart')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(_Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProductDetailsSheet(
          product: product,
          onAdd: () {
            setState(() => _cartCount++);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.name} added to cart')),
            );
          },
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search seeds, fertilizers, tools...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFFE4EDE0)),
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  const _CategoryFilters({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories) ...[
            ChoiceChip(
              label: Text(category),
              selected: selected == category,
              onSelected: (_) => onSelected(category),
              selectedColor: const Color(0xFFEAF7E8),
              checkmarkColor: const Color(0xFF16823A),
              labelStyle: TextStyle(
                color: selected == category ? const Color(0xFF14532D) : const Color(0xFF667366),
                fontWeight: FontWeight.w900,
              ),
              side: BorderSide(
                color: selected == category ? const Color(0xFF16823A) : const Color(0xFFE0E8DD),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _RecommendedBanner extends StatelessWidget {
  const _RecommendedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6EED2)),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF16823A)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended for You',
                  style: TextStyle(
                    color: Color(0xFF17251A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Best products for Wheat crop in Field A',
                  style: TextStyle(
                    color: Color(0xFF556755),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  final _Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 82,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: product.color.withAlpha(22),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(product.icon, color: product.color, size: 42),
                  ),
                  if (product.discount.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _SmallTag(label: product.discount),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF17251A),
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.quantity,
                style: const TextStyle(
                  color: Color(0xFF667366),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.price,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF14532D),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: IconButton.filled(
                      tooltip: 'Add to cart',
                      onPressed: onAdd,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF14532D),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductDetailsSheet extends StatelessWidget {
  const _ProductDetailsSheet({required this.product, required this.onAdd});

  final _Product product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.82),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFCF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD8E2D4),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: product.color.withAlpha(25),
                child: Icon(product.icon, color: product.color, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Color(0xFF17251A),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.brand} • ${product.quantity}',
                      style: const TextStyle(
                        color: Color(0xFF667366),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _SmallTag(label: product.tag),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            product.description,
            style: const TextStyle(
              color: Color(0xFF435246),
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _DetailLine(icon: Icons.spa_outlined, label: 'Crop compatibility', value: product.compatibility),
          _DetailLine(icon: Icons.fact_check_outlined, label: 'Usage', value: product.usage),
          _DetailLine(icon: Icons.star_rounded, label: 'Rating', value: '${product.rating} / 5 reviews'),
          _DetailLine(icon: Icons.local_shipping_outlined, label: 'Stock', value: product.stock),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF14532D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text(
                'Add to Cart • ${product.price}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF16823A), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF17251A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF667366),
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Cart',
          onPressed: () {},
          icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF17251A)),
        ),
        if (count > 0)
          Positioned(
            right: 5,
            top: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7E8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF14532D),
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyStoreState extends StatelessWidget {
  const _EmptyStoreState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: const [
          Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF8A968A)),
          SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(
              color: Color(0xFF435246),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Product {
  const _Product({
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.icon,
    required this.color,
    required this.description,
    required this.compatibility,
    required this.usage,
    required this.brand,
    required this.rating,
    required this.stock,
    required this.tag,
    required this.discount,
  });

  final String name;
  final String category;
  final String quantity;
  final String price;
  final IconData icon;
  final Color color;
  final String description;
  final String compatibility;
  final String usage;
  final String brand;
  final String rating;
  final String stock;
  final String tag;
  final String discount;
}
