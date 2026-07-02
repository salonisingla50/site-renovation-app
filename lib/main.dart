import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const SchoolSiteTrackerApp());

enum UserRole { admin, supervisor, contractor, principal }

enum WorkStatus {
  pending,
  started,
  ongoing,
  completed,
  principalApproved,
  verified,
  rejected,
}

enum WorkOrderStatus { draft, sent, accepted, completed }

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    this.approved = true,
    this.active = true,
    this.aadhaar = '',
    this.gst = '',
    this.pan = '',
    this.address = '',
    this.workType = '',
    this.photo,
  });

  final String id;
  String name;
  String mobile;
  final UserRole role;
  bool approved;
  bool active;
  String aadhaar;
  String gst;
  String pan;
  String address;
  String workType;
  Uint8List? photo;
}

class Site {
  Site({
    required this.id,
    required this.name,
    required this.address,
    required this.principal,
    required this.primaryPhone,
    this.circle = '',
    this.grantAmount = '',
    this.paymentAuthority = '',
    this.principalUserId,
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
  String circle;
  String grantAmount;
  String paymentAuthority;
  String? principalUserId;
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
    this.qty = '',
    this.uom = '',
    this.sorItemNo = '',
    this.sorDescription = '',
    this.rate = 0,
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
  String qty;
  String uom;
  String sorItemNo;
  String sorDescription;
  double rate;
  Uint8List? beforePhoto;
  Uint8List? afterPhoto;
  String? contractorId;
  DateTime? dueDate;
  WorkStatus status;
  String contractorRemark;
  String verificationRemark;
  List<WorkHistory> history;

  double get quantityValue => double.tryParse(qty) ?? 0;
  double get totalRate => quantityValue * rate;
  double get contractorVisibleRate => rate * 0.7;
}

class SorItem {
  const SorItem({
    required this.itemNo,
    required this.description,
    required this.rate,
    required this.uom,
    required this.type,
  });

  final String itemNo;
  final String description;
  final double rate;
  final String uom;
  final String type;
}

class WorkEstimateLine {
  WorkEstimateLine({required this.item, this.qty = 1});

  final SorItem item;
  double qty;

  double get total => qty * item.rate;
}

class WorkHistory {
  WorkHistory({required this.label, required this.at, required this.by});

  final String label;
  final DateTime at;
  final String by;
}

class LabourMember {
  LabourMember({
    required this.name,
    required this.aadhaar,
    required this.pan,
    required this.field,
  });

  String name;
  String aadhaar;
  String pan;
  String field;
}

class ContractorApplication {
  ContractorApplication({
    required this.name,
    required this.mobile,
    required this.aadhaar,
    required this.gst,
    required this.pan,
    required this.address,
    required this.workType,
    this.photo,
  });

  String name;
  String mobile;
  String aadhaar;
  String gst;
  String pan;
  String address;
  String workType;
  Uint8List? photo;
}

class VendorUpdateRequest {
  VendorUpdateRequest({
    required this.contractorId,
    required this.title,
    required this.details,
    this.apply,
  });

  final String contractorId;
  final String title;
  final String details;
  final VoidCallback? apply;
}

class WorkOrder {
  WorkOrder({
    required this.id,
    required this.siteId,
    required this.contractorId,
    required this.workType,
    required this.estimatedValue,
    required this.date,
    this.status = WorkOrderStatus.sent,
  });

  final String id;
  final String siteId;
  final String contractorId;
  String workType;
  String estimatedValue;
  DateTime date;
  WorkOrderStatus status;
}

class ContractorBill {
  ContractorBill({
    required this.id,
    required this.siteId,
    required this.contractorId,
    required this.title,
    required this.amount,
    required this.submittedAt,
    this.note = '',
    this.paid,
  });

  final String id;
  final String siteId;
  final String contractorId;
  String title;
  String amount;
  String note;
  DateTime submittedAt;
  bool? paid;
}

class Complaint {
  Complaint({
    required this.id,
    required this.siteId,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String siteId;
  String title;
  String description;
  String createdBy;
  DateTime createdAt;
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

List<Site> seedCollegeSites() {
  final rows = <List<String>>[
    ['Circle 2', 'Government Engg. College, Gandhinagar', 'GTERS', '1000000'],
    ['Circle 2', 'Govt. Polytechnic, Gandhinagar', 'GTERS', '1000000'],
    ['Circle 2', 'CTE, Gandhinagar', 'GTERS', '700000'],
    ['Circle 2', 'TEB Office, Gandhinagar', 'GTERS', '700000'],
    ['Circle 2', 'GKS, Gandhinagar', 'GTERS', '700000'],
    ['Circle 2', 'GTERS, Gandhinagar', 'GTERS', '700000'],
    ['Circle 2', 'GTI Kalol, Gandhinagar', 'GTERS', '1000000'],
    [
      'Circle 2',
      'Government Arts College, Sector 15, Gandhinagar',
      'KCG',
      '1000000',
    ],
    [
      'Circle 2',
      'Government Science College, Sector 15, Gandhinagar',
      'KCG',
      '1000000',
    ],
    [
      'Circle 2',
      'Government Commerce College, Sector 15, Gandhinagar',
      'KCG',
      '1000000',
    ],
    ...circleThreeCollegeRows,
    ...circleFourCollegeRows,
    ...circleFiveCollegeRows,
    ...circleSixCollegeRows,
  ];

  return [
    for (var i = 0; i < rows.length; i++)
      Site(
        id: 's${i + 1}',
        name: rows[i][1],
        address: inferInstituteLocation(rows[i][1]),
        principal: '',
        primaryPhone: '',
        circle: rows[i][0],
        paymentAuthority: rows[i][2],
        grantAmount: rows[i][3],
        mapsLink:
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(rows[i][1])}',
      ),
  ];
}

String inferInstituteLocation(String name) {
  if (!name.contains(',')) return name;
  return name.split(',').last.trim();
}

const circleThreeCollegeRows = <List<String>>[
  ['Circle 3', 'Government Engg. College, Patan', 'GTERS', '1000000'],
  ['Circle 3', 'K.D. Polytechnic, Patan', 'GTERS', '1000000'],
  ['Circle 3', 'Govt. Polytechnic, Vadnagar', 'GTERS', '1000000'],
  ['Circle 3', 'GTHS Patan', 'GTERS', '1000000'],
  ['Circle 3', 'VTC Patan', 'GTERS', '1000000'],
  ['Circle 3', 'Government Engg. College, Palanpur', 'GTERS', '1000000'],
  ['Circle 3', 'Govt. Polytechnic, Palanpur', 'GTERS', '1000000'],
  ['Circle 3', 'GTHS Palanpur', 'GTERS', '1000000'],
  ['Circle 3', 'Government Engg. College, Bhuj', 'GTERS', '1000000'],
  ['Circle 3', 'Govt. Polytechnic, Bhuj', 'GTERS', '1000000'],
  ['Circle 3', 'Government Arts College, Amirgadh', 'KCG', '1000000'],
  ['Circle 3', 'Government Arts & Commerce College, Tharad', 'KCG', '1000000'],
  ['Circle 3', 'Government Arts College, Vaav', 'KCG', '1000000'],
  ['Circle 3', 'Government Science College, Tharad', 'KCG', '404100'],
  ['Circle 3', 'Government Arts College, Bhabhar', 'KCG', '14000'],
  ['Circle 3', 'Government Arts College, Sui Gam', 'KCG', '383800'],
  [
    'Circle 3',
    'Government Arts, Commerce & Science College, Diyodar, Banaskantha',
    'KCG',
    '20000',
  ],
  [
    'Circle 3',
    'Government Science College, Danta, Banaskantha',
    'KCG',
    '20000',
  ],
  ['Circle 3', 'R.R. Lalan College, Bhuj', 'KCG', '1000000'],
  ['Circle 3', 'Government Science College, Mandvi', 'KCG', '600000'],
  ['Circle 3', 'Government Arts & Commerce College, Rapar', 'KCG', '600000'],
  [
    'Circle 3',
    'Maharav Shri Lakhpatji Government Arts & Commerce College, Dayapar, Lakhpat',
    'KCG',
    '14000',
  ],
  ['Circle 3', 'Government Arts & Commerce College, Abdasa', 'KCG', '14000'],
  [
    'Circle 3',
    'Government Arts & Commerce College, Anjar, Kachchh',
    'KCG',
    '20000',
  ],
  ['Circle 3', 'M.N. College, Visnagar', 'KCG', '1000000'],
  ['Circle 3', 'Government Arts College, Bahucharaji', 'KCG', '200000'],
  ['Circle 3', 'Government Science College, Vadnagar', 'KCG', '1000000'],
  ['Circle 3', 'Government Science College, Unjha', 'KCG', '31600'],
  ['Circle 3', 'Tanariri Performing Arts College, Vadnagar', 'KCG', '160000'],
  ['Circle 3', 'Government Arts & Commerce College, Sami', 'KCG', '600000'],
  ['Circle 3', 'Government Arts College, Santalpur', 'KCG', '151200'],
  ['Circle 3', 'Government Arts & Science College, Harij', 'KCG', '14000'],
];

const circleFourCollegeRows = <List<String>>[
  ['Circle 4', 'Government Engg. College, Rajkot', 'GTERS', '1000000'],
  ['Circle 4', 'A.V. Parekh Technical Instt, Rajkot', 'GTERS', '1000000'],
  ['Circle 4', 'Govt. Polytechnic, Rajkot', 'GTERS', '1000000'],
  ['Circle 4', 'B.K. Modi Govt. Pharmacy College, Rajkot', 'GTERS', '1000000'],
  ['Circle 4', 'GTHS Dhoraji', 'GTERS', '350000'],
  ['Circle 4', 'Lukhdhirji Engg. College, Morbi', 'GTERS', '1000000'],
  ['Circle 4', 'Lukhdhirji Engg. College (Poly), Morbi', 'GTERS', '1000000'],
  ['Circle 4', 'C.U. Shah Polytechnic, Surendranagar', 'GTERS', '1000000'],
  ['Circle 4', 'GTHS Dhrangadra', 'GTERS', '350000'],
  ['Circle 4', 'GTHS Surendranagar', 'GTERS', '350000'],
  ['Circle 4', 'Govt. Polytechnic, Jamnagar', 'GTERS', '1000000'],
  ['Circle 4', 'Government Arts College, Kalyanpur', 'KCG', '1000000'],
  ['Circle 4', 'Government Arts College, Bhanvad', 'KCG', '600000'],
  [
    'Circle 4',
    'Government Arts & Commerce College, Jam-Khambhaliya',
    'KCG',
    '400000',
  ],
  [
    'Circle 4',
    'Government Arts & Commerce College, Okha Mandal',
    'KCG',
    '14000',
  ],
  ['Circle 4', 'Shri DKV Arts & Science College, Jamnagar', 'KCG', '1000000'],
  ['Circle 4', 'Government Commerce College, Jamnagar', 'KCG', '658600'],
  ['Circle 4', 'Government Arts & Commerce College, Lalpur', 'KCG', '1000000'],
  ['Circle 4', 'H & H B Kotak Institute of Science, Rajkot', 'KCG', '20000'],
  ['Circle 4', 'Dharmendrasinhji Arts College, Rajkot', 'KCG', '1000000'],
  ['Circle 4', 'AMP Government Law College, Rajkot', 'KCG', '600000'],
  [
    'Circle 4',
    'Government Arts & Commerce College, Paddhari',
    'KCG',
    '1000000',
  ],
  [
    'Circle 4',
    'Thakor Shree Mulvaji Government Arts College, Kotada Sangani',
    'KCG',
    '1000000',
  ],
  ['Circle 4', 'Government Science College, Jasdan', 'KCG', '14000'],
  [
    'Circle 4',
    'Government Arts & Commerce College, Jasdan, Rajkot',
    'KCG',
    '14000',
  ],
  ['Circle 4', 'Shri M P Shah Arts & Science, Surendranagar', 'KCG', '1000000'],
  ['Circle 4', 'Government Arts College, Chotila', 'KCG', '1000000'],
  [
    'Circle 4',
    'Government Arts, Commerce & Science College, Patdi',
    'KCG',
    '1000000',
  ],
  ['Circle 4', 'Government Arts & Commerce College, Muli', 'KCG', '400000'],
];

const circleFiveCollegeRows = <List<String>>[
  ['Circle 5', 'Dr. J.N. Mehta Govt. Polytechnic, Amreli', 'GTERS', '1000000'],
  ['Circle 5', 'KKPTI Amreli', 'GTERS', '1000000'],
  ['Circle 5', 'Government Engg. College, Bhavnagar', 'GTERS', '1000000'],
  ['Circle 5', 'Shantilal Shah Engg. College, Bhavnagar', 'GTERS', '1000000'],
  [
    'Circle 5',
    'Sir Bhavsinhji Polytechnic Institute, Bhavnagar',
    'GTERS',
    '1000000',
  ],
  ['Circle 5', 'GTHS Bhavnagar', 'GTERS', '350000'],
  ['Circle 5', 'VTC Bhavnagar', 'GTERS', '350000'],
  ['Circle 5', 'Govt. Polytechnic, Junagadh', 'GTERS', '1000000'],
  ['Circle 5', 'Govt. Polytechnic, Porbandar', 'GTERS', '1000000'],
  [
    'Circle 5',
    'Government Arts & Commerce College, Jafrabad',
    'KCG',
    '1000000',
  ],
  ['Circle 5', 'Government Arts & Commerce College, Liliya', 'KCG', '600000'],
  ['Circle 5', 'Government Arts & Commerce College, Babara', 'KCG', '600000'],
  ['Circle 5', 'Government Science College, Bagasara', 'KCG', '14000'],
  ['Circle 5', 'Government Arts & Commerce College, Khambaa', 'KCG', '20000'],
  [
    'Circle 5',
    'Government Arts, Commerce & Science College, Kukavavadiya',
    'KCG',
    '20000',
  ],
  ['Circle 5', 'Government Arts College, Talaja', 'KCG', '1000000'],
  ['Circle 5', 'Government Arts College, Vallabhipur', 'KCG', '14000'],
  ['Circle 5', 'Government Science College, Gariyadhar', 'KCG', '30000'],
  ['Circle 5', 'Government Arts & Commerce College, Ghogha', 'KCG', '30000'],
  ['Circle 5', 'Government Arts & Commerce College, Palitana', 'KCG', '156100'],
  [
    'Circle 5',
    'Bhaktraj Dada Khachar Government Arts & Commerce College, Gadhada',
    'KCG',
    '600000',
  ],
  ['Circle 5', 'Government Arts & Commerce College, Barvala', 'KCG', '600000'],
  ['Circle 5', 'Government Science College, Veraval', 'KCG', '59800'],
  ['Circle 5', 'Government Arts & Commerce College, Talala', 'KCG', '27300'],
  ['Circle 5', 'Bahauddin Arts College, Junagadh', 'KCG', '1000000'],
  ['Circle 5', 'Bahauddin Science College, Junagadh', 'KCG', '1000000'],
  ['Circle 5', 'Government Arts College, Bhesan', 'KCG', '1000000'],
  [
    'Circle 5',
    'Government Arts & Commerce College, Vanthali (Sorath)',
    'KCG',
    '15400',
  ],
  ['Circle 5', 'Government Arts College, Ranavaav', 'KCG', '1000000'],
];

const circleSixCollegeRows = <List<String>>[
  [
    'Circle 6',
    'Dr. S & S Gandhy College of Engg. & Tech., Surat',
    'GTERS',
    '1000000',
  ],
  [
    'Circle 6',
    'Dr. S & S Gandhy College of Engg. & Tech (Polytechnic), Surat',
    'GTERS',
    '1000000',
  ],
  ['Circle 6', 'Govt. Girls Polytechnic, Surat', 'GTERS', '1000000'],
  ['Circle 6', 'FSPTH Surat', 'GTERS', '700000'],
  ['Circle 6', 'Government Engg. College, Valsad', 'GTERS', '1000000'],
  ['Circle 6', 'Govt. Polytechnic, Valsad', 'GTERS', '1000000'],
  ['Circle 6', 'Govt. Polytechnic, Waghai', 'GTERS', '1000000'],
  ['Circle 6', 'WII Dharampur', 'GTERS', '350000'],
  ['Circle 6', 'GTHS Valsad', 'GTERS', '1000000'],
  ['Circle 6', 'Govt. Polytechnic, Vyara', 'GTERS', '1000000'],
  ['Circle 6', 'GTI Vyara', 'GTERS', '1000000'],
  ['Circle 6', 'Govt. Polytechnic, Navsari', 'GTERS', '1000000'],
  ['Circle 6', 'GTHS Navsari', 'GTERS', '1000000'],
  [
    'Circle 6',
    'Government Arts & Commerce College, Ahwa-Dang',
    'KCG',
    '381000',
  ],
  ['Circle 6', 'Government Science College, Ahwa-Dang', 'KCG', '1000000'],
  ['Circle 6', 'Government Arts & Commerce College, Vaghai', 'KCG', '20000'],
  ['Circle 6', 'Government Arts College, Subir, Dang', 'KCG', '20000'],
  ['Circle 6', 'Government Arts & Commerce College, Vansda', 'KCG', '1000000'],
  ['Circle 6', 'Government B.Ed. College, Vansda', 'KCG', '1000000'],
  [
    'Circle 6',
    'Government Arts, Commerce & Science College, Khergam',
    'KCG',
    '1000000',
  ],
  ['Circle 6', 'Government Science College, Chikhli', 'KCG', '600000'],
  [
    'Circle 6',
    'Government Arts, Commerce & Science College, Kachhal, Ta-Mahuva',
    'KCG',
    '1000000',
  ],
  ['Circle 6', 'Government B.Ed. College, Kachhal, Mahuva', 'KCG', '386000'],
  [
    'Circle 6',
    'Government Arts & Commerce College, Vankal, Mangrol',
    'KCG',
    '600000',
  ],
  ['Circle 6', 'Government Science College, Vankal, Mangrol', 'KCG', '1000000'],
  [
    'Circle 6',
    'Government Arts, Commerce & Science College, Umarpada',
    'KCG',
    '600000',
  ],
  [
    'Circle 6',
    'Government Arts, Commerce & Science College, Limbayat',
    'KCG',
    '14000',
  ],
  ['Circle 6', 'Government Science College, Varachha', 'KCG', '100800'],
  ['Circle 6', 'Government Arts & Commerce College, Songadh', 'KCG', '1000000'],
  ['Circle 6', 'Government Science College, Valod', 'KCG', '1000000'],
  ['Circle 6', 'Government Science College, Songadh', 'KCG', '1000000'],
  ['Circle 6', 'Government Arts & Commerce College, Nizar', 'KCG', '20000'],
  [
    'Circle 6',
    'Government Arts, Commerce & Science College, Dolvan, Tapi',
    'KCG',
    '160000',
  ],
  [
    'Circle 6',
    'Government Arts & Commerce College, Bhilad, Ta-Umargam',
    'KCG',
    '1000000',
  ],
  ['Circle 6', 'Government Arts College, Kaparada', 'KCG', '1000000'],
  ['Circle 6', 'Government Science College, Bhilad, Umargam', 'KCG', '237400'],
  ['Circle 6', 'Government Science College, Killa Pardi', 'KCG', '346600'],
];

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
      aadhaar: '1234 5678 9012',
      gst: '24ABCDE1234F1Z5',
      pan: 'ABCDE1234F',
      address: 'Surat, Gujarat',
      workType: 'Civil',
    ),
    AppUser(
      id: 'u5',
      name: 'Electrical Contractor',
      mobile: '5555555555',
      role: UserRole.contractor,
      aadhaar: '2234 5678 9012',
      gst: '24ELECE1234F1Z5',
      pan: 'ELECE1234F',
      address: 'Ahmedabad, Gujarat',
      workType: 'Electrical',
    ),
    AppUser(
      id: 'u6',
      name: 'Mrs. Sharma',
      mobile: '9810011100',
      role: UserRole.principal,
    ),
  ];

  final sites = seedCollegeSites();

  final categories = <WorkCategory>[
    WorkCategory(name: 'Civil'),
    WorkCategory(name: 'Electrical'),
    WorkCategory(name: 'Plumbing'),
    WorkCategory(name: 'Furniture'),
    WorkCategory(name: 'All'),
    WorkCategory(name: 'Other'),
  ];

  final sorItems = <SorItem>[
    const SorItem(
      itemNo: '1',
      description: 'Brick masonry repair work as per SOR',
      rate: 1250,
      uom: 'Sqm',
      type: 'Civil',
    ),
    const SorItem(
      itemNo: '2',
      description: 'Internal wall painting with approved material',
      rate: 180,
      uom: 'Sqm',
      type: 'Civil',
    ),
    const SorItem(
      itemNo: '3',
      description: 'Electrical point wiring and testing',
      rate: 950,
      uom: 'Point',
      type: 'Electrical',
    ),
    const SorItem(
      itemNo: '4',
      description: 'Plumbing line repair with fittings',
      rate: 750,
      uom: 'Rmt',
      type: 'Plumbing',
    ),
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
  final contractorApplications = <ContractorApplication>[];
  final vendorUpdateRequests = <VendorUpdateRequest>[];
  final workOrders = <WorkOrder>[
    WorkOrder(
      id: 'WO-001',
      siteId: 's1',
      contractorId: 'u4',
      workType: 'Civil',
      estimatedValue: '450000',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: WorkOrderStatus.accepted,
    ),
  ];
  final complaints = <Complaint>[];
  final bills = <ContractorBill>[];
  final labourByContractor = <String, List<LabourMember>>{
    'u4': [
      LabourMember(
        name: 'Ramesh Patel',
        aadhaar: '1111 2222 3333',
        pan: 'RAMPP1234F',
        field: 'Mason',
      ),
    ],
  };
  AppUser? currentUser;

  List<AppUser> get supervisors =>
      users.where((user) => user.role == UserRole.supervisor).toList();

  List<AppUser> get contractors =>
      users.where((user) => user.role == UserRole.contractor).toList();

  List<AppUser> get principals =>
      users.where((user) => user.role == UserRole.principal).toList();

  List<Site> visibleSitesFor(AppUser user) {
    if (user.role == UserRole.admin) return sites;
    if (user.role == UserRole.supervisor) {
      return sites
          .where((site) => site.supervisorIds.contains(user.id))
          .toList();
    }
    if (user.role == UserRole.principal) {
      return sites.where((site) => site.principalUserId == user.id).toList();
    }
    return sites.where((site) => site.contractorId == user.id).toList();
  }

  List<WorkItem> visibleWorkFor(AppUser user) {
    if (user.role == UserRole.admin) return workItems;
    if (user.role == UserRole.supervisor) {
      final siteIds = visibleSitesFor(user).map((site) => site.id).toSet();
      return workItems.where((item) => siteIds.contains(item.siteId)).toList();
    }
    if (user.role == UserRole.principal) {
      final siteIds = visibleSitesFor(user).map((site) => site.id).toSet();
      return workItems.where((item) => siteIds.contains(item.siteId)).toList();
    }
    final siteIds = visibleSitesFor(user).map((site) => site.id).toSet();
    return workItems.where((item) => siteIds.contains(item.siteId)).toList();
  }

  Site siteById(String id) => sites.firstWhere((site) => site.id == id);

  String userName(String? id) {
    if (id == null) return 'Unassigned';
    return users
        .firstWhere(
          (user) => user.id == id,
          orElse: () => AppUser(
            id: '',
            name: 'Unknown',
            mobile: '',
            role: UserRole.contractor,
          ),
        )
        .name;
  }

  List<WorkItem> workForSite(String siteId) =>
      workItems.where((item) => item.siteId == siteId).toList();

  List<WorkOrder> workOrdersForSite(String siteId) =>
      workOrders.where((order) => order.siteId == siteId).toList();

  List<WorkOrder> workOrdersForContractor(String contractorId) =>
      workOrders.where((order) => order.contractorId == contractorId).toList();

  List<Complaint> complaintsForSite(String siteId) =>
      complaints.where((complaint) => complaint.siteId == siteId).toList();

  SorItem? sorByItemNo(String itemNo) {
    final matches = sorItems.where((item) => item.itemNo == itemNo.trim());
    return matches.isEmpty ? null : matches.first;
  }

  Future<void> loadSorRatesFromAsset() async {
    try {
      final html = await rootBundle.loadString(
        'assets/gters_rate_estimator.html',
      );
      final match = RegExp(
        r'const ITEMS\s*=\s*(\[[\s\S]*?\]);',
      ).firstMatch(html);
      if (match == null) return;
      final rawItems = jsonDecode(match.group(1)!) as List<dynamic>;
      sorItems
        ..clear()
        ..addAll(
          rawItems.map((rawItem) {
            final item = rawItem as Map<String, dynamic>;
            final schedule = (item['s'] ?? '').toString();
            return SorItem(
              itemNo: (item['n'] ?? '').toString(),
              description: (item['d'] ?? '').toString(),
              rate: ((item['r'] ?? 0) as num).toDouble(),
              uom: (item['u'] ?? '').toString(),
              type: schedule == 'E' ? 'Electrical' : 'Civil',
            );
          }),
        );
      notifyListeners();
    } catch (_) {
      // Keep the small built-in list available if the HTML asset cannot load.
    }
  }

  List<SorItem> searchSorItems(String query, {String? type, int limit = 35}) {
    final trimmed = query.trim().toLowerCase();
    final terms = trimmed.split(RegExp(r'\s+'));
    final matches = sorItems.where((item) {
      if (type != null && type != 'All' && type != 'Other') {
        if (item.type.toLowerCase() != type.toLowerCase()) return false;
      }
      if (trimmed.isEmpty) return true;
      final haystack = '${item.itemNo} ${item.description}'.toLowerCase();
      return terms.every(haystack.contains);
    });
    return matches.take(limit).toList();
  }

  List<ContractorBill> billsForSite(String siteId) =>
      bills.where((bill) => bill.siteId == siteId).toList();

  List<ContractorBill> billsForContractor(String contractorId) =>
      bills.where((bill) => bill.contractorId == contractorId).toList();

  double estimatedAmountForSite(String siteId) {
    final workEstimate = workForSite(
      siteId,
    ).fold<double>(0, (sum, item) => sum + item.totalRate);
    if (workEstimate > 0) return workEstimate;
    final site = siteById(siteId);
    final grantAmount = parseMoney(site.grantAmount);
    if (grantAmount > 0) return grantAmount;
    final orders = workOrdersForSite(siteId);
    if (orders.isEmpty) return 0;
    return parseMoney(orders.first.estimatedValue);
  }

  double usedEstimateForSite(String siteId) {
    return workForSite(
      siteId,
    ).fold<double>(0, (sum, item) => sum + item.totalRate);
  }

  double budgetCapForSite(String siteId) =>
      parseMoney(siteById(siteId).grantAmount);

  double remainingBudgetForSite(String siteId) {
    return budgetCapForSite(siteId) - usedEstimateForSite(siteId);
  }

  String estimatedValueForSite(String siteId) {
    final amount = estimatedAmountForSite(siteId);
    if (amount <= 0) return 'Not estimated';
    return inr(amount);
  }

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

  void addContractorApplication(ContractorApplication application) {
    contractorApplications.add(application);
    notifyListeners();
  }

  void approveContractorApplication(ContractorApplication application) {
    users.add(
      AppUser(
        id: 'u${users.length + 1}',
        name: application.name,
        mobile: application.mobile,
        role: UserRole.contractor,
        aadhaar: application.aadhaar,
        gst: application.gst,
        pan: application.pan,
        address: application.address,
        workType: application.workType,
        photo: application.photo,
      ),
    );
    contractorApplications.remove(application);
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

  int importSchoolsCsv(String csvText) {
    var added = 0;
    final lines = csvText
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    for (var i = 0; i < lines.length; i++) {
      final cols = parseCsvLine(lines[i]);
      if (cols.isEmpty) continue;
      if (i == 0 && cols.first.toLowerCase().contains('school')) continue;
      if (cols.length < 5) continue;
      sites.add(
        Site(
          id: 's${sites.length + 1}',
          name: cols[0],
          circle: cols[1],
          grantAmount: cols[2],
          primaryPhone: cols[3],
          mapsLink: cols[4],
          address: cols[4],
          principal: cols.length > 5 ? cols[5] : '',
          paymentAuthority: cols.length > 6 ? cols[6] : '',
        ),
      );
      added++;
    }
    notifyListeners();
    return added;
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

  void createWorkOrder(
    Site site,
    String contractorId,
    String workType,
    String estimatedValue,
  ) {
    final order = WorkOrder(
      id: 'WO-${(workOrders.length + 1).toString().padLeft(3, '0')}',
      siteId: site.id,
      contractorId: contractorId,
      workType: workType,
      estimatedValue: estimatedValue,
      date: DateTime.now(),
    );
    workOrders.insert(0, order);
    assignSiteContractor(site, contractorId);
    notifyListeners();
  }

  void acceptWorkOrder(WorkOrder order) {
    order.status = WorkOrderStatus.accepted;
    notifyListeners();
  }

  void addComplaint(Site site, String title, String description) {
    complaints.insert(
      0,
      Complaint(
        id: 'C-${complaints.length + 1}',
        siteId: site.id,
        title: title,
        description: description,
        createdBy: currentUser?.name ?? 'User',
        createdAt: DateTime.now(),
      ),
    );
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
    final role = currentUser?.role;
    if (approved && role == UserRole.principal) {
      item.status = WorkStatus.principalApproved;
    } else {
      item.status = approved ? WorkStatus.verified : WorkStatus.rejected;
    }
    item.verificationRemark = remark;
    item.history.add(
      WorkHistory(
        label: approved
            ? role == UserRole.principal
                  ? 'Approved by principal'
                  : 'Marked completed by admin'
            : 'Rejected for rework',
        at: DateTime.now(),
        by: currentUser?.name ?? 'User',
      ),
    );
    notifyListeners();
  }

  void addBill(
    Site site,
    String contractorId,
    String title,
    String amount,
    String note,
  ) {
    bills.insert(
      0,
      ContractorBill(
        id: 'B-${bills.length + 1}',
        siteId: site.id,
        contractorId: contractorId,
        title: title,
        amount: amount,
        note: note,
        submittedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void markBillPaid(ContractorBill bill, bool paid) {
    bill.paid = paid;
    notifyListeners();
  }

  void updateUser(AppUser user, String name, String mobile) {
    user.name = name;
    user.mobile = mobile;
    notifyListeners();
  }

  void requestVendorProfileUpdate(AppUser contractor, AppUser draft) {
    vendorUpdateRequests.add(
      VendorUpdateRequest(
        contractorId: contractor.id,
        title: 'Vendor profile update',
        details:
            '${draft.name}, ${draft.mobile}, Aadhaar: ${draft.aadhaar}, GST: ${draft.gst}, PAN: ${draft.pan}, Work: ${draft.workType}',
        apply: () {
          contractor.name = draft.name;
          contractor.mobile = draft.mobile;
          contractor.aadhaar = draft.aadhaar;
          contractor.gst = draft.gst;
          contractor.pan = draft.pan;
          contractor.address = draft.address;
          contractor.workType = draft.workType;
          contractor.photo = draft.photo ?? contractor.photo;
        },
      ),
    );
    notifyListeners();
  }

  void requestLabourAdd(String contractorId, LabourMember labour) {
    vendorUpdateRequests.add(
      VendorUpdateRequest(
        contractorId: contractorId,
        title: 'Labour team update',
        details:
            '${labour.name}, Aadhaar: ${labour.aadhaar}, PAN: ${labour.pan}, Field: ${labour.field}',
        apply: () =>
            labourByContractor.putIfAbsent(contractorId, () => []).add(labour),
      ),
    );
    notifyListeners();
  }

  void approveVendorUpdate(VendorUpdateRequest request) {
    request.apply?.call();
    vendorUpdateRequests.remove(request);
    notifyListeners();
  }

  void rejectVendorUpdate(VendorUpdateRequest request) {
    vendorUpdateRequests.remove(request);
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

  void saveUserProfile({
    AppUser? user,
    required String name,
    required String mobile,
    required UserRole role,
    String aadhaar = '',
    String gst = '',
    String pan = '',
    String address = '',
    String workType = '',
    Uint8List? photo,
  }) {
    if (user == null) {
      users.add(
        AppUser(
          id: 'u${users.length + 1}',
          name: name,
          mobile: mobile,
          role: role,
          aadhaar: aadhaar,
          gst: gst,
          pan: pan,
          address: address,
          workType: workType,
          photo: photo,
        ),
      );
    } else {
      user.name = name;
      user.mobile = mobile;
      user.aadhaar = aadhaar;
      user.gst = gst;
      user.pan = pan;
      user.address = address;
      user.workType = workType;
      user.photo = photo ?? user.photo;
    }
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

const arihaLogoAsset = 'assets/ariha_infra_logo.png';
const arihaLogoBlue = Color(0xFF5572AD);
const arihaNavy = Color(0xFF0D2A57);
const arihaDeepNavy = Color(0xFF071A35);
const arihaSky = Color(0xFFEAF1FF);
const arihaIce = Color(0xFFF6F9FF);

class SchoolSiteTrackerApp extends StatefulWidget {
  const SchoolSiteTrackerApp({super.key});

  @override
  State<SchoolSiteTrackerApp> createState() => _SchoolSiteTrackerAppState();
}

class _SchoolSiteTrackerAppState extends State<SchoolSiteTrackerApp> {
  @override
  void initState() {
    super.initState();
    store.loadSorRatesFromAsset();
  }

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
              seedColor: arihaLogoBlue,
              primary: arihaNavy,
              secondary: arihaLogoBlue,
              surface: Colors.white,
              onPrimary: Colors.white,
            ),
            scaffoldBackgroundColor: arihaIce,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: arihaDeepNavy,
              elevation: 0,
              centerTitle: false,
              surfaceTintColor: Colors.white,
            ),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: arihaSky,
              labelTextStyle: WidgetStateProperty.resolveWith(
                (states) => TextStyle(
                  color: states.contains(WidgetState.selected)
                      ? arihaNavy
                      : const Color(0xFF5F6F89),
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
              iconTheme: WidgetStateProperty.resolveWith(
                (states) => IconThemeData(
                  color: states.contains(WidgetState.selected)
                      ? arihaNavy
                      : const Color(0xFF64748B),
                ),
              ),
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                backgroundColor: arihaNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                foregroundColor: arihaNavy,
                side: const BorderSide(color: arihaLogoBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: arihaLogoBlue, width: 1.4),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD7E1F4)),
              ),
            ),
            cardTheme: const CardThemeData(
              elevation: 0,
              margin: EdgeInsets.symmetric(vertical: 6),
              color: Colors.white,
              surfaceTintColor: Colors.white,
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
  final aadhaar = TextEditingController();
  final gst = TextEditingController();
  final pan = TextEditingController();
  final address = TextEditingController();
  final otherWorkType = TextEditingController();
  String applicationWorkType = 'Civil';
  Uint8List? applicationPhoto;

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
                  Image.asset(arihaLogoAsset, height: 108, fit: BoxFit.contain),
                  const SizedBox(height: 10),
                  Text(
                    'Ariha Infra Site Tracker',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: arihaDeepNavy,
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
                      ButtonSegment(value: 3, label: Text('Contractor')),
                    ],
                    selected: {tab},
                    onSelectionChanged: (value) =>
                        setState(() => tab = value.first),
                  ),
                  const SizedBox(height: 16),
                  if (tab == 0) _loginCard(context),
                  if (tab == 1) _registerCard(context),
                  if (tab == 2) _forgotCard(context),
                  if (tab == 3) _contractorApplicationCard(context),
                  const SizedBox(height: 16),
                  const Text(
                    'Demo logins: Admin 9999999999, Supervisor 8888888888, Contractor 6666666666, Principal 9810011100. Any password works.',
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

  Widget _contractorApplicationCard(BuildContext context) {
    final activeTypes = store.categories
        .where((category) => category.active)
        .map((category) => category.name)
        .toList();
    if (!activeTypes.contains(applicationWorkType)) {
      applicationWorkType = activeTypes.isEmpty ? 'Other' : activeTypes.first;
    }
    return AppCard(
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Apply as Contractor / Vendor',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          AppTextField(controller: name, label: 'Vendor name'),
          AppTextField(controller: mobile, label: 'Mobile number'),
          AppTextField(controller: aadhaar, label: 'Aadhaar number'),
          AppTextField(controller: gst, label: 'GST number'),
          AppTextField(controller: pan, label: 'PAN number'),
          AppTextField(controller: address, label: 'Address', maxLines: 2),
          DropdownButtonFormField<String>(
            initialValue: applicationWorkType,
            decoration: const InputDecoration(
              labelText: 'Type of work',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final type in activeTypes)
                DropdownMenuItem(value: type, child: Text(type)),
            ],
            onChanged: (value) => setState(() => applicationWorkType = value!),
          ),
          if (applicationWorkType == 'Other') ...[
            const SizedBox(height: 10),
            AppTextField(controller: otherWorkType, label: 'Other work type'),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              PhotoBox(bytes: applicationPhoto, label: 'Photo'),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: const Text('Upload vendor photo'),
                  onPressed: () async {
                    applicationPhoto = await pickPhoto(ImageSource.gallery);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Submit contractor application'),
            onPressed: () {
              final type = applicationWorkType == 'Other'
                  ? otherWorkType.text.trim()
                  : applicationWorkType;
              store.addContractorApplication(
                ContractorApplication(
                  name: name.text,
                  mobile: mobile.text,
                  aadhaar: aadhaar.text,
                  gst: gst.text,
                  pan: pan.text,
                  address: address.text,
                  workType: type,
                  photo: applicationPhoto,
                ),
              );
              showMessage(context, 'Application sent to admin for approval.');
              setState(() => tab = 0);
            },
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
        ProfilesScreen(),
        SettingsScreen(),
      ],
      UserRole.supervisor => const [
        SupervisorDashboard(),
        SitesScreen(),
        WorkListScreen(),
        SettingsScreen(),
      ],
      UserRole.contractor => const [ContractorDashboard(), WorkListScreen()],
      UserRole.principal => const [
        PrincipalDashboard(),
        SitesScreen(),
        WorkListScreen(),
      ],
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
      UserRole.principal => const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.school), label: 'College'),
        NavigationDestination(icon: Icon(Icons.task_alt), label: 'Work'),
      ],
    };

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: Image.asset(arihaLogoAsset, fit: BoxFit.contain),
        ),
        title: Text(
          '${user.name} - ${roleLabel(user.role)}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
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
        const SectionTitle('Start here'),
        WorkflowGrid(
          children: [
            WorkflowCard(
              icon: Icons.task_alt,
              title: 'Track work',
              subtitle: 'Choose circle, open college, review work progress.',
              actionLabel: 'Go to Work tab',
              onTap: () => showMessage(context, 'Use the Work tab below.'),
            ),
            WorkflowCard(
              icon: Icons.upload_file,
              title: 'Add colleges',
              subtitle: 'Download template or paste Excel/CSV rows.',
              actionLabel: 'Open uploader',
              onTap: () => showBulkSchoolImportDialog(context),
            ),
            WorkflowCard(
              icon: Icons.verified_user,
              title: 'Approve vendors',
              subtitle:
                  '${store.contractorApplications.length + store.vendorUpdateRequests.length} approval items waiting.',
              actionLabel: 'Review below',
              onTap: () => showMessage(context, 'Approval queues are below.'),
            ),
            WorkflowCard(
              icon: Icons.receipt_long,
              title: 'Bills',
              subtitle: '${store.bills.length} submitted contractor bills.',
              actionLabel: 'Review below',
              onTap: () => showMessage(context, 'Bill approvals are below.'),
            ),
          ],
        ),
        SectionTitle('Bill approvals'),
        if (store.bills.isEmpty)
          const AppCard(child: Text('No contractor bills submitted yet.')),
        for (final bill in store.bills) BillCard(bill: bill),
        SectionTitle('Contractor applications'),
        if (store.contractorApplications.isEmpty)
          const AppCard(child: Text('No pending contractor applications.')),
        for (final application in store.contractorApplications)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: PhotoBox(bytes: application.photo, label: 'Photo'),
                  title: Text(application.name),
                  subtitle: Text(
                    '${application.mobile} • ${application.workType}\n'
                    'Aadhaar: ${application.aadhaar} • GST: ${application.gst} • PAN: ${application.pan}',
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.verified_user),
                    label: const Text('Approve as contractor'),
                    onPressed: () =>
                        store.approveContractorApplication(application),
                  ),
                ),
              ],
            ),
          ),
        SectionTitle('Vendor profile approvals'),
        if (store.vendorUpdateRequests.isEmpty)
          const AppCard(child: Text('No pending vendor update requests.')),
        for (final request in store.vendorUpdateRequests)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text('Vendor: ${store.userName(request.contractorId)}'),
                Text(request.details),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => store.approveVendorUpdate(request),
                      child: const Text('Approve'),
                    ),
                    OutlinedButton(
                      onPressed: () => store.rejectVendorUpdate(request),
                      child: const Text('Reject'),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                icon: const Icon(Icons.table_view),
                label: const Text('Download Excel CSV'),
                onPressed: () => downloadCollegeExcel(context),
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
        const SectionTitle('Start here'),
        WorkflowGrid(
          children: [
            WorkflowCard(
              icon: Icons.add_a_photo,
              title: 'Capture site work',
              subtitle: 'Open an assigned college and add photo-based work.',
              actionLabel: 'Use Sites tab',
              onTap: () => showMessage(context, 'Open the Sites tab below.'),
            ),
            WorkflowCard(
              icon: Icons.description,
              title: 'Create work order',
              subtitle: 'Send vendor work order after estimate approval.',
              actionLabel: 'Open site',
              onTap: () => showMessage(context, 'Open a site card below.'),
            ),
            WorkflowCard(
              icon: Icons.report_problem,
              title: 'Register complaint',
              subtitle: 'Create complaint for a college/site issue.',
              actionLabel: 'Open site',
              onTap: () =>
                  showMessage(context, 'Use Complaint on a site card.'),
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
    final contractor = store.currentUser!;
    final work = store.visibleWorkFor(contractor);
    final orders = store.workOrdersForContractor(contractor.id);
    final labours = store.labourByContractor[contractor.id] ?? [];
    final bills = store.billsForContractor(contractor.id);
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
        const SectionTitle('Start here'),
        WorkflowGrid(
          children: [
            WorkflowCard(
              icon: Icons.description,
              title: 'Accept work order',
              subtitle:
                  '${orders.where((order) => order.status == WorkOrderStatus.sent).length} new orders waiting.',
              actionLabel: 'Review orders',
              onTap: () => showMessage(context, 'Work orders are below.'),
            ),
            WorkflowCard(
              icon: Icons.upload,
              title: 'Update progress',
              subtitle: 'Mark work started, ongoing, or completed.',
              actionLabel: 'Use Work tab',
              onTap: () => showMessage(context, 'Open the Work tab below.'),
            ),
            WorkflowCard(
              icon: Icons.receipt_long,
              title: 'Submit bill',
              subtitle: 'Add invoice/bill against a college work.',
              actionLabel: 'Open work site',
              onTap: () => showMessage(context, 'Open a site from Work tab.'),
            ),
          ],
        ),
        const SectionTitle('Vendor profile'),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: PhotoBox(bytes: contractor.photo, label: 'Photo'),
                title: Text(contractor.name),
                subtitle: Text(
                  '${contractor.mobile} • ${contractor.workType}\n'
                  'Aadhaar: ${contractor.aadhaar} • GST: ${contractor.gst} • PAN: ${contractor.pan}',
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit own details'),
                    onPressed: () =>
                        showVendorSelfEditDialog(context, contractor),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.group_add),
                    label: const Text('Add labour'),
                    onPressed: () => showLabourDialog(context, contractor),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SectionTitle('Team details'),
        if (labours.isEmpty)
          const AppCard(child: Text('No approved labour details yet.')),
        for (final labour in labours)
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(labour.name),
              subtitle: Text(
                '${labour.field} • Aadhaar: ${labour.aadhaar} • PAN: ${labour.pan}',
              ),
            ),
          ),
        const SectionTitle('Work orders'),
        if (orders.isEmpty)
          const AppCard(child: Text('No work orders sent yet.')),
        for (final order in orders) WorkOrderCard(order: order),
        const SectionTitle('Bills'),
        if (bills.isEmpty)
          const AppCard(child: Text('No bills submitted yet.')),
        for (final bill in bills) BillCard(bill: bill),
        const SectionTitle('My assigned work'),
        for (final item in work) WorkItemCard(item: item),
      ],
    );
  }
}

