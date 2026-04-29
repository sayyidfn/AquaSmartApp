import 'package:flame/components.dart';
import '../aqua_catch_game.dart';
import 'package:flame/collisions.dart';

// 1. Enum untuk membedakan jenis barang (Makanan vs Sampah)
enum ItemType { food, trashCan }

class FallingItemComponent extends SpriteComponent
    with HasGameReference<AquaCatchGame> {
  final ItemType itemType;
  final double speed; // Kecepatan jatuh (berbeda-beda tiap barang agar seru)

  FallingItemComponent({required this.itemType, required this.speed});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 2. Menentukan gambar dan ukuran berdasarkan ItemType
    String spriteName;
    double itemSize = 40.0; // Ukuran default

    switch (itemType) {
      case ItemType.food:
        spriteName = 'food_pellet.png';
        itemSize = 35.0;
        break;
      case ItemType.trashCan:
        spriteName = 'trash_can.png';
        itemSize = 45.0;
        break;
    }

    sprite = await game.loadSprite(spriteName);
    size = Vector2(itemSize, itemSize);
    anchor = Anchor.center;

    add(RectangleHitbox());
  }

  // 3. JANTUNG GRAVITASI (Dijalankan 60x per detik)
  @override
  void update(double dt) {
    super.update(dt);

    // Posisi Y bertambah artinya benda turun ke bawah layar
    // dt (delta time) memastikan kecepatan jatuhnya mulus dan stabil
    position.y += speed * dt;

    // 4. OPTIMALISASI MEMORI (SANGAT KRUSIAL!)
    // Jika barang sudah melewati batas bawah layar, hancurkan dari memori
    if (position.y > game.size.y + size.y) {
      removeFromParent();
    }
  }
}
