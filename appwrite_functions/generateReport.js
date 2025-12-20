// Appwrite Function: generateReport
// Generates various reports for the medical camp

const { Client, Databases, Query } = require('node-appwrite');

module.exports = async function(req, res) {
  try {
    const client = new Client()
      .setEndpoint(process.env.APPWRITE_ENDPOINT)
      .setProject(process.env.APPWRITE_PROJECT_ID)
      .setKey(process.env.APPWRITE_API_KEY);

    const databases = new Databases(client);
    const databaseId = process.env.DATABASE_ID || 'medical_camp_db';

    const { reportType, startDate, endDate } = req.payload;

    if (!reportType || !startDate || !endDate) {
      return res.json({
        success: false,
        message: 'Missing required parameters'
      }, 400);
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    switch (reportType) {
      case 'summary':
        return await generateSummaryReport(databases, databaseId, start, end, res);
      case 'volunteers':
        return await generateVolunteerReport(databases, databaseId, start, end, res);
      case 'medications':
        return await generateMedicationsReport(databases, databaseId, start, end, res);
      case 'demographics':
        return await generateDemographicsReport(databases, databaseId, start, end, res);
      default:
        return res.json({
          success: false,
          message: 'Unknown report type'
        }, 400);
    }

  } catch (error) {
    console.error('Error generating report:', error);
    return res.json({
      success: false,
      message: 'Internal server error'
    }, 500);
  }
};

async function generateSummaryReport(databases, databaseId, startDate, endDate, res) {
  try {
    // Get patients in date range
    const patients = await databases.listDocuments(
      databaseId,
      'patients',
      [
        Query.greaterThanEqual('registeredAt', startDate.toISOString()),
        Query.lessThanEqual('registeredAt', endDate.toISOString())
      ]
    );

    const totalPatients = patients.documents.length;
    const completed = patients.documents.filter(p => p.status === 'completed').length;
    const inProgress = patients.documents.filter(p => p.status === 'in_consultation').length;
    const referred = patients.documents.filter(p => p.status === 'referred').length;
    const waiting = patients.documents.filter(p => p.status === 'waiting').length;

    // Priority breakdown
    const routine = patients.documents.filter(p => p.priority === 'routine').length;
    const urgent = patients.documents.filter(p => p.priority === 'urgent').length;
    const emergency = patients.documents.filter(p => p.priority === 'emergency').length;

    // Department breakdown
    const departments = {};
    patients.documents.forEach(patient => {
      const dept = patient.department || 'Unknown';
      departments[dept] = (departments[dept] || 0) + 1;
    });

    return res.json({
      success: true,
      data: {
        totalPatients,
        completed,
        inProgress,
        referred,
        waiting,
        routine,
        urgent,
        emergency,
        departments
      },
      period: {
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString()
      }
    });

  } catch (error) {
    console.error('Error in summary report:', error);
    return res.json({
      success: false,
      message: 'Failed to generate summary report'
    }, 500);
  }
}

async function generateVolunteerReport(databases, databaseId, startDate, endDate, res) {
  try {
    // Get volunteers and their activity
    const volunteers = await databases.listDocuments(
      databaseId,
      'volunteers'
    );

    const consultations = await databases.listDocuments(
      databaseId,
      'consultations',
      [
        Query.greaterThanEqual('startedAt', startDate.toISOString()),
        Query.lessThanEqual('startedAt', endDate.toISOString())
      ]
    );

    const shifts = await databases.listDocuments(
      databaseId,
      'volunteer_shifts',
      [
        Query.greaterThanEqual('checkIn', startDate.toISOString()),
        Query.lessThanEqual('checkIn', endDate.toISOString())
      ]
    );

    const volunteerStats = {};

    // Calculate patients seen per volunteer
    volunteers.documents.forEach(volunteer => {
      const patientCount = consultations.documents.filter(
        c => c.volunteerId === volunteer.userId
      ).length;

      const hoursWorked = shifts.documents
        .filter(s => s.volunteerId === volunteer.userId)
        .reduce((total, shift) => {
          if (shift.checkOut) {
            const duration = new Date(shift.checkOut) - new Date(shift.checkIn);
            return total + (duration / (1000 * 60 * 60)); // Convert to hours
          }
          return total;
        }, 0);

      volunteerStats[volunteer.fullName] = {
        patients: patientCount,
        hours: Math.round(hoursWorked * 10) / 10
      };
    });

    return res.json({
      success: true,
      data: {
        volunteers: volunteerStats
      },
      period: {
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString()
      }
    });

  } catch (error) {
    console.error('Error in volunteer report:', error);
    return res.json({
      success: false,
      message: 'Failed to generate volunteer report'
    }, 500);
  }
}

async function generateMedicationsReport(databases, databaseId, startDate, endDate, res) {
  try {
    const medications = await databases.listDocuments(
      databaseId,
      'medications_dispensed',
      [
        Query.greaterThanEqual('dispensedAt', startDate.toISOString()),
        Query.lessThanEqual('dispensedAt', endDate.toISOString())
      ]
    );

    const medicationCount = {};
    medications.documents.forEach(med => {
      const name = med.medicineName;
      medicationCount[name] = (medicationCount[name] || 0) + med.quantity;
    });

    // Sort by quantity
    const sortedMeds = Object.entries(medicationCount)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 20); // Top 20 medications

    const result = {};
    sortedMeds.forEach(([name, count]) => {
      result[name] = count;
    });

    return res.json({
      success: true,
      data: {
        medications: result
      },
      period: {
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString()
      }
    });

  } catch (error) {
    console.error('Error in medications report:', error);
    return res.json({
      success: false,
      message: 'Failed to generate medications report'
    }, 500);
  }
}

async function generateDemographicsReport(databases, databaseId, startDate, endDate, res) {
  try {
    const patients = await databases.listDocuments(
      databaseId,
      'patients',
      [
        Query.greaterThanEqual('registeredAt', startDate.toISOString()),
        Query.lessThanEqual('registeredAt', endDate.toISOString())
      ]
    );

    // Age groups
    const ageGroups = {
      '0-12': 0,
      '13-18': 0,
      '19-35': 0,
      '36-50': 0,
      '51-65': 0,
      '65+': 0
    };

    const genderCount = {
      male: 0,
      female: 0,
      other: 0
    };

    patients.documents.forEach(patient => {
      const age = patient.age;
      
      // Age grouping
      if (age <= 12) ageGroups['0-12']++;
      else if (age <= 18) ageGroups['13-18']++;
      else if (age <= 35) ageGroups['19-35']++;
      else if (age <= 50) ageGroups['36-50']++;
      else if (age <= 65) ageGroups['51-65']++;
      else ageGroups['65+']++;

      // Gender count
      if (patient.gender === 'M') genderCount.male++;
      else if (patient.gender === 'F') genderCount.female++;
      else genderCount.other++;
    });

    return res.json({
      success: true,
      data: {
        ageGroups,
        male: genderCount.male,
        female: genderCount.female,
        other: genderCount.other
      },
      period: {
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString()
      }
    });

  } catch (error) {
    console.error('Error in demographics report:', error);
    return res.json({
      success: false,
      message: 'Failed to generate demographics report'
    }, 500);
  }
}