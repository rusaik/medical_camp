# Medical Camp Management App

A comprehensive mobile application for managing medical camps, built with Flutter and Appwrite.

## Features

### 🏥 Patient Management
- **Patient Registration**: Quick and easy patient registration with auto-generated IDs
- **Patient Queue**: Real-time patient queue with priority management
- **Vital Signs**: Record and track patient vital signs
- **Consultations**: Complete consultation workflow with templates

### 👥 User Management
- **Role-based Access**: Admin, Volunteer, and Viewer roles
- **Volunteer Registration**: Self-registration with admin approval
- **Authentication**: Secure email/password authentication
- **Profile Management**: User profiles with statistics

### 📊 Reporting & Analytics
- **Patient Reports**: Summary, demographics, and activity reports
- **Volunteer Reports**: Activity tracking and hours worked
- **Medication Reports**: Most dispensed medications
- **Export**: CSV export for further analysis

### 🔄 Real-time Features
- **Live Updates**: Real-time patient queue updates
- **Notifications**: Instant notifications for new registrations
- **Synchronization**: Automatic data synchronization

### 📱 Mobile-First Design
- **Responsive UI**: Works on phones and tablets
- **Offline Support**: Offline capability with sync when online
- **Accessibility**: Screen reader support and high contrast
- **Multi-language**: Support for multiple languages

## Technology Stack

### Frontend
- **Flutter**: Cross-platform mobile development
- **Riverpod**: State management
- **GoRouter**: Navigation
- **Material Design**: UI components

### Backend
- **Appwrite**: Backend as a Service
- **Database**: NoSQL document database
- **Authentication**: User management
- **Functions**: Serverless functions
- **Real-time**: WebSocket connections

## Project Structure

```
medical_camp_app/
├── medical_camp_flutter/          # Flutter application
│   ├── lib/
│   │   ├── models/               # Data models
│   │   ├── screens/              # UI screens
│   │   ├── services/             # Business logic
│   │   ├── utils/                # Utilities
│   │   └── widgets/              # Reusable widgets
│   ├── pubspec.yaml
│   └── README.md
├── appwrite_setup.js             # Database setup script
├── appwrite_functions/           # Serverless functions
│   ├── generateReport.js
│   └── volunteerApprovalWebhook.js
├── DEPLOYMENT_GUIDE.md
└── README.md
```

## Quick Start

### Prerequisites

- Flutter SDK (3.16+)
- Dart SDK (3.2+)
- Appwrite instance (cloud or self-hosted)
- Node.js (for setup scripts)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd medical_camp_app
   ```

2. **Setup Appwrite Backend**
   ```bash
   # Install dependencies
   npm install
   
   # Configure environment variables
   export APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
   export APPWRITE_PROJECT_ID=your_project_id
   export APPWRITE_API_KEY=your_api_key
   
   # Run setup script
   node appwrite_setup.js
   ```

3. **Setup Flutter App**
   ```bash
   cd medical_camp_flutter
   flutter pub get
   ```

4. **Configure Appwrite Settings**
   Edit `lib/services/appwrite_config.dart` and update:
   ```dart
   static const String projectId = 'your_project_id_here';
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

## Configuration

### Appwrite Configuration

Update the following in `lib/services/appwrite_config.dart`:

```dart
class AppwriteConfig {
  static const String endpoint = 'https://cloud.appwrite.io/v1';
  static const String projectId = 'your_project_id';
  static const String databaseId = 'medical_camp_db';
  
  // Collection IDs...
  // Function IDs...
}
```

### Environment Variables

For production deployment, set these environment variables:

```bash
APPWRITE_ENDPOINT=https://cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=your_project_id
APPWRITE_API_KEY=your_api_key
DATABASE_ID=medical_camp_db
```

## Database Schema

The application uses the following collections in Appwrite:

### volunteers
- userId (relation to Appwrite users)
- fullName
- phone
- role (admin/volunteer/viewer)
- department
- isActive
- joinedAt

### patients
- campId
- registrationNumber (unique)
- firstName, lastName
- age, gender
- phone, address
- registeredBy, registeredAt
- status, priority

### vital_signs
- patientId
- recordedBy, recordedAt
- temperature, bloodPressure
- pulse, respiratoryRate
- weight, height
- notes

### consultations
- patientId, volunteerId
- department, startedAt, completedAt
- chiefComplaint, examinationFindings
- diagnosis, prescription, advice
- followUpRequired, referredTo

### Additional Collections
- camps
- medications_dispensed
- volunteer_shifts
- audit_log

## API Documentation

### Authentication Endpoints

- `POST /account` - Create account
- `POST /account/sessions/email` - Create email session
- `DELETE /account/sessions/current` - Delete current session
- `PATCH /account/password` - Update password

### Database Endpoints

- `POST /databases/{databaseId}/collections/{collectionId}/documents` - Create document
- `GET /databases/{databaseId}/collections/{collectionId}/documents` - List documents
- `GET /databases/{databaseId}/collections/{collectionId}/documents/{documentId}` - Get document
- `PATCH /databases/{databaseId}/collections/{collectionId}/documents/{documentId}` - Update document
- `DELETE /databases/{databaseId}/collections/{collectionId}/documents/{documentId}` - Delete document

### Real-time Subscriptions

- `subscribe(['databases.{databaseId}.collections.{collectionId}.documents'])` - Subscribe to collection changes

## Features in Detail

### Patient Registration
- Auto-generated registration numbers
- Priority classification (Routine/Urgent/Emergency)
- Duplicate detection
- Offline registration with sync

### Vital Signs
- Temperature, Blood Pressure, Pulse
- Respiratory Rate, Weight, Height
- BMI calculation
- Notes and observations

### Consultation Workflow
- Chief complaint recording
- Examination findings
- Diagnosis and prescription
- Template shortcuts for common medications
- Follow-up and referral tracking

### Reporting
- Patient summary reports
- Volunteer activity tracking
- Medication dispensing reports
- Demographics analysis
- CSV export functionality

### Admin Functions
- Volunteer approval
- Role management
- Camp configuration
- System monitoring

## Security Features

- Role-based access control
- Input validation and sanitization
- Secure authentication
- Audit logging
- Data encryption in transit

## Performance Optimizations

- Database indexing
- Query optimization
- Pagination for large datasets
- Offline caching
- Lazy loading

## Testing

### Unit Tests
```bash
cd medical_camp_flutter
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Manual Testing
- Test registration flow
- Test patient workflow
- Test offline functionality
- Test real-time updates
- Test report generation

## Deployment

### Mobile Apps
- Build APK/AAB for Android
- Build IPA for iOS
- Submit to respective app stores

### Appwrite Backend
- Deploy to cloud or self-host
- Configure production settings
- Set up monitoring

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed deployment instructions.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Check the documentation
- Search existing issues
- Create a new issue
- Join the community discussions

## Acknowledgments

- Appwrite team for the excellent backend platform
- Flutter community for the amazing framework
- All contributors and testers

## Roadmap

- [ ] Multi-camp support
- [ ] Advanced analytics
- [ ] Telemedicine integration
- [ ] AI-powered diagnosis assistance
- [ ] Multi-language support
- [ ] Advanced offline features
- [ ] Integration with hospital systems
- [ ] Blockchain for data integrity

---

Built with ❤️ by the Medical Camp Management Team