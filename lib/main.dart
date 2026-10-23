
import 'package:flutter/material.dart';
import 'api_service.dart';
import 'article_model.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Berita',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const NewsScreen(),
    );
  }
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController =
      ScrollController();

  late Future<List<Article>> _articlesFuture;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    _articlesFuture = _apiService.fetchArticles();

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;

      final showButton = _scrollController.offset > 200;

      if (showButton != _showBackToTop && mounted) {
        setState(() {
          _showBackToTop = showButton;
        });
      }
    });
  }

  // Memuat ulang berita
  Future<void> _refreshArticles() async {
    final future = _apiService.fetchArticles();

    setState(() {
      _articlesFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // Pesan error ditampilkan oleh FutureBuilder.
    }
  }

  // Kembali ke bagian atas
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        title: const Text(
          'Berita Terkini Indonesia',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<List<Article>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          // Tampilan loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Tampilan jika terjadi error
          if (snapshot.hasError) {
            return RefreshIndicator(
              onRefresh: _refreshArticles,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: 450,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 50,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Gagal memuat berita',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SelectableText(
                              snapshot.error.toString(),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _refreshArticles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final articles = snapshot.data ?? [];

          // Tampilan jika berita kosong
          if (articles.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshArticles,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(
                    height: 450,
                    child: Center(
                      child: Text(
                        'Tidak ada berita ditemukan.',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Daftar berita dan pull-to-refresh
          return RefreshIndicator(
            onRefresh: _refreshArticles,
            color: Colors.blue,
            child: ListView.builder(
              controller: _scrollController,
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: 16,
                  ),
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        if (article.urlToImage != null &&
                            article.urlToImage!.isNotEmpty)
                          Image.network(
                            article.urlToImage!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) {
                              return Container(
                                height: 120,
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 45,
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.description ??
                              'Tidak ada deskripsi berita.',
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      // Tombol kembali ke atas
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              tooltip: 'Kembali ke atas',
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }
}