class PrincipalDashboard extends StatelessWidget {
  const PrincipalDashboard({super.key});

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
              label: 'My colleges',
              value: '${sites.length}',
              icon: Icons.school,
            ),
            MetricCard(
              label: 'Work orders',
              value:
                  '${sites.expand((site) => store.workOrdersForSite(site.id)).length}',
              icon: Icons.description,
            ),
            MetricCard(
              label: 'Complaints',
              value:
                  '${sites.expand((site) => store.complaintsForSite(site.id)).length}',
              icon: Icons.report_problem,
            ),
          ],
        ),
        const SectionTitle('Start here'),
        WorkflowGrid(
          children: [
            WorkflowCard(
              icon: Icons.verified_user,
              title: 'Approve completed work',
              subtitle: 'Check contractor completion before admin closure.',
              actionLabel: 'Use Work tab',
              onTap: () => showMessage(context, 'Open Work tab below.'),
            ),
            WorkflowCard(
              icon: Icons.report_problem,
              title: 'Register complaint',
              subtitle: 'Raise college maintenance issue quickly.',
              actionLabel: 'Open college',
              onTap: () =>
                  showMessage(context, 'Use Complaint on a college card.'),
            ),
            WorkflowCard(
              icon: Icons.engineering,
              title: 'Vendor entry update',
              subtitle: 'View accepted work orders and vendor details.',
              actionLabel: 'Open work',
              onTap: () => showMessage(context, 'Open Work tab below.'),
            ),
          ],
        ),
        const SectionTitle('College updates'),
        for (final site in sites) SiteCard(site: site),
      ],
    );
  }
}

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  String type = 'Schools';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: type,
          decoration: const InputDecoration(
            labelText: 'Select profile type',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Schools',
              child: Text('School including principals'),
            ),
            DropdownMenuItem(value: 'Contractors', child: Text('Contractors')),
            DropdownMenuItem(
              value: 'Supervisors',
              child: Text('Site supervisors'),
            ),
          ],
          onChanged: (value) => setState(() => type = value!),
        ),
        const SizedBox(height: 12),
        if (type == 'Schools') const SitesScreen(embed: true),
        if (type == 'Contractors')
          const ProfileSection(
            title: 'Profiles of contractors',
            role: UserRole.contractor,
          ),
        if (type == 'Supervisors')
          const ProfileSection(
            title: 'Profiles of site supervisors',
            role: UserRole.supervisor,
          ),
      ],
    );
  }
}

