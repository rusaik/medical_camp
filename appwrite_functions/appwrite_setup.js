// Appwrite Setup Script for Medical Camp Management App
// Run this script using Appwrite CLI or Server SDK

const { Client, Databases, Users, Teams, Storage, Functions } = require('node-appwrite');

// Configuration - Update these values
const APPWRITE_ENDPOINT = 'https://sgp.cloud.appwrite.io/v1';
const APPWRITE_PROJECT_ID = '694575cd0030a30c66a7';
const APPWRITE_API_KEY = '1942007616df2af1827a9c39cc7b63d9d7f9361b33f36bf2f6ab96a31e097fa5153f125717badcfa740de1de6ad5c76f50d0b171f142865e462e54d3157d9f67d8b810dd0de49c2aaf562ea7f5743f6e3c91273fb94e64b4a6ec4bc9250c3c7d7e6ecc9806f983f2116279dfb99515f10a5273dc47461b70ab9147babb6ba5a5';
//'standard_4683d2c7534982ee1b6bd40418269abe4683081134745d8004f49c98c103f32d31c1dc5e90509a1ee9bc6f8918896a21670df66d3135e4539fcd872efdc7a3c42733098cc3487ce05ca27282ef58a2261759e89452664cbc4b1c2b4c77c50599cbe22e754e6a7fddc308a2d0aabf483452f0ab68e7d99e23a4f9f5e39d0eb88d';
const DATABASE_ID = 'medical_camp_db'
// Initialize Appwrite client
const clent = new Client()
    .setEndpoint(APPWRITE_ENDPOINT)
    .setProject(APPWRITE_PROJECT_ID)
    .setKey(APPWRITE_API_KEY);

const databases = new Databases(client);
const users = new Users(client);
const functions = new Functions(client);

// Database Setup
async function createDatabase() {
    try {
        console.log('Creating database...');
        await databases.create(DATABASE_ID, 'Medical Camp Database');
        console.log('Database created successfully');
    } catch (error) {
        if (error.code === 409) {
            console.log('Database already exists');
        } else {
            console.error('Error creating database:', error);
        }
    }
}

