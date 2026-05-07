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

  // Accelerometer: menggerakkan ikan kiri/kanan
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double tiltX = 0.0;

  // Gyroscope: efek parallax background
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  double bgOffsetX = 0.0;

  // Difficulty scaling
  double _difficultyTimer = 0.0;
  double _currentSpawnInterval = 1.2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Background dibuat lebih besar 60px agar bisa digeser untuk efek parallax
    background = SpriteComponent()
      ..sprite = await loadSprite('ocean_bg.png')
      ..size = Vector2(size.x + 60, size.y + 60)
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y / 2);
    add(background);

    player = PlayerComponent();
    add(player);

    spawnTimer = Timer(_currentSpawnInterval, onTick: spawnItem, repeat: true);
    spawnTimer.start();

    // Sensor mungkin tidak tersedia di semua perangkat, tangkap error agar tidak crash
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          tiltX = event.x;
        },
      );
    } catch (e) {
      // Accelerometer tidak tersedia di perangkat ini
      print('Error: $e');
    }

    try {
      _gyroscopeSubscription = gyroscopeEventStream().listen(
        (GyroscopeEvent event) {
          bgOffsetX = (bgOffsetX + event.y * 4.0).clamp(-30.0, 30.0);
        },
      );
    } catch (e) {
      // Gyroscope tidak tersedia di perangkat ini
      print('Error: $e');
    }
  }

  void spawnItem() {
    if (gameController.isGameOver.value) return;

    final int currentScore = gameController.score.value;

    // Kecepatan item meningkat seiring skor untuk menambah tingkat kesulitan (maksimal 2.2x)
    final double speedMultiplier = 1.0 + min(currentScore / 300.0, 1.2);
    final double baseSpeed = 150 + random.nextDouble() * 100;
    final double randomSpeed = baseSpeed * speedMultiplier;

    // Peluang sampah muncul meningkat seiring skor (maksimal 50%)
    final double trashChance = min(0.25 + currentScore / 500.0, 0.50);
    final ItemType randomType = random.nextDouble() < trashChance
        ? ItemType.trashCan
        : ItemType.food;

    // Atur posisi spawn item di antara 30px dari kiri dan 30px dari kanan (agar tidak keluar layar)
    final double randomX = 30 + random.nextDouble() * (size.x - 60);

    // Buat item dan tambahkan ke game
    final item = FallingItemComponent(itemType: randomType, speed: randomSpeed);
    item.position = Vector2(randomX, -50);
    add(item);
  }

  // Perbarui interval spawn setiap 10 detik sesuai skor
  void _updateSpawnRate() {
    // Ambil skor saat ini dari GameController
    final int score = gameController.score.value;
    // Hitung interval spawn baru berdasarkan skor (minimal 0.5 detik)
    final double newInterval = (1.2 - score / 600.0).clamp(0.5, 1.2);

    // Jika interval berubah, update timer
    if (newInterval != _currentSpawnInterval) {
      _currentSpawnInterval = newInterval;
      spawnTimer.stop();
      spawnTimer = Timer(_currentSpawnInterval, onTick: spawnItem, repeat: true);
      spawnTimer.start();
    }
  }

  // Reset seluruh state game untuk memulai sesi baru
  void resetAll() {
    removeWhere((component) => component is FallingItemComponent);
    bgOffsetX = 0.0;
    tiltX = 0.0;
    _difficultyTimer = 0.0;
    _currentSpawnInterval = 1.2;

    spawnTimer.stop();
    spawnTimer = Timer(_currentSpawnInterval, onTick: spawnItem, repeat: true);
    spawnTimer.start();
  }

  @override
  void update(double dt) {
    super.update(dt);
    spawnTimer.update(dt);

    if (!gameController.isGameOver.value) {
      player.moveFromTilt(-tiltX, dt);
      background.position.x = (size.x / 2) + bgOffsetX;

      // Cek difficulty scaling setiap 10 detik
      _difficultyTimer += dt;
      if (_difficultyTimer >= 10.0) {
        _difficultyTimer = 0.0;
        _updateSpawnRate();
      }
    }
  }

  @override
  void onRemove() {
    _accelerometerSubscription?.cancel();
    _gyroscopeSubscription?.cancel();
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