class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key, this.embed = false});

  final bool embed;

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = store.currentUser!;
    var sites = store.visibleSitesFor(user);
    if (search.text.trim().isNotEmpty) {
      final term = search.text.trim().toLowerCase();
      sites = sites.where((site) {
        final estimate = store.estimatedValueForSite(site.id);
        final haystack =
            '${site.name} ${site.principal} ${site.address} ${site.mapsLink} '
                    '${site.primaryPhone} ${site.secondaryPhone} ${site.circle} '
                    '${site.paymentAuthority} ${site.grantAmount} $estimate'
                .toLowerCase();
        return haystack.contains(term);
      }).toList();
    }
    final content = <Widget>[
      AppTextField(
        controller: search,
        label: 'Search school, location, contact, estimate',
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: 8),
      if (user.role == UserRole.admin)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.add_business),
              label: const Text('Add school'),
              onPressed: () => showSiteDialog(context),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload Excel/CSV'),
              onPressed: () => showBulkSchoolImportDialog(context),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download template'),
              onPressed: downloadSchoolTemplate,
            ),
          ],
        ),
      const SizedBox(height: 8),
      if (sites.isEmpty)
        const AppCard(child: Text('No school profiles found.')),
      for (final site in sites) SiteCard(site: site),
    ];
    if (widget.embed) {
      return Column(children: content);
    }
    return ListView(padding: const EdgeInsets.all(16), children: [...content]);
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
          Text(
            'Authority: ${site.paymentAuthority.isEmpty ? 'Not added' : site.paymentAuthority}',
          ),
          const SizedBox(height: 10),
          BudgetStrip(site: site),
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
              if (user.role == UserRole.admin ||
                  user.role == UserRole.supervisor ||
                  user.role == UserRole.principal)
                FilledButton.icon(
                  icon: const Icon(Icons.calculate),
                  label: const Text('Add work estimate'),
                  onPressed: () => showWorkDialog(context, site),
                ),
              if (user.role == UserRole.supervisor)
                FilledButton.icon(
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Start site visit'),
                  onPressed: () => showWorkDialog(context, site),
                ),
              if (user.role == UserRole.supervisor ||
                  user.role == UserRole.principal)
                OutlinedButton.icon(
                  icon: const Icon(Icons.report_problem),
                  label: const Text('Complaint'),
                  onPressed: () => showComplaintDialog(context, site),
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
              if (user.role == UserRole.admin ||
                  user.role == UserRole.supervisor ||
                  user.role == UserRole.principal)
                FilledButton.icon(
                  icon: const Icon(Icons.description),
                  label: const Text('Work order'),
                  onPressed: () => showWorkOrderDialog(context, site),
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

class BudgetStrip extends StatelessWidget {
  const BudgetStrip({super.key, required this.site});

  final Site site;

  @override
  Widget build(BuildContext context) {
    final cap = store.budgetCapForSite(site.id);
    final used = store.usedEstimateForSite(site.id);
    final remaining = store.remainingBudgetForSite(site.id);
    final progress = cap <= 0 ? 0.0 : (used / cap).clamp(0.0, 1.0);
    final overBudget = remaining < 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: arihaSky,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD7E1F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              Text('Budget cap: ${cap > 0 ? inr(cap) : 'Not added'}'),
              Text('Work estimate: ${inr(used)}'),
              Text(
                '${overBudget ? 'Over budget' : 'Remaining'}: ${inr(remaining.abs())}',
                style: TextStyle(
                  color: overBudget ? const Color(0xFFB42318) : arihaNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: overBudget ? const Color(0xFFB42318) : arihaNavy,
              backgroundColor: Colors.white,
            ),
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
  String? selectedCircle;
  String progressFilter = 'All';
  String assignedDateFilter = 'All';
  String supervisorFilter = 'All';
  String contractorFilter = 'All';

  @override
  Widget build(BuildContext context) {
    var sites = store.visibleSitesFor(store.currentUser!);
    final circles = allCircles();
    final visibleCircles = sites.map((site) => site.circle).toSet();
    selectedCircle ??= circles.firstWhere(
      visibleCircles.contains,
      orElse: () => circles.first,
    );
    sites = sites.where((site) => site.circle == selectedCircle).toList();
    final term = search.text.trim().toLowerCase();
    if (term.isNotEmpty) {
      sites = sites.where((site) {
        final estimate = store.estimatedValueForSite(site.id);
        final haystack =
            '${site.name} ${site.principal} ${site.address} ${site.mapsLink} '
                    '${site.primaryPhone} ${site.secondaryPhone} ${site.circle} '
                    '${site.paymentAuthority} ${site.grantAmount} ${store.userName(site.contractorId)} $estimate'
                .toLowerCase();
        return haystack.contains(term);
      }).toList();
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
        const SectionTitle('Select circle'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final circle in circles)
              ChoiceChip(
                label: Text(circle),
                selected: selectedCircle == circle,
                onSelected: (_) => setState(() => selectedCircle = circle),
              ),
          ],
        ),
        const SizedBox(height: 14),
        AppTextField(
          controller: search,
          label: 'Search name, location, contact, estimate in $selectedCircle',
          onChanged: (_) => setState(() {}),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add work'),
            onPressed: () => showAddWorkFromWorkPageDialog(context),
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tune, color: arihaNavy),
            title: const Text(
              'More filters',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Progress: $progressFilter • Date: $assignedDateFilter',
            ),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth < 430
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 10) / 2;
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: itemWidth,
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
                              value: 'Pending principal approval',
                              child: Text('Pending principal approval'),
                            ),
                            DropdownMenuItem(
                              value: 'Pending admin completion',
                              child: Text('Pending admin completion'),
                            ),
                            DropdownMenuItem(
                              value: 'Verified',
                              child: Text('Verified'),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => progressFilter = value!),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
                        child: DropdownButtonFormField<String>(
                          initialValue: assignedDateFilter,
                          decoration: const InputDecoration(
                            labelText: 'Date assigned',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All dates'),
                            ),
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
                        width: itemWidth,
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
                              DropdownMenuItem(
                                value: user.id,
                                child: Text(user.name),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => supervisorFilter = value!),
                        ),
                      ),
                      SizedBox(
                        width: itemWidth,
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
                              DropdownMenuItem(
                                value: user.id,
                                child: Text(user.name),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => contractorFilter = value!),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        SectionTitle('Colleges / schools in $selectedCircle'),
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
              'Authority: ${site.paymentAuthority.isEmpty ? 'Not added' : site.paymentAuthority} • Budget: ${store.estimatedValueForSite(site.id)}\n'
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
              if (store.currentUser!.role == UserRole.admin ||
                  store.currentUser!.role == UserRole.supervisor ||
                  store.currentUser!.role == UserRole.principal)
                OutlinedButton.icon(
                  icon: const Icon(Icons.note_add),
                  label: const Text('New work order'),
                  onPressed: () => showWorkOrderDialog(context, site),
                ),
              if (store.currentUser!.role == UserRole.contractor)
                OutlinedButton.icon(
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Add bill'),
                  onPressed: () => showBillDialog(context, site),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkOrderCard extends StatelessWidget {
  const WorkOrderCard({super.key, required this.order});

  final WorkOrder order;

  @override
  Widget build(BuildContext context) {
    final site = store.siteById(order.siteId);
    final canAccept =
        store.currentUser?.role == UserRole.contractor &&
        order.status == WorkOrderStatus.sent;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${order.id} • ${site.name}'),
            subtitle: Text(
              '${order.workType} • ₹${order.estimatedValue} • ${formatDateTime(order.date)}\n'
              'Vendor: ${store.userName(order.contractorId)} • ${workOrderStatusLabel(order.status)}',
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.article),
                label: const Text('View format'),
                onPressed: () => showWorkOrderPreview(context, order),
              ),
              if (canAccept)
                FilledButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Accept work order'),
                  onPressed: () => store.acceptWorkOrder(order),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class BillCard extends StatelessWidget {
  const BillCard({super.key, required this.bill});

  final ContractorBill bill;

  @override
  Widget build(BuildContext context) {
    final isAdmin = store.currentUser?.role == UserRole.admin;
    final status = bill.paid == null
        ? 'Payment not marked'
        : bill.paid!
        ? 'Paid'
        : 'Not paid';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('${bill.title} • ₹${bill.amount}'),
            subtitle: Text(
              'Vendor: ${store.userName(bill.contractorId)}\n'
              '${bill.note}\nSubmitted: ${formatDateTime(bill.submittedAt)} • $status',
            ),
          ),
          if (isAdmin)
            Wrap(
              spacing: 8,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Paid'),
                  onPressed: () => store.markBillPaid(bill, true),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Not paid'),
                  onPressed: () => store.markBillPaid(bill, false),
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
    final orders = store.workOrdersForSite(site.id);
    final complaints = store.complaintsForSite(site.id);
    return Scaffold(
      appBar: AppBar(title: Text(site.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SiteWorkCard(site: site, showOpenButton: false),
          const SectionTitle('Next action'),
          WorkflowGrid(
            children: [
              if (user.role == UserRole.supervisor)
                WorkflowCard(
                  icon: Icons.add_a_photo,
                  title: 'Add work item',
                  subtitle: 'Capture photo, SOR item, quantity, and rate.',
                  actionLabel: 'Add work',
                  onTap: () => showWorkDialog(context, site),
                ),
              if (user.role == UserRole.admin ||
                  user.role == UserRole.supervisor ||
                  user.role == UserRole.principal)
                WorkflowCard(
                  icon: Icons.description,
                  title: 'Create work order',
                  subtitle: 'Select vendor and send work order.',
                  actionLabel: 'Create order',
                  onTap: () => showWorkOrderDialog(context, site),
                ),
              if (user.role == UserRole.contractor)
                WorkflowCard(
                  icon: Icons.receipt_long,
                  title: 'Submit bill',
                  subtitle: 'Add invoice details for this college.',
                  actionLabel: 'Add bill',
                  onTap: () => showBillDialog(context, site),
                ),
              if (user.role == UserRole.principal ||
                  user.role == UserRole.supervisor)
                WorkflowCard(
                  icon: Icons.report_problem,
                  title: 'Register complaint',
                  subtitle: 'Raise a college maintenance issue.',
                  actionLabel: 'New complaint',
                  onTap: () => showComplaintDialog(context, site),
                ),
            ],
          ),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.currency_rupee, color: arihaNavy),
              title: const Text('Estimated value'),
              subtitle: Text(store.estimatedValueForSite(site.id)),
            ),
          ),
          const SectionTitle('Work orders'),
          if (orders.isEmpty)
            const AppCard(child: Text('No work orders created yet.')),
          for (final order in orders) WorkOrderCard(order: order),
          const SectionTitle('Complaints'),
          if (complaints.isEmpty)
            const AppCard(child: Text('No complaints registered yet.')),
          for (final complaint in complaints)
            AppCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(complaint.title),
                subtitle: Text(
                  '${complaint.description}\n${complaint.createdBy} • ${formatDateTime(complaint.createdAt)}',
                ),
              ),
            ),
          const SectionTitle('Bills'),
          if (store.billsForSite(site.id).isEmpty)
            const AppCard(child: Text('No bills submitted yet.')),
          for (final bill in store.billsForSite(site.id)) BillCard(bill: bill),
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
    final isNarrow = MediaQuery.sizeOf(context).width < 430;
    final photo = PhotoBox(
      bytes: item.beforePhoto,
      label: 'Before photo',
      onTap: () => showLargePhoto(context, item.beforePhoto, 'Before photo'),
    );
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.description,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(site.name),
        Text('${item.category} - ${item.location} - ${item.priority} priority'),
        Text(
          'Qty: ${item.qty} ${item.uom} • SOR item: ${item.sorItemNo.isEmpty ? 'Not set' : item.sorItemNo}',
        ),
        if (item.sorDescription.isNotEmpty) Text('SOR: ${item.sorDescription}'),
        Text(
          user.role == UserRole.contractor
              ? 'Rate: ₹${item.contractorVisibleRate.toStringAsFixed(2)} • Total: ₹${(item.quantityValue * item.contractorVisibleRate).toStringAsFixed(2)}'
              : 'Rate: ₹${item.rate.toStringAsFixed(2)} • Total: ₹${item.totalRate.toStringAsFixed(2)}',
        ),
        Text('Contractor: ${store.userName(site.contractorId)}'),
        const SizedBox(height: 8),
        StatusChip(status: item.status),
      ],
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isNarrow) ...[
            photo,
            const SizedBox(height: 12),
            details,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                photo,
                const SizedBox(width: 12),
                Expanded(child: details),
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
              if (user.role == UserRole.principal &&
                  item.status == WorkStatus.completed)
                FilledButton.icon(
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Principal approve'),
                  onPressed: () => showVerifyDialog(context, item),
                ),
              if (user.role == UserRole.admin &&
                  item.status == WorkStatus.principalApproved)
                FilledButton.icon(
                  icon: const Icon(Icons.task_alt),
                  label: const Text('Mark work completed'),
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
        const SectionTitle('Work types'),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add work type'),
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
      ],
    );
  }
}

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key, required this.title, required this.role});

  final String title;
  final UserRole role;

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var people = store.users.where((user) => user.role == widget.role).toList();
    final term = search.text.trim().toLowerCase();
    if (term.isNotEmpty) {
      people = people.where((person) {
        final haystack =
            '${person.name} ${person.mobile} ${person.workType} ${person.aadhaar} ${person.gst} ${person.pan} ${person.address}'
                .toLowerCase();
        return haystack.contains(term);
      }).toList();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(widget.title),
        AppTextField(
          controller: search,
          label: 'Search ${roleLabel(widget.role)}',
          onChanged: (_) => setState(() {}),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.person_add),
          label: Text('Add ${roleLabel(widget.role)}'),
          onPressed: () => showUserProfileDialog(context, role: widget.role),
        ),
        const SizedBox(height: 8),
        if (people.isEmpty)
          AppCard(child: Text('No ${roleLabel(widget.role)} profiles found.')),
        for (final person in people)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.role == UserRole.contractor)
                  PhotoBox(bytes: person.photo, label: 'Photo'),
                const SizedBox(height: 8),
                Text(
                  person.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  widget.role == UserRole.contractor
                      ? '${person.mobile} • ${person.workType} • ${person.active ? 'Active' : 'Inactive'}\n'
                            'Aadhaar: ${person.aadhaar} • GST: ${person.gst} • PAN: ${person.pan}'
                      : '${person.mobile} • ${person.active ? 'Active' : 'Inactive'}',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
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
                        role: widget.role,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => store.removeUser(person),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class WorkflowGrid extends StatelessWidget {
  const WorkflowGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 620;
        final width = isNarrow
            ? constraints.maxWidth
            : (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class WorkflowCard extends StatelessWidget {
  const WorkflowCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: arihaSky,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: arihaNavy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: arihaDeepNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                    const SizedBox(height: 8),
                    Text(
                      actionLabel,
                      style: const TextStyle(
                        color: arihaNavy,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE3EAF7)),
      ),
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
        DropdownMenuItem(value: UserRole.principal, child: Text('Principal')),
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
    final screenWidth = MediaQuery.sizeOf(context).width;
    final width = screenWidth < 420 ? double.infinity : 165.0;
    return SizedBox(
      width: width,
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
          color: arihaSky,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD7E1F4)),
        ),
        child: bytes == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_outlined, color: arihaLogoBlue),
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
          WorkStatus.pending => const Color(0xFFB42318),
          WorkStatus.started => arihaLogoBlue,
          WorkStatus.ongoing => const Color(0xFFB76E00),
          WorkStatus.completed => const Color(0xFF16805C),
          WorkStatus.principalApproved => arihaLogoBlue,
          WorkStatus.verified => arihaNavy,
          WorkStatus.rejected => const Color(0xFF475569),
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
  var selectedCircle = site?.circle.isNotEmpty == true
      ? site!.circle
      : allCircles().first;
  final paymentAuthority = TextEditingController(
    text: site?.paymentAuthority ?? '',
  );
  final grantAmount = TextEditingController(text: site?.grantAmount ?? '');
  final secondaryPhone = TextEditingController(
    text: site?.secondaryPhone ?? '',
  );
  final mapsLink = TextEditingController(text: site?.mapsLink ?? '');
  showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setLocalState) => AlertDialog(
        title: Text(site == null ? 'Add school/site' : 'Edit school/site'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCircle,
                decoration: const InputDecoration(
                  labelText: 'Circle number',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final circle in allCircles())
                    DropdownMenuItem(value: circle, child: Text(circle)),
                ],
                onChanged: (value) =>
                    setLocalState(() => selectedCircle = value!),
              ),
              const SizedBox(height: 10),
              AppTextField(controller: name, label: 'School/site name'),
              AppTextField(
                controller: paymentAuthority,
                label: 'Payment authority (GTERS / KCG)',
              ),
              AppTextField(
                controller: grantAmount,
                label: 'Estimated cost / budget cap',
              ),
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
                    circle: selectedCircle,
                    paymentAuthority: paymentAuthority.text,
                    grantAmount: grantAmount.text,
                    secondaryPhone: secondaryPhone.text,
                    mapsLink: mapsLink.text,
                  ),
                );
              } else {
                site.name = name.text;
                site.address = address.text;
                site.principal = principal.text;
                site.primaryPhone = primaryPhone.text;
                site.circle = selectedCircle;
                site.paymentAuthority = paymentAuthority.text;
                site.grantAmount = grantAmount.text;
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
    ),
  );
}

