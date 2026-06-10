import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const SchoolSiteTrackerApp());

enum UserRole { admin, supervisor, contractor }

enum WorkStatus { pending, started, ongoing, completed, verified, rejected }

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    this.approved = true,
    this.active = true,
  });

  final String id;
  String name;
  String mobile;
  final UserRole role;
  bool approved;
  bool active;
}

class Site {
  Site({
    required this.id,
    required this.name,
    required this.address,
    required this.principal,
    required this.primaryPhone,
    this.secondaryPhone = '',
    this.mapsLink = '',
    this.contractorId,
    this.supervisorIds = const [],
  });

  final String id;
  String name;
  String address;
  String principal;
  String primaryPhone;
  String secondaryPhone;
  String mapsLink;
  String? contractorId;
  List<String> supervisorIds;
}

class WorkCategory {
  WorkCategory({required this.name, this.active = true});

  String name;
  bool active;
}

class WorkItem {
  WorkItem({
    required this.id,
    required this.siteId,
    required this.createdBy,
    required this.description,
    required this.category,
    required this.location,
    required this.priority,
    this.beforePhoto,
    this.afterPhoto,
    this.contractorId,
    this.dueDate,
    this.status = WorkStatus.pending,
    this.contractorRemark = '',
    this.verificationRemark = '',
    List<WorkHistory>? history,
  }) : history = history ?? [];

  final String id;
  final String siteId;
  final String createdBy;
  String description;
  String category;
  String location;
  String priority;
  Uint8List? beforePhoto;
  Uint8List? afterPhoto;
  String? contractorId;
  DateTime? dueDate;
  WorkStatus status;
  String contractorRemark;
  String verificationRemark;
  List<WorkHistory> history;
}

class WorkHistory {
  WorkHistory({required this.label, required this.at, required this.by});

  final String label;
  final DateTime at;
  final String by;
}

class RegistrationRequest {
  RegistrationRequest({
    required this.name,
    required this.mobile,
    required this.role,
  });

  final String name;
  final String mobile;
  final UserRole role;
}

class DemoStore extends ChangeNotifier {
  final users = <AppUser>[
    AppUser(
      id: 'u1',
      name: 'Admin',
      mobile: '9999999999',
      role: UserRole.admin,
    ),
    AppUser(
      id: 'u2',
      name: 'Supervisor A',
      mobile: '8888888888',
      role: UserRole.supervisor,
    ),
    AppUser(
      id: 'u3',
      name: 'Supervisor B',
      mobile: '7777777777',
      role: UserRole.supervisor,
    ),
    AppUser(
      id: 'u4',
      name: 'Civil Contractor',
      mobile: '6666666666',
      role: UserRole.contractor,
    ),
    AppUser(
      id: 'u5',
      name: 'Electrical Contractor',
      mobile: '5555555555',
      role: UserRole.contractor,
    ),
  ];

  final sites = <Site>[
    Site(
      id: 's1',
      name: 'Green Valley School',
      address: 'Sector 12, Gurgaon',
      principal: 'Mrs. Sharma',
      primaryPhone: '9810011100',
      secondaryPhone: '9810011101',
      mapsLink: 'https://maps.google.com/?q=Sector%2012%20Gurgaon',
      contractorId: 'u4',
      supervisorIds: ['u2'],
    ),
    Site(
      id: 's2',
      name: 'Sunrise Public School',
      address: 'Dwarka, New Delhi',
      principal: 'Mr. Verma',
      primaryPhone: '9810022200',
      secondaryPhone: '9810022201',
      mapsLink: 'https://maps.google.com/?q=Dwarka%20New%20Delhi',
      contractorId: 'u5',
      supervisorIds: ['u2', 'u3'],
    ),
  ];

  final categories = <WorkCategory>[
    WorkCategory(name: 'Civil'),
    WorkCategory(name: 'Plumbing'),
    WorkCategory(name: 'Electrical'),
    WorkCategory(name: 'Painting'),
    WorkCategory(name: 'Waterproofing'),
    WorkCategory(name: 'Carpentry'),
  ];

  final workItems = <WorkItem>[
    WorkItem(
      id: 'w1',
      siteId: 's1',
      createdBy: 'u2',
      description: 'Repair classroom wall cracks',
      category: 'Civil',
      location: 'Classroom 4',
      priority: 'High',
      contractorId: 'u4',
      dueDate: DateTime.now().add(const Duration(days: 5)),
      status: WorkStatus.ongoing,
      history: [
        WorkHistory(
          label: 'Assigned to contractor',
          at: DateTime.now().subtract(const Duration(days: 2)),
          by: 'Admin',
        ),
        WorkHistory(
          label: 'Started work',
          at: DateTime.now().subtract(const Duration(days: 1)),
          by: 'Civil Contractor',
        ),
      ],
    ),
    WorkItem(
      id: 'w2',
      siteId: 's2',
      createdBy: 'u3',
      description: 'Replace corridor tube lights',
      category: 'Electrical',
      location: 'Main corridor',
      priority: 'Medium',
      contractorId: 'u5',
      dueDate: DateTime.now().add(const Duration(days: 3)),
      status: WorkStatus.completed,
      contractorRemark: 'Lights replaced and tested.',
      history: [
        WorkHistory(
          label: 'Assigned to contractor',
          at: DateTime.now().subtract(const Duration(days: 3)),
          by: 'Admin',
        ),
        WorkHistory(
          label: 'Started work',
          at: DateTime.now().subtract(const Duration(days: 2)),
          by: 'Electrical Contractor',
        ),
        WorkHistory(
          label: 'Marked completed',
          at: DateTime.now().subtract(const Duration(hours: 6)),
          by: 'Electrical Contractor',
        ),
      ],
    ),
  ];

