# Contributing to Fluid

Thank you for your interest in contributing to Fluid! We welcome contributions from the community and are excited to collaborate with developers who share our passion for building exceptional macOS applications.

## 🚀 Quick Start

1. **Fork** the repository
2. **Clone** your fork: `git clone https://github.com/your-username/fluid-dictation.git`
3. **Create** a feature branch: `git checkout -b feature/amazing-feature`
4. **Make** your changes following our guidelines
5. **Test** your changes thoroughly
6. **Submit** a pull request

## 📋 Contribution Guidelines

### Code Standards

#### Swift Style Guide
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use descriptive variable and function names
- Prefer `let` over `var` when possible
- Add comprehensive documentation for public APIs
- Include error handling for all fallible operations

#### Naming Conventions
```swift
// ✅ Good
class SpeechRecognitionService {
    func transcribe(audioData: Data) async throws -> String
}

// ❌ Avoid
class SpeechService {
    func transcribeAudio(data: Data) -> String
}
```

#### Documentation
- Add documentation comments for all public classes, methods, and properties
- Use clear, concise language
- Include parameter descriptions and return value explanations
- Add examples when helpful

```swift
/// Handles speech recognition with real-time transcription capabilities.
/// - Parameter audioData: Raw audio data in PCM format
/// - Returns: Transcribed text from the audio
/// - Throws: `ASRServiceError` if transcription fails
public func transcribe(audioData: Data) async throws -> String
```

### Testing Requirements

#### Unit Tests
- Add unit tests for new functionality
- Test both success and error scenarios
- Mock external dependencies when possible
- Aim for 80%+ code coverage for new features

#### Integration Tests
- Test integration with system APIs (Accessibility, Audio)
- Verify functionality across different macOS versions
- Test with various input devices and configurations

#### Manual Testing Checklist
- [ ] Test with different microphones
- [ ] Verify global hotkey functionality
- [ ] Check text insertion in multiple applications
- [ ] Test AI integration (if applicable)
- [ ] Validate accessibility permissions
- [ ] Test with different audio environments (quiet/noisy)

### Pull Request Process

#### Before Submitting
1. **Test thoroughly** - Ensure your changes work as expected
2. **Update documentation** - Add or update README if needed
3. **Add tests** - Include unit and integration tests
4. **Check formatting** - Use consistent code style
5. **Review changes** - Double-check your implementation

#### PR Template
```markdown
## Description
[Brief description of changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Added unit tests
- [ ] Tested manually on macOS [version]
- [ ] Verified with different input devices

## Screenshots
[Add screenshots if UI changes are involved]

## Related Issues
Closes #123

## Checklist
- [ ] Follows code style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Accessibility considered
- [ ] Performance impact assessed
```

### Development Workflow

#### Branch Naming
```
feature/descriptive-feature-name
bugfix/issue-number-description
hotfix/critical-fix-description
docs/update-documentation
```

#### Commit Messages
Use conventional commit format:
```
feat: add new speech recognition model support
fix: resolve crash when accessibility permissions denied
docs: update API documentation for AI providers
test: add unit tests for audio processing
```

## 🛠️ Development Setup

### Prerequisites
- **macOS 12.0+**
- **Xcode 14.0+**
- **Swift 5.7+**

### Local Development
1. Clone the repository
2. Open `dictate_v2.xcodeproj` in Xcode
3. Build the project (`Cmd + B`)
4. Run tests (`Cmd + U`)

### Debugging Tips
- Enable debug logging in Settings → Debug Settings
- Use Xcode's debugging tools (breakpoints, console)
- Check system logs for accessibility-related issues
- Test with different audio input sources

## 🎯 Feature Development

### Adding New AI Providers
1. Implement the `AIProvider` protocol
2. Add to the provider selection UI
3. Include configuration options
4. Add tests for the new provider

### Custom ASR Models
1. Update `HuggingFaceModelDownloader` configuration
2. Test model compatibility
3. Update documentation
4. Add fallback handling

### UI Enhancements
1. Follow SwiftUI design patterns
2. Consider accessibility features
3. Test on different screen sizes
4. Maintain consistent visual style

## 🔒 Security Considerations

### API Keys and Credentials
- Never commit API keys to the repository
- Use environment variables for sensitive data
- Document secure configuration procedures
- Validate input from external sources

### Privacy
- Respect user privacy preferences
- Handle personal data securely
- Follow macOS privacy guidelines
- Document data collection and usage

## 📱 macOS-Specific Guidelines

### Accessibility
- Use proper accessibility labels
- Support keyboard navigation
- Test with VoiceOver
- Follow Apple accessibility guidelines

### System Integration
- Handle permission requests gracefully
- Provide clear error messages
- Support system dark mode
- Follow macOS human interface guidelines

### Performance
- Minimize CPU usage during idle periods
- Efficient memory management
- Optimize audio processing
- Profile performance regularly

## 🤝 Code Review Process

### What We Look For
- **Code quality**: Clean, readable, maintainable code
- **Functionality**: Does it work as intended?
- **Testing**: Comprehensive test coverage
- **Documentation**: Clear and complete
- **Security**: No security vulnerabilities
- **Performance**: Efficient and optimized

### Review Checklist
- [ ] Code follows project style guidelines
- [ ] Functionality works as described
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes without discussion
- [ ] Performance impact assessed
- [ ] Security considerations addressed

## 📞 Communication

### Getting Help
- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Email**: For private communications

### Response Times
- **Issues**: We aim to respond within 2-3 business days
- **Pull Requests**: Reviews typically completed within 1 week
- **Security Issues**: Addressed immediately

## 🎉 Recognition

We love to recognize our contributors! Contributors who make significant improvements will be:
- Mentioned in release notes
- Added to the acknowledgments section
- Featured in community updates

## 📄 License

By contributing to Fluid, you agree that your contributions will be licensed under the same license as the original project (MIT License).

---

Thank you for contributing to Fluid! Your efforts help make dictation technology more accessible and powerful for everyone. 🚀