void showBulkSchoolImportDialog(BuildContext context) {
  final csv = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Upload Excel / CSV schools'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'For this local demo, paste rows from the downloaded Excel-compatible CSV template here.',
            ),
            const SizedBox(height: 10),
            AppTextField(controller: csv, label: 'Paste CSV rows', maxLines: 8),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Template'),
          onPressed: downloadSchoolTemplate,
        ),
        FilledButton(
          onPressed: () {
            final added = store.importSchoolsCsv(csv.text);
            Navigator.pop(context);
            showMessage(context, '$added schools imported.');
          },
          child: const Text('Import'),
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
      title: Text(category == null ? 'Add work type' : 'Edit work type'),
      content: AppTextField(controller: name, label: 'Work type name'),
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
  final aadhaar = TextEditingController(text: user?.aadhaar ?? '');
  final gst = TextEditingController(text: user?.gst ?? '');
  final pan = TextEditingController(text: user?.pan ?? '');
  final address = TextEditingController(text: user?.address ?? '');
  var workType = user?.workType ?? store.categories.first.name;
  Uint8List? photo = user?.photo;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setLocalState) => AlertDialog(
        title: Text(user == null ? 'Add ${roleLabel(role)}' : 'Edit profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (role == UserRole.contractor) ...[
                PhotoBox(bytes: photo, label: 'Photo'),
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text('Upload photo'),
                  onPressed: () async {
                    photo = await pickPhoto(ImageSource.gallery);
                    setLocalState(() {});
                  },
                ),
              ],
              AppTextField(controller: name, label: 'Name'),
              AppTextField(controller: mobile, label: 'Mobile number'),
              if (role == UserRole.contractor) ...[
                AppTextField(controller: aadhaar, label: 'Aadhaar number'),
                AppTextField(controller: gst, label: 'GST number'),
                AppTextField(controller: pan, label: 'PAN number'),
                AppTextField(
                  controller: address,
                  label: 'Address',
                  maxLines: 2,
                ),
                DropdownButtonFormField<String>(
                  initialValue: workType,
                  decoration: const InputDecoration(
                    labelText: 'Work type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final type in store.categories.where(
                      (type) => type.active,
                    ))
                      DropdownMenuItem(
                        value: type.name,
                        child: Text(type.name),
                      ),
                  ],
                  onChanged: (value) => workType = value!,
                ),
              ],
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
              store.saveUserProfile(
                user: user,
                name: name.text,
                mobile: mobile.text,
                role: role,
                aadhaar: aadhaar.text,
                gst: gst.text,
                pan: pan.text,
                address: address.text,
                workType: workType,
                photo: photo,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
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

void showAddWorkFromWorkPageDialog(BuildContext context) {
  var visibleSites = store.visibleSitesFor(store.currentUser!);
  final visibleCircles = visibleSites.map((site) => site.circle).toSet();
  var selectedCircle = allCircles().firstWhere(
    visibleCircles.contains,
    orElse: () => allCircles().first,
  );
  var circleSites = visibleSites
      .where((site) => site.circle == selectedCircle)
      .toList();
  Site? selectedSite = circleSites.isEmpty ? null : circleSites.first;
  showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setLocalState) => AlertDialog(
        title: const Text('Add work'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedCircle,
              decoration: const InputDecoration(
                labelText: 'Circle',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final circle in allCircles())
                  DropdownMenuItem(value: circle, child: Text(circle)),
              ],
              onChanged: (value) {
                selectedCircle = value!;
                visibleSites = store.visibleSitesFor(store.currentUser!);
                circleSites = visibleSites
                    .where((site) => site.circle == selectedCircle)
                    .toList();
                selectedSite = circleSites.isEmpty ? null : circleSites.first;
                setLocalState(() {});
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              key: ValueKey(selectedCircle),
              initialValue: selectedSite?.id,
              decoration: const InputDecoration(
                labelText: 'School / college',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final site in circleSites)
                  DropdownMenuItem(value: site.id, child: Text(site.name)),
              ],
              onChanged: circleSites.isEmpty
                  ? null
                  : (value) {
                      selectedSite = circleSites.firstWhere(
                        (site) => site.id == value,
                      );
                      setLocalState(() {});
                    },
            ),
            if (circleSites.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('No schools found in this circle.'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: selectedSite == null
                ? null
                : () {
                    final site = selectedSite!;
                    Navigator.pop(dialogContext);
                    showWorkDialog(context, site);
                  },
            child: const Text('Continue'),
          ),
        ],
      ),
    ),
  );
}