  final registrationRequests = <RegistrationRequest>[];
  AppUser? currentUser;

  List<AppUser> get supervisors =>
      users.where((user) => user.role == UserRole.supervisor).toList();

  List<AppUser> get contractors =>
      users.where((user) => user.role == UserRole.contractor).toList();

  List<Site> visibleSitesFor(AppUser user) {
    if (user.role == UserRole.admin) return sites;
    if (user.role == UserRole.supervisor) {
      return sites
          .where((site) => site.supervisorIds.contains(user.id))
          .toList();
    }
    return sites.where((site) => site.contractorId == user.id).toList();
  }

  List<WorkItem> visibleWorkFor(AppUser user) {
    if (user.role == UserRole.admin) return workItems;
    if (user.role == UserRole.supervisor) {
      final siteIds = visibleSitesFor(user).map((site) => site.id).toSet();
      return workItems.where((item) => siteIds.contains(item.siteId)).toList();
    }
    final siteIds = visibleSitesFor(user).map((site) => site.id).toSet();
    return workItems.where((item) => siteIds.contains(item.siteId)).toList();
  }

  Site siteById(String id) => sites.firstWhere((site) => site.id == id);

  String userName(String? id) {
    if (id == null) return 'Unassigned';
    return users.firstWhere((user) => user.id == id).name;
  }

  List<WorkItem> workForSite(String siteId) =>
      workItems.where((item) => item.siteId == siteId).toList();

  void login(AppUser user) {
    currentUser = user;
    notifyListeners();
  }

  void logout() {
    currentUser = null;
    notifyListeners();
  }

  void addRegistrationRequest(String name, String mobile, UserRole role) {
    registrationRequests.add(
      RegistrationRequest(name: name, mobile: mobile, role: role),
    );
    notifyListeners();
  }

  void approveRequest(RegistrationRequest request) {
    users.add(
      AppUser(
        id: 'u${users.length + 1}',
        name: request.name,
        mobile: request.mobile,
        role: request.role,
      ),
    );
    registrationRequests.remove(request);
    notifyListeners();
  }

  void addCategory(String name) {
    if (name.trim().isEmpty) return;
    categories.add(WorkCategory(name: name.trim()));
    notifyListeners();
  }

  void toggleCategory(WorkCategory category) {
    category.active = !category.active;
    notifyListeners();
  }

  void removeCategory(WorkCategory category) {
    categories.remove(category);
    notifyListeners();
  }

  void updateCategory(WorkCategory category, String name) {
    category.name = name.trim();
    notifyListeners();
  }

  void addSite(Site site) {
    sites.add(site);
    notifyListeners();
  }

  void updateSite(Site site) {
    notifyListeners();
  }

  void assignSiteContractor(Site site, String contractorId) {
    site.contractorId = contractorId;
    for (final item in workForSite(site.id)) {
      item.contractorId = contractorId;
      item.dueDate ??= DateTime.now().add(const Duration(days: 7));
      item.history.add(
        WorkHistory(
          label: 'Assigned to ${userName(contractorId)}',
          at: DateTime.now(),
          by: currentUser?.name ?? 'Admin',
        ),
      );
    }
    notifyListeners();
  }

  void toggleSupervisorAccess(Site site, String supervisorId) {
    if (site.supervisorIds.contains(supervisorId)) {
      site.supervisorIds.remove(supervisorId);
    } else {
      site.supervisorIds.add(supervisorId);
    }
    notifyListeners();
  }

  void addWorkItem(WorkItem item) {
    item.contractorId ??= siteById(item.siteId).contractorId;
    item.history.add(
      WorkHistory(
        label: 'Work item created',
        at: DateTime.now(),
        by: currentUser?.name ?? 'User',
      ),
    );
    workItems.insert(0, item);
    notifyListeners();
  }

  void assignWork(WorkItem item, String contractorId) {
    item.contractorId = contractorId;
    item.status = WorkStatus.pending;
    item.dueDate ??= DateTime.now().add(const Duration(days: 7));
    item.history.add(
      WorkHistory(
        label: 'Assigned to ${userName(contractorId)}',
        at: DateTime.now(),
        by: currentUser?.name ?? 'Admin',
      ),
    );
    notifyListeners();
  }

  void updateContractorWork(
    WorkItem item,
    WorkStatus status,
    Uint8List? afterPhoto,
    String remark,
  ) {
    item.status = status;
    item.afterPhoto = afterPhoto ?? item.afterPhoto;
    item.contractorRemark = remark;
    item.history.add(
      WorkHistory(
        label: 'Status changed to ${statusLabel(status)}',
        at: DateTime.now(),
        by: currentUser?.name ?? 'Contractor',
      ),
    );
    notifyListeners();
  }

  void verifyWork(WorkItem item, bool approved, String remark) {
    item.status = approved ? WorkStatus.verified : WorkStatus.rejected;
    item.verificationRemark = remark;
    item.history.add(
      WorkHistory(
        label: approved ? 'Verified by supervisor' : 'Rejected for rework',
        at: DateTime.now(),
        by: currentUser?.name ?? 'Supervisor',
      ),
    );
    notifyListeners();
  }

  void updateUser(AppUser user, String name, String mobile) {
    user.name = name;
    user.mobile = mobile;
    notifyListeners();
  }

  void toggleUserActive(AppUser user) {
    user.active = !user.active;
    notifyListeners();
  }

