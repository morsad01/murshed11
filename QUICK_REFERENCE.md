# VaraHub - Quick Reference Guide

## Essential Commands

### Setup
```bash
flutter pub get                 # Install dependencies
flutter doctor                  # Check Flutter installation
flutter devices                 # List available devices
```

### Running
```bash
flutter run                     # Run in debug mode
flutter run --release          # Run in release mode
flutter run -d <device-id>     # Run on specific device
```

### Building
```bash
flutter build apk              # Build Android APK
flutter build appbundle        # Build Android App Bundle
flutter build ios              # Build iOS app (macOS only)
```

### Maintenance
```bash
flutter clean                  # Clean build files
flutter pub upgrade            # Update dependencies
flutter analyze                # Static code analysis
```

## Key File Locations

### Main Application
- **Entry Point:** `lib/main.dart`
- **Home Screen:** `lib/screens/home/home_screen.dart`
- **Theme Config:** `lib/config/app_theme.dart`
- **Colors:** `lib/config/app_colors.dart`

### Authentication
- **Login:** `lib/screens/auth/login_screen.dart`
- **Register:** `lib/screens/auth/register_screen.dart`
- **KYC:** `lib/screens/auth/kyc_verification_screen.dart`

### Configuration
- **Android:** `android/app/src/main/AndroidManifest.xml`
- **iOS:** `ios/Runner/Info.plist`
- **Dependencies:** `pubspec.yaml`

## Demo Data

### User Account
```
Email: demo@varahub.com
Password: Demo@123
KYC Status: Approved
Wallet: ৳5000.00
```

### Sample Vehicles
- 3 Cars for Rent (Dhaka area)
- 2 Bikes for Rent (Dhaka area)
- 2 Cars for Sale
- 2 Bikes for Sale

### Locations
- Dhanmondi, Dhaka: 23.8103, 90.4125
- Gulshan, Dhaka: 23.7808, 90.4217
- Mirpur, Dhaka: 23.8759, 90.3795

## Important URLs

### Supabase
- Dashboard: Available through environment
- Database: Configured automatically
- Storage: Configured automatically

### Google Maps
- Console: https://console.cloud.google.com
- Documentation: https://developers.google.com/maps

### Firebase (Optional)
- Console: https://console.firebase.google.com

## Color Reference

```dart
Primary:     #007BFF (Blue)
Success:     #28A745 (Green)
Warning:     #FFC107 (Yellow)
Danger:      #DC3545 (Red)
Info:        #17A2B8 (Cyan)
Text:        #212529 (Dark)
Secondary:   #6C757D (Gray)
Background:  #F8F9FA (Light)
```

## API Key Configuration

### Google Maps API Key
**Android:** Replace in `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

**iOS:** Replace in `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

## Database Tables Quick Reference

### users
- User profiles and KYC data
- Wallet balance
- Language and theme preferences

### vehicles
- Vehicle listings (rent/sell)
- Pricing, location, specifications
- Availability status

### vehicle_photos
- Multiple photos per vehicle
- Ordered display

### bookings
- Rental transactions
- Duration, pricing, insurance
- Payment and status tracking

### messages
- User-to-user chat
- Vehicle and booking references

### reviews
- User ratings and comments
- Linked to bookings

### notifications
- Push notification records
- Read/unread status

### wallet_transactions
- Payment history
- Deposits and withdrawals

## Common Issues & Solutions

### Maps not showing
```bash
# Check API key is set correctly
# Enable Maps SDK in Google Cloud Console
# Verify location permissions granted
```

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

### Dependency conflicts
```bash
flutter pub upgrade --major-versions
```

## State Management

### App-wide State (Provider)
- Current user data
- Language preference
- Dark mode setting

### Usage Example
```dart
final appProvider = Provider.of<AppProvider>(context);
String language = appProvider.currentLanguage;
```

## Supabase Queries

### Fetch Vehicles
```dart
final response = await Supabase.instance.client
    .from('vehicles')
    .select('*, vehicle_photos(*), users(*)')
    .eq('type', 'car')
    .eq('listing_type', 'rent');
```

### Create Booking
```dart
await Supabase.instance.client
    .from('bookings')
    .insert({
      'vehicle_id': vehicleId,
      'renter_id': userId,
      'total_amount': amount,
    });
```

## Screen Navigation

```dart
// Push new screen
Navigator.push(context,
    MaterialPageRoute(builder: (_) => NewScreen()));

// Replace current screen
Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (_) => NewScreen()));

// Pop current screen
Navigator.pop(context);
```

## Responsive Design Breakpoints

```dart
Small:  < 600px
Medium: 600px - 1024px
Large:  > 1024px
```

## Testing Checklist

- [ ] Login with demo account
- [ ] Register new user
- [ ] Upload KYC documents
- [ ] Browse vehicles on map
- [ ] View vehicle details
- [ ] Create a booking
- [ ] Toggle dark mode
- [ ] Switch language
- [ ] Check profile information

## Performance Tips

1. Use `const` constructors where possible
2. Implement pagination for large lists
3. Cache images with `cached_network_image`
4. Use `ListView.builder` for long lists
5. Lazy load images and data

## Security Notes

- Never commit API keys to version control
- Use environment variables for secrets
- Enable RLS on all Supabase tables
- Validate user input on client and server
- Use HTTPS for all network requests

## Next Development Steps

1. Implement post vehicle form
2. Add real-time chat UI
3. Integrate payment gateway APIs
4. Add push notifications handler
5. Create admin dashboard
6. Add analytics tracking
7. Implement advanced filters
8. Add user reviews display

## Support Resources

- Flutter Docs: https://docs.flutter.dev
- Supabase Docs: https://supabase.com/docs
- Google Maps Flutter: https://pub.dev/packages/google_maps_flutter
- Provider Package: https://pub.dev/packages/provider

## Version Information

- Flutter: 3.0.0+
- Dart: 3.0.0+
- Supabase: 2.3.4
- Google Maps: 2.5.3

---

**Last Updated:** 2025-10-23
**App Version:** 1.0.0