void showWorkDialog(BuildContext context, Site site) {
  final search = TextEditingController();
  var category = store.categories.firstWhere((item) => item.active).name;
  var priority = 'Medium';
  Uint8List? photo;
  final lines = <String, WorkEstimateLine>{};

  String lineKey(SorItem item) =>
      '${item.type}|${item.itemNo}|${item.description}';

  double estimateTotal() {
    return lines.values.fold<double>(0, (sum, line) => sum + line.total);
  }

  void addLine(SorItem item, void Function(void Function()) setLocalState) {
    final key = lineKey(item);
    final existing = lines[key];
    if (existing == null) {
      lines[key] = WorkEstimateLine(item: item);
    } else {
      existing.qty += 1;
    }
    setLocalState(() {});
  }

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocalState) {
        final results = store.searchSorItems(
          search.text,
          type: category,
          limit: 24,
        );
        return AlertDialog(
          title: Text('Add work estimate - ${site.name}'),
          content: SizedBox(
            width: 760,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BudgetStrip(site: site),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: arihaSky,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFD7E1F4)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.photo_camera,
                          size: 38,
                          color: arihaNavy,
                        ),
                        const SizedBox(height: 8),
                        PhotoBox(bytes: photo, label: 'Common work photo'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(
                      labelText: 'Type',
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
                    onChanged: (value) =>
                        setLocalState(() => category = value!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: search,
                    onChanged: (_) => setLocalState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Search item description or SOR item no.',
                      hintText: 'Example: excavation, wiring, painting',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Rate list results',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 320),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE3EAF7)),
                    ),
                    child: results.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text('No matching SOR items found.'),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: results.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = results[index];
                              final currentQty = lines[lineKey(item)]?.qty ?? 0;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${item.type} • Item ${item.itemNo} • ${item.uom} • ${inr(item.rate)}'
                                  '${currentQty > 0 ? ' • Added qty ${currentQty.toStringAsFixed(currentQty.truncateToDouble() == currentQty ? 0 : 2)}' : ''}',
                                ),
                                trailing: IconButton.filled(
                                  tooltip: 'Add work',
                                  icon: const Icon(Icons.add),
                                  onPressed: () => addLine(item, setLocalState),
                                ),
                                onTap: () => addLine(item, setLocalState),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Selected work items',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (lines.isEmpty)
                    const AppCard(
                      child: Text(
                        'No work added yet. Search above and press +.',
                      ),
                    )
                  else
                    for (final entry in lines.entries)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value.item.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.value.item.type} • Item ${entry.value.item.itemNo} • ${entry.value.item.uom} • Rate ${inr(entry.value.item.rate)}',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton.outlined(
                                  tooltip: 'Reduce quantity',
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    entry.value.qty -= 1;
                                    if (entry.value.qty <= 0) {
                                      lines.remove(entry.key);
                                    }
                                    setLocalState(() {});
                                  },
                                ),
                                SizedBox(
                                  width: 88,
                                  child: TextFormField(
                                    key: ValueKey(
                                      '${entry.key}-${entry.value.qty}',
                                    ),
                                    initialValue: entry.value.qty
                                        .toStringAsFixed(
                                          entry.value.qty.truncateToDouble() ==
                                                  entry.value.qty
                                              ? 0
                                              : 2,
                                        ),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      labelText: 'Qty',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      entry.value.qty =
                                          double.tryParse(value) ?? 0;
                                      setLocalState(() {});
                                    },
                                  ),
                                ),
                                IconButton.outlined(
                                  tooltip: 'Increase quantity',
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    entry.value.qty += 1;
                                    setLocalState(() {});
                                  },
                                ),
                                const Spacer(),
                                Text(
                                  inr(entry.value.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  AppCard(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Estimated total for selected work',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          inr(estimateTotal()),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: arihaNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority for these work items',
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
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: lines.isEmpty
                  ? null
                  : () {
                      for (final line in lines.values.where(
                        (line) => line.qty > 0,
                      )) {
                        store.addWorkItem(
                          WorkItem(
                            id: 'w${store.workItems.length + 1}',
                            siteId: site.id,
                            createdBy: store.currentUser!.id,
                            description: line.item.description,
                            category: line.item.type,
                            location: site.name,
                            priority: priority,
                            qty: line.qty.toStringAsFixed(
                              line.qty.truncateToDouble() == line.qty ? 0 : 2,
                            ),
                            uom: line.item.uom,
                            sorItemNo: line.item.itemNo,
                            sorDescription: line.item.description,
                            rate: line.item.rate,
                            beforePhoto: photo,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
              child: Text(
                'Save ${lines.length} work item${lines.length == 1 ? '' : 's'}',
              ),
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
          WorkStatus.principalApproved => 0.9,
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
    return 'Pending principal approval';
  }
  if (work.any((item) => item.status == WorkStatus.principalApproved)) {
    return 'Pending admin completion';
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
    'Verified' => arihaNavy,
    'Pending admin completion' => arihaLogoBlue,
    'Pending principal approval' => const Color(0xFF16805C),
    'In progress' => arihaLogoBlue,
    _ => const Color(0xFFB42318),
  };
}

List<String> allCircles() => const [
  'Circle 1',
  'Circle 2',
  'Circle 3',
  'Circle 4',
  'Circle 5',
  'Circle 6',
];

double parseMoney(String value) {
  final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
  return double.tryParse(cleaned) ?? 0;
}

String inr(double amount) {
  final whole = amount.round().toString();
  if (whole.length <= 3) return '₹ $whole';
  final prefix = whole.substring(0, whole.length - 3);
  final last = whole.substring(whole.length - 3);
  final groups = <String>[];
  for (var end = prefix.length; end > 0; end -= 2) {
    final start = end - 2 < 0 ? 0 : end - 2;
    groups.insert(0, prefix.substring(start, end));
  }
  return '₹ ${groups.join(',')},$last';
}

String buildSiteReport(Site site) {
  final work = store.workForSite(site.id);
  final bills = store.billsForSite(site.id);
  return [
    'School Site Report',
    'Generated: ${formatDateTime(DateTime.now())}',
    '',
    'Site: ${site.name}',
    'Address: ${site.address}',
    'Principal: ${site.principal}',
    'Payment authority: ${site.paymentAuthority}',
    'Budget cap: ${site.grantAmount.isEmpty ? 'Not added' : inr(parseMoney(site.grantAmount))}',
    'Primary phone: ${site.primaryPhone}',
    if (site.secondaryPhone.isNotEmpty)
      'Secondary phone: ${site.secondaryPhone}',
    'Maps: ${site.mapsLink}',
    'Supervisors: ${site.supervisorIds.isEmpty ? 'Not assigned' : site.supervisorIds.map(store.userName).join(', ')}',
    'Contractor: ${store.userName(site.contractorId)}',
    'Estimated value: ${store.estimatedValueForSite(site.id)}',
    'Progress: ${siteProgressLabel(work)} (${(siteProgress(work) * 100).round()}%)',
    '',
    'Work items:',
    for (final item in work)
      '- ${item.description} | ${item.category} | Qty ${item.qty} ${item.uom} | SOR ${item.sorItemNo} ${item.sorDescription} | Rate ₹${item.rate.toStringAsFixed(2)} | Total ₹${item.totalRate.toStringAsFixed(2)} | ${statusLabel(item.status)} | Remark: ${item.contractorRemark}',
    '',
    'Bills:',
    if (bills.isEmpty) 'No bills submitted',
    for (final bill in bills)
      '- ${bill.title} | ₹${bill.amount} | ${bill.paid == null
          ? 'Payment not marked'
          : bill.paid!
          ? 'Paid'
          : 'Not paid'}',
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

void showWorkOrderDialog(BuildContext context, Site site) {
  var contractorId = site.contractorId ?? store.contractors.first.id;
  var workType = store.categories.firstWhere((type) => type.active).name;
  final search = TextEditingController();
  final lines = <String, WorkEstimateLine>{};

  String lineKey(SorItem item) =>
      '${item.type}|${item.itemNo}|${item.description}';

  double estimateTotal() {
    return lines.values.fold<double>(0, (sum, line) => sum + line.total);
  }

  void addLine(SorItem item, void Function(void Function()) setLocalState) {
    final key = lineKey(item);
    final existing = lines[key];
    if (existing == null) {
      lines[key] = WorkEstimateLine(item: item);
    } else {
      existing.qty += 1;
    }
    setLocalState(() {});
  }

  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocalState) {
        final results = store.searchSorItems(
          search.text,
          type: workType,
          limit: 24,
        );
        return AlertDialog(
          title: Text('Create work order - ${site.name}'),
          content: SizedBox(
            width: 760,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BudgetStrip(site: site),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: contractorId,
                    decoration: const InputDecoration(
                      labelText: 'Select contractor/vendor',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final contractor in store.contractors.where(
                        (c) => c.active,
                      ))
                        DropdownMenuItem(
                          value: contractor.id,
                          child: Text(
                            '${contractor.name} (${contractor.workType.isEmpty ? 'General' : contractor.workType})',
                          ),
                        ),
                    ],
                    onChanged: (value) => contractorId = value!,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: workType,
                    decoration: const InputDecoration(
                      labelText: 'Work category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final type in store.categories.where(
                        (type) => type.active,
                      ))
                        DropdownMenuItem(
                          value: type.name,
                          child: Text(type.name),
                        ),
                    ],
                    onChanged: (value) =>
                        setLocalState(() => workType = value!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: search,
                    onChanged: (_) => setLocalState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Search work item description or SOR no.',
                      hintText: 'Example: wiring, excavation, plaster',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Rate list results',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE3EAF7)),
                    ),
                    child: results.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: Text('No matching SOR items found.'),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: results.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = results[index];
                              final currentQty = lines[lineKey(item)]?.qty ?? 0;
                              return ListTile(
                                dense: true,
                                title: Text(
                                  item.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${item.type} • Item ${item.itemNo} • ${item.uom} • ${inr(item.rate)}'
                                  '${currentQty > 0 ? ' • Added qty ${currentQty.toStringAsFixed(currentQty.truncateToDouble() == currentQty ? 0 : 2)}' : ''}',
                                ),
                                trailing: IconButton.filled(
                                  tooltip: 'Add to order',
                                  icon: const Icon(Icons.add),
                                  onPressed: () => addLine(item, setLocalState),
                                ),
                                onTap: () => addLine(item, setLocalState),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Work order items',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (lines.isEmpty)
                    const AppCard(
                      child: Text(
                        'No work added yet. Search above and press +.',
                      ),
                    )
                  else
                    for (final entry in lines.entries)
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.value.item.description,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${entry.value.item.type} • Item ${entry.value.item.itemNo} • ${entry.value.item.uom} • Rate ${inr(entry.value.item.rate)}',
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                IconButton.outlined(
                                  tooltip: 'Reduce quantity',
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    entry.value.qty -= 1;
                                    if (entry.value.qty <= 0) {
                                      lines.remove(entry.key);
                                    }
                                    setLocalState(() {});
                                  },
                                ),
                                SizedBox(
                                  width: 88,
                                  child: TextFormField(
                                    key: ValueKey(
                                      'order-${entry.key}-${entry.value.qty}',
                                    ),
                                    initialValue: entry.value.qty
                                        .toStringAsFixed(
                                          entry.value.qty.truncateToDouble() ==
                                                  entry.value.qty
                                              ? 0
                                              : 2,
                                        ),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      labelText: 'Qty',
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                    onChanged: (value) {
                                      entry.value.qty =
                                          double.tryParse(value) ?? 0;
                                      setLocalState(() {});
                                    },
                                  ),
                                ),
                                IconButton.outlined(
                                  tooltip: 'Increase quantity',
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    entry.value.qty += 1;
                                    setLocalState(() {});
                                  },
                                ),
                                const Spacer(),
                                Text(
                                  inr(entry.value.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  AppCard(
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Work order estimated value',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        Text(
                          inr(estimateTotal()),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: arihaNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: lines.isEmpty
                  ? null
                  : () {
                      store.createWorkOrder(
                        site,
                        contractorId,
                        workType,
                        estimateTotal().toStringAsFixed(2),
                      );
                      for (final line in lines.values.where(
                        (line) => line.qty > 0,
                      )) {
                        store.addWorkItem(
                          WorkItem(
                            id: 'w${store.workItems.length + 1}',
                            siteId: site.id,
                            createdBy: store.currentUser!.id,
                            description: line.item.description,
                            category: line.item.type,
                            location: site.name,
                            priority: 'Medium',
                            qty: line.qty.toStringAsFixed(
                              line.qty.truncateToDouble() == line.qty ? 0 : 2,
                            ),
                            uom: line.item.uom,
                            sorItemNo: line.item.itemNo,
                            sorDescription: line.item.description,
                            rate: line.item.rate,
                            contractorId: contractorId,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
              child: Text('Create order for ${inr(estimateTotal())}'),
            ),
          ],
        );
      },
    ),
  );
}

void showComplaintDialog(BuildContext context, Site site) {
  final title = TextEditingController();
  final description = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Register complaint - ${site.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(controller: title, label: 'Complaint title'),
          AppTextField(
            controller: description,
            label: 'Complaint description',
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            store.addComplaint(site, title.text, description.text);
            Navigator.pop(context);
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}

void showBillDialog(BuildContext context, Site site) {
  final title = TextEditingController();
  final amount = TextEditingController();
  final note = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Add bill - ${site.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(controller: title, label: 'Bill title / invoice no.'),
          AppTextField(controller: amount, label: 'Bill amount'),
          AppTextField(controller: note, label: 'Bill note', maxLines: 3),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            store.addBill(
              site,
              store.currentUser!.id,
              title.text,
              amount.text,
              note.text,
            );
            Navigator.pop(context);
          },
          child: const Text('Submit bill'),
        ),
      ],
    ),
  );
}

void showVendorSelfEditDialog(BuildContext context, AppUser contractor) {
  final name = TextEditingController(text: contractor.name);
  final mobile = TextEditingController(text: contractor.mobile);
  final aadhaar = TextEditingController(text: contractor.aadhaar);
  final gst = TextEditingController(text: contractor.gst);
  final pan = TextEditingController(text: contractor.pan);
  final address = TextEditingController(text: contractor.address);
  var workType = contractor.workType.isEmpty
      ? store.categories.first.name
      : contractor.workType;
  Uint8List? photo = contractor.photo;
  showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setLocalState) => AlertDialog(
        title: const Text('Request vendor profile update'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhotoBox(bytes: photo, label: 'Photo'),
              OutlinedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text('Change photo'),
                onPressed: () async {
                  photo = await pickPhoto(ImageSource.gallery);
                  setLocalState(() {});
                },
              ),
              AppTextField(controller: name, label: 'Name'),
              AppTextField(controller: mobile, label: 'Number'),
              AppTextField(controller: aadhaar, label: 'Aadhaar number'),
              AppTextField(controller: gst, label: 'GST number'),
              AppTextField(controller: pan, label: 'PAN number'),
              AppTextField(controller: address, label: 'Address', maxLines: 2),
              DropdownButtonFormField<String>(
                initialValue: workType,
                decoration: const InputDecoration(
                  labelText: 'Work type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  for (final type in store.categories.where(
                    (type) => type.active,
                  ))
                    DropdownMenuItem(value: type.name, child: Text(type.name)),
                ],
                onChanged: (value) => workType = value!,
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
              store.requestVendorProfileUpdate(
                contractor,
                AppUser(
                  id: contractor.id,
                  name: name.text,
                  mobile: mobile.text,
                  role: UserRole.contractor,
                  aadhaar: aadhaar.text,
                  gst: gst.text,
                  pan: pan.text,
                  address: address.text,
                  workType: workType,
                  photo: photo,
                ),
              );
              Navigator.pop(context);
              showMessage(context, 'Sent to admin for approval.');
            },
            child: const Text('Submit for approval'),
          ),
        ],
      ),
    ),
  );
}