  void addUser(String name, String mobile, UserRole role) {
    users.add(
      AppUser(
        id: 'u${users.length + 1}',
        name: name,
        mobile: mobile,
        role: role,
      ),
    );
    notifyListeners();
  }

  void removeUser(AppUser user) {
    users.remove(user);
    for (final site in sites) {
      site.supervisorIds.remove(user.id);
      if (site.contractorId == user.id) site.contractorId = null;
    }
    notifyListeners();
  }
}

final store = DemoStore();
final picker = ImagePicker();

class SchoolSiteTrackerApp extends StatelessWidget {
  const SchoolSiteTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'School Site Tracker',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF126C57),
            ),
            scaffoldBackgroundColor: const Color(0xFFF6F8F7),
            cardTheme: const CardThemeData(
              elevation: 0,
              margin: EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          home: store.currentUser == null
              ? const AuthScreen()
              : const HomeShell(),
        );
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int tab = 0;
  UserRole selectedRole = UserRole.supervisor;
  final mobile = TextEditingController(text: '9999999999');
  final name = TextEditingController();
  final password = TextEditingController(text: 'password');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.photo_camera_back,
                    size: 56,
                    color: Color(0xFF126C57),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'School Site Tracker',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Photo-first maintenance tracking for schools and contractors.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Login')),
                      ButtonSegment(value: 1, label: Text('Register')),
                      ButtonSegment(value: 2, label: Text('Forgot')),
                    ],
                    selected: {tab},
                    onSelectionChanged: (value) =>
                        setState(() => tab = value.first),
                  ),
                  const SizedBox(height: 16),
                  if (tab == 0) _loginCard(context),
                  if (tab == 1) _registerCard(context),
                  if (tab == 2) _forgotCard(context),
                  const SizedBox(height: 16),
                  const Text(
                    'Demo logins: Admin 9999999999, Supervisor 8888888888, Contractor 6666666666. Any password works.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loginCard(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          AppTextField(controller: mobile, label: 'Mobile number or email'),
          AppTextField(
            controller: password,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Login'),
            onPressed: () {
              final matches = store.users.where(
                (user) =>
                    user.mobile == mobile.text.trim() &&
                    user.approved &&
                    user.active,
              );
              if (matches.isEmpty) {
                showMessage(context, 'User not found or not approved yet.');
                return;
              }
              store.login(matches.first);
            },
          ),
        ],
      ),
    );
  }

  Widget _registerCard(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          AppTextField(controller: name, label: 'Full name'),
          AppTextField(controller: mobile, label: 'Mobile number'),
          RolePicker(
            value: selectedRole,
            onChanged: (role) => setState(() => selectedRole = role),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Submit for admin approval'),
            onPressed: () {
              store.addRegistrationRequest(
                name.text,
                mobile.text,
                selectedRole,
              );
              showMessage(context, 'Registration request sent to admin.');
              setState(() => tab = 0);
            },
          ),
        ],
      ),
    );
  }

  Widget _forgotCard(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          AppTextField(controller: mobile, label: 'Registered mobile/email'),
          const SizedBox(height: 10),
          FilledButton.icon(
            icon: const Icon(Icons.sms),
            label: const Text('Send OTP reset link'),
            onPressed: () => showMessage(
              context,
              'Demo OTP sent. In production this will connect to SMS/email.',
            ),
          ),
        ],
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser!;
    final pages = switch (user.role) {
      UserRole.admin => const [
        AdminDashboard(),
        WorkListScreen(),
        SitesScreen(),
        SettingsScreen(),
      ],
      UserRole.supervisor => const [
        SupervisorDashboard(),
        SitesScreen(),
        WorkListScreen(),
        SettingsScreen(),
      ],
      UserRole.contractor => const [ContractorDashboard(), WorkListScreen()],
    };
    final destinations = switch (user.role) {
      UserRole.admin => const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.task_alt), label: 'Work'),
        NavigationDestination(icon: Icon(Icons.school), label: 'Profiles'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      UserRole.supervisor => const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.school), label: 'Sites'),
        NavigationDestination(icon: Icon(Icons.task_alt), label: 'Work'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      UserRole.contractor => const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.task_alt), label: 'Work'),
      ],
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('${user.name} - ${roleLabel(user.role)}'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: store.logout,
          ),
        ],
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        destinations: destinations,
        onDestinationSelected: (value) => setState(() => index = value),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final pendingVerification = store.workItems
        .where((item) => item.status == WorkStatus.completed)
        .length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MetricCard(
              label: 'Total schools',
              value: '${store.sites.length}',
              icon: Icons.school,
            ),
            MetricCard(
              label: 'Open work',
              value:
                  '${store.workItems.where((item) => item.status != WorkStatus.verified).length}',
              icon: Icons.pending_actions,
            ),
            MetricCard(
              label: 'Completed',
              value:
                  '${store.workItems.where((item) => item.status == WorkStatus.verified).length}',
              icon: Icons.verified,
            ),
            MetricCard(
              label: 'Pending verification',
              value: '$pendingVerification',
              icon: Icons.fact_check,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SectionTitle('Registration approvals'),
        if (store.registrationRequests.isEmpty)
          const AppCard(child: Text('No pending registration requests.')),
        for (final request in store.registrationRequests)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(request.name),
              subtitle: Text('${request.mobile} - ${roleLabel(request.role)}'),
              trailing: FilledButton(
                onPressed: () => store.approveRequest(request),
                child: const Text('Approve'),
              ),
            ),
          ),
        const SectionTitle('Reports'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PDF/Excel report module placeholder',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Includes school details, before/after photos, contractor, status, verification, and remarks.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate sample PDF report'),
                onPressed: () => showMessage(
                  context,
                  'Backend PDF generation will plug in here.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SupervisorDashboard extends StatelessWidget {
  const SupervisorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser!;
    final sites = store.visibleSitesFor(user);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MetricCard(
              label: 'Assigned sites',
              value: '${sites.length}',
              icon: Icons.school,
            ),
            MetricCard(
              label: 'Captured items',
              value: '${store.visibleWorkFor(user).length}',
              icon: Icons.photo_library,
            ),
            MetricCard(
              label: 'Need verification',
              value:
                  '${store.visibleWorkFor(user).where((item) => item.status == WorkStatus.completed).length}',
              icon: Icons.fact_check,
            ),
          ],
        ),
        const SectionTitle('Assigned sites'),
        for (final site in sites) SiteCard(site: site),
      ],
    );
  }
}

