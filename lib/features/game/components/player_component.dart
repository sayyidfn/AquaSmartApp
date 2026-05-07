import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import '../aqua_catch_game.dart';
import 'falling_item_component.dart';

class PlayerComponent extends SpriteComponent
    with HasGameReference<AquaCatchGame>, CollisionCallbacks {
  final double playerSize = 80.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await game.loadSprite('player_fish.png');
    size = Vector2(playerSize, playerSize);
    anchor = Anchor.center;
    position = Vector2(game.size.x / 2, game.size.y - 120);

    add(RectangleHitbox());
  }

  // Gerakkan ikan secara horizontal dengan batas tepi layar
  void move(double deltaX) {
    position.x += deltaX;

    // Jaga ikan tetap di dalam batas layar
    if (position.x < size.x / 2) position.x = size.x / 2;
    if (position.x > game.size.x - (size.x / 2)) {
      position.x = game.size.x - (size.x / 2);
    }
  }

  // Atur posisi ikan saat ukuran layar berubah
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    position.y = size.y - 120;
  }

  // Deteksi tabrakan dengan item jatuh
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is FallingItemComponent) {
      other.removeFromParent();

      // Makanan → tambah skor, sampah → kurangi nyawa
      if (other.itemType == ItemType.food) {
        game.gameController.increaseScore();
      } else {
        game.gameController.decreaseHeart();
      }
    }
  }

  // Gerakkan ikan berdasarkan kemiringan accelerometer (delta time untuk kelancaran)
  void moveFromTilt(double tiltX, double dt) {
    final double sensitivity = 250.0;
    position.x += tiltX * sensitivity * dt;

    // Jaga ikan tetap di dalam batas layar
    if (position.x < size.x / 2) position.x = size.x / 2;
    if (position.x > game.size.x - (size.x / 2)) {
      position.x = game.size.x - (size.x / 2);
    }
  }
}