void showLabourDialog(BuildContext context, AppUser contractor) {
  final name = TextEditingController();
  final aadhaar = TextEditingController();
  final pan = TextEditingController();
  var field = 'Mason';
  const fields = [
    'Carpenter',
    'Electrician',
    'Supervisor',
    'Mason',
    'Plumber',
    'Painter',
  ];
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add labour for approval'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(controller: name, label: 'Labour name'),
          AppTextField(controller: aadhaar, label: 'Aadhaar details'),
          AppTextField(controller: pan, label: 'PAN details'),
          DropdownButtonFormField<String>(
            initialValue: field,
            decoration: const InputDecoration(
              labelText: 'Field',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final item in fields)
                DropdownMenuItem(value: item, child: Text(item)),
            ],
            onChanged: (value) => field = value!,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            store.requestLabourAdd(
              contractor.id,
              LabourMember(
                name: name.text,
                aadhaar: aadhaar.text,
                pan: pan.text,
                field: field,
              ),
            );
            Navigator.pop(context);
            showMessage(context, 'Labour details sent to admin for approval.');
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}

void showWorkOrderPreview(BuildContext context, WorkOrder order) {
  final text = buildWorkOrderText(order);
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(order.id),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(child: SelectableText(text)),
      ),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.download),
          label: const Text('Download text'),
          onPressed: () => downloadText('${order.id}.txt', text),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