class ContractorDashboard extends StatelessWidget {
  const ContractorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final work = store.visibleWorkFor(store.currentUser!);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            MetricCard(
              label: 'Assigned work',
              value: '${work.length}',
              icon: Icons.assignment,
            ),
            MetricCard(
              label: 'Ongoing',
              value:
                  '${work.where((item) => item.status == WorkStatus.ongoing).length}',
              icon: Icons.timelapse,
            ),
            MetricCard(
              label: 'Completed',
              value:
                  '${work.where((item) => item.status == WorkStatus.completed).length}',
              icon: Icons.done_all,
            ),
          ],
        ),
        const SectionTitle('My assigned work'),
        for (final item in work) WorkItemCard(item: item),
      ],
    );
  }
}

class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key});

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final search = TextEditingController();
  String supervisorFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser!;
    var sites = store.visibleSitesFor(user);
    if (search.text.trim().isNotEmpty) {
      final term = search.text.trim().toLowerCase();
      sites = sites
          .where(
            (site) =>
                site.name.toLowerCase().contains(term) ||
                site.principal.toLowerCase().contains(term) ||
                site.address.toLowerCase().contains(term),
          )
          .toList();
    }
    if (supervisorFilter == 'Assigned') {
      sites = sites.where((site) => site.supervisorIds.isNotEmpty).toList();
    }
    if (supervisorFilter == 'Not assigned') {
      sites = sites.where((site) => site.supervisorIds.isEmpty).toList();
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppTextField(
          controller: search,
          label: 'Search school, principal, address',
          onChanged: (_) => setState(() {}),
        ),
        if (user.role == UserRole.admin)
          DropdownButtonFormField<String>(
            initialValue: supervisorFilter,
            decoration: const InputDecoration(
              labelText: 'Supervisor filter',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All schools')),
              DropdownMenuItem(
                value: 'Assigned',
                child: Text('Supervisor assigned'),
              ),
              DropdownMenuItem(
                value: 'Not assigned',
                child: Text('No supervisor assigned'),
              ),
            ],
            onChanged: (value) => setState(() => supervisorFilter = value!),
          ),
        const SizedBox(height: 8),
        if (user.role == UserRole.admin)
          FilledButton.icon(
            icon: const Icon(Icons.add_business),
            label: const Text('Add school/site'),
            onPressed: () => showSiteDialog(context),
          ),
        const SizedBox(height: 8),
        if (sites.isEmpty)
          const AppCard(child: Text('No school profiles found.')),
        for (final site in sites) SiteCard(site: site),
      ],
    );
  }
}

class SiteCard extends StatelessWidget {
  const SiteCard({super.key, required this.site});

  final Site site;

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser!;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              site.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              '${site.address}\nPrincipal: ${site.principal}\nPrimary: ${site.primaryPhone}'
              '${site.secondaryPhone.isEmpty ? '' : ' | Secondary: ${site.secondaryPhone}'}',
            ),
            isThreeLine: true,
          ),
          Text(
            'Supervisors: ${site.supervisorIds.isEmpty ? 'Not assigned' : site.supervisorIds.map(store.userName).join(', ')}',
          ),
          Text('Contractor: ${store.userName(site.contractorId)}'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.call),
                label: const Text('Call'),
                onPressed: () => launchPhone(site.primaryPhone),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Maps'),
                onPressed: () => launchMaps(site),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('WhatsApp'),
                onPressed: () => shareSiteOnWhatsApp(site),
              ),
              if (user.role == UserRole.supervisor)
                FilledButton.icon(
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Start site visit'),
                  onPressed: () => showWorkDialog(context, site),
                ),
              if (user.role == UserRole.admin)
                OutlinedButton.icon(
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text('Supervisor access'),
                  onPressed: () => showSupervisorAccessDialog(context, site),
                ),
              if (user.role == UserRole.admin)
                OutlinedButton.icon(
                  icon: const Icon(Icons.engineering),
                  label: const Text('Contractor'),
                  onPressed: () => showSiteContractorDialog(context, site),
                ),
              if (user.role == UserRole.admin)
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  onPressed: () => showSiteDialog(context, site: site),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkListScreen extends StatefulWidget {
  const WorkListScreen({super.key});

  @override
  State<WorkListScreen> createState() => _WorkListScreenState();
}

class _WorkListScreenState extends State<WorkListScreen> {
  final search = TextEditingController();
  String progressFilter = 'All';
  String assignedDateFilter = 'All';
  String supervisorFilter = 'All';
  String contractorFilter = 'All';

