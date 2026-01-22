# Browsey iOS

A native iOS companion app for [Browsey](https://github.com/vforsh/browsey) - the mobile-friendly web file browser.

## Features

- **Server Discovery**: Connect via manual entry, QR code scanning, or Bonjour auto-discovery
- **Native File Browser**: Browse directories with a native iOS experience
- **File Viewers**: View code with syntax highlighting, images with gestures, and rendered markdown
- **Dark Mode**: Full dark mode support matching the Browsey web theme

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Local Development Layout

This repository is designed to work alongside the main Browsey server:

```
dev/
├── browsey/          # Main Browsey server (TypeScript/Bun)
└── browsey-ios/      # This iOS app (Swift/SwiftUI)
```

## API Endpoints

The iOS app connects to a Browsey server and uses these endpoints:

| Endpoint | Purpose |
|----------|---------|
| `GET /api/list?path=` | Directory listing |
| `GET /api/view?path=` | File content for viewer |
| `GET /api/file?path=` | Raw file download |
| `GET /api/stat?path=` | File metadata |

## Building

1. Open `BrowseyApp.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (Cmd+R)

## License

MIT License - see [LICENSE](LICENSE) for details.