String buildWorkOrderText(WorkOrder order) {
  final site = store.siteById(order.siteId);
  return '''
ARIHA TRADING AND INFRASTRUCTURE PRIVATE LIMITED
CORPORATE WORK ORDER
COLLEGE RENOVATION, REPAIR & MAINTENANCE WORKS

Letterhead / Logo: Ariha Infra
Work Order No.: ${order.id}
Date: ${formatDateTime(order.date)}

Project Name: College Renovation & Repair Works
College Name: ${site.name}
Vendor: ${store.userName(order.contractorId)}
Estimated Value: ₹ ${order.estimatedValue}
Completion Period: 1 Month

1. Scope of Work
Vendor shall inspect site, prepare quotation as per approved SOR, execute works and submit all documentation.
2. Quotation Conditions
Quotation shall not exceed approved estimate. SOR item numbers shall be strictly followed.
3. Pre-Commencement Requirements
Approval from Principal and Site Supervisor. Upload GPS photographs, quantities, UOM and SOR references.
4. Daily Progress Reporting
Vendor shall update DPR daily through application.
5. Time Schedule
Entire work to be completed within one month.
6. Penalty Clause
2% penalty per week on work order value for delay.
7. Quality Control
All works subject to inspection and verification.
8. Billing & Invoicing
Invoice to include GPS photographs, BOQ, measurements and approvals.
9. Payment Terms
90% within 45 days after verification. Balance 6% after successful completion.
10. Defect Liability Period
26 Months from completion date.
11. Safety & Compliance
Vendor responsible for labour and safety compliance.
12. Jurisdiction
Subject to Surat Jurisdiction.

Annexure A - Mandatory Submission Checklist
1. Approved BOQ - Yes/No
2. GPS Photos - Yes/No
3. Measurement Sheet - Yes/No
4. DPR Reports - Yes/No
5. Completion Certificate - Yes/No
6. Final Invoice - Yes/No

Acceptance & Signatures
For Ariha Trading and Infrastructure Private Limited
Authorized Signatory: ____________________
Seal: ____________________

For Vendor / Contractor
Authorized Signatory: ____________________
Seal: ____________________
''';
}

