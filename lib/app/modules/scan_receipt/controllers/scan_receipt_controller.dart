import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanReceiptController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final textRecognizer = TextRecognizer();

  final RxBool isScanning = false.obs;
  final RxString scannedText = ''.obs;
  final RxString extractedAmount = ''.obs;
  final RxString extractedDate = ''.obs;

  Future<void> scanReceipt() async {
    try {
      isScanning.value = true;
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        final inputImage = InputImage.fromFilePath(image.path);
        final recognizedText = await textRecognizer.processImage(inputImage);
        scannedText.value = recognizedText.text;

        // Extract amount and date from the scanned text
        extractInformation(recognizedText.text);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to scan receipt: $e');
    } finally {
      isScanning.value = false;
    }
  }

  void extractInformation(String text) {
    // Basic amount extraction (looks for currency symbols and numbers)
    final amountRegex = RegExp(r'(?:₹|RS|INR)\s*(\d+(?:\.\d{2})?)');
    final match = amountRegex.firstMatch(text);
    if (match != null) {
      extractedAmount.value = match.group(1) ?? '';
    }

    // Basic date extraction (common Indian date formats)
    final dateRegex = RegExp(r'\d{2}[-/]\d{2}[-/]\d{4}');
    final dateMatch = dateRegex.firstMatch(text);
    if (dateMatch != null) {
      extractedDate.value = dateMatch.group(0) ?? '';
    }
  }

  @override
  void onClose() {
    textRecognizer.close();
    super.onClose();
  }
}