// Collection Schemas
const collections = [
    {
        id: 'volunteers',
        name: 'Volunteers',
        schema: [
            { key: 'userId', type: 'string', required: true, array: false },
            { key: 'fullName', type: 'string', required: true, array: false, size: 100 },
            { key: 'phone', type: 'string', required: true, array: false, size: 20 },
            { key: 'role', type: 'enum', required: true, array: false, elements: ['admin', 'volunteer', 'viewer'] },
            { key: 'department', type: 'string', required: true, array: false, size: 50 },
            { key: 'isActive', type: 'boolean', required: true, array: false },
            { key: 'joinedAt', type: 'datetime', required: true, array: false }
        ],
        indexes: [
            { key: 'userId_idx', type: 'unique', attributes: ['userId'], orders: ['ASC'] },
            { key: 'role_idx', type: 'key', attributes: ['role'], orders: ['ASC'] },
            { key: 'isActive_idx', type: 'key', attributes: ['isActive'], orders: ['ASC'] }
        ]
    },
    {
        id: 'patients',
        name: 'Patients',
        schema: [
            { key: 'campId', type: 'string', required: true, array: false ,size: 50},
            { key: 'registrationNumber', type: 'string', required: true, array: false, size: 50 },
            { key: 'firstName', type: 'string', required: true, array: false, size: 50 },
            { key: 'lastName', type: 'string', required: true, array: false, size: 50 },
            { key: 'age', type: 'integer', required: true, array: false, min: 0, max: 150 },
            { key: 'gender', type: 'enum', required: true, array: false, elements: ['M', 'F', 'O'] },
            { key: 'phone', type: 'string', required: false, array: false, size: 20 },
            { key: 'address', type: 'string', required: true, array: false, size: 500 },
            { key: 'registeredBy', type: 'string', required: true, array: false },
            { key: 'registeredAt', type: 'datetime', required: true, array: false },
            { key: 'status', type: 'enum', required: true, array: false, elements: ['waiting', 'in_consultation', 'completed', 'referred'] },
            { key: 'priority', type: 'enum', required: true, array: false, elements: ['routine', 'urgent', 'emergency'] }
        ],
        indexes: [
            { key: 'campId_idx', type: 'key', attributes: ['campId'], orders: ['ASC'] },
            { key: 'registrationNumber_idx', type: 'unique', attributes: ['registrationNumber'], orders: ['ASC'] },
            { key: 'status_idx', type: 'key', attributes: ['status'], orders: ['ASC'] },
            { key: 'priority_idx', type: 'key', attributes: ['priority'], orders: ['ASC'] },
            { key: 'registeredAt_idx', type: 'key', attributes: ['registeredAt'], orders: ['DESC'] }
        ]
    },
    {
        id: 'vital_signs',
        name: 'Vital Signs',
        schema: [
            { key: 'patientId', type: 'string', required: true, array: false },
            { key: 'recordedBy', type: 'string', required: true, array: false },
            { key: 'recordedAt', type: 'datetime', required: true, array: false },
            { key: 'temperature', type: 'string', required: false, array: false, size: 10 },
            { key: 'bloodPressure', type: 'string', required: false, array: false, size: 10 },
            { key: 'pulse', type: 'integer', required: false, array: false, min: 0, max: 300 },
            { key: 'respiratoryRate', type: 'integer', required: false, array: false, min: 0, max: 100 },
            { key: 'weight', type: 'string', required: false, array: false, size: 10 },
            { key: 'height', type: 'string', required: false, array: false, size: 10 },
            { key: 'notes', type: 'string', required: false, array: false, size: 500 }
        ],
        indexes: [
            { key: 'patientId_idx', type: 'key', attributes: ['patientId'], orders: ['ASC'] },
            { key: 'recordedAt_idx', type: 'key', attributes: ['recordedAt'], orders: ['DESC'] }
        ]
    },
    {
        id: 'consultations',
        name: 'Consultations',
        schema: [
            { key: 'patientId', type: 'string', required: true, array: false },
            { key: 'volunteerId', type: 'string', required: true, array: false },
            { key: 'department', type: 'string', required: true, array: false, size: 50 },
            { key: 'startedAt', type: 'datetime', required: true, array: false },
            { key: 'completedAt', type: 'datetime', required: false, array: false },
            { key: 'chiefComplaint', type: 'string', required: true, array: false, size: 1000 },
            { key: 'examinationFindings', type: 'string', required: false, array: false, size: 2000 },
            { key: 'diagnosis', type: 'string', required: false, array: false, size: 1000 },
            { key: 'prescription', type: 'string', required: false, array: false, size: 2000 },
            { key: 'advice', type: 'string', required: false, array: false, size: 1000 },
            { key: 'followUpRequired', type: 'boolean', required: false, array: false },
            { key: 'referredTo', type: 'string', required: false, array: false, size: 100 }
        ],
        indexes: [
            { key: 'patientId_idx', type: 'key', attributes: ['patientId'], orders: ['ASC'] },
            { key: 'volunteerId_idx', type: 'key', attributes: ['volunteerId'], orders: ['ASC'] },
            { key: 'department_idx', type: 'key', attributes: ['department'], orders: ['ASC'] },
            { key: 'startedAt_idx', type: 'key', attributes: ['startedAt'], orders: ['DESC'] }
        ]
    },
    {
        id: 'camps',
        name: 'Camps',
        schema: [
            { key: 'name', type: 'string', required: true, array: false, size: 100 },
            { key: 'location', type: 'string', required: true, array: false, size: 200 },
            { key: 'startDate', type: 'datetime', required: true, array: false },
            { key: 'endDate', type: 'datetime', required: true, array: false },
            { key: 'departments', type: 'string', required: true, array: true, size: 50 },
            { key: 'status', type: 'enum', required: true, array: false, elements: ['planned', 'active', 'completed'] },
            { key: 'createdBy', type: 'string', required: true, array: false }
        ],
        indexes: [
            { key: 'status_idx', type: 'key', attributes: ['status'], orders: ['ASC'] },
            { key: 'startDate_idx', type: 'key', attributes: ['startDate'], orders: ['DESC'] }
        ]
    },
    {
        id: 'medications_dispensed',
        name: 'Medications Dispensed',
        schema: [
            { key: 'consultationId', type: 'string', required: true, array: false },
            { key: 'medicineName', type: 'string', required: true, array: false, size: 100 },
            { key: 'dosage', type: 'string', required: true, array: false, size: 50 },
            { key: 'frequency', type: 'string', required: true, array: false, size: 50 },
            { key: 'quantity', type: 'integer', required: true, array: false, min: 1 },
            { key: 'dispensedBy', type: 'string', required: true, array: false },
            { key: 'dispensedAt', type: 'datetime', required: true, array: false }
        ],
        indexes: [
            { key: 'consultationId_idx', type: 'key', attributes: ['consultationId'], orders: ['ASC'] },
            { key: 'medicineName_idx', type: 'key', attributes: ['medicineName'], orders: ['ASC'] },
            { key: 'dispensedAt_idx', type: 'key', attributes: ['dispensedAt'], orders: ['DESC'] }
        ]
    },
    {
        id: 'volunteer_shifts',
        name: 'Volunteer Shifts',
        schema: [
            { key: 'volunteerId', type: 'string', required: true, array: false },
            { key: 'campId', type: 'string', required: true, array: false },
            { key: 'department', type: 'string', required: true, array: false, size: 50 },
            { key: 'checkIn', type: 'datetime', required: true, array: false },
            { key: 'checkOut', type: 'datetime', required: false, array: false },
            { key: 'hoursWorked', type: 'double', required: false, array: false, min: 0 }
        ],
        indexes: [
            { key: 'volunteerId_idx', type: 'key', attributes: ['volunteerId'], orders: ['ASC'] },
            { key: 'campId_idx', type: 'key', attributes: ['campId'], orders: ['ASC'] },
            { key: 'checkIn_idx', type: 'key', attributes: ['checkIn'], orders: ['DESC'] }
        ]
    },
    {
        id: 'audit_log',
        name: 'Audit Log',
        schema: [
            { key: 'action', type: 'string', required: true, array: false, size: 50 },
            { key: 'userId', type: 'string', required: true, array: false },
            { key: 'timestamp', type: 'datetime', required: true, array: false },
            { key: 'details', type: 'string', required: false, array: false, size: 2000 }
        ],
        indexes: [
            { key: 'timestamp_idx', type: 'key', attributes: ['timestamp'], orders: ['DESC'] },
            { key: 'userId_idx', type: 'key', attributes: ['userId'], orders: ['ASC'] }
        ]
    }
];

