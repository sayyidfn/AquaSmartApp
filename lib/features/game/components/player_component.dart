import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../aqua_catch_game.dart';
import 'falling_item_component.dart';

// 1. Menggunakan HasGameReference<NamaGameKita>
class PlayerComponent extends SpriteComponent
    with HasGameReference<AquaCatchGame>, CollisionCallbacks {
  final double playerSize = 80.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 2. Menggunakan 'game.' bukan lagi 'gameRef.'
    sprite = await game.loadSprite('player_fish.png');

    size = Vector2(playerSize, playerSize);
    anchor = Anchor.center;

    // 3. Menggunakan 'game.size'
    position = Vector2(game.size.x / 2, game.size.y - 120);

    add(RectangleHitbox());
  }

  void move(double deltaX) {
    position.x += deltaX;

    if (position.x < size.x / 2) {
      position.x = size.x / 2;
    }
    // 4. Menggunakan 'game.size.x'
    if (position.x > game.size.x - (size.x / 2)) {
      position.x = game.size.x - (size.x / 2);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position.y = size.y - 120;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    // Jika yang menabrak ikan adalah benda yang jatuh...
    if (other is FallingItemComponent) {
      // 1. Hancurkan/hilangkan benda tersebut dari layar
      other.removeFromParent();

      // 2. Cek apakah itu makanan atau sampah, lalu lapor ke Controller
      if (other.itemType == ItemType.food) {
        game.gameController.increaseScore(); // Makanan -> Tambah Skor
      } else {
        game.gameController.decreaseHeart(); // Sampah -> Kurangi Nyawa
      }
    }
  }

  // Fungsi baru untuk pergerakan via sensor kemiringan
  void moveFromTilt(double tiltX, double dt) {
    // Kecepatan gerak ikan (bisa Anda sesuaikan nanti jika terlalu lambat/cepat)
    final double sensitivity = 250.0;

    // Posisi X diubah berdasarkan kemiringan * kecepatan * delta time (agar mulus)
    position.x += tiltX * sensitivity * dt;

    // Mempertahankan dinding batas (jangan sampai ikan keluar layar)
    if (position.x < size.x / 2) position.x = size.x / 2;
    if (position.x > game.size.x - (size.x / 2)) {
      position.x = game.size.x - (size.x / 2);
    }
  }
}
