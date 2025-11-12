import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/bottom_nav.dart';
import 'dart:math';

class PlacesListPage extends StatefulWidget {
  final String userId;
  const PlacesListPage({super.key, required this.userId});

  @override
  State<PlacesListPage> createState() => _PlacesListPageState();
}

class _PlacesListPageState extends State<PlacesListPage> with SingleTickerProviderStateMixin {
  final _db = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> places = [];
  bool _isLoading = true;
  final int _currentIndex = 1;
  late AnimationController _starController;
  final List<Star> _stars = [];
  final Random _random = Random();
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    _initializeStars();
    _loadPlaces();
  }

  void _initializeStars() {
    for (int i = 0; i < 30; i++) {
      _stars.add(Star(
        x: _random.nextDouble() * 1.5 - 0.5,
        y: _random.nextDouble() * 2 - 1,
        speed: 0.3 + _random.nextDouble() * 0.7,
        size: 2.0 + _random.nextDouble() * 4.0,
        delay: _random.nextDouble() * 3.0,
        brightness: 0.6 + _random.nextDouble() * 0.4,
      ));
    }
  }

  void _loadPlaces() async {
    final snapshot = await _db.child('places').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final placesList = <Map<String, dynamic>>[];
      
      for (final placeId in data.keys) {
        final placeData = Map<String, dynamic>.from(data[placeId] as Map);
        placeData['id'] = placeId;
        
        // Загрузка отзывов для каждого места
        final reviewsSnapshot = await _db.child('places/$placeId/reviews').get();
        List<Map<String, dynamic>> reviews = [];
        double totalRating = 0;
        
        if (reviewsSnapshot.exists) {
          final reviewsData = Map<String, dynamic>.from(reviewsSnapshot.value as Map);
          for (final reviewId in reviewsData.keys) {
            final reviewData = Map<String, dynamic>.from(reviewsData[reviewId] as Map);
            reviews.add(reviewData);
            totalRating += reviewData['rating'] as double;
          }
        }
        
        placeData['reviews'] = reviews;
        placeData['averageRating'] = reviews.isNotEmpty ? totalRating / reviews.length : 0.0;
        placeData['reviewsCount'] = reviews.length;
        
        placesList.add(placeData);
      }
      
      setState(() {
        places = placesList;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigate(int index) {
    final routes = [
      '/choice_tests',
      '/map_page',
      '/chat',
      '/professions',
      '/profile',
    ];
    if (index >= 0 && index < routes.length) {
      Navigator.pushReplacementNamed(context, routes[index], arguments: widget.userId);
    }
  }

  Widget _buildStarBackground() {
    if (!_isDarkMode) return const SizedBox();

    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Stack(
          children: _stars.map((star) {
            final progress = (_starController.value * star.speed + star.delay) % 2.0;
            final x = star.x + progress * 1.5;
            final y = star.y + progress * 1.5;
            final opacity = x > 0 && x < 1.5 && y > -0.5 && y < 1.5
                ? (1.0 - (progress / 2.0).abs()) * star.brightness
                : 0.0;

            final pulse = (sin(_starController.value * 5 * pi + star.delay * 8) + 1) / 2;
            final currentOpacity = opacity * (0.8 + 0.2 * pulse);

            return Positioned(
              left: x * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: currentOpacity.clamp(0.0, 1.0),
                child: Container(
                  width: star.size,
                  height: star.size,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.9),
                        blurRadius: star.size * 3,
                        spreadRadius: star.size * 0.8,
                      ),
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: star.size * 6,
                        spreadRadius: star.size * 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showPlaceDetails(Map<String, dynamic> place) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Place Details",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [const Color(0xFF1E3A8A), const Color(0xFF0A0F2D)]
                    : [Colors.white, const Color(0xFFE3F2FD)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Заголовок
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFF6C63FF),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        place['name'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: _isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Рейтинг
                Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final rating = place['averageRating'] as double;
                        if (index < rating.floor()) {
                          return const Icon(Icons.star, color: Colors.amber, size: 20);
                        } else if (index < rating) {
                          return const Icon(Icons.star_half, color: Colors.amber, size: 20);
                        } else {
                          return Icon(Icons.star_border, color: Colors.grey[400], size: 20);
                        }
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(place['averageRating'] as double).toStringAsFixed(1)} (${place['reviewsCount']} отзывов)',
                      style: GoogleFonts.nunito(
                        color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Описание
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    place['description'] as String,
                    style: GoogleFonts.nunito(
                      color: _isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Кнопки
                if (place['url'] != null && place['url'].toString().isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _launchURL(place['url'] as String);
                    },
                    icon: const Icon(Icons.link, size: 18),
                    label: Text(
                      'Перейти по ссылке',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Кнопка добавления отзыва
                ElevatedButton.icon(
                  onPressed: () => _showAddReviewDialog(place),
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: Text(
                    'Оставить отзыв',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Отзывы
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Отзывы',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: (place['reviews'] as List).isEmpty
                              ? Center(
                                  child: Text(
                                    'Пока нет отзывов',
                                    style: GoogleFonts.nunito(
                                      color: _isDarkMode ? Colors.white60 : Colors.grey[600],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: (place['reviews'] as List).length,
                                  itemBuilder: (context, index) {
                                    final review = (place['reviews'] as List)[index] as Map<String, dynamic>;
                                    return _buildReviewItem(review);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final rating = review['rating'] as double;
                  if (index < rating.floor()) {
                    return const Icon(Icons.star, color: Colors.amber, size: 16);
                  } else if (index < rating) {
                    return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                  } else {
                    return Icon(Icons.star_border, color: Colors.grey[400], size: 16);
                  }
                }),
              ),
              const SizedBox(width: 8),
              Text(
                (review['rating'] as double).toStringAsFixed(1),
                style: GoogleFonts.nunito(
                  color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (review['comment'] != null && review['comment'].toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review['comment'] as String,
              style: GoogleFonts.nunito(
                color: _isDarkMode ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddReviewDialog(Map<String, dynamic> place) {
    double rating = 5.0;
    final commentController = TextEditingController();

    showGeneralDialog(
      context: context,
      barrierLabel: "Add Review",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isDarkMode
                    ? [const Color(0xFF1E3A8A), const Color(0xFF0A0F2D)]
                    : [Colors.white, const Color(0xFFE3F2FD)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Оставить отзыв',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      place['name'] as String,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6C63FF),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Ваша оценка',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(10, (index) {
                        final starValue = (index + 1) * 0.5;
                        final isSelected = starValue <= rating;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              rating = starValue;
                            });
                          },
                          child: Icon(
                            starValue <= rating
                                ? (starValue % 1 == 0 ? Icons.star : Icons.star_half)
                                : Icons.star_border,
                            color: isSelected ? Colors.amber : Colors.grey[400],
                            size: 30,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      rating.toStringAsFixed(1),
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Ваш комментарий (необязательно)',
                        hintStyle: GoogleFonts.nunito(
                          color: _isDarkMode ? Colors.white60 : Colors.grey[600],
                        ),
                        filled: true,
                        fillColor: _isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: GoogleFonts.nunito(
                        color: _isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Отмена',
                            style: GoogleFonts.nunito(
                              color: _isDarkMode ? Colors.white70 : Colors.grey[700]!,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final review = {
                              'userId': widget.userId,
                              'rating': rating,
                              'comment': commentController.text.trim(),
                              'timestamp': ServerValue.timestamp,
                            };

                            await _db.child('places/${place['id']}/reviews').push().set(review);
                            
                            if (mounted) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              _loadPlaces();
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Отзыв добавлен!',
                                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Отправить',
                            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child),
        );
      },
    );
  }

  void _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF0A0F2D) : Colors.grey[100],
      body: Stack(
        children: [
          _buildStarBackground(),
          SafeArea(
            child: Column(
              children: [
                // Заголовок
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isDarkMode ? Colors.white.withOpacity(0.95) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF6C63FF)),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Интересные места",
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: _isDarkMode ? const Color(0xFF0A0F2D) : Colors.black,
                              ),
                            ),
                            Text(
                              "Удмуртская Республика",
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                // Список мест
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: const Color(0xFF6C63FF),
                          ),
                        )
                      : places.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 64,
                                    color: _isDarkMode ? Colors.white30 : Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Пока нет добавленных мест',
                                    style: GoogleFonts.nunito(
                                      fontSize: 18,
                                      color: _isDarkMode ? Colors.white60 : Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Добавьте первое место на карте',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: _isDarkMode ? Colors.white24 : Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: places.length,
                              itemBuilder: (context, index) {
                                final place = places[index];
                                return _buildPlaceCard(place);
                              },
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: _navigate, userId: widget.userId),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isDarkMode
              ? [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPlaceDetails(place),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFF6C63FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place['name'] as String,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            place['description'] as String,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        final rating = place['averageRating'] as double;
                        if (index < rating.floor()) {
                          return const Icon(Icons.star, color: Colors.amber, size: 16);
                        } else if (index < rating) {
                          return const Icon(Icons.star_half, color: Colors.amber, size: 16);
                        } else {
                          return Icon(Icons.star_border, color: Colors.grey[400], size: 16);
                        }
                      }),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(place['averageRating'] as double).toStringAsFixed(1)} (${place['reviewsCount']})',
                      style: GoogleFonts.nunito(
                        color: _isDarkMode ? Colors.white60 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double delay;
  final double brightness;

  Star({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.delay,
    required this.brightness,
  });
}