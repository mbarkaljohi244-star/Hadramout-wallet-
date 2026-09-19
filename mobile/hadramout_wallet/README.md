# Hadramout Wallet Flutter App

RTL Arabic Flutter frontend for the Hadramout Wallet API.

## Run locally

Install Flutter, then run:

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
```

Use the host machine's LAN IP instead of `10.0.2.2` on a physical device. The API server must be reachable from the device and allow the selected host/port.

The default API URL is `http://10.0.2.2:8080/api`, which targets the local Node server from an Android emulator. Override it with `API_BASE_URL` for iOS simulators, physical devices, or a published development URL.

## API coverage

- `POST /users/register`
- `POST /auth/login`
- `POST /transfer`

The 11-step KYC flow is implemented as a validated local draft because the existing Node API does not yet expose KYC document upload or submission endpoints.