import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

/// ويدجت موحدة لعرض صورة الدرس:
/// - بتعرض صورة من assets أو صورة محفوظة محليًا على الجهاز
/// - بتسمح باختيار صورة جديدة من الجهاز وحفظها بشكل دائم (تفضل موجودة بعد إغلاق التطبيق)
/// - الضغط عليها بيفتح شاشة Fullscreen مع إمكانية الزوم
/// - فيها زرار لتنزيل/حفظ الصورة في معرض الصور بتاع الجهاز
class LessonImage extends StatefulWidget {
  /// مسار صورة من الـ assets (تُستخدم كافتراضية لو مفيش صورة محفوظة محليًا)
  final String? assetPath;

  /// معرف فريد للدرس، بيُستخدم كاسم لملف الصورة المحفوظة محليًا
  /// (لازم يكون فريد لكل درس عشان كل درس يحتفظ بصورته الخاصة)
  final String lessonId;

  /// هل الويدجت تسمح بإضافة/تغيير الصورة
  final bool editable;

  final double height;
  final Color accentColor;

  const LessonImage({
    super.key,
    required this.lessonId,
    this.assetPath,
    this.editable = false,
    this.height = 180,
    this.accentColor = Colors.blue,
  });

  @override
  State<LessonImage> createState() => _LessonImageState();
}

class _LessonImageState extends State<LessonImage> {
  File? _localFile;
  bool _loading = true;

  bool get _hasAsset =>
      widget.assetPath != null && widget.assetPath!.isNotEmpty;
  bool get _hasImage => _localFile != null || _hasAsset;

  @override
  void initState() {
    super.initState();
    _loadPersistedImage();
  }

  /// المسار الثابت اللي هنحفظ فيه صورة الدرس ده جوه مساحة التطبيق
  Future<File> _localImageFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/lesson_images/${widget.lessonId}.jpg');
  }

  /// بيدور على صورة محفوظة قبل كده لنفس الدرس ويحملها لو موجودة
  Future<void> _loadPersistedImage() async {
    final file = await _localImageFile();
    if (await file.exists()) {
      setState(() {
        _localFile = file;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  /// اختيار صورة جديدة من الجهاز وحفظها بشكل دائم في مساحة التطبيق
  /// (بما إن مفيش باك إند حاليًا، الحفظ المحلي ده هو اللي بيضمن إن الصورة
  /// تفضل ظاهرة حتى لو قفلنا التطبيق وفتحناه تاني)
  Future<void> _pickAndPersistImage() async {
    final picker = ImagePicker();
    final XFile? result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (result == null) return;

    final targetFile = await _localImageFile();
    await targetFile.parent.create(recursive: true);
    final savedFile = await File(result.path).copy(targetFile.path);

    setState(() => _localFile = savedFile);
  }

  /// تنزيل/حفظ الصورة الحالية في معرض الصور بتاع الجهاز
  Future<void> _downloadImage(BuildContext context) async {
    try {
      if (_localFile != null) {
        await Gal.putImage(_localFile!.path);
      } else if (_hasAsset) {
        // الصور من الـ assets لازم تتحول لملف مؤقت الأول قبل ما تتحفظ
        final byteData =
            await DefaultAssetBundle.of(context).load(widget.assetPath!);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_download.jpg');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List());
        await Gal.putImage(tempFile.path);
      } else {
        return;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ الصورة في معرض الصور')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر حفظ الصورة')),
        );
      }
    }
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          assetPath: _localFile == null ? widget.assetPath : null,
          file: _localFile,
          onDownload: () => _downloadImage(context),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (_loading) {
      return _placeholder(child: const CircularProgressIndicator());
    }
    if (_localFile != null) {
      return Image.file(
        _localFile!,
        width: double.infinity,
        height: widget.height,
        fit: BoxFit.cover,
      );
    }
    if (_hasAsset) {
      return Image.asset(
        widget.assetPath!,
        width: double.infinity,
        height: widget.height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }
    return _placeholder();
  }

  Widget _placeholder({Widget? child}) {
    return Container(
      width: double.infinity,
      height: widget.height,
      color: widget.accentColor.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: child ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                size: 32,
                color: widget.accentColor.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              Text(
                'هذا المحتوى ليس له صورة حاليًا',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: widget.accentColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _hasImage ? () => _openFullScreen(context) : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildImage(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasImage)
                _circleButton(Icons.download, () => _downloadImage(context)),
              if (widget.editable) ...[
                const SizedBox(width: 8),
                _circleButton(Icons.camera_alt, _pickAndPersistImage),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

/// شاشة عرض الصورة بحجم كامل مع إمكانية التكبير/التصغير وزرار تنزيل
class _FullScreenImageViewer extends StatelessWidget {
  final String? assetPath;
  final File? file;
  final VoidCallback onDownload;

  const _FullScreenImageViewer({
    this.assetPath,
    this.file,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: onDownload,
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.0,
          child: Hero(
            tag: file?.path ?? assetPath ?? 'lesson_image',
            child: file != null ? Image.file(file!) : Image.asset(assetPath!),
          ),
        ),
      ),
    );
  }
}
