# VaraHub Setup Guide

## Quick Start

This guide will help you set up and run the VaraHub Flutter application.

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio (for Android development)
- Xcode (for iOS development, macOS only)
- VS Code or Android Studio with Flutter plugins

## Step 1: Install Flutter Dependencies

```bash
cd varahub
flutter pub get
```

## Step 2: Supabase Configuration

The Supabase configuration is automatically handled through environment variables. The database is already set up with:
- User authentication tables
- Vehicle listings
- Booking system
- Messaging system
- Reviews and ratings

**Demo account:**
- Email: demo@varahub.com
- Password: Demo@123

## Step 3: Google Maps Setup

### Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Geocoding API
4. Create credentials (API Key)
5. Restrict the API key (optional but recommended)

### Configure Android

Edit `android/app/src/main/AndroidManifest.xml` and replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

### Configure iOS

Edit `ios/Runner/AppDelegate.swift` and replace `YOUR_GOOGLE_MAPS_API_KEY` with your actual API key:

```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

## Step 4: Firebase Setup (Optional - for Push Notifications)

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app:
   - Package name: `com.varahub.app`
   - Download `google-services.json`
   - Place in `android/app/` directory

3. Add iOS app:
   - Bundle ID: `com.varahub.app`
   - Download `GoogleService-Info.plist`
   - Place in `ios/Runner/` directory

4. Enable Firebase Cloud Messaging in your Firebase project

## Step 5: Run the Application

### For Android

```bash
flutter run
```

Or select an Android device/emulator in your IDE and click Run.

### For iOS (macOS only)

```bash
cd ios
pod install
cd ..
flutter run
```

## Testing the Application

### 1. Login/Register
- Use the demo account or create a new one
- Email: demo@varahub.com
- Password: Demo@123

### 2. Browse Vehicles
- Navigate through the bottom tabs
- View cars and bikes for rent
- Browse marketplace for vehicles to buy

### 3. Book a Vehicle
- Tap on any rental vehicle
- Select duration (hourly/daily)
- Add insurance if needed
- Choose payment method
- Confirm booking

### 4. Profile Features
- View profile with verification badge
- Check wallet balance
- Toggle dark mode
- Switch language (English/Bangla)

## Sample Data

The database includes:
- 1 demo user (verified)
- 3 cars for rent
- 2 bikes for rent
- 2 cars for sale
- 2 bikes for sale

All vehicles are located around Dhaka, Bangladesh.

## Troubleshooting

### Google Maps not showing
- Verify API key is correctly set
- Ensure Maps SDK is enabled in Google Cloud Console
- Check that location permissions are granted

### Cannot connect to Supabase
- Environment variables are automatically configured
- Check internet connection
- Verify Supabase project is active

### Image upload fails
- Grant camera and storage permissions
- Check Supabase storage bucket exists
- Verify storage RLS policies

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

## Development Tips

### Hot Reload
Press `r` in the terminal while the app is running to hot reload.

### Debug Mode
The app runs in debug mode by default. To build a release version:

```bash
flutter build apk --release  # For Android
flutter build ios --release  # For iOS
```

### Code Structure

```
lib/
├── config/          # App configuration
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # Business logic
└── widgets/        # Reusable components
```

## Features Overview

### Implemented
- ✅ User authentication (email/password)
- ✅ KYC verification with document upload
- ✅ Vehicle listings (rent & buy/sell)
- ✅ Google Maps integration
- ✅ Booking system with insurance
- ✅ Profile management
- ✅ Dark mode
- ✅ Bilingual support (English/Bangla)
- ✅ Payment method selection
- ✅ Wallet system
- ✅ Reviews and ratings structure

### To Be Implemented
- Real-time chat functionality
- Live tracking during rides
- Push notifications
- Real payment gateway integration
- OCR for document parsing
- Advanced search filters

## API Documentation

The app uses Supabase REST API for all backend operations:
- Authentication: Supabase Auth
- Database: PostgreSQL with RLS
- Storage: Supabase Storage for images
- Real-time: Supabase Real-time subscriptions

## Support

For issues or questions:
- Check the README.md for detailed documentation
- Review the troubleshooting section above
- Check Flutter and Supabase documentation

## Next Steps

1. Customize the app theme in `lib/config/app_theme.dart`
2. Add your branding and logo
3. Configure real payment gateways
4. Implement push notifications
5. Add analytics tracking
6. Test on multiple devices
7. Prepare for production deployment

## Production Checklist

Before deploying to production:
- [ ] Configure proper API keys
- [ ] Set up proper Firebase project
- [ ] Configure app signing
- [ ] Update app icons and splash screen
- [ ] Test on multiple devices
- [ ] Enable proper error tracking
- [ ] Configure analytics
- [ ] Set up CI/CD pipeline
- [ ] Prepare privacy policy and terms
- [ ] Submit to app stores

Happy coding! 🚀
