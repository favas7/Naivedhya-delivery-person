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