import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:appwrite/appwrite.dart';
import 'package:medical_camp_flutter/main.dart';
import 'package:medical_camp_flutter/models/volunteer.dart';
import 'package:medical_camp_flutter/services/appwrite_service.dart';
import 'package:medical_camp_flutter/utils/theme.dart';

class VolunteerManagementScreen extends ConsumerStatefulWidget {
  const VolunteerManagementScreen({super.key});

  @override
  ConsumerState<VolunteerManagementScreen> createState() =>
      _VolunteerManagementScreenState();
}

class _VolunteerManagementScreenState extends ConsumerState<VolunteerManagementScreen> {
  List<Volunteer> _volunteers = [];
  List<Volunteer> _filteredVolunteers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRole = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }

  Future<void> _loadVolunteers() async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      final docs = await appwriteService.listDocuments(
        collectionId: 'volunteers',
        queries: [
          Query.orderAsc('fullName'),
        ],
      );

      setState(() {
        _volunteers = docs.rows.map((doc) {
          return Volunteer.fromJson(doc.data);
        }).toList();
        _filteredVolunteers = _volunteers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      Fluttertoast.showToast(
        msg: 'Failed to load volunteers: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  void _filterVolunteers() {
    setState(() {
      _filteredVolunteers = _volunteers.where((volunteer) {
        // Filter by role
        if (_selectedRole != 'all' && volunteer.role != _selectedRole) {
          return false;
        }
        
        // Filter by status
        if (_selectedStatus != 'all') {
          final status = _selectedStatus == 'active' ? true : false;
          if (volunteer.isActive != status) {
            return false;
          }
        }
        
        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final fullName = volunteer.fullName.toLowerCase();
          final department = volunteer.department.toLowerCase();
          
          if (!fullName.contains(query) && !department.contains(query)) {
            return false;
          }
        }
        
        return true;
      }).toList();
    });
  }

  Future<void> _toggleVolunteerStatus(Volunteer volunteer) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      await appwriteService.updateDocument(
        collectionId: 'volunteers',
        documentId: volunteer.id!,
        data: {'isActive': !volunteer.isActive},
      );

      setState(() {
        final index = _volunteers.indexWhere((v) => v.id == volunteer.id);
        if (index != -1) {
          _volunteers[index] = volunteer.copyWith(isActive: !volunteer.isActive);
          _filterVolunteers();
        }
      });

      Fluttertoast.showToast(
        msg: 'Volunteer status updated',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update status: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _updateVolunteerRole(Volunteer volunteer, String newRole) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      await appwriteService.updateDocument(
        collectionId: 'volunteers',
        documentId: volunteer.id!,
        data: {'role': newRole},
      );

      setState(() {
        final index = _volunteers.indexWhere((v) => v.id == volunteer.id);
        if (index != -1) {
          _volunteers[index] = volunteer.copyWith(role: newRole);
          _filterVolunteers();
        }
      });

      Fluttertoast.showToast(
        msg: 'Volunteer role updated',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update role: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  void _showVolunteerDetails(Volunteer volunteer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(volunteer.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(
                label: 'Email',
                value: volunteer.id!, // In real app, fetch user email
              ),
              _DetailRow(
                label: 'Phone',
                value: volunteer.phone,
              ),
              _DetailRow(
                label: 'Department',
                value: volunteer.department,
              ),
              _DetailRow(
                label: 'Role',
                value: volunteer.role.toUpperCase(),
              ),
              _DetailRow(
                label: 'Status',
                value: volunteer.isActive ? 'Active' : 'Inactive',
                valueColor: volunteer.isActive 
                    ? AppTheme.successColor 
                    : AppTheme.errorColor,
              ),
              _DetailRow(
                label: 'Joined',
                value: volunteer.joinedAt.toString().split(' ')[0],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!volunteer.isActive)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _toggleVolunteerStatus(volunteer);
              },
              child: const Text('Activate'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer Management'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVolunteers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search volunteers',
                    hintText: 'Search by name or department',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterVolunteers();
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Role and Status filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Roles')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'volunteer', child: Text('Volunteer')),
                          DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                            _filterVolunteers();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            _filterVolunteers();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Volunteer count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Showing ${_filteredVolunteers.length} of ${_volunteers.length} volunteers',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          
          // Volunteer list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredVolunteers.isEmpty
                    ? const Center(
                        child: Text('No volunteers found'),
                      )
                    : ListView.builder(
                        itemCount: _filteredVolunteers.length,
                        itemBuilder: (context, index) {
                          final volunteer = _filteredVolunteers[index];
                          return _VolunteerCard(
                            volunteer: volunteer,
                            onTap: () => _showVolunteerDetails(volunteer),
                            onToggleStatus: () => _toggleVolunteerStatus(volunteer),
                            onUpdateRole: (role) => _updateVolunteerRole(volunteer, role),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  const _VolunteerCard({
    required this.volunteer,
    required this.onTap,
    required this.onToggleStatus,
    required this.onUpdateRole,
  });

  final Volunteer volunteer;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;
  final Function(String) onUpdateRole;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      volunteer.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: volunteer.isActive 
                          ? AppTheme.successColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      volunteer.isActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: volunteer.isActive 
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    volunteer.department,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    volunteer.role.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    volunteer.phone,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'toggle') {
                        onToggleStatus();
                      } else if (value.startsWith('role_')) {
                        onUpdateRole(value.substring(5));
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(
                          volunteer.isActive ? 'Deactivate' : 'Activate',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'role_admin',
                        child: Text('Make Admin'),
                      ),
                      const PopupMenuItem(
                        value: 'role_volunteer',
                        child: Text('Make Volunteer'),
                      ),
                      const PopupMenuItem(
                        value: 'role_viewer',
                        child: Text('Make Viewer'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}