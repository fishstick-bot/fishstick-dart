import 'client/client.dart';

final Client client = Client();
void main() async {
  await client.start();
}
