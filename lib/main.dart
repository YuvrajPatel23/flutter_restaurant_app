import 'package:flutter/material.dart';

void main() {
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bansi Restaurent',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class MenuItem {
  final int id;
  final String name;
  final double price;
  final String category;
  final String imagePath;
  int quantity;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imagePath,
    this.quantity = 1,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<MenuItem> _menuItems = [
    MenuItem(id: 1, name: 'Palak Paneer', price: 8.99, category: 'Mains', imagePath: 'assets/images/1.jpg'),
    MenuItem(id: 2, name: 'Pizza', price: 12.99, category: 'Mains', imagePath: 'assets/images/2.jpg'),
    MenuItem(id: 3, name: 'Chien Tikka Dry', price: 7.49, category: 'Appetizers', imagePath: 'assets/images/3.jpg'),
    MenuItem(id: 4, name: 'Cheese Butter Masala', price: 10.99, category: 'Mains', imagePath: 'assets/images/4.jpg'),
    MenuItem(id: 5, name: 'Cheese balls', price: 2.49, category: 'Appetizers', imagePath: 'assets/images/5.jpg'),
    MenuItem(id: 6, name: 'Cheese pops', price: 4.99, category: 'Appetizers', imagePath: 'assets/images/6.jpg'),
    MenuItem(id: 7, name: 'Hyderabadi Biryani', price: 4.49, category: 'Rice', imagePath: 'assets/images/7.jpg'),
    MenuItem(id: 8, name: 'Palak Ginger', price: 5.99, category: 'Mains', imagePath: 'assets/images/8.jpeg'),
    MenuItem(id: 9, name: 'Paneer Chilli', price: 16.99, category: 'Appetizers', imagePath: 'assets/images/9.jpg'),
    MenuItem(id: 10, name: 'Paneer Aloo', price: 21.00, category: 'Appetizers', imagePath: 'assets/images/10.jpeg'),
    MenuItem(id: 11, name: 'Beer', price: 21.00, category: 'Drinks', imagePath: 'assets/images/11.jpg'),
  ];

  final List<MenuItem> _cartItems = [];
  String _selectedCategory = 'All';

  List<String> get _categories {
    return ['All', ..._menuItems.map((item) => item.category).toSet()];
  }

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'All') return _menuItems;
    return _menuItems.where((item) => item.category == _selectedCategory).toList();
  }

  void _addToCart(MenuItem menuItem) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item.id == menuItem.id);
      if (existingIndex >= 0) {
        _cartItems[existingIndex].quantity += 1;
      } else {
        _cartItems.add(MenuItem(
          id: menuItem.id,
          name: menuItem.name,
          price: menuItem.price,
          category: menuItem.category,
          imagePath: menuItem.imagePath,
          quantity: 1,
        ));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${menuItem.name} to order'), duration: const Duration(seconds: 1)),
    );
  }

  void _clearCart() {
    setState(() {
      _cartItems.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cart cleared'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bansi Restaurent'),
        actions: [_buildCartButton()],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildMenuList()),
        ],
      ),
    );
  }

  Widget _buildCartButton() {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => CartScreen(
                items: _cartItems,
                onPlaceOrder: () {
                  setState(() {
                    _cartItems.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed successfully!'), duration: Duration(seconds: 2)),
                  );
                },
                onClearCart: _clearCart,
              ),
            ),
          ),
        ),
        if (_cartItems.isNotEmpty)
          Positioned(
            right: 8,
            top: 8,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.red,
              child: Text(
                _cartItems.fold(0, (sum, item) => sum + item.quantity).toString(),
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (ctx, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: _selectedCategory == category,
              onSelected: (selected) => setState(() {
                _selectedCategory = selected ? category : 'All';
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredItems.length,
      itemBuilder: (ctx, index) {
        final item = _filteredItems[index];
        return MenuItemCard(item: item, onAddToCart: () => _addToCart(item));
      },
    );
  }
}

class CartScreen extends StatelessWidget {
  final List<MenuItem> items;
  final VoidCallback onPlaceOrder;
  final VoidCallback onClearCart;

  const CartScreen({
    super.key,
    required this.items,
    required this.onPlaceOrder,
    required this.onClearCart,
  });

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Order')),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Your order is empty', style: TextStyle(fontSize: 18)))
                : ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, index) {
                final item = items[index];
                return ListTile(
                  leading: _buildItemImage(item),
                  title: Text(item.name),
                  subtitle: Text('\$${item.price.toStringAsFixed(2)} • ${item.category}'),
                  trailing: Text('x${item.quantity}', style: const TextStyle(fontSize: 16)),
                );
              },
            ),
          ),
          _buildOrderSummary(context),
        ],
      ),
    );
  }

  Widget _buildItemImage(MenuItem item) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(image: AssetImage(item.imagePath), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal:', '\$${totalPrice.toStringAsFixed(2)}'),
          _buildSummaryRow('Tax (10%):', '\$${(totalPrice * 0.1).toStringAsFixed(2)}'),
          const Divider(height: 20),
          _buildSummaryRow(
            'Total:',
            '\$${(totalPrice * 1.1).toStringAsFixed(2)}',
            isBold: true,
          ),
          const SizedBox(height: 16),
          if (items.isNotEmpty)
            Row(
              children: [
                Expanded(child: _buildPlaceOrderButton(context)),
                const SizedBox(width: 10),
                Expanded(child: _buildClearOrderButton(context)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildPlaceOrderButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onPlaceOrder();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('Place Order'),
    );
  }

  Widget _buildClearOrderButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onClearCart();
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const Text('Clear Order'),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onAddToCart;

  const MenuItemCard({super.key, required this.item, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _buildItemImage(),
            const SizedBox(width: 16),
            _buildItemDetails(),
            _buildAddButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: AssetImage(item.imagePath), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(item.category, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton(
      onPressed: onAddToCart,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: const Text('Add'),
    );
  }
}
