// Mengimpor paket bawaan Flutter untuk membangun antarmuka UI dengan Material Design
import 'package:flutter/material.dart';
// Mengimpor paket provider untuk manajemen state reaktif aplikasi
import 'package:provider/provider.dart';

// ==========================================
// 1. MODEL (Struktur Data)
// ==========================================

// Class Product digunakan sebagai blueprint (cetakan) data barang yang dijual
class Product {
  final String id; // Properti unik untuk mengidentifikasi produk
  final String title; // Nama atau judul produk
  final double price; // Harga produk dalam tipe data angka desimal
  final String imageUrl; // Alamat link (URL) gambar produk

  // Constructor untuk menginisialisasi properti class Product (semua wajib diisi)
  Product({
    required this.id, // Menandakan parameter id wajib diisi
    required this.title, // Menandakan parameter title wajib diisi
    required this.price, // Menandakan parameter price wajib diisi
    required this.imageUrl, // Menandakan parameter imageUrl wajib diisi
  });
}

// Class CartItem merepresentasikan satu jenis produk yang ada di dalam keranjang belanja
class CartItem {
  final Product product; // Objek data produk itu sendiri
  int quantity; // Jumlah (kuantitas) barang yang dibeli (bisa bertambah/berkurang)

  // Constructor untuk menginisialisasi CartItem (kuantitas default adalah 1)
  CartItem({
    required this.product, // Parameter produk wajib diisi
    this.quantity = 1, // Kuantitas opsional, default nilainya 1
  });
}

// Fungsi pembantu (helper) untuk mengubah angka menjadi format mata uang Rupiah (contoh: Rp 150.000)
String formatRupiah(double amount) {
  // Mengubah double ke String tanpa desimal, lalu menambahkan titik setiap kelipatan 3 digit dari belakang
  return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
}

// ==========================================
// 2. STATE MANAGER (PROVIDER)
// ==========================================

// Class CartProvider mengelola data keranjang dan memberitahu UI jika ada perubahan (ChangeNotifier)
class CartProvider with ChangeNotifier {
  // Map internal untuk menyimpan item keranjang dengan productId sebagai Key-nya
  final Map<String, CartItem> _items = {};

  // Getter untuk mengambil data keranjang dari luar class dalam bentuk copy (mencegah modifikasi langsung)
  Map<String, CartItem> get items => {..._items};

  // Getter untuk menghitung total seluruh kuantitas barang yang ada di keranjang
  int get itemCount {
    int total = 0; // Inisialisasi variabel penampung total item
    _items.forEach((key, cartItem) { // Melakukan perulangan untuk setiap item di keranjang
      total += cartItem.quantity; // Menambahkan kuantitas tiap item ke variabel total
    });
    return total; // Mengembalikan jumlah total kuantitas item
  }

  // Getter untuk menghitung total keseluruhan harga belanjaan di keranjang
  double get totalAmount {
    var total = 0.0; // Inisialisasi variabel penampung total harga
    _items.forEach((key, cartItem) { // Melakukan perulangan untuk setiap item di keranjang
      total += cartItem.product.price * cartItem.quantity; // Mengalikan harga dengan kuantitas item lalu menjumlahkannya
    });
    return total; // Mengembalikan jumlah total biaya
  }

  // Method untuk menambahkan produk ke dalam keranjang belanja
  void addItem(Product product) {
    if (_items.containsKey(product.id)) { // Mengecek apakah produk sudah ada di keranjang
      _items.update( // Jika sudah ada, perbarui kuantitas produk tersebut
        product.id, // Berdasarkan ID produk
        (existing) => CartItem( // Buat instance CartItem baru dengan kuantitas bertambah
          product: existing.product, // Tetapkan produk yang sama
          quantity: existing.quantity + 1, // Tambahkan jumlah kuantitas sebanyak 1
        ),
      );
    } else {
      _items.putIfAbsent(product.id, () => CartItem(product: product)); // Jika belum ada, masukkan item baru ke Map
    }
    notifyListeners(); // Mengirim pemberitahuan ke UI agar me-render ulang tampilan sesuai data terbaru
  }

  // Method untuk mengurangi 1 kuantitas produk tertentu di keranjang
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return; // Jika produk tidak ada di keranjang, hentikan fungsi

    if (_items[productId]!.quantity > 1) { // Jika kuantitas produk lebih dari 1
      _items.update( // Kurangi jumlah kuantitas produk tersebut sebanyak 1
        productId,
        (existing) => CartItem(
          product: existing.product,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId); // Jika kuantitas tinggal 1, hapus produk tersebut dari keranjang sepenuhnya
    }
    notifyListeners(); // Memperbarui tampilan UI
  }

