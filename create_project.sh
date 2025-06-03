#!/bin/bash

# Flutter Family Tree Builder Project Generator
# This script creates the complete project structure with all files

set -e

PROJECT_NAME="flutter_family_tree_builder"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🌳 Flutter Family Tree Builder Project Generator${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}⚠️  Flutter is not installed. Please install Flutter first.${NC}"
    echo "Visit: https://docs.flutter.dev/get-started/install"
    exit 1
fi

# Create project directory
echo -e "${GREEN}📁 Creating project directory: $PROJECT_NAME${NC}"
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Initialize Flutter project
echo -e "${GREEN}🚀 Initializing Flutter project...${NC}"
flutter create . --org com.example --project-name family_tree_builder

# Create directory structure
echo -e "${GREEN}📂 Creating directory structure...${NC}"
mkdir -p .devcontainer
mkdir -p .github/workflows
mkdir -p lib/{models,providers,services,theme,utils,widgets}
mkdir -p android/app/src/main/res/xml
mkdir -p scripts

# Create .devcontainer/devcontainer.json
echo -e "${GREEN}⚙️  Creating devcontainer configuration...${NC}"
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "Flutter Family Tree Builder",
  "image": "cirrusci/flutter:stable",
  
  "features": {
    "ghcr.io/devcontainers/features/android-sdk:1": {
      "version": "latest",
      "ndkVersion": "21.4.7075529",
      "cmdLineToolsVersion": "latest"
    },
    "ghcr.io/devcontainers/features/java:1": {
      "version": "17"
    },
    "ghcr.io/devcontainers/features/chrome:1": {
      "version": "latest"
    }
  },
  
  "customizations": {
    "vscode": {
      "extensions": [
        "Dart-Code.flutter",
        "Dart-Code.dart-code",
        "ms-vscode.vscode-json"
      ],
      "settings": {
        "flutter.sdkPath": "/home/cirrus/sdks/flutter",
        "dart.flutterSdkPath": "/home/cirrus/sdks/flutter",
        "editor.formatOnSave": true
      }
    }
  },
  
  "forwardPorts": [3000, 8080, 5000],
  "postCreateCommand": "bash .devcontainer/setup.sh",
  "remoteUser": "cirrus"
}
EOF

# Create .devcontainer/setup.sh
cat > .devcontainer/setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Setting up Flutter Family Tree Builder..."
flutter config --enable-web --no-analytics
if [ -f "pubspec.yaml" ]; then
    flutter pub get
    if grep -q "build_runner" pubspec.yaml; then
        flutter packages pub run build_runner build --delete-conflicting-outputs
    fi
fi
echo "✅ Setup complete!"
EOF
chmod +x .devcontainer/setup.sh

# Create GitHub workflow
echo -e "${GREEN}🔄 Creating GitHub Actions workflow...${NC}"
cat > .github/workflows/flutter-ci.yml << 'EOF'
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.x'
    - run: flutter pub get
    - run: flutter packages pub run build_runner build --delete-conflicting-outputs
    - run: flutter test
    - run: flutter build web --release
EOF

# Create pubspec.yaml
echo -e "${GREEN}📦 Creating pubspec.yaml...${NC}"
cat > pubspec.yaml << 'EOF'
name: family_tree_builder
description: A comprehensive family tree builder mobile app

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.10.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State management
  provider: ^6.1.1
  
  # UI components
  cupertino_icons: ^1.0.6
  google_fonts: ^6.1.0
  flutter_colorpicker: ^1.0.3
  
  # File handling and export
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  share_plus: ^7.2.1
  permission_handler: ^11.1.0
  
  # PDF and image generation
  pdf: ^3.10.7
  image: ^4.1.3
  flutter_svg: ^2.0.9
  
  # JSON and data
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  build_runner: ^2.4.7
  json_serializable: ^6.7.1

flutter:
  uses-material-design: true
EOF

# Create Android manifest
echo -e "${GREEN}📱 Creating Android configuration...${NC}"
cat > android/app/src/main/AndroidManifest.xml << 'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />

    <application
        android:label="Family Tree Builder"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:allowBackup="true"
        android:requestLegacyExternalStorage="true"
        android:usesCleartextTraffic="true">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
EOF

# Create Android XML files
cat > android/app/src/main/res/xml/file_paths.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<paths xmlns:android="http://schemas.android.com/apk/res/android">
    <files-path name="internal_files" path="." />
    <external-files-path name="external_files" path="." />
    <cache-path name="cache" path="." />
    <external-cache-path name="external_cache" path="." />
    <external-path name="external_storage" path="." />
</paths>
EOF

cat > android/app/src/main/res/xml/backup_rules.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
    <include domain="sharedpref" path="." />
    <include domain="file" path="." />
    <exclude domain="file" path="cache" />
</full-backup-content>
EOF

cat > android/app/src/main/res/xml/data_extraction_rules.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup>
        <include domain="sharedpref" path="." />
        <include domain="file" path="." />
        <exclude domain="file" path="cache" />
    </cloud-backup>
    <device-transfer>
        <include domain="sharedpref" path="." />
        <include domain="file" path="." />
        <exclude domain="file" path="cache" />
    </device-transfer>
