.PHONY: run-release build-ios run-debug clean

# Debug mode
run-debug:
	flutter run

# Release mode su device fisico
run-release:
	flutter run --release

# Build iOS release (senza code signing per CI)
build-ios:
	flutter build ios --release --no-codesign

# Build iOS release con code signing
build-ios-signed:
	flutter build ios --release

# Clean completo
clean:
	flutter clean && flutter pub get
