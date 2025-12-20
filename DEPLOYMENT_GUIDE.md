# Medical Camp Management App - Deployment Guide

## Overview

This guide will help you deploy the Medical Camp Management App using Flutter frontend and Appwrite backend.

## Prerequisites

### Appwrite Backend
- Appwrite instance (cloud or self-hosted)
- Appwrite project created
- API key with appropriate permissions

### Flutter Development
- Flutter SDK (3.16+)
- Dart SDK (3.2+)
- Android Studio / Xcode for mobile development
- Git for version control

## Step 1: Appwrite Setup

### 1.1 Create Appwrite Project
1. Go to [Appwrite Cloud](https://cloud.appwrite.io) or your self-hosted instance
2. Create a new project
3. Note down the Project ID

### 1.2 Setup Database and Collections

Run the setup script to create the database schema:

```bash
node appwrite_setup.js
```

**Manual Setup (if script fails):**

1. Create Database: `medical_camp_db`
2. Create Collections with following schemas:

#### Collection: volunteers
```json
{
  "userId": "string (relation to users)",
  "fullName": "string",
  "phone": "string",
  "role": "enum ['admin', 'volunteer', 'viewer']",
  "department": "string",
  "isActive": "boolean",
  "joinedAt": "datetime"
}
```

#### Collection: patients
```json
{
  "campId": "string",
  "registrationNumber": "string (unique)",
  "firstName": "string",
  "lastName": "string",
  "age": "integer",
  "gender": "enum ['M', 'F', 'O']",
  "phone": "string (optional)",
  "address": "string",
  "registeredBy": "string",
  "registeredAt": "datetime",
  "status": "enum ['waiting', 'in_consultation', 'completed', 'referred']",
  "priority": "enum ['routine', 'urgent', 'emergency']"
}
```

#### Collection: vital_signs
```json
{
  "patientId": "string",
  "recordedBy": "string",
  "recordedAt": "datetime",
  "temperature": "string",
  "bloodPressure": "string",
  "pulse": "integer",
  "respiratoryRate": "integer",
  "weight": "string",
  "height": "string",
  "notes": "string"
}
```

#### Collection: consultations
```json
{
  "patientId": "string",
  "volunteerId": "string",
  "department": "string",
  "startedAt": "datetime",
  "completedAt": "datetime",
  "chiefComplaint": "string",
  "examinationFindings": "string",
  "diagnosis": "string",
  "prescription": "string",
  "advice": "string",
  "followUpRequired": "boolean",
  "referredTo": "string"
}
```

#### Collection: camps
```json
{
  "name": "string",
  "location": "string",
  "startDate": "datetime",
  "endDate": "datetime",
  "departments": "string[]",
  "status": "enum ['planned', 'active', 'completed']",
  "createdBy": "string"
}
```

#### Collection: medications_dispensed
```json
{
  "consultationId": "string",
  "medicineName": "string",
  "dosage": "string",
  "frequency": "string",
  "quantity": "integer",
  "dispensedBy": "string",
  "dispensedAt": "datetime"
}
```

#### Collection: volunteer_shifts
```json
{
  "volunteerId": "string",
  "campId": "string",
  "department": "string",
  "checkIn": "datetime",
  "checkOut": "datetime",
  "hoursWorked": "double"
}
```

#### Collection: audit_log
```json
{
  "action": "string",
  "userId": "string",
  "timestamp": "datetime",
  "details": "string"
}
```

### 1.3 Setup Functions

1. Create two functions in Appwrite:
   - `generateReport` - For generating reports
   - `volunteerApprovalWebhook` - For handling volunteer approvals

2. Deploy the function code from `appwrite_functions/` directory

3. Configure environment variables:
   - `APPWRITE_ENDPOINT`
   - `APPWRITE_PROJECT_ID`
   - `APPWRITE_API_KEY`
   - `DATABASE_ID`

### 1.4 Configure Authentication

1. Go to Authentication settings
2. Enable Email/Password authentication
3. Configure password requirements (min 8 characters)
4. Enable email verification (optional for development)

## Step 2: Flutter App Setup

### 2.1 Clone and Setup

```bash
cd medical_camp_flutter
flutter pub get
```

### 2.2 Configure Appwrite Settings

Edit `lib/services/appwrite_config.dart`:

```dart
static const String projectId = 'your_project_id_here';
```

### 2.3 Build for Different Platforms

#### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web (for testing)
```bash
flutter build web --release
```

## Step 3: Environment Configuration

### 3.1 Development Environment

Create a `.env` file in the Flutter project:

```env
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id
```

### 3.2 Production Environment

For production, use environment-specific configuration:

```dart
// In appwrite_config.dart
static const String projectId = String.fromEnvironment(
  'APPWRITE_PROJECT_ID',
  defaultValue: 'your_default_project_id',
);
```

## Step 4: Testing

### 4.1 Unit Tests
```bash
flutter test
```

### 4.2 Integration Tests
```bash
flutter test integration_test/
```

### 4.3 Manual Testing Checklist

- [ ] User registration and login
- [ ] Patient registration
- [ ] Vital signs recording
- [ ] Consultation workflow
- [ ] Real-time updates
- [ ] Report generation
- [ ] Admin functions
- [ ] Offline functionality

## Step 5: Deployment

### 5.1 Mobile App Stores

#### Android (Google Play Store)
1. Create developer account
2. Build AAB: `flutter build appbundle`
3. Upload to Play Console
4. Fill store listing
5. Set up pricing and distribution
6. Submit for review

#### iOS (App Store)
1. Create developer account
2. Build IPA: `flutter build ios`
3. Upload using Xcode or Transporter
4. Fill App Store Connect information
5. Submit for review

### 5.2 Appwrite Production Setup

For self-hosted Appwrite:

```bash
# Using Docker
docker run -d --name appwrite \
  -v /var/appwrite:/usr/src/code/appwrite \
  -p 80:80 \
  -p 443:443 \
  appwrite/appwrite:latest
```

Configure environment variables for production:
- `_APP_ENV=production`
- `_APP_OPTIONS_ABUSE=enabled`
- `_APP_OPTIONS_FORCE_HTTPS=enabled`

## Step 6: Monitoring and Maintenance

### 6.1 Appwrite Monitoring

Monitor the following metrics:
- API usage (keep under 1M requests/month for free tier)
- Database storage (keep under 1GB)
- Bandwidth usage (keep under 5GB)
- Function executions

### 6.2 App Maintenance

Regular maintenance tasks:
- Update dependencies: `flutter pub upgrade`
- Monitor crash reports
- Update Appwrite functions
- Backup data regularly
- Review security rules

### 6.3 Scaling Considerations

If exceeding free tier limits:
1. Upgrade Appwrite plan
2. Implement data archival
3. Optimize queries
4. Add caching layers
5. Consider load balancing

## Troubleshooting

### Common Issues

1. **Authentication fails**
   - Check API key permissions
   - Verify project ID
   - Check endpoint URL

2. **Real-time updates not working**
   - Verify WebSocket connections
   - Check network permissions
   - Ensure proper subscription setup

3. **Data not saving**
   - Check collection permissions
   - Verify field types
   - Check validation rules

4. **Performance issues**
   - Add database indexes
   - Implement pagination
   - Optimize queries
   - Add caching

### Debug Mode

Enable debug mode in Flutter:
```dart
// In main.dart
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };
  runApp(const MedicalCampApp());
}
```

## Security Best Practices

1. **API Keys**
   - Use environment-specific keys
   - Rotate keys regularly
   - Limit permissions

2. **Data Security**
   - Implement proper validation
   - Use parameterized queries
   - Encrypt sensitive data

3. **Authentication**
   - Enforce strong passwords
   - Enable 2FA where possible
   - Monitor login attempts

4. **Network Security**
   - Use HTTPS only
   - Implement rate limiting
   - Validate all inputs

## Support and Resources

- Appwrite Documentation: https://appwrite.io/docs
- Flutter Documentation: https://flutter.dev/docs
- GitHub Issues: Report bugs and feature requests
- Community Forums: Get help from the community

## License

This project is licensed under the MIT License. See LICENSE file for details.