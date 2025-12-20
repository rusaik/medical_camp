class AppwriteConfig {
  // Appwrite Configuration
  static const String endpoint = 'https://sgp.cloud.appwrite.io/v1';
  static const String projectId =
      '694575cd0030a30c66a7'; // Replace with your project ID
  static const String databaseId = 'medical_camp_db';
  static const appwriteEndpointKey =
      '1942007616df2af1827a9c39cc7b63d9d7f9361b33f36bf2f6ab96a31e097fa5153f125717badcfa740de1de6ad5c76f50d0b171f142865e462e54d3157d9f67d8b810dd0de49c2aaf562ea7f5743f6e3c91273fb94e64b4a6ec4bc9250c3c7d7e6ecc9806f983f2116279dfb99515f10a5273dc47461b70ab9147babb6ba5a5';
//'standard_4683d2c7534982ee1b6bd40418269abe4683081134745d8004f49c98c103f32d31c1dc5e90509a1ee9bc6f8918896a21670df66d3135e4539fcd872efdc7a3c42733098cc3487ce05ca27282ef58a2261759e89452664cbc4b1c2b4c77c50599cbe22e754e6a7fddc308a2d0aabf483452f0ab68e7d99e23a4f9f5e39d0eb88d';

  // Collection IDs
  static const String volunteersCollection = 'volunteers';
  static const String patientsCollection = 'patients';
  static const String vitalSignsCollection = 'vital_signs';
  static const String consultationsCollection = 'consultations';
  static const String campsCollection = 'camps';
  static const String medicationsCollection = 'medications_dispensed';
  static const String shiftsCollection = 'volunteer_shifts';
  static const String auditLogCollection = 'audit_log';

  // Function IDs
  static const String generateReportFunction = 'generateReport';
  static const String volunteerApprovalFunction = 'volunteerApprovalWebhook';

  // Storage bucket (if needed for future file support)
  static const String storageBucket = 'medical_camp_files';

  // App settings
  static const int maxRetries = 3;
  static const Duration timeout = Duration(seconds: 30);
  static const int maxPageSize = 100;

  // Validation rules
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxAddressLength = 500;

  // Cache settings
  static const Duration cacheExpiry = Duration(minutes: 5);
  static const int maxCacheSize = 100;
}
