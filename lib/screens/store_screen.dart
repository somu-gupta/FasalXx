import 'package:flutter/material.dart';

import '../screens/cart_screen.dart';
import '../services/cart_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/fasalx_header.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  _SortOption _selectedSort = _SortOption.popularity;
  String _query = '';

  static const _categories = [
    'All',
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Tools',
  ];
  static const _products = [
    _Product(
      id: 1,
      name: 'Hybrid Wheat Seeds',
      category: 'Seeds',
      quantity: '10 kg',
      price: 'Rs 1,250',
      priceValue: 1250,
      popularity: 94,
      image: 'wheat_seeds',
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
      id: 2,
      name: 'DAP Fertilizer',
      category: 'Fertilizers',
      quantity: '45 kg',
      price: 'Rs 1,350',
      priceValue: 1350,
      popularity: 89,
      image: 'dap_fertilizer',
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
      id: 3,
      name: 'Neem Pesticide',
      category: 'Pesticides',
      quantity: '1 litre',
      price: 'Rs 420',
      priceValue: 420,
      popularity: 82,
      image: 'neem_pesticide',
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
      id: 4,
      name: 'Spray Pump',
      category: 'Tools',
      quantity: '16 litre',
      price: 'Rs 2,100',
      priceValue: 2100,
      popularity: 91,
      image: 'spray_pump',
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
      id: 5,
      name: 'Zinc Micronutrient',
      category: 'Fertilizers',
      quantity: '5 kg',
      price: 'Rs 680',
      priceValue: 680,
      popularity: 76,
      image: 'zinc_micronutrient',
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
      id: 6,
      name: 'Soyabean Seeds',
      category: 'Seeds',
      quantity: '30 kg',
      price: 'Rs 3,250',
      priceValue: 3250,
      popularity: 86,
      image: 'soyabean_seeds',
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
    final products = _products.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final lowerQuery = _query.toLowerCase();
      final matchesSearch =
          lowerQuery.isEmpty ||
          product.name.toLowerCase().contains(lowerQuery) ||
          product.category.toLowerCase().contains(lowerQuery) ||
          product.compatibility.toLowerCase().contains(lowerQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    _sortProducts(products);
    return products;
  }

  void _sortProducts(List<_Product> products) {
    // Keep sorting in one place so category/search filtering can reuse it safely.
    switch (_selectedSort) {
      case _SortOption.popularity:
        products.sort((a, b) => b.popularity.compareTo(a.popularity));
        break;
      case _SortOption.priceLowToHigh:
        products.sort((a, b) => a.priceValue.compareTo(b.priceValue));
        break;
      case _SortOption.priceHighToLow:
        products.sort((a, b) => b.priceValue.compareTo(a.priceValue));
        break;
    }
  }

  void _selectSort(_SortOption option) {
    setState(() => _selectedSort = option);
    Navigator.of(context).pop();
  }

  void _openSortSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SortSheet(selectedSort: _selectedSort, onSelected: _selectSort);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = _filteredProducts;
    final cart = CartScope.watch(context);
    final fx = context.fx;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const FasalXHeader(),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'FasalX Store',
                              style: TextStyle(
                                color: fx.textStrong,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          _StoreQuickActionButton(
                            tooltip: 'Order history',
                            icon: Icons.history_rounded,
                            onTap: () => _openOrderHistory(context),
                          ),
                          const SizedBox(width: 8),
                          _StoreQuickActionButton(
                            tooltip: 'Cart',
                            icon: Icons.shopping_cart_outlined,
                            count: cart.totalItems,
                            onTap: () => _openCart(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _SearchBar(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _SortButton(
                            label: _selectedSort.shortLabel,
                            onTap: _openSortSheet,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _CategoryFilters(
                        categories: _categories,
                        selected: _selectedCategory,
                        onSelected: (category) =>
                            setState(() => _selectedCategory = category),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Text(
                            'Products',
                            style: TextStyle(
                              color: fx.textStrong,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Sorted by ${_selectedSort.label}',
                            style: TextStyle(
                              color: fx.textMuted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 206),
                sliver: products.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyStoreState())
                    : SliverGrid.builder(
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: 14,
                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final quantity = cart.quantityFor(product.id);
                          return _ProductCard(
                            product: product,
                            quantity: quantity,
                            onTap: () => _showProductDetails(product),
                            onAdd: () => cart.add(product.toCartProduct()),
                            onMinus: () => cart.decrement(product.id),
                            onPlus: () => cart.increment(product.id),
                          );
                        },
                      ),
              ),
            ],
          ),
          _FloatingCartSummary(
            cart: cart,
            onViewCart: () => _openCart(context),
          ),
        ],
      ),
    );
  }

  void _openCart(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  void _openOrderHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
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
            CartScope.read(context).add(product.toCartProduct());
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

enum _SortOption { popularity, priceLowToHigh, priceHighToLow }

extension _SortOptionLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.popularity:
        return 'Popularity';
      case _SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case _SortOption.priceHighToLow:
        return 'Price: High to Low';
    }
  }

  String get shortLabel {
    switch (this) {
      case _SortOption.popularity:
        return 'Popular';
      case _SortOption.priceLowToHigh:
        return 'Low-High';
      case _SortOption.priceHighToLow:
        return 'High-Low';
    }
  }

  IconData get icon {
    switch (this) {
      case _SortOption.popularity:
        return Icons.trending_up_rounded;
      case _SortOption.priceLowToHigh:
        return Icons.south_rounded;
      case _SortOption.priceHighToLow:
        return Icons.north_rounded;
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search seeds, fertilizers, tools...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: fx.fieldFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: fx.border),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: fx.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: fx.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 21,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  const _SortSheet({required this.selectedSort, required this.onSelected});

  final _SortOption selectedSort;
  final ValueChanged<_SortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    const options = [
      _SortOption.popularity,
      _SortOption.priceLowToHigh,
      _SortOption.priceHighToLow,
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        18 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: fx.surfaceAlt,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(
            'Sort By',
            style: TextStyle(
              color: fx.textStrong,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final option in options) ...[
            _SortOptionTile(
              option: option,
              isSelected: selectedSort == option,
              onTap: () => onSelected(option),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  const _SortOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _SortOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: isSelected ? fx.selectedFill : fx.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : fx.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                option.icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : fx.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : fx.textStrong,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
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
    final fx = context.fx;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories) ...[
            ChoiceChip(
              label: Text(category),
              selected: selected == category,
              onSelected: (_) => onSelected(category),
              selectedColor: fx.selectedFill,
              checkmarkColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: selected == category
                    ? Theme.of(context).colorScheme.primary
                    : fx.textMuted,
                fontWeight: FontWeight.w900,
              ),
              side: BorderSide(
                color: selected == category
                    ? Theme.of(context).colorScheme.primary
                    : fx.border,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.onTap,
    required this.onAdd,
    required this.onMinus,
    required this.onPlus,
  });

  final _Product product;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Material(
      color: fx.surface,
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
                style: TextStyle(
                  color: fx.textStrong,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                product.quantity,
                style: TextStyle(
                  color: fx.textMuted,
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  quantity == 0
                      ? SizedBox(
                          width: 42,
                          height: 42,
                          child: IconButton.filled(
                            tooltip: 'Add to cart',
                            onPressed: onAdd,
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                            ),
                            icon: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 20,
                            ),
                          ),
                        )
                      : _StoreQuantityControls(
                          quantity: quantity,
                          onMinus: onMinus,
                          onPlus: onPlus,
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

class _StoreQuantityControls extends StatelessWidget {
  const _StoreQuantityControls({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_rounded, size: 17),
            color: Theme.of(context).colorScheme.primary,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 30, height: 38),
            padding: EdgeInsets.zero,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Text(
              '$quantity',
              key: ValueKey(quantity),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_rounded, size: 17),
            color: Theme.of(context).colorScheme.primary,
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints.tightFor(width: 30, height: 38),
            padding: EdgeInsets.zero,
          ),
        ],
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
    final fx = context.fx;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      decoration: BoxDecoration(
        color: fx.surfaceAlt,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                      style: TextStyle(
                        color: fx.textStrong,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.brand} • ${product.quantity}',
                      style: TextStyle(
                        color: fx.textMuted,
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
            style: TextStyle(
              color: fx.textMuted,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _DetailLine(
            icon: Icons.spa_outlined,
            label: 'Crop compatibility',
            value: product.compatibility,
          ),
          _DetailLine(
            icon: Icons.fact_check_outlined,
            label: 'Usage',
            value: product.usage,
          ),
          _DetailLine(
            icon: Icons.star_rounded,
            label: 'Rating',
            value: '${product.rating} / 5 reviews',
          ),
          _DetailLine(
            icon: Icons.local_shipping_outlined,
            label: 'Stock',
            value: product.stock,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text(
                'Add to Cart • ${product.price}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: fx.textStrong,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: fx.textMuted,
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

class _StoreQuickActionButton extends StatelessWidget {
  const _StoreQuickActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.count = 0,
  });

  final String tooltip;
  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: fx.surface,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          hoverColor: fx.selectedFill,
          splashColor: fx.selectedFill,
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: fx.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(icon, color: fx.textStrong, size: 24),
                if (count > 0)
                  Positioned(
                    right: 5,
                    top: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white, width: 1.4),
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
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingCartSummary extends StatelessWidget {
  const _FloatingCartSummary({required this.cart, required this.onViewCart});

  final CartController cart;
  final VoidCallback onViewCart;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      left: 16,
      right: 16,
      bottom: cart.isEmpty ? -110 : 112,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: cart.isEmpty ? 0 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(22),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${cart.totalItems} items',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Total ${_formatStoreMoney(cart.subtotal)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onViewCart,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F9D6C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('View Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  const _SmallTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final fx = context.fx;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: fx.selectedFill,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
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
    final fx = context.fx;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 54, color: fx.textMuted),
          const SizedBox(height: 12),
          Text(
            'No products found',
            style: TextStyle(
              color: fx.textStrong,
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
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.priceValue,
    required this.popularity,
    required this.image,
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

  final int id;
  final String name;
  final String category;
  final String quantity;
  final String price;
  final int priceValue;
  final int popularity;
  final String image;
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

  CartProduct toCartProduct() {
    return CartProduct(
      id: id,
      name: name,
      quantityLabel: quantity,
      price: priceValue,
      iconCodePoint: icon.codePoint,
      colorValue: color.toARGB32(),
      category: category,
    );
  }
}

String _formatStoreMoney(int value) => '\u20B9$value';