  // Method untuk menghapus item produk sepenuhnya dari keranjang tanpa memedulikan berapa pun kuantitasnya
  void removeItem(String productId) {
    _items.remove(productId); // Menghapus key/produk terkait dari Map keranjang
    notifyListeners(); // Memperbarui tampilan UI
  }
}

// ==========================================
// 3. MAIN ENTRY POINT
// ==========================================

// Fungsi utama yang dipanggil pertama kali saat aplikasi Flutter dijalankan
void main() {
  runApp(const MyApp()); // Mengaktifkan widget utama aplikasi (MyApp)
}

// Widget utama aplikasi bertipe StatelessWidget (UI statis di tingkat akar)
class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor const MyApp

  @override
  Widget build(BuildContext context) {
    // Membungkus seluruh aplikasi dengan ChangeNotifierProvider agar data CartProvider bisa diakses di layar mana saja
    return ChangeNotifierProvider(
      create: (ctx) => CartProvider(), // Menginisialisasi instansiasi CartProvider
      child: MaterialApp( // Mengkonfigurasi aplikasi berdasar Material Design
        debugShowCheckedModeBanner: false, // Menghilangkan banner penanda debug di pojok kanan atas
        title: 'Smart-Cart', // Judul aplikasi untuk sistem operasi
        theme: ThemeData( // Mengatur konfigurasi tema tampilan aplikasi
          fontFamily: 'sans-serif', // Menetapkan jenis huruf (font) bawaan aplikasi
          useMaterial3: true, // Mengaktifkan gaya desain Material 3 terbaru
        ),
        home: const ProductListScreen(), // Menetapkan halaman utama yang muncul pertama kali (Halaman Produk)
      ),
    );
  }
}

// ==========================================
// 4. HALAMAN KATALOG PRODUK (PRODUCT LIST PAGE)
// ==========================================