Future<void> downloadCollegeExcel(BuildContext context) async {
  final rows = [
    [
      'College Name',
      'Circle',
      'Location',
      'Grant Amount',
      'Contractor Civil (Name & Number)',
      'Contractor Electrical (Name & Number)',
      'Principal Name',
      'Location Link',
      'Contact Number',
      'Site Supervision (Name & Number)',
      'Estimation Status',
      'Estimated Cost',
      'Work Category',
    ],
    for (final site in store.sites)
      [
        site.name,
        site.circle,
        site.address,
        site.grantAmount,
        contractorByType(site, 'Civil'),
        contractorByType(site, 'Electrical'),
        site.principal,
        site.mapsLink,
        site.primaryPhone,
        site.supervisorIds
            .map((id) => '${store.userName(id)} (${userMobile(id)})')
            .join('; '),
        store.workOrdersForSite(site.id).isEmpty ? 'Pending' : 'Estimated',
        store.workOrdersForSite(site.id).isEmpty
            ? ''
            : store.workOrdersForSite(site.id).first.estimatedValue,
        store.workOrdersForSite(site.id).isEmpty
            ? ''
            : store.workOrdersForSite(site.id).first.workType,
      ],
  ];
  final csv = rows.map((row) => row.map(csvCell).join(',')).join('\n');
  await downloadText('ariha_college_work_summary.csv', csv);
}

Future<void> downloadSchoolTemplate() async {
  const template =
      'school name,circle,estimation,contact number,location,principal name,payment authority\n'
      'Example College,Circle 2,500000,9999999999,https://maps.google.com/?q=Example+College,Principal Name,GTERS\n';
  await downloadText('school_upload_template.csv', template);
}

String contractorByType(Site site, String type) {
  final contractor = store.contractors.where((user) {
    return user.id == site.contractorId &&
        user.workType.toLowerCase().contains(type.toLowerCase());
  });
  if (contractor.isEmpty) return '';
  final user = contractor.first;
  return '${user.name} (${user.mobile})';
}

String userMobile(String id) {
  return store.users
      .firstWhere(
        (user) => user.id == id,
        orElse: () =>
            AppUser(id: '', name: '', mobile: '', role: UserRole.contractor),
      )
      .mobile;
}

String csvCell(String value) => '"${value.replaceAll('"', '""')}"';

List<String> parseCsvLine(String line) {
  final result = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        buffer.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      result.add(buffer.toString().trim());
      buffer.clear();
    } else {
      buffer.write(char);
    }
  }
  result.add(buffer.toString().trim());
  return result;
}

Future<void> downloadText(String filename, String text) async {
  final uri = Uri.parse(
    'data:text/plain;charset=utf-8,${Uri.encodeComponent(text)}',
  );
  await launchUrl(uri);
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
    UserRole.principal => 'Principal',
  };
}

String workOrderStatusLabel(WorkOrderStatus status) {
  return switch (status) {
    WorkOrderStatus.draft => 'Draft',
    WorkOrderStatus.sent => 'Sent',
    WorkOrderStatus.accepted => 'Accepted',
    WorkOrderStatus.completed => 'Completed',
  };
}

String statusLabel(WorkStatus status) {
  return switch (status) {
    WorkStatus.pending => 'Pending',
    WorkStatus.started => 'Started',
    WorkStatus.ongoing => 'Ongoing',
    WorkStatus.completed => 'Completed',
    WorkStatus.principalApproved => 'Principal Approved',
    WorkStatus.verified => 'Verified',
    WorkStatus.rejected => 'Rework Required',
  };
}
