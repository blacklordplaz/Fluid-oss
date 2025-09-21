# Fluid - Advanced macOS Dictation App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://developer.apple.com/macos/)

Fluid is a sophisticated macOS dictation application that transforms speech into text with real-time transcription capabilities. Built with Swift and SwiftUI, it provides professional-grade speech recognition with AI enhancement features.

## ✨ Features

- **Real-time Speech Recognition**: Instant transcription with minimal latency
- **Global Hotkey Support**: Start/stop recording with customizable keyboard shortcuts
- **AI Processing**: Enhance transcriptions with OpenAI-compatible APIs
- **Audio Visualization**: Real-time visual feedback during recording
- **Multi-App Support**: Seamlessly type into any application
- **Model Management**: Automatic downloading and management of ASR models
- **Accessibility Integration**: Full support for macOS accessibility features
- **Menu Bar Integration**: Non-intrusive menubar app design

## 🚀 Installation

### Prerequisites

- **macOS 12.0** or later
- **Xcode 14.0** or later
- **Swift 5.7** or later
- **Developer Tools** (install via Xcode)

### Build Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd fluid-dictation
   ```

2. **Install dependencies**
   ```bash
   # The project uses Swift Package Manager
   # Dependencies are automatically resolved by Xcode
   ```

3. **Open in Xcode**
   ```bash
   open Fluid.xcodeproj
   ```

4. **Build and Run**
   - Select the `Fluid` scheme
   - Build with `Cmd + B`
   - Run with `Cmd + R`

## ⚙️ Configuration

### Model Repository

By default, Fluid uses optimized ASR models from Hugging Face. You can customize the model repository:

```swift
let downloader = HuggingFaceModelDownloader(
    owner: "your-username",
    repo: "your-model-repository",
    revision: "main"
)
```

### API Configuration

Configure AI providers in the settings:

1. Open Fluid
2. Go to Settings → AI Prompts
3. Add your API credentials for supported providers

**Supported Providers:**
- OpenAI (GPT-4, GPT-3.5)
- OpenAI-compatible APIs (Azure OpenAI, Local models, etc.)
- Custom endpoints

### Global Hotkey

Set up a global keyboard shortcut:

1. Open Fluid
2. Go to Settings → General
3. Click "Record Shortcut" and press your desired key combination
4. Default: `Right Option` key

## 🎯 Usage

### Basic Dictation

1. **Start Recording**: Press your configured global hotkey or use the menu bar
2. **Speak**: The app will show visual feedback and transcribe your speech
3. **Stop Recording**: Press the hotkey again or use the menu bar
4. **Text Insertion**: Transcribed text is automatically typed into the focused application

### AI Enhancement

Enable AI processing to enhance your transcriptions:

1. Enable "AI Processing" in Settings
2. Configure your AI provider and API key
3. Create custom prompts for different use cases
4. Transcribed text will be processed through your AI model before insertion

### Audio Settings

Adjust audio processing parameters:

- **Input Device**: Choose your microphone
- **Noise Threshold**: Adjust sensitivity for audio visualization
- **Audio Visualization**: Customize the visual feedback display

## 🏗️ Architecture

### Core Components

- **ASRService**: Handles speech recognition and model management
- **TypingService**: Manages text insertion across applications
- **GlobalHotkeyManager**: Manages system-wide keyboard shortcuts
- **MenuBarManager**: Controls the menubar integration
- **SettingsStore**: Persists user preferences and configuration
- **DebugLogger**: Provides structured logging for troubleshooting

### Key Technologies

- **FluidAudio**: Advanced speech recognition framework
- **CoreML**: On-device machine learning for model inference
- **AVFoundation**: Audio capture and processing
- **Accessibility API**: System integration for text insertion
- **SwiftUI**: Modern user interface framework

## 🔧 Development

### Project Structure

```
fluid-dictation/
├── Sources/Fluid/            # Main application source code
│   ├── Assets.xcassets/      # App icons and resources
│   ├── Services/             # Core service classes
│   │   ├── ASRService.swift  # Speech recognition service
│   │   ├── TypingService.swift # Text insertion service
│   │   ├── GlobalHotkeyManager.swift
│   │   └── ...
│   ├── Networking/           # API and model management
│   │   ├── AIProvider.swift  # AI integration protocols
│   │   └── ModelDownloader.swift # Hugging Face model management
│   ├── Persistence/          # Data persistence
│   │   └── SettingsStore.swift # User preferences
│   ├── Models/               # Data models
│   │   └── HotkeyShortcut.swift # Keyboard shortcut model
│   ├── UI/                   # User interface components
│   ├── ContentView.swift     # Main application view
│   └── fluidApp.swift        # App entry point
├── Fluid.xcodeproj/          # Xcode project
├── LICENSE                   # MIT license
├── README.md                 # This file
├── CONTRIBUTING.md           # Contribution guidelines
└── ERROR_HANDLING.md         # Error handling documentation
```

### Building Custom Models

To use custom ASR models:

1. Upload your model to Hugging Face
2. Update the repository configuration in `ModelDownloader.swift`
3. The app will automatically download and use your custom models

### Debugging

Enable debug logging for development:

1. Go to Settings → Debug Settings
2. Enable "Debug Logging"
3. Check the console for detailed logs

## 🧪 Testing

### Unit Tests

```bash
# Run tests in Xcode
# Product → Test (Cmd + U)
```

### Manual Testing

- Test with different audio input devices
- Verify global hotkey functionality
- Test AI integration with various providers
- Validate text insertion across different applications

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable and function names
- Add comprehensive documentation
- Include error handling for all operations

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **FluidAudio** framework for advanced speech recognition
- **Apple** for macOS accessibility APIs
- **OpenAI** for AI integration standards
- **Hugging Face** for model hosting infrastructure

## 🐛 Troubleshooting

### Common Issues

**Accessibility permissions not granted:**
- Go to System Settings → Privacy & Security → Accessibility
- Enable Fluid in the list of allowed applications

**Microphone not detected:**
- Check System Settings → Privacy & Security → Microphone
- Ensure Fluid has microphone access

**AI processing not working:**
- Verify API key is correctly configured
- Check network connectivity
- Validate provider endpoint URL

**Global hotkey not responding:**
- Ensure no other application is using the same shortcut
- Check accessibility permissions
- Try restarting the application

### Getting Help

- Check the debug logs (Settings → Debug Settings)
- Review the troubleshooting section
- Create an issue on GitHub with detailed information

## 🔄 Updates

### Version History

- **v1.0**: Initial release with basic dictation
- **v2.0**: Added AI processing and model management
- **v2.1**: Enhanced audio visualization and accessibility

### Release Notes

For detailed release information, see [CHANGELOG.md](CHANGELOG.md).

---

**Made with ❤️ for the macOS community**