// Create collections
async function createCollections() {
    for (const collection of collections) {
        try {
            console.log(`Creating collection: ${collection.name}`);
            
            // Create collection
            await databases.createCollection(
                DATABASE_ID,
                collection.id,
                collection.name
            );

            // Create attributes
            for (const attribute of collection.schema) {
                try {
                    switch (attribute.type) {
                        case 'string':
                            await databases.createStringAttribute(
                                DATABASE_ID,
                                collection.id,
                                attribute.key,
                                attribute.size,
                                attribute.required,
                                attribute.array ? [] : undefined
                            );
                            break;
                        case 'integer':
                            await databases.createIntegerAttribute(
                                DATABASE_ID,
                                collection.id,
                                attribute.key,
                                attribute.required,
                                attribute.array ? [] : undefined,
                                attribute.min,
                                attribute.max
                            );
                            break;
                        case 'double':
                            await databases.createFloatAttribute(
                                DATABASE_ID,
                                collection.id,
                                attribute.key,
                                attribute.required,
                                attribute.array ? [] : undefined,
                                attribute.min,
                                attribute.max
                            );
                            break;
                        case 'boolean':
                            await databases.createBooleanAttribute(
                                DATABASE_ID,
                                collection.id,
                                attribute.key,
                                attribute.required,
                                attribute.array ? [] : undefined
                            );
                            break;
                        case 'datetime':
                            await databases.createDatetimeAttribute(
                                DATABASE_ID,
                                collection.id,
                                attribute.key,
                                attribute.required,
                                attribute.array ? [] : undefined
                            );
                            break;
                        case 'enum':
                            await databases.createEnumAttribute(
                                DATABASE_ID,
                                collection.id,
                                attribute.key,
                                attribute.elements,
                                attribute.required,
                                attribute.array ? [] : undefined
                            );
                            break;
                    }
                } catch (attrError) {
                    if (attrError.code === 409) {
                        console.log(`Attribute ${attribute.key} already exists`);
                    } else {
                        console.error(`Error creating attribute ${attribute.key}:`, attrError);
                    }
                }
            }

            // Create indexes
            for (const index of collection.indexes) {
                try {
                    await databases.createIndex(
                        DATABASE_ID,
                        collection.id,
                        index.key,
                        index.type,
                        index.attributes,
                        index.orders
                    );
                } catch (indexError) {
                    if (indexError.code === 409) {
                        console.log(`Index ${index.key} already exists`);
                    } else {
                        console.error(`Error creating index ${index.key}:`, indexError);
                    }
                }
            }

            console.log(`Collection ${collection.name} created successfully`);
        } catch (error) {
            if (error.code === 409) {
                console.log(`Collection ${collection.name} already exists`);
            } else {
                console.error(`Error creating collection ${collection.name}:`, error);
            }
        }
    }
}