  @override
  Widget build(BuildContext context) {
    var sites = store.visibleSitesFor(store.currentUser!);
    final term = search.text.trim().toLowerCase();
    if (term.isNotEmpty) {
      sites = sites
          .where(
            (site) =>
                site.name.toLowerCase().contains(term) ||
                site.address.toLowerCase().contains(term) ||
                store.userName(site.contractorId).toLowerCase().contains(term),
          )
          .toList();
    }
    if (progressFilter != 'All') {
      sites = sites
          .where(
            (site) =>
                siteProgressLabel(store.workForSite(site.id)) == progressFilter,
          )
          .toList();
    }
    if (assignedDateFilter != 'All') {
      sites = sites.where((site) {
        final assignedAt = siteAssignedDate(store.workForSite(site.id));
        if (assignedAt == null) return false;
        final age = DateTime.now().difference(assignedAt);
        return assignedDateFilter == 'Last 7 days'
            ? age.inDays <= 7
            : age.inDays <= 30;
      }).toList();
    }
    if (supervisorFilter != 'All') {
      sites = sites
          .where((site) => site.supervisorIds.contains(supervisorFilter))
          .toList();
    }
    if (contractorFilter != 'All') {
      sites = sites
          .where((site) => site.contractorId == contractorFilter)
          .toList();
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppTextField(
          controller: search,
          label: 'Search school, contractor, address',
          onChanged: (_) => setState(() {}),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: progressFilter,
                decoration: const InputDecoration(
                  labelText: 'Progress',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(
                    value: 'Not started',
                    child: Text('Not started'),
                  ),
                  DropdownMenuItem(
                    value: 'In progress',
                    child: Text('In progress'),
                  ),
                  DropdownMenuItem(
                    value: 'Pending verification',
                    child: Text('Pending verification'),
                  ),
                  DropdownMenuItem(value: 'Verified', child: Text('Verified')),
                ],
                onChanged: (value) => setState(() => progressFilter = value!),
              ),
            ),
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<String>(
                initialValue: assignedDateFilter,
                decoration: const InputDecoration(
                  labelText: 'Date assigned',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All dates')),
                  DropdownMenuItem(
                    value: 'Last 7 days',
                    child: Text('Last 7 days'),
                  ),
                  DropdownMenuItem(
                    value: 'Last 30 days',
                    child: Text('Last 30 days'),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => assignedDateFilter = value!),
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                initialValue: supervisorFilter,
                decoration: const InputDecoration(
                  labelText: 'Supervisor',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'All',
                    child: Text('All supervisors'),
                  ),
                  for (final user in store.supervisors)
                    DropdownMenuItem(value: user.id, child: Text(user.name)),
                ],
                onChanged: (value) => setState(() => supervisorFilter = value!),
              ),
            ),
            SizedBox(
              width: 190,
              child: DropdownButtonFormField<String>(
                initialValue: contractorFilter,
                decoration: const InputDecoration(
                  labelText: 'Contractor',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: 'All',
                    child: Text('All contractors'),
                  ),
                  for (final user in store.contractors)
                    DropdownMenuItem(value: user.id, child: Text(user.name)),
                ],
                onChanged: (value) => setState(() => contractorFilter = value!),
              ),
            ),
          ],
        ),
        const SectionTitle('Sites and work progress'),
        if (sites.isEmpty)
          const AppCard(child: Text('No sites match these filters.')),
        for (final site in sites) SiteWorkCard(site: site),
      ],
    );
  }
}

class SiteWorkCard extends StatelessWidget {
  const SiteWorkCard({
    super.key,
    required this.site,
    this.showOpenButton = true,
  });

  final Site site;
  final bool showOpenButton;

  @override
  Widget build(BuildContext context) {
    final work = store.workForSite(site.id);
    final progress = siteProgress(work);
    final progressLabel = siteProgressLabel(work);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              site.name,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Contractor: ${store.userName(site.contractorId)}\n'
              'Supervisor: ${site.supervisorIds.isEmpty ? 'Not assigned' : site.supervisorIds.map(store.userName).join(', ')}',
            ),
            trailing: StatusChip(
              label: progressLabel,
              color: progressColor(progressLabel),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: progress, minHeight: 9),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}% complete • ${work.length} work photos',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (showOpenButton)
                FilledButton.icon(
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open site work'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SiteWorkDetailScreen(site: site),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download report'),
                onPressed: () => downloadSiteReport(context, site),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SiteWorkDetailScreen extends StatelessWidget {
  const SiteWorkDetailScreen({super.key, required this.site});

  final Site site;

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser!;
    final work = store.workForSite(site.id);
    return Scaffold(
      appBar: AppBar(title: Text(site.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SiteWorkCard(site: site, showOpenButton: false),
          if (user.role == UserRole.supervisor)
            FilledButton.icon(
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add work photo'),
              onPressed: () => showWorkDialog(context, site),
            ),
          const SectionTitle('Work photos and status history'),
          if (work.isEmpty)
            const AppCard(child: Text('No work photos added yet.')),
          for (final item in work) WorkItemCard(item: item),
        ],
      ),
    );
  }
}

class WorkItemCard extends StatelessWidget {
  const WorkItemCard({super.key, required this.item});

