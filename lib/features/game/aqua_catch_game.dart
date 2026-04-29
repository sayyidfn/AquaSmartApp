import 'dart:async';
import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'game_controller.dart';
import 'components/player_component.dart';
import 'components/falling_item_component.dart';

class AquaCatchGame extends FlameGame with HasCollisionDetection {
  final GameController gameController;

  AquaCatchGame(this.gameController);

  late SpriteComponent background;
  late PlayerComponent player;

  final Random random = Random();
  late Timer spawnTimer;

  // --- VARIABEL SENSOR 1: ACCELEROMETER (Untuk Menyetir Ikan) ---
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  double tiltX = 0.0;

  // --- VARIABEL SENSOR 2: GYROSCOPE (Untuk Efek 3D Background) ---
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;
  double bgOffsetX = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 1. Setup Background (Buat ukurannya sedikit lebih besar dari layar agar bisa digeser)
    background = SpriteComponent()
      ..sprite = await loadSprite('ocean_bg.png')
      ..size =
          Vector2(size.x + 60, size.y + 60) // Lebihkan 60 piksel
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y / 2); // Posisikan di tengah
    add(background);

    player = PlayerComponent();
    add(player);

    spawnTimer = Timer(1.2, onTick: spawnItem, repeat: true);
    spawnTimer.start();

    // 2. MENGAKTIFKAN SENSOR 1: ACCELEROMETER (Menyetir Ikan)
    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      tiltX = event.x;
    });

    // 3. MENGAKTIFKAN SENSOR 2: GYROSCOPE (Efek Parallax)
    _gyroscopeSubscription = gyroscopeEventStream().listen((
      GyroscopeEvent event,
    ) {
      // Gyro event.y membaca putaran pada sumbu vertikal
      bgOffsetX += event.y * 4.0; // Angka 2.0 adalah sensitivitas putaran

      // Batasi pergeseran agar tidak keluar dari batas gambar (maksimal geser 30 piksel)
      bgOffsetX = bgOffsetX.clamp(-30.0, 30.0);
    });
  }

  void spawnItem() {
    if (gameController.isGameOver.value) return;

    final itemTypes = ItemType.values;
    final randomType = itemTypes[random.nextInt(itemTypes.length)];
    final double randomX = 30 + random.nextDouble() * (size.x - 60);
    final double randomSpeed = 150 + random.nextDouble() * 200;

    final item = FallingItemComponent(itemType: randomType, speed: randomSpeed);
    item.position = Vector2(randomX, -50);
    add(item);
  }

  @override
  void update(double dt) {
    super.update(dt);
    spawnTimer.update(dt);

    if (!gameController.isGameOver.value) {
      // Update posisi ikan
      player.moveFromTilt(-tiltX, dt);

      // Update posisi background untuk efek 3D secara mulus (Lerp)
      // Ini akan membuat background bereaksi terhadap pergelangan tangan Anda!
      background.position.x = (size.x / 2) + bgOffsetX;
    }
  }

  @override
  void onRemove() {
    // SANGAT PENTING: Matikan kedua sensor saat keluar
    _accelerometerSubscription.cancel();
    _gyroscopeSubscription.cancel();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) {
      background.size = Vector2(size.x + 60, size.y + 60);
      background.position = Vector2(size.x / 2, size.y / 2);
    }
  }
}
