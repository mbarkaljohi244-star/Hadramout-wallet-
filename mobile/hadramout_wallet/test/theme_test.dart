import 'package:flutter_test/flutter_test.dart';

import 'package:hadramout_wallet/src/theme.dart';

void main() {
  test('Hadramout Wallet theme uses the fintech blue palette', () {
    final theme = buildWalletTheme();

    expect(theme.colorScheme.primary, WalletColors.blue);
    expect(theme.scaffoldBackgroundColor, WalletColors.canvas);
  });
}