  final WorkItem item;

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser!;
    final site = store.siteById(item.siteId);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PhotoBox(
                bytes: item.beforePhoto,
                label: 'Before photo',
                onTap: () =>
                    showLargePhoto(context, item.beforePhoto, 'Before photo'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(site.name),
                    Text(
                      '${item.category} - ${item.location} - ${item.priority} priority',
                    ),
                    Text('Contractor: ${store.userName(site.contractorId)}'),
                    const SizedBox(height: 8),
                    StatusChip(status: item.status),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (user.role == UserRole.admin)
                OutlinedButton.icon(
                  icon: const Icon(Icons.engineering),
                  label: const Text('Change site contractor'),
                  onPressed: () => showSiteContractorDialog(context, site),
                ),
              if (user.role == UserRole.contractor)
                FilledButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('Update status / after photo'),
                  onPressed: () => showContractorUpdateDialog(context, item),
                ),
              if (user.role == UserRole.supervisor &&
                  item.status == WorkStatus.completed)
                FilledButton.icon(
                  icon: const Icon(Icons.verified),
                  label: const Text('Verify'),
                  onPressed: () => showVerifyDialog(context, item),
                ),
            ],
          ),
          if (item.afterPhoto != null || item.contractorRemark.isNotEmpty) ...[
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PhotoBox(
                  bytes: item.afterPhoto,
                  label: 'After photo',
                  onTap: () =>
                      showLargePhoto(context, item.afterPhoto, 'After photo'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Contractor remark: ${item.contractorRemark}'),
                ),
              ],
            ),
          ],
          if (item.history.isNotEmpty) ...[
            const Divider(height: 24),
            const Text(
              'History',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            for (final event in item.history.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${formatDateTime(event.at)} • ${event.label} • ${event.by}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionTitle('Categories'),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add category'),
          onPressed: () => showCategoryDialog(context),
        ),
        const SizedBox(height: 8),
        for (final category in store.categories)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(category.name),
              subtitle: Text(category.active ? 'Active' : 'Inactive'),
              trailing: Wrap(
                spacing: 6,
                children: [
                  Switch(
                    value: category.active,
                    onChanged: user.role == UserRole.contractor
                        ? null
                        : (_) => store.toggleCategory(category),
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit),
                    onPressed: () =>
                        showCategoryDialog(context, category: category),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => store.removeCategory(category),
                  ),
                ],
              ),
            ),
          ),
        if (user.role == UserRole.admin) ...[
          ProfileSection(
            title: 'Profiles of supervisors',
            role: UserRole.supervisor,
          ),
          ProfileSection(
            title: 'Profiles of contractors',
            role: UserRole.contractor,
          ),
        ],
      ],
    );
  }
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.title, required this.role});

  final String title;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final people = store.users.where((user) => user.role == role).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        FilledButton.icon(
          icon: const Icon(Icons.person_add),
          label: Text('Add ${roleLabel(role)}'),
          onPressed: () => showUserProfileDialog(context, role: role),
        ),
        const SizedBox(height: 8),
        for (final person in people)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(person.name),
              subtitle: Text(
                '${person.mobile} • ${person.active ? 'Active' : 'Inactive'}',
              ),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: 'Call',
                    icon: const Icon(Icons.call),
                    onPressed: () => launchPhone(person.mobile),
                  ),
                  Switch(
                    value: person.active,
                    onChanged: (_) => store.toggleUserActive(person),
                  ),
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit),
                    onPressed: () => showUserProfileDialog(
                      context,
                      user: person,
                      role: role,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => store.removeUser(person),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.obscureText = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class RolePicker extends StatelessWidget {
  const RolePicker({super.key, required this.value, required this.onChanged});

  final UserRole value;
  final ValueChanged<UserRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<UserRole>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Role',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: UserRole.supervisor,
          child: Text('Site Supervisor'),
        ),
        DropdownMenuItem(value: UserRole.contractor, child: Text('Contractor')),
        DropdownMenuItem(value: UserRole.admin, child: Text('Admin')),
      ],
      onChanged: (role) => onChanged(role!),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 165,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class PhotoBox extends StatelessWidget {
  const PhotoBox({
    super.key,
    required this.bytes,
    required this.label,
    this.onTap,
  });

  final Uint8List? bytes;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 86,
        height: 86,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EFEC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: bytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_outlined),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              )
            : Image.memory(bytes!, fit: BoxFit.cover),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, this.status, this.label, this.color});

  final WorkStatus? status;
  final String? label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor =
        color ??
        switch (status!) {
          WorkStatus.pending => Colors.red,
          WorkStatus.started => Colors.blue,
          WorkStatus.ongoing => Colors.orange,
          WorkStatus.completed => Colors.green,
          WorkStatus.verified => Colors.deepPurple,
          WorkStatus.rejected => Colors.blueGrey,
        };
    return Chip(
      label: Text(label ?? statusLabel(status!)),
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: chipColor,
      side: BorderSide.none,
    );
  }
}

Future<Uint8List?> pickPhoto(ImageSource source) async {
  final file = await picker.pickImage(
    source: source,
    imageQuality: 75,
    maxWidth: 1600,
  );
  return file?.readAsBytes();
}