// Halaman katalog produk bertipe StatefulWidget karena menyimpan state pencarian yang dinamis
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState(); // Membuat State untuk ProductListScreen
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Data tiruan (dummy data) produk yang ditampilkan di halaman katalog
  final List<Product> dummyProducts = [
    Product(
      id: 'p1',
      title: 'Sepatu Kasual Wanita',
      price: 300000,
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRHNVBMcx8vkgpR4yf4JepVeMM7G5Ztikk8mTMJPFCVyw&s=10',
    ),
    Product(
      id: 'p2',
      title: 'Headphones Sony Wireless',
      price: 150000,
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlfVZ29IImCo_ERzTC6Vihf7Tmm_xMQdhsKFygNrb0FA&s=10',
    ),
    Product(
      id: 'p3',
      title: 'DigiCam DC403',
      price: 900000,
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR7vKKwjb3N4PeNzRPCbg4MKjKsdNMWARBM-FrIWmRVaw&s=10',
    ),
    Product(
      id: 'p4',
      title: 'Tumblr Stainless Pinky Blue',
      price: 80000,
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRN89zTQjkbTyEsB9KpFhdVcM9wDx2DEndTHfAuNzfhmg&s=10',
    ),
    Product(
      id: 'p5',
      title: 'Shoulder Slingbag Wanita',
      price: 250000,
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRTZoMFgB6U-RAAmGSD4qzpwbzHCqvKzFcvZqVYXr1SCg&s',
    ),
  ];

  String _searchQuery = ''; // Variabel untuk menyimpan kata kunci pencarian dari user
  final TextEditingController _searchController = TextEditingController(); // Controller untuk mengontrol teks pada TextField

  @override
  void dispose() {
    _searchController.dispose(); // Membersihkan memori controller saat widget dihancurkan
    super.dispose(); // Memanggil fungsi dispose dari parent class
  }

  @override
  Widget build(BuildContext context) {
    // Menyaring daftar produk dummy sesuai kata kunci pencarian (case-insensitive)
    final filteredProducts = dummyProducts.where((product) {
      return product.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold( // Struktur tata letak standar halaman aplikasi Material Design
      backgroundColor: const Color(0xFFFAF0F0), // Mengatur warna latar belakang halaman
      appBar: AppBar( // Bilah aplikasi di bagian atas halaman
        backgroundColor: const Color(0xFFFFD6D6), // Warna latar belakang AppBar
        elevation: 0, // Menghilangkan efek bayangan di bawah AppBar
        automaticallyImplyLeading: false, // Menghilangkan tombol "kembali" (back) bawaan
        centerTitle: true, // Mengetengahkan judul teks pada AppBar
        title: const Text(
          'Smart-Cart', // Judul halaman
          style: TextStyle(
            color: Colors.white, // Warna teks judul
            fontSize: 26, // Ukuran font judul
            fontWeight: FontWeight.bold, // Ketebalan font judul
          ),
        ),
        actions: [ // Tombol aksi di sisi kanan AppBar
          Consumer<CartProvider>( // Widget untuk mendengarkan perubahan data dari CartProvider
            builder: (_, cart, childWidget) => Badge( // Menampilkan lencana angka di atas ikon keranjang
              label: Text(cart.itemCount.toString()), // Jumlah item keranjang sebagai teks lencana
              isLabelVisible: cart.itemCount > 0, // Hanya menampilkan lencana jika item keranjang > 0
              backgroundColor: const Color(0xFFFF2B2B), // Warna merah latar belakang lencana
              child: childWidget, // Child widget yang ditempeli badge (Icon Button)
            ),
            child: IconButton( // Tombol ikon keranjang belanja
              icon: const Icon(
                Icons.shopping_bag_outlined, // Ikon kantong belanja
                color: Colors.white, // Warna ikon
                size: 28, // Ukuran ikon
              ),
              onPressed: () { // Aksi ketika tombol ikon keranjang diklik
                Navigator.of(context).push( // Berpindah (navigasi) ke halaman Keranjang Belanja (CartScreen)
                  MaterialPageRoute(builder: (ctx) => const CartScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 12), // Memberi jarak kosong horizontal di sisi kanan ikon
        ],
      ),
      body: Column( // Membagi susunan halaman secara vertikal (Pencarian & Grid Produk)
        children: [
          Padding( // Padding di sekeliling kolom input pencarian
            padding: const EdgeInsets.all(16.0),
            child: Container( // Wadah pembungkus input pencarian untuk styling kotak
              padding: const EdgeInsets.symmetric(horizontal: 16), // Jarak di dalam container
              decoration: BoxDecoration( // Properti visual kotak pencarian
                color: const Color(0xFFF9ECEC), // Warna latar belakang kotak pencarian
                borderRadius: BorderRadius.circular(15), // Membuat sudut kotak menjadi melengkung
                boxShadow: const [ // Efek bayangan kotak pencarian
                  BoxShadow(
                    color: Colors.black12, // Warna bayangan transparan
                    blurRadius: 4, // Tingkat keburaman bayangan
                    offset: Offset(0, 2), // Posisi bayangan (X=0, Y=2)
                  ),
                ],
              ),
              child: TextField( // Field tempat penginputan teks pencarian produk
                controller: _searchController, // Menghubungkan input teks ke controller
                onChanged: (value) { // Dipanggil setiap kali teks input berubah
                  setState(() { // Memperbarui state agar halaman me-render ulang filteredProducts
                    _searchQuery = value; // Memasukkan teks input terbaru ke variabel _searchQuery
                  });
                },
                decoration: InputDecoration( // Desain visual teks input
                  icon: const Icon(Icons.search, color: Colors.black54), // Ikon pencarian di sebelah kiri
                  hintText: 'Cari produk...', // Teks petunjuk sebelum diinput
                  hintStyle: const TextStyle(color: Color(0xFFB59393)), // Style dari hintText
                  border: InputBorder.none, // Menghilangkan garis tepi/border bawaan
                  suffixIcon: _searchQuery.isNotEmpty // Menampilkan tombol clear hanya jika ada teks pencarian
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18), // Ikon 'X' untuk menghapus kata kunci
                          onPressed: () {
                            setState(() { // Memperbarui state aplikasi
                              _searchController.clear(); // Bersihkan isi TextField
                              _searchQuery = ''; // Reset kata kunci pencarian menjadi kosong
                            });
                          },
                        )
                      : null, // Jika pencarian kosong, suffixIcon tidak ditampilkan
                ),
              ),
            ),
          ),
          Expanded( // Memenuhi sisa ruang vertikal halaman untuk menampilkan produk
            child: filteredProducts.isEmpty // Mengecek apakah hasil pencarian kosong
                ? const Center( // Menampilkan teks jika produk tidak ditemukan
                    child: Text(
                      'Produk tidak ditemukan',
                      style: TextStyle(color: Color(0xFFB59393)),
                    ),
                  )
                : GridView.builder( // Menampilkan daftar produk dalam susunan kisi (grid)
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: filteredProducts.length, // Jumlah item yang ditampilkan dalam grid
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Menampilkan 2 kolom produk menyamping
                      childAspectRatio: 0.72, // Rasio lebar dibanding tinggi kartu produk
                      crossAxisSpacing: 14, // Spasi vertikal antar kolom grid
                      mainAxisSpacing: 14, // Spasi horizontal antar baris grid
                    ),
                    itemBuilder: (ctx, i) { // Fungsi pembangun UI tiap item kartu produk
                      final product = filteredProducts[i]; // Ambil data produk indeks ke-i
                      return Container( // Wadah utama penyusun kartu produk
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9ECEC), // Warna latar belakang kartu produk
                          borderRadius: BorderRadius.circular(10), // Lengkungan sudut kartu
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12, // Efek bayangan lembut kartu produk
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column( // Menata isi kartu produk (Gambar, Nama, Harga, Tombol)
                          crossAxisAlignment: CrossAxisAlignment.stretch, // Membuat widget anak melebar penuh
                          children: [
                            Expanded( // Membuat elemen gambar mengambil sisa area teratas dari kartu
                              child: ClipRRect( // Memotong sudut gambar agar selaras dengan border container
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(10), // Lengkungan sudut atas gambar
                                ),
                                child: Image.network( // Memuat gambar dari URL internet
                                  product.imageUrl, // Link gambar produk
                                  fit: BoxFit.cover, // Gambar dipotong rapi memenuhi area secara penuh
                                ),
                              ),
                            ),
                            Padding( // Memberi jarak tepi untuk teks nama, harga, dan tombol
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri konten informasi
                                children: [
                                  Text( // Menampilkan judul produk
                                    product.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF5D4037),
                                    ),
                                  ),
                                  const SizedBox(height: 2), // Jarak vertikal pendek antar elemen
                                  Text( // Menampilkan harga produk yang diformat Rupiah
                                    formatRupiah(product.price),
                                    style: const TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8), // Jarak vertikal sebelum tombol "Tambah"
                                  SizedBox( // Mengatur lebar dan tinggi tombol "Tambah"
                                    width: double.infinity, // Tombol melebar memenuhi kartu
                                    height: 32, // Tinggi tombol 32 pixel
                                    child: ElevatedButton( // Tombol Material Design untuk menambah item ke keranjang
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFFFD1D1), // Warna latar tombol
                                        elevation: 1, // Efek ketinggian/bayangan tombol
                                        padding: EdgeInsets.zero, // Menghilangkan padding internal tombol
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6), // Sudut tombol dibuat agak melengkung
                                        ),
                                      ),
                                      onPressed: () { // Aksi saat tombol "Tambah" ditekan
                                        Provider.of<CartProvider>(
                                          context,
                                          listen: false, // listen: false digunakan karena hanya memanggil fungsi tanpa perlu mendengarkan perubahan di sini
                                        ).addItem(product); // Menambahkan produk terpilih ke dalam keranjang

                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar(); // Menyembunyikan snackbar yang sedang tampil sebelumnya
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar( // Menampilkan notifikasi pemberitahuan SnackBar di bawah layar
                                          SnackBar(
                                            content: Text( // Isi pesan snackbar
                                              '${product.title} ditambahkan!',
                                            ),
                                            duration:
                                                const Duration(seconds: 1), // Lama SnackBar tampil (1 detik)
                                            backgroundColor:
                                                const Color(0xFFFF8A8A), // Warna snackbar
                                          ),
                                        );
                                      },
                                      child: const Row( // Isi tombol disusun secara horizontal (Ikon + Teks)
                                        mainAxisAlignment:
                                            MainAxisAlignment.center, // Memposisikan isi tombol di tengah
                                        children: [
                                          Icon(
                                            Icons.add, // Ikon tambah (+)
                                            size: 16,
                                            color: Color(0xFF5D4037),
                                          ),
                                          SizedBox(width: 4), // Jarak antara ikon dan teks tombol
                                          Text(
                                            'Tambah', // Teks label pada tombol
                                            style: TextStyle(
                                              color: Color(0xFF5D4037),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
        ],
      ),
    );
  }
}

// ==========================================
// 5. HALAMAN KERANJANG BELANJA (CART PAGE)
// ==========================================

// Halaman tampilan detail keranjang belanja menggunakan StatelessWidget
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengakses data dari CartProvider yang disediakan di bagian paling atas aplikasi
    final cart = Provider.of<CartProvider>(context);
    // Mengubah nilai (values) dari Map keranjang belanja menjadi daftar (List) CartItem
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang layar halaman keranjang
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD6D6), // Warna latar AppBar keranjang
        elevation: 0,
        leading: IconButton( // Tombol kembali di pojok kiri atas
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(), // Menutup halaman CartScreen (kembali ke halaman sebelumnya)
        ),
        centerTitle: true,
        title: const Text(
          'Keranjang', // Judul halaman keranjang
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column( // Menyusun tampilan halaman menjadi bagian daftar item dan baris Total Belanja di bawah
        children: [
          Expanded( // Menampung daftar item agar bisa di-scroll secara independen
            child: cartItems.isEmpty // Mengecek apakah keranjang kosong
                ? const Center( // Tampilan teks jika keranjang tidak berisi item apapun
                    child: Text(
                      'Keranjang masih kosong',
                      style:
                          TextStyle(fontSize: 16, color: Color(0xFFB59393)),
                    ),
                  )
                : ListView.builder( // Menampilkan daftar item keranjang secara berurutan vertikal
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    itemCount: cartItems.length, // Jumlah item yang ada di keranjang
                    itemBuilder: (ctx, i) { // Pembangun komponen kartu untuk tiap baris item di keranjang
                      final item = cartItems[i]; // Mengambil objek item pada posisi indeks ke-i
                      return Container( // Kartu item keranjang
                        margin: const EdgeInsets.only(bottom: 16), // Jarak antar kartu item
                        padding: const EdgeInsets.all(12), // Padding bagian dalam kartu item
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9ECEC),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row( // Menyusun tampilan item secara horizontal (Gambar | Detail Nama & Tombol Kuantitas)
                          children: [
                            ClipRRect( // Pemotong sudut gambar thumbnail produk
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item.product.imageUrl, // Menampilkan thumbnail gambar produk
                                width: 90, // Lebar gambar 90 pixel
                                height: 90, // Tinggi gambar 90 pixel
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12), // Jarak horisontal dari gambar ke info teks produk
                            Expanded( // Agar kolom teks mengambil semua sisa area horisontal yang tersedia
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row( // Baris untuk Nama Produk dan Tombol Hapus Produk di kanan
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween, // Memisah judul ke kiri dan sampah ke kanan
                                    children: [
                                      Text(
                                        item.product.title, // Judul nama produk
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                      IconButton( // Tombol tempat ikon hapus item (sampah)
                                        icon: const Icon(
                                          Icons.delete_outline, // Ikon tempat sampah
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          cart.removeItem(item.product.id); // Menghapus seluruh item ini dari keranjang
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    formatRupiah(item.product.price), // Format harga produk per item
                                    style: const TextStyle(
                                      color: Color(0xFF5D4037),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align( // Memposisikan widget pengatur kuantitas ke pojok kanan bawah kartu
                                    alignment: Alignment.centerRight,
                                    child: Container( // Pengatur jumlah kuantitas item (- 1 +)
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD1D1), // Latar belakang pengatur kuantitas
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row( // Komponen pengatur kuantitas (Tombol minus, Teks jumlah, Tombol plus)
                                        mainAxisSize: MainAxisSize.min, // Lebar dibatasi hanya pas untuk isi komponennya
                                        children: [
                                          InkWell( // Area interaktif tombol minus (-)
                                            onTap: () {
                                              cart.removeSingleItem( // Mengurangi 1 jumlah barang
                                                item.product.id,
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              child: Text(
                                                '–', // Karakter tanda kurangi
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF5D4037),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              '${item.quantity}', // Menampilkan kuantitas produk saat ini
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF5D4037),
                                              ),
                                            ),
                                          ),
                                          InkWell( // Area interaktif tombol plus (+)
                                            onTap: () {
                                              cart.addItem(item.product); // Menambah 1 jumlah barang
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                              ),
                                              child: Text(
                                                '+', // Karakter tanda tambah
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF5D4037),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
          Container( // Panel bagian bawah (bottom bar) untuk total pembayaran dan tombol checkout
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFFFD6D6), // Warna latar panel bawah
            child: Column(
              children: [
                Row( // Baris tempat label "Total Belanja" dan Angka Totalnya
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Meratakan elemen ke kiri dan kanan
                  children: [
                    const Text(
                      'Total Belanja :', // Label total belanja
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    Text(
                      formatRupiah(cart.totalAmount), // Mengambil dan menformat total biaya seluruh keranjang
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF2B2B), // Teks total belanja berwarna merah
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox( // Container penentu dimensi tombol Checkout
                  width: double.infinity, // Memenuhi lebar layar
                  height: 45, // Tinggi tombol 45 pixel
                  child: ElevatedButton( // Tombol proses Checkout
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF1E1E), // Warna tombol checkout merah terang
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Tombol dinonaktifkan (null) jika keranjang kosong, jika ada isi maka tombol bisa diklik
                    onPressed: cartItems.isEmpty ? null : () {},
                    child: const Text(
                      'Checkout Sekarang', // Teks tombol checkout
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
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