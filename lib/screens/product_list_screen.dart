import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatelessWidget {
  ProductListScreen({super.key});

  final List<Product> dummyProducts = [
    Product(
      id: 'p1',
      title: 'Sepatu Putih',
      price: 250000,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHNVBMcx8vkgpR4yf4JepVeMM7G5Ztikk8mTMJPFCVyw&s=10',
    ),
    Product(
      id: 'p2',
      title: 'Headphones Wireless',
      price: 350000,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtxsFy1QfAA-0HMrHPqfYVI0WcaNHuUqVPmyDLi4niEg&s=10',
    ),
    Product(
      id: 'p3',
      title: 'Digicam DC403',
      price: 500000,
      imageUrl: 'https://image.made-in-china.com/202f0j00LICoPdBslOrg/DC403-44MP-1080P-HD-Digital-Camera-Kids-Professional-Photography-Camera.webp',
    ),
    Product(
      id: 'p4',
      title: 'Tumblr Minum',
      price: 120000,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRN89zTQjkbTyEsB9KpFhdVcM9wDx2DEndTHfAuNzfhmg&s=10',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD6D6),
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.white, size: 28),
        centerTitle: true,
        title: const Text(
          'Smart-Cart',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, childWidget) => Badge(
              label: Text(cart.itemCount.toString()),
              isLabelVisible: cart.itemCount > 0,
              backgroundColor: const Color(0xFFFF2B2B),
              child: childWidget,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const CartScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9ECEC),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.brown),
                  hintText: 'Cari produk...',
                  hintStyle: TextStyle(color: Color(0xFFB59393)),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          // Product Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: dummyProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (ctx, i) {
                final product = dummyProducts[i];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9ECEC),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF5D4037),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rp ${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                              style: const TextStyle(
                                color: Color(0xFF5D4037),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFD1D1),
                                  elevation: 1,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onPressed: () {
                                  Provider.of<CartProvider>(context, listen: false)
                                      .addItem(product);
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${product.title} ditambahkan!'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: const Color(0xFFFF8A8A),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 16, color: Color(0xFF5D4037)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tambah',
                                      style: TextStyle(
                                        color: Color(0xFF5D4037),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}