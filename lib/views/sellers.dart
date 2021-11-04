import 'dart:io';
import 'dart:math';
import 'package:barcode_scanner/barcode_scanning_data.dart';
import 'package:barcode_scanner/common_data.dart';
import 'package:barcode_scanner/scanbot_barcode_sdk.dart';
import 'package:barcode_scanner/scanbot_sdk_models.dart';
import 'package:citymart/models/barcode_model.dart';
import 'package:citymart/services/barcode_preview.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

bool shouldInitWithEncryption = false;

const BARCODE_SDK_LICENSE_KEY = "BsKmRY682Ao7xpjrD37v2VzxeXKZLD" +
    "GO4iNx+5T5NfIBEqMueEpn5nooaRs6" +
    "UT/3mSmMzVwTx9WsCqlmIkHVhhFHNL" +
    "RHXRWd/u/tiGm4zNH89iQrmLUwbatq" +
    "UMMGk5cMm5ccucz2y9dQ4ZwzjbX0Py" +
    "UNP6QKuespmK28PYfVu1HH+vLizvgG" +
    "aCv+f8HcyJ9GbbIO4Aks1iMS3NdX6I" +
    "QboBvdnDOk1Ulhr87W+OW6rwUxSOoi" +
    "DPHJGmpVw6tIyStuPSBHqByIn+HLxx" +
    "5VRJMECKlA5E20ahStIOLwkWq6Cgcv" +
    "rve1+ffCrD9nQ7WwJHcHZjqfN+ydKW" +
    "Fh5vJqHKm5vA==\nU2NhbmJvdFNESw" +
    "pjb20uZXhhbXBsZS5jaXR5bWFydAox" +
    "NjM3NzExOTk5CjgzODg2MDcKMw==\n";

_initScanbotSdk() async {
  Directory? storageDirectory;
  if (Platform.isAndroid) {
    storageDirectory = await getExternalStorageDirectory();
  }
  if (Platform.isIOS) {
    storageDirectory = await getApplicationDocumentsDirectory();
  }
  EncryptionParameters? encryptionParameters;
  if (shouldInitWithEncryption) {
    encryptionParameters = EncryptionParameters(
        password: "password", mode: FileEncryptionMode.AES256);
  }
  var config = ScanbotSdkConfig(
      licenseKey: BARCODE_SDK_LICENSE_KEY,
      encryptionParameters: encryptionParameters,
      loggingEnabled:
          true, // Consider disabling logging in production builds for security and performance reasons.
      storageBaseDirectory:
          "${storageDirectory?.path}/custom-barcode-sdk-storage");
  try {
    await ScanbotBarcodeSdk.initScanbotSdk(config);
  } catch (e) {
    print(e);
  }
}

class SellerPage extends StatefulWidget {
  const SellerPage({Key? key}) : super(key: key);

  @override
  _SellerPageState createState() {
    _initScanbotSdk();
    return _SellerPageState();
  }
}

class _SellerPageState extends State<SellerPage> {
  @override
  void initState() {
    super.initState();
  }

  BarcodeFormatsRepository barcodeFormatsRepository =
      BarcodeFormatsRepository();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Sell your product",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => startBarcodeScanner(),
        child: Icon(Icons.add_shopping_cart),
      ),
    );
  }

  startBarcodeScanner({bool shouldSnapImage = false}) async {
    // if (!await checkLicenseStatus(context)) {
    //   return;
    // }
    // ignore: unused_local_variable
    final additionalParameters = BarcodeAdditionalParameters(
      enableGS1Decoding: false,
      minimumTextLength: 10,
      maximumTextLength: 11,
      minimum1DBarcodesQuietZone: 10,
    );
    var config = BarcodeScannerConfiguration(
      barcodeImageGenerationType: shouldSnapImage
          ? BarcodeImageGenerationType.VIDEO_FRAME
          : BarcodeImageGenerationType.NONE,
      topBarBackgroundColor: Colors.blueAccent,
      finderLineColor: Colors.red,
      cancelButtonTitle: "Cancel",
      finderTextHint:
          "Please align any supported barcode in the frame to scan it.",
      successBeepEnabled: true,
      // cameraZoomFactor: 1,
      // additionalParameters: additionalParameters,
      barcodeFormats: barcodeFormatsRepository.selectedFormats.toList(),
      // see further customization configs ...
    );

    try {
      var result = await ScanbotBarcodeSdk.startBarcodeScanner(config);

      if (result.operationResult == OperationResult.SUCCESS) {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => BarcodesResultPreviewWidget(result)),
        );
      }
    } catch (e) {
      print(e);
    }
  }
}