void showSiteDialog(BuildContext context, {Site? site}) {
  final name = TextEditingController(text: site?.name ?? '');
  final address = TextEditingController(text: site?.address ?? '');
  final principal = TextEditingController(text: site?.principal ?? '');
  final primaryPhone = TextEditingController(text: site?.primaryPhone ?? '');
  final secondaryPhone = TextEditingController(
    text: site?.secondaryPhone ?? '',
  );
  final mapsLink = TextEditingController(text: site?.mapsLink ?? '');
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(site == null ? 'Add school/site' : 'Edit school/site'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: name, label: 'School/site name'),
            AppTextField(controller: address, label: 'Address'),
            AppTextField(
              controller: mapsLink,
              label: 'Google Maps link/address',
            ),
            AppTextField(controller: principal, label: 'Principal name'),
            AppTextField(
              controller: primaryPhone,
              label: 'Primary phone number',
            ),
            AppTextField(
              controller: secondaryPhone,
              label: 'Secondary phone number',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (site == null) {
              store.addSite(
                Site(
                  id: 's${store.sites.length + 1}',
                  name: name.text,
                  address: address.text,
                  principal: principal.text,
                  primaryPhone: primaryPhone.text,
                  secondaryPhone: secondaryPhone.text,
                  mapsLink: mapsLink.text,
                ),
              );
            } else {
              site.name = name.text;
              site.address = address.text;
              site.principal = principal.text;
              site.primaryPhone = primaryPhone.text;
              site.secondaryPhone = secondaryPhone.text;
              site.mapsLink = mapsLink.text;
              store.updateSite(site);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void showCategoryDialog(BuildContext context, {WorkCategory? category}) {
  final name = TextEditingController(text: category?.name ?? '');
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(category == null ? 'Add category' : 'Edit category'),
      content: AppTextField(controller: name, label: 'Category name'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (category == null) {
              store.addCategory(name.text);
            } else {
              store.updateCategory(category, name.text);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void showUserProfileDialog(
  BuildContext context, {
  AppUser? user,
  required UserRole role,
}) {
  final name = TextEditingController(text: user?.name ?? '');
  final mobile = TextEditingController(text: user?.mobile ?? '');
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(user == null ? 'Add ${roleLabel(role)}' : 'Edit profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(controller: name, label: 'Name'),
          AppTextField(controller: mobile, label: 'Mobile number'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (user == null) {
              store.addUser(name.text, mobile.text, role);
            } else {
              store.updateUser(user, name.text, mobile.text);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void showSupervisorAccessDialog(BuildContext context, Site site) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Access for ${site.name}'),
      content: StatefulBuilder(
        builder: (context, setLocalState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final supervisor in store.supervisors)
                CheckboxListTile(
                  title: Text(supervisor.name),
                  value: site.supervisorIds.contains(supervisor.id),
                  onChanged: (_) {
                    store.toggleSupervisorAccess(site, supervisor.id);
                    setLocalState(() {});
                  },
                ),
            ],
          );
        },
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

void showSiteContractorDialog(BuildContext context, Site site) {
  var selected = site.contractorId ?? store.contractors.first.id;
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Contractor for ${site.name}'),
      content: DropdownButtonFormField<String>(
        initialValue: selected,
        decoration: const InputDecoration(
          labelText: 'One contractor assigned to this school',
          border: OutlineInputBorder(),
        ),
        items: [
          for (final contractor in store.contractors.where(
            (user) => user.active,
          ))
            DropdownMenuItem(
              value: contractor.id,
              child: Text(contractor.name),
            ),
        ],
        onChanged: (value) => selected = value!,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            store.assignSiteContractor(site, selected);
            Navigator.pop(context);
          },
          child: const Text('Assign'),
        ),
      ],
    ),
  );
}

void showAssignDialog(BuildContext context, WorkItem item) {
  var selected = item.contractorId ?? store.contractors.first.id;
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Assign contractor'),
      content: DropdownButtonFormField<String>(
        initialValue: selected,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        items: [
          for (final contractor in store.contractors)
            DropdownMenuItem(
              value: contractor.id,
              child: Text(contractor.name),
            ),
        ],
        onChanged: (value) => selected = value!,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            store.assignWork(item, selected);
            Navigator.pop(context);
          },
          child: const Text('Assign'),
        ),
      ],
    ),
  );
}

void showWorkDialog(BuildContext context, Site site) {
  final description = TextEditingController();
  final location = TextEditingController();
  var category = store.categories.firstWhere((item) => item.active).name;
  var priority = 'Medium';
  Uint8List? photo;

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocalState) {
        return AlertDialog(
          title: Text('New work item - ${site.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhotoBox(bytes: photo, label: 'Before photo'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Click'),
                      onPressed: () async {
                        photo = await pickPhoto(ImageSource.camera);
                        setLocalState(() {});
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Upload'),
                      onPressed: () async {
                        photo = await pickPhoto(ImageSource.gallery);
                        setLocalState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(
                  controller: description,
                  label: 'Work description',
                  maxLines: 3,
                ),
                AppTextField(controller: location, label: 'Location/area'),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final item in store.categories.where(
                      (item) => item.active,
                    ))
                      DropdownMenuItem(
                        value: item.name,
                        child: Text(item.name),
                      ),
                  ],
                  onChanged: (value) => category = value!,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (value) => priority = value!,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                store.addWorkItem(
                  WorkItem(
                    id: 'w${store.workItems.length + 1}',
                    siteId: site.id,
                    createdBy: store.currentUser!.id,
                    description: description.text,
                    category: category,
                    location: location.text,
                    priority: priority,
                    beforePhoto: photo,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    ),
  );
}

void showContractorUpdateDialog(BuildContext context, WorkItem item) {
  final remark = TextEditingController(text: item.contractorRemark);
  var status = item.status == WorkStatus.pending
      ? WorkStatus.started
      : item.status;
  Uint8List? afterPhoto = item.afterPhoto;
  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocalState) {
        return AlertDialog(
          title: const Text('Update work'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhotoBox(bytes: afterPhoto, label: 'After photo'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Click'),
                      onPressed: () async {
                        afterPhoto = await pickPhoto(ImageSource.camera);
                        setLocalState(() {});
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Upload'),
                      onPressed: () async {
                        afterPhoto = await pickPhoto(ImageSource.gallery);
                        setLocalState(() {});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<WorkStatus>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: WorkStatus.started,
                      child: Text('Started'),
                    ),
                    DropdownMenuItem(
                      value: WorkStatus.ongoing,
                      child: Text('Ongoing'),
                    ),
                    DropdownMenuItem(
                      value: WorkStatus.completed,
                      child: Text('Completed'),
                    ),
                  ],
                  onChanged: (value) => status = value!,
                ),
                const SizedBox(height: 10),
                AppTextField(
                  controller: remark,
                  label: 'Completion remarks',
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                store.updateContractorWork(
                  item,
                  status,
                  afterPhoto,
                  remark.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    ),
  );
}

void showVerifyDialog(BuildContext context, WorkItem item) {
  final remark = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Verify work'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PhotoBox(bytes: item.beforePhoto, label: 'Before'),
              const SizedBox(width: 12),
              PhotoBox(bytes: item.afterPhoto, label: 'After'),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: remark,
            label: 'Verification/rejection remark',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            store.verifyWork(item, false, remark.text);
            Navigator.pop(context);
          },
          child: const Text('Reject'),
        ),
        FilledButton(
          onPressed: () {
            store.verifyWork(item, true, remark.text);
            Navigator.pop(context);
          },
          child: const Text('Approve'),
        ),
      ],
    ),
  );
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

