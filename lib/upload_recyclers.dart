import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadRecyclers() async {
  final firestore = FirebaseFirestore.instance;

  final recyclers = [
    // =========================
    // RAJASTHAN - RSPCB
    // =========================

    {
      'recyclerId': 'RJ-JPR-001',
      'name': 'M/s ETCO E-Waste Recycler Private Ltd',
      'address': 'SB-23, Shilp Bari, Road No. 14-15, VKI Area, Jaipur',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'activity': 'Recycling & Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-JPR-002',
      'name': 'M/s Green Web Recycling',
      'address': 'H1-865, Industrial Area, Manda-II, Chomu, Jaipur',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'activity': 'Dismantling & Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-JPR-003',
      'name': 'M/s S.S. Enviro Care',
      'address':
          'E-216B, Sarna Dungar Industrial Area, Jhotawara Extension, Jaipur',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'activity': 'Recycling',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-JPR-004',
      'name': 'M/s Shyam E Waste Recycling',
      'address':
          'Plot No. G1-107, Manda Industrial Area, Chomu, Jaipur, Rajasthan',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'activity': 'Recycling & Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-JPR-005',
      'name': 'M/s Telsys Green Web Recycling Pvt. Ltd.',
      'address':
          'Plot No. E-559, RIICO Industrial Area, Manda-II, Chomu, Jaipur',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'activity': 'Recycling & Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-JPR-006',
      'name': 'M/s HULLADEK PWL',
      'address':
          'Plot No. F-142, RIICO Industrial Area Bindayka, Sirsi, Jaipur',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'activity': 'Recycling',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-JPR-007',
      'name': 'M/s Marss Recycler Private Limited',
      'address': 'G-5 Industrial Area Manda, Chomu, Jaipur',
      'city': 'Jaipur',
      'state': 'Rajasthan',
      'activity': 'Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-ALW-001',
      'name': 'M/s Greenscape Eco Management Pvt. Ltd.',
      'address': 'Plot No. 203, 203A, MIA Alwar, Rajasthan',
      'city': 'Alwar',
      'state': 'Rajasthan',
      'activity': 'E-waste Recycling & Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-ALW-002',
      'name': 'M/s Greenlet Recyclers Private Limited',
      'address':
          'Plot No. G-15-G, Sotanala Industrial Area, Behror, Alwar',
      'city': 'Alwar',
      'state': 'Rajasthan',
      'activity': 'Dismantling & Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-BHI-001',
      'name': 'M/s Go Green Management LLP',
      'address': 'G1-612N, Khushkhera RIICO Industrial Area, Bhiwadi, Alwar',
      'city': 'Bhiwadi',
      'state': 'Rajasthan',
      'activity': 'Recycling',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-BHI-002',
      'name': 'M/s Universal E-Waste Recycling Private Limited',
      'address':
          'Plot No. G1-742, RIICO Industrial Area Chopanki, Bhiwadi',
      'city': 'Bhiwadi',
      'state': 'Rajasthan',
      'activity': 'Recycling & Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-BHI-003',
      'name': 'M/s Tanwar Traders',
      'address':
          'Plot No. F-1294(E), Industrial Area, Bhiwadi, Alwar',
      'city': 'Bhiwadi',
      'state': 'Rajasthan',
      'activity': 'Recycling',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'RJ-CHU-001',
      'name': 'M/s SAS Tech E-waste Recycling Solutions',
      'address':
          'Plot No. G-286, Road No. 1, RIICO Industrial Area, Ratangarh, Churu',
      'city': 'Churu',
      'state': 'Rajasthan',
      'activity': 'Recycling & Refurbishing',
      'registrationStatus': 'Authorised by RSPCB',
      'sourceAuthority': 'Rajasthan State Pollution Control Board',
      'sourceType': 'State PCB authorised list',
      'sourceUrl':
          'https://environment.rajasthan.gov.in/content/environment/en/rajasthan-state-pollution-control-board/information/WasteManagement/E-Waste_Management/DISMANTLERS-REFURBISHERS-RECYCLERS.html',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    // =========================
    // GUJARAT - GPCB
    // =========================

    {
      'recyclerId': 'GJ-AHM-001',
      'name': 'E-Ali Recyclers',
      'address':
          'Plot No. 730, Survey No. 730, Plot No. 3, Village Paldi Kankaj, Daskroi, Ahmedabad',
      'city': 'Ahmedabad',
      'state': 'Gujarat',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in GPCB record; validity shown to 31-12-2027',
      'sourceAuthority': 'Gujarat Pollution Control Board',
      'sourceType': 'NGT-hosted GPCB status report',
      'sourceUrl':
          'https://www.greentribunal.gov.in/sites/default/files/news_updates/Status%20Report%20on%20behalf%20of%20Gujarat%20Pollution%20Control%20Board.pdf',
      'sourceYear': 2024,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'GJ-AHM-002',
      'name': 'Gujarat Green Recycling',
      'address':
          'Plot No. MSME-500, Sanand-II, Engineering Industrial Estate, GIDC Sanand-II',
      'city': 'Ahmedabad',
      'state': 'Gujarat',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in GPCB record; validity shown to 30-09-2026',
      'sourceAuthority': 'Gujarat Pollution Control Board',
      'sourceType': 'NGT-hosted GPCB status report',
      'sourceUrl':
          'https://www.greentribunal.gov.in/sites/default/files/news_updates/Status%20Report%20on%20behalf%20of%20Gujarat%20Pollution%20Control%20Board.pdf',
      'sourceYear': 2024,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'GJ-AHM-003',
      'name': 'Mahaarana Industries Pvt. Ltd.',
      'address':
          'Survey No. 466 & 475, Village Timba, Daskroi, Ahmedabad',
      'city': 'Ahmedabad',
      'state': 'Gujarat',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in GPCB record; validity shown to 15-05-2026',
      'sourceAuthority': 'Gujarat Pollution Control Board',
      'sourceType': 'NGT-hosted GPCB status report',
      'sourceUrl':
          'https://www.greentribunal.gov.in/sites/default/files/news_updates/Status%20Report%20on%20behalf%20of%20Gujarat%20Pollution%20Control%20Board.pdf',
      'sourceYear': 2024,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'GJ-AHM-004',
      'name': 'Kalpana E-Recyclers',
      'address':
          'Plot No. 2486, Madhuban Industrial Park, Village Kuha, Daskroi, Ahmedabad',
      'city': 'Ahmedabad',
      'state': 'Gujarat',
      'activity': 'E-waste Recycling & Refurbishing',
      'registrationStatus': 'Listed in GPCB record; validity shown to 22-01-2026',
      'sourceAuthority': 'Gujarat Pollution Control Board',
      'sourceType': 'NGT-hosted GPCB status report',
      'sourceYear': 2024,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'GJ-AHM-005',
      'name': 'Mangalam ECS Environment Pvt. Ltd.',
      'address':
          'Block No. 24 Paiki, Vautha, Dholka, Ahmedabad',
      'city': 'Ahmedabad',
      'state': 'Gujarat',
      'activity': 'E-waste Recycling & Refurbishing',
      'registrationStatus': 'Listed in GPCB record; validity shown to 30-09-2027',
      'sourceAuthority': 'Gujarat Pollution Control Board',
      'sourceType': 'NGT-hosted GPCB status report',
      'sourceYear': 2024,
      'lastChecked': '2026-09-26',
    },

    // =========================
    // TAMIL NADU - TNPCB
    // =========================

    {
      'recyclerId': 'TN-CHE-001',
      'name': 'Aer Worldwide India Pvt Ltd',
      'address':
          'SF No. 2B, 2C, 2D, 2E, Elanthanjeri Village, Thiruvottiyur Taluk, Chennai',
      'city': 'Chennai',
      'state': 'Tamil Nadu',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in TNPCB Recycler Directory 2025',
      'sourceAuthority': 'Tamil Nadu Pollution Control Board',
      'sourceType': 'State PCB recycler directory',
      'sourceUrl':
          'https://tnpcb.gov.in/PDF/Updates/Whats_New/Recyclers_Directory_2025.pdf',
      'sourceYear': 2025,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'TN-CHE-002',
      'name': 'E Cycle Solutions Private Limited',
      'address':
          'Pattravakkam Village, Ambattur Industrial Estate, Ambattur, Chennai',
      'city': 'Chennai',
      'state': 'Tamil Nadu',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in TNPCB Recycler Directory 2025',
      'sourceAuthority': 'Tamil Nadu Pollution Control Board',
      'sourceType': 'State PCB recycler directory',
      'sourceUrl':
          'https://tnpcb.gov.in/PDF/Updates/Whats_New/Recyclers_Directory_2025.pdf',
      'sourceYear': 2025,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'TN-CHE-003',
      'name': 'Rescalex',
      'address':
          'S. No. 17, Sadayankuppam, Off Ponneri High Road, Manali New Town, Chennai',
      'city': 'Chennai',
      'state': 'Tamil Nadu',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in TNPCB Recycler Directory 2025',
      'sourceAuthority': 'Tamil Nadu Pollution Control Board',
      'sourceType': 'State PCB recycler directory',
      'sourceUrl':
          'https://tnpcb.gov.in/PDF/Updates/Whats_New/Recyclers_Directory_2025.pdf',
      'sourceYear': 2025,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'TN-CHE-004',
      'name': 'Green E-Waste Pvt Ltd',
      'address':
          '31 A/15, 4th Cross Street, SIDCO Industrial Estate, Korattur, Ambattur, Chennai',
      'city': 'Chennai',
      'state': 'Tamil Nadu',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in TNPCB Recycler Directory 2025',
      'sourceAuthority': 'Tamil Nadu Pollution Control Board',
      'sourceType': 'State PCB recycler directory',
      'sourceUrl':
          'https://tnpcb.gov.in/PDF/Updates/Whats_New/Recyclers_Directory_2025.pdf',
      'sourceYear': 2025,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'TN-CHE-005',
      'name': 'ASM Era Recycler',
      'address':
          'SF No. 485/7B, 7C, 7D, 7E, Lal Bahadur Shastri Street, Sholinganallur, Chennai',
      'city': 'Chennai',
      'state': 'Tamil Nadu',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in TNPCB Recycler Directory 2025',
      'sourceAuthority': 'Tamil Nadu Pollution Control Board',
      'sourceType': 'State PCB recycler directory',
      'sourceUrl':
          'https://tnpcb.gov.in/PDF/Updates/Whats_New/Recyclers_Directory_2025.pdf',
      'sourceYear': 2025,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'TN-CBE-001',
      'name': 'Green Era Recyclers',
      'address':
          'SF No. 91/1B, Seerapalayam Village, Madukkarai Taluk, Coimbatore',
      'city': 'Coimbatore',
      'state': 'Tamil Nadu',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in TNPCB Recycler Directory 2025',
      'sourceAuthority': 'Tamil Nadu Pollution Control Board',
      'sourceType': 'State PCB recycler directory',
      'sourceUrl':
          'https://tnpcb.gov.in/PDF/Updates/Whats_New/Recyclers_Directory_2025.pdf',
      'sourceYear': 2025,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'TN-CBE-002',
      'name': 'Green India Recyclers',
      'address':
          'SF No. 26/1B Part, Soolakal Village, Kinathukadavu Taluk, Coimbatore',
      'city': 'Coimbatore',
      'state': 'Tamil Nadu',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in TNPCB Recycler Directory 2025',
      'sourceAuthority': 'Tamil Nadu Pollution Control Board',
      'sourceType': 'State PCB recycler directory',
      'sourceUrl':
          'https://tnpcb.gov.in/PDF/Updates/Whats_New/Recyclers_Directory_2025.pdf',
      'sourceYear': 2025,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'TN-CBE-003',
      'name': 'Techazar E-Cyclers Private Limited',
      'address':
          'SF No. 379/1B1 Site No. 15, Mother India Industrial Estate, Seerapalayam Village, Madukkarai Taluk, Coimbatore',
      'city': 'Coimbatore',
      'state': 'Tamil Nadu',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'Listed in TNPCB Recycler Directory 2025',
      'sourceAuthority': 'Tamil Nadu Pollution Control Board',
      'sourceType': 'State PCB recycler directory',
      'sourceUrl':
          'https://tnpcb.gov.in/PDF/Updates/Whats_New/Recyclers_Directory_2025.pdf',
      'sourceYear': 2025,
      'lastChecked': '2026-09-26',
    },

    // =========================
    // KERALA - CPCB/STATE RECORD
    // =========================

    {
      'recyclerId': 'KL-KOC-001',
      'name': 'Kerala Enviro Infrastructure Ltd',
      'address':
          'CTSDF, Inside FACT Cochin Division Campus, Ambalamedu, Kochi, Ernakulam',
      'city': 'Kochi',
      'state': 'Kerala',
      'activity': 'E-waste Recycling',
      'registrationStatus': 'EPR-registered recycler reported in CPCB/State submission',
      'sourceAuthority': 'CPCB / Kerala State Pollution Control Board',
      'sourceType': 'CPCB/NGT status report',
      'sourceUrl':
          'https://www.greentribunal.gov.in/sites/default/files/news_updates/Action%20Taken%20Report%20by%20CPCB.pdf',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },

    {
      'recyclerId': 'KL-IDK-001',
      'name': 'Sahya Solutions Group of Waste Management',
      'address':
          '3/310 Badayil Estate, Meloram P.O., Peruvanthanam, Idukki, Kerala',
      'city': 'Idukki',
      'state': 'Kerala',
      'activity': 'E-waste Dismantling & Recycling',
      'registrationStatus': 'EPR-registered recycler reported in CPCB/State submission',
      'sourceAuthority': 'CPCB / Kerala State Pollution Control Board',
      'sourceType': 'CPCB/NGT status report',
      'sourceUrl':
          'https://www.greentribunal.gov.in/sites/default/files/news_updates/Action%20Taken%20Report%20by%20CPCB.pdf',
      'sourceYear': 2026,
      'lastChecked': '2026-09-26',
    },
  ];

  int uploaded = 0;

for (final recycler in recyclers) {
  await firestore
      .collection('recyclers')
      .doc(recycler['recyclerId'] as String)
      .set(
        recycler,
        SetOptions(merge: true),
      );

  uploaded++;
}

debugPrint('$uploaded recycler records uploaded successfully');
}