</data-extraction-rules>
EOF

# Create main.dart (simplified version)
echo -e "${GREEN}💻 Creating main Flutter application...${NC}"
cat > lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/family_tree_provider.dart';

void main() {
  runApp(const FamilyTreeApp());
}

class FamilyTreeApp extends StatelessWidget {
  const FamilyTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FamilyTreeProvider(),
      child: MaterialApp(
        title: 'Family Tree Builder',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const FamilyTreeHome(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class FamilyTreeHome extends StatelessWidget {
  const FamilyTreeHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Tree Builder'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_tree,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Family Tree Builder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Complete project structure created!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Next steps:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('1. Run: flutter pub get'),
            Text('2. Add the complete model and provider files'),
            Text('3. Add the widget files'),
            Text('4. Run: flutter run -d web-server'),
          ],
        ),
      ),
    );
  }
}
EOF

# Create basic provider
cat > lib/providers/family_tree_provider.dart << 'EOF'
import 'package:flutter/material.dart';

class FamilyTreeProvider extends ChangeNotifier {
  final List<String> _people = [];
  
  List<String> get people => _people;
  
  void addPerson(String name) {
    _people.add(name);
    notifyListeners();
  }
  
  void removePerson(String name) {
    _people.remove(name);
    notifyListeners();
  }
}
EOF

# Create quick start script
echo -e "${GREEN}🎯 Creating quick start script...${NC}"
cat > scripts/quick_start.sh << 'EOF'
#!/bin/bash

echo "🌳 Flutter Family Tree Builder - Quick Start"
echo "==========================================="

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Enable web
echo "🌐 Enabling web support..."
flutter config --enable-web

# Run on web
echo "🚀 Starting web server..."
echo "App will be available at: http://localhost:3000"
flutter run -d web-server --web-port=3000 --web-hostname=0.0.0.0
EOF
chmod +x scripts/quick_start.sh

# Create README files
echo -e "${GREEN}📖 Creating documentation...${NC}"
cat > README.md << 'EOF'
# 🌳 Flutter Family Tree Builder

A comprehensive family tree builder mobile app built with Flutter.

## 🚀 Quick Start

### For Local Development:
```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d web-server --web-port=3000

# Or use the quick start script
./scripts/quick_start.sh
```

### For GitHub Codespaces:
1. Open this repository in GitHub Codespaces
2. Wait for automatic setup
3. Run: `flutter run -d web-server --web-port=3000 --web-hostname=0.0.0.0`

## 📱 Features

- Interactive visual family tree
- Table view with search and sorting
- Relationship management
- Export/Import functionality
- Font and color customization
- Responsive design

## 🛠️ Development

This project includes:
- Complete Flutter project structure
- GitHub Codespaces configuration
- CI/CD workflow
- Comprehensive documentation

## 📝 Next Steps

1. **Complete the implementation** by adding the full model and widget files
2. **Run the code generation**: `flutter packages pub run build_runner build`
3. **Test the application** in your preferred environment
4. **Customize** as needed for your requirements

## 🔗 Links

- [Flutter Documentation](https://docs.flutter.dev/)
- [GitHub Codespaces](https://github.com/features/codespaces)
EOF

cat > SETUP-INSTRUCTIONS.md << 'EOF'
# 📋 Setup Instructions

## 🏗️ Project Structure Created

This script has created a complete Flutter project with:

- ✅ Flutter project initialization
- ✅ Dependencies configuration
- ✅ GitHub Codespaces setup
- ✅ CI/CD workflow
- ✅ Android configuration
- ✅ Basic app structure

## 📝 Complete the Setup

### 1. Install Dependencies
```bash
cd flutter_family_tree_builder
flutter pub get
```

### 2. Add Full Implementation Files

You'll need to add the complete implementation files:

- `lib/models/person.dart` - Complete data models
- `lib/providers/family_tree_provider.dart` - Complete state management
- `lib/widgets/` - All widget files
- `lib/theme/app_theme.dart` - Theme configuration
- `lib/services/export_service.dart` - Export functionality

### 3. Generate Code
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the App
```bash
# For web development
flutter run -d web-server --web-port=3000

# Or use the quick start script
./scripts/quick_start.sh
```

## 🌐 GitHub Codespaces

To use with GitHub Codespaces:

1. Push this project to a GitHub repository
2. Open in Codespaces
3. The devcontainer will automatically set up the environment
4. Run the web server and access via forwarded ports

## 📱 Android Development

For Android development:
- Connect a physical device via USB debugging
- Or set up an Android emulator
- Run: `flutter run`

Enjoy building your family tree app! 🎉
EOF

echo ""
echo -e "${GREEN}✅ Project created successfully!${NC}"
echo -e "${BLUE}📁 Project location: $PWD${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. cd $PROJECT_NAME"
echo "2. flutter pub get"
echo "3. Add the complete implementation files (models, widgets, etc.)"
echo "4. flutter packages pub run build_runner build"
echo "5. ./scripts/quick_start.sh"
echo ""
echo -e "${GREEN}🎉 Happy coding!${NC}"