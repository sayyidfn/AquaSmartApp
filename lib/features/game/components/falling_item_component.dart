import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../aqua_catch_game.dart';

enum ItemType { food, trashCan }

class FallingItemComponent extends SpriteComponent
    with HasGameReference<AquaCatchGame> {
  final ItemType itemType;
  final double speed;

  FallingItemComponent({required this.itemType, required this.speed});

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    String spriteName;
    double itemSize = 40.0;

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

  @override
  void update(double dt) {
    super.update(dt);

    position.y += speed * dt;

    // Makanan yang terlewat akan mereset streak dan multiplier pemain
    if (position.y > game.size.y + size.y) {
      if (itemType == ItemType.food) {
        game.gameController.onFoodMissed();
      }
      removeFromParent();
    }
  }
}
