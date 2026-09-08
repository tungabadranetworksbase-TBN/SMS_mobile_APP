import 'package:url_launcher/url_launcher.dart';

Future<bool> openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return true;
  return launchUrl(uri, mode: LaunchMode.platformDefault);
}