Future<void> launchPhone(String phone) async {
  final uri = Uri.parse('tel:$phone');
  if (!await launchUrl(uri)) {}
}

Future<void> launchMaps(Site site) async {
  final target = site.mapsLink.trim().isEmpty
      ? 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(site.address)}'
      : site.mapsLink.trim();
  await launchUrl(Uri.parse(target), mode: LaunchMode.externalApplication);
}

Future<void> shareSiteOnWhatsApp(Site site) async {
  final details = [
    'Site: ${site.name}',
    'Principal: ${site.principal}',
    'Primary contact: ${site.primaryPhone}',
    if (site.secondaryPhone.isNotEmpty)
      'Secondary contact: ${site.secondaryPhone}',
    'Location: ${site.mapsLink.isNotEmpty ? site.mapsLink : site.address}',
  ].join('\n');
  final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(details)}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

void showLargePhoto(BuildContext context, Uint8List? bytes, String title) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        body: Center(
          child: bytes == null
              ? const Text('No photo uploaded yet.')
              : InteractiveViewer(child: Image.memory(bytes)),
        ),
      ),
    ),
  );
}

double siteProgress(List<WorkItem> work) {
  if (work.isEmpty) return 0;
  final score = work.fold<double>(0, (total, item) {
    return total +
        switch (item.status) {
          WorkStatus.pending => 0,
          WorkStatus.started => 0.25,
          WorkStatus.ongoing => 0.5,
          WorkStatus.completed => 0.8,
          WorkStatus.verified => 1,
          WorkStatus.rejected => 0.35,
        };
  });
  return score / work.length;
}

String siteProgressLabel(List<WorkItem> work) {
  if (work.isEmpty) return 'Not started';
  if (work.every((item) => item.status == WorkStatus.verified)) {
    return 'Verified';
  }
  if (work.any((item) => item.status == WorkStatus.completed)) {
    return 'Pending verification';
  }
  if (work.any(
    (item) =>
        item.status == WorkStatus.started || item.status == WorkStatus.ongoing,
  )) {
    return 'In progress';
  }
  return 'Not started';
}

DateTime? siteAssignedDate(List<WorkItem> work) {
  final dates = <DateTime>[];
  for (final item in work) {
    for (final event in item.history) {
      if (event.label.toLowerCase().contains('assigned')) {
        dates.add(event.at);
      }
    }
  }
  if (dates.isEmpty) return null;
  dates.sort();
  return dates.last;
}

Color progressColor(String label) {
  return switch (label) {
    'Verified' => Colors.deepPurple,
    'Pending verification' => Colors.green,
    'In progress' => Colors.orange,
    _ => Colors.red,
  };
}

String buildSiteReport(Site site) {
  final work = store.workForSite(site.id);
  return [
    'School Site Report',
    'Generated: ${formatDateTime(DateTime.now())}',
    '',
    'Site: ${site.name}',
    'Address: ${site.address}',
    'Principal: ${site.principal}',
    'Primary phone: ${site.primaryPhone}',
    if (site.secondaryPhone.isNotEmpty)
      'Secondary phone: ${site.secondaryPhone}',
    'Maps: ${site.mapsLink}',
    'Supervisors: ${site.supervisorIds.isEmpty ? 'Not assigned' : site.supervisorIds.map(store.userName).join(', ')}',
    'Contractor: ${store.userName(site.contractorId)}',
    'Progress: ${siteProgressLabel(work)} (${(siteProgress(work) * 100).round()}%)',
    '',
    'Work items:',
    for (final item in work)
      '- ${item.description} | ${item.category} | ${item.location} | ${statusLabel(item.status)} | Remark: ${item.contractorRemark}',
  ].join('\n');
}

Future<void> downloadSiteReport(BuildContext context, Site site) async {
  final report = buildSiteReport(site);
  final uri = Uri.parse(
    'data:text/plain;charset=utf-8,${Uri.encodeComponent(report)}',
  );
  final opened = await launchUrl(uri);
  if (!opened && context.mounted) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${site.name} report'),
        content: SingleChildScrollView(child: SelectableText(report)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

String formatDateTime(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}';
}

String roleLabel(UserRole role) {
  return switch (role) {
    UserRole.admin => 'Admin',
    UserRole.supervisor => 'Site Supervisor',
    UserRole.contractor => 'Contractor',
  };
}

String statusLabel(WorkStatus status) {
  return switch (status) {
    WorkStatus.pending => 'Pending',
    WorkStatus.started => 'Started',
    WorkStatus.ongoing => 'Ongoing',
    WorkStatus.completed => 'Completed',
    WorkStatus.verified => 'Verified',
    WorkStatus.rejected => 'Rework Required',
  };
}