// Security Rules
const securityRules = {
    volunteers: `{
        "create": ["role:admin"],
        "read": ["role:admin", "role:volunteer"],
        "update": ["role:admin"],
        "delete": ["role:admin"]
    }`,
    patients: `{
        "create": ["any"],
        "read": ["any"],
        "update": ["userId:{registeredBy}", "role:admin"],
        "delete": ["role:admin"]
    }`,
    vital_signs: `{
        "create": ["any"],
        "read": ["any"],
        "update": ["userId:{recordedBy}", "role:admin"],
        "delete": ["role:admin"]
    }`,
    consultations: `{
        "create": ["any"],
        "read": ["userId:{volunteerId}", "role:admin"],
        "update": ["userId:{volunteerId}", "role:admin"],
        "delete": ["role:admin"]
    }`,
    camps: `{
        "create": ["role:admin"],
        "read": ["any"],
        "update": ["role:admin"],
        "delete": ["role:admin"]
    }`,
    medications_dispensed: `{
        "create": ["any"],
        "read": ["any"],
        "update": ["userId:{dispensedBy}", "role:admin"],
        "delete": ["role:admin"]
    }`,
    volunteer_shifts: `{
        "create": ["any"],
        "read": ["userId:{volunteerId}", "role:admin"],
        "update": ["userId:{volunteerId}", "role:admin"],
        "delete": ["role:admin"]
    }`,
    audit_log: `{
        "create": ["any"],
        "read": ["role:admin"],
        "update": ["role:admin"],
        "delete": ["role:admin"]
    }`
};

// Apply security rules
async function applySecurityRules() {
    for (const [collectionId, rules] of Object.entries(securityRules)) {
        try {
            await databases.updateCollection(
                DATABASE_ID,
                collectionId,
                undefined,
                rules
            );
            console.log(`Security rules applied to ${collectionId}`);
        } catch (error) {
            console.error(`Error applying rules to ${collectionId}:`, error);
        }
    }
}

// Main execution
async function main() {
    try {
        console.log('Starting Appwrite setup...');
        
        await createDatabase();
        await createCollections();
        await applySecurityRules();
        
        console.log('Appwrite setup completed successfully!');
        console.log('Database ID:', DATABASE_ID);
        
    } catch (error) {
        console.error('Setup failed:', error);
        process.exit(1);
    }
}

// Run setup
main();