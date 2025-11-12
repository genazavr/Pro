import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/themed_page.dart';
import 'services/event_service.dart';
import 'dart:math';

class MerchShopScreen extends StatefulWidget {
  final String userId;
  const MerchShopScreen({super.key, required this.userId});

  @override
  State<MerchShopScreen> createState() => _MerchShopScreenState();
}

class _MerchShopScreenState extends State<MerchShopScreen> {
  final _db = FirebaseDatabase.instance.ref();
  final EventService _eventService = EventService();
  
  late List<Map<String, dynamic>> merchandise;
  Map<int, int> cartItems = {};
  int _userStars = 0;

  @override
  void initState() {
    super.initState();
    _initializeMerchandise();
    _loadUserStars();
  }

  Future<void> _loadUserStars() async {
    final stars = await _eventService.getUserStars(widget.userId);
    setState(() {
      _userStars = stars;
    });
  }

  void _initializeMerchandise() {
    merchandise = [
      {
        'id': 0,
        'name': 'Футболка',
        'price': 50,
        'description': 'Стильная футболка с логотипом',
        'icon': Icons.shopping_bag,
      },
      {
        'id': 1,
        'name': 'Шорты',
        'price': 40,
        'description': 'Удобные спортивные шорты',
        'icon': Icons.shopping_bag,
      },
      {
        'id': 2,
        'name': 'Ручки',
        'price': 10,
        'description': 'Набор качественных ручек (5 шт)',
        'icon': Icons.edit,
      },
      {
        'id': 3,
        'name': 'Блокнот',
        'price': 20,
        'description': 'Красивый блокнот для заметок',
        'icon': Icons.note,
      },
    ];
  }

  Future<void> _purchaseItems() async {
    final totalPrice = _getTotalPrice();
    
    if (totalPrice > _userStars) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Недостаточно звезд! Нужно: $totalPrice, есть: $_userStars',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final success = await _eventService.purchaseMerch(widget.userId, totalPrice);
      
      if (success) {
        await _db.child('users/${widget.userId}/purchases').push().set({
          'timestamp': DateTime.now().toIso8601String(),
          'total': totalPrice,
          'items': cartItems,
        });

        if (mounted) {
          setState(() {
            cartItems.clear();
            _userStars -= totalPrice;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Покупка успешна! Потрачено звезд: $totalPrice',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Ошибка при покупке',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ошибка: $e',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addToCart(int id) {
    setState(() {
      cartItems[id] = (cartItems[id] ?? 0) + 1;
    });
  }

  void _removeFromCart(int id) {
    if (cartItems.containsKey(id) && cartItems[id]! > 0) {
      setState(() {
        cartItems[id] = cartItems[id]! - 1;
        if (cartItems[id] == 0) {
          cartItems.remove(id);
        }
      });
    }
  }

  int _getTotalPrice() {
    int total = 0;
    cartItems.forEach((id, quantity) {
      final item = merchandise.firstWhere((item) => item['id'] == id);
      total += (item['price'] as int) * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _getTotalPrice();
    
    return ThemedPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'Магазин мерча',
                        style: GoogleFonts.nunito(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_userStars',
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Badge(
                      label: Text(
                        cartItems.values.fold(0, (sum, v) => sum + v).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFF6C63FF),
                      child: const Icon(Icons.shopping_cart, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: merchandise.length,
                  itemBuilder: (context, index) {
                    final item = merchandise[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Icon(
                                item['icon'] as IconData,
                                size: 40,
                                color: const Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0A0F2D),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'] as String,
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item['price']}',
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (cartItems.containsKey(item['id']))
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF6C63FF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'В корзине: ${cartItems[item['id']]}',
                                          style: GoogleFonts.nunito(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    if (!cartItems.containsKey(item['id']))
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _addToCart(item['id'] as int),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6C63FF),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'В корзину',
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (cartItems.containsKey(item['id'])) ...[
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _removeFromCart(item['id'] as int),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            '-',
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () => _addToCart(item['id'] as int),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF6C63FF),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            '+',
                                            style: GoogleFonts.nunito(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (cartItems.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Итого:',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '$totalPrice',
                                  style: GoogleFonts.nunito(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _purchaseItems,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Купить',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}