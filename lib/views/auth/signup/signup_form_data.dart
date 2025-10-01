import 'package:flutter/material.dart';
import 'dart:io';

class SignupFormData {
  // Form keys
  final List<GlobalKey<FormState>> formKeys = List.generate(4, (index) => GlobalKey<FormState>());

  // Controllers for Step 1 (Basic Info)
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Controllers for Step 2 (Personal Details)
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController aadhaarController = TextEditingController();
  DateTime? selectedDate;

  // Controllers for Step 3 (Vehicle Details)
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();
  String? selectedVehicleType;

  // Image files for Step 4
  File? licenseImage;
  File? aadhaarImage;

  // Password visibility states
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // Selected state for dropdown
  String? selectedState;

  // Focus nodes to prevent keyboard issues
  final FocusNode nameFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode stateFocus = FocusNode();
  final FocusNode cityFocus = FocusNode();
  final FocusNode aadhaarFocus = FocusNode();
  final FocusNode vehicleModelFocus = FocusNode();
  final FocusNode numberPlateFocus = FocusNode();

  // Complete list of Indian States and Union Territories
  static const List<String> indianStates = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Andaman and Nicobar Islands',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Delhi',
    'Jammu and Kashmir',
    'Ladakh',
    'Lakshadweep',
    'Puducherry',
  ];

  void dispose() {
    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    stateController.dispose();
    cityController.dispose();
    aadhaarController.dispose();
    vehicleModelController.dispose();
    numberPlateController.dispose();
    
    // Dispose focus nodes
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    fullNameFocus.dispose();
    phoneFocus.dispose();
    stateFocus.dispose();
    cityFocus.dispose();
    aadhaarFocus.dispose();
    vehicleModelFocus.dispose();
    numberPlateFocus.dispose();
  }
}