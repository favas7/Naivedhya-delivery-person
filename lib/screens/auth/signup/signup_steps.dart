import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:naivedhya_delivery_app/screens/auth/signup/signup_helper.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'signup_form_data.dart';

class SignupSteps {
  // Validator for name field - allows spaces between words but not at start/end or multiple consecutive spaces
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    
    // Check for leading or trailing spaces
    if (value.trim() != value) {
      return 'Name cannot start or end with spaces';
    }
    
    // Check for multiple consecutive spaces
    if (value.contains(RegExp(r'\s{2,}'))) {
      return 'Name cannot have multiple consecutive spaces';
    }
    
    // Check if name contains only letters and single spaces
    if (!RegExp(r'^[a-zA-Z]+(\s[a-zA-Z]+)*$').hasMatch(value)) {
      return 'Name can only contain letters and single spaces';
    }
    
    return null;
  }

  // Validator for Indian number plate format
  static String? validateNumberPlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your number plate';
    }
    
    // Remove spaces and convert to uppercase for validation
    String cleanedValue = value.replaceAll(' ', '').replaceAll('-', '').toUpperCase();
    
    // Indian number plate formats:
    // Format 1: KL01AB1234 (State Code - RTO Number - Series - Number)
    // State code: 2 letters, RTO: 2 digits, Series: 1-2 letters, Number: 1-4 digits
    
    RegExp numberPlateRegex = RegExp(
      r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{1,4}$'
    );
    
    if (!numberPlateRegex.hasMatch(cleanedValue)) {
      return 'Invalid number plate format (e.g., KL01AB1234)';
    }
    
    return null;
  }

  static Widget buildStep1(SignupFormData formData) {
    return SingleChildScrollView(
      key: const PageStorageKey('step1'),
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: formData.formKeys[0],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Let\'s start with your basic details',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              
              TextFormField(
                controller: formData.nameController,
                focusNode: formData.nameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => formData.emailFocus.requestFocus(),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                  helperText: 'Only letters and single spaces allowed',
                ),
                validator: validateName,
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: formData.emailController,
                focusNode: formData.emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => formData.passwordFocus.requestFocus(),
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              StatefulBuilder(
                builder: (context, setState) {
                  return TextFormField(
                    controller: formData.passwordController,
                    focusNode: formData.passwordFocus,
                    obscureText: !formData.isPasswordVisible,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => formData.confirmPasswordFocus.requestFocus(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          formData.isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            formData.isPasswordVisible = !formData.isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              StatefulBuilder(
                builder: (context, setState) {
                  return TextFormField(
                    controller: formData.confirmPasswordController,
                    focusNode: formData.confirmPasswordFocus,
                    obscureText: !formData.isConfirmPasswordVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          formData.isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            formData.isConfirmPasswordVisible = !formData.isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != formData.passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildStep2(SignupFormData formData, BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('step2'),
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: formData.formKeys[1],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us more about yourself',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              
              TextFormField(
                controller: formData.fullNameController,
                focusNode: formData.fullNameFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => formData.phoneFocus.requestFocus(),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: formData.phoneController,
                focusNode: formData.phoneFocus,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  prefixText: '+91 ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length != 10) {
                    return 'Please enter a valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // State Dropdown
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: formData.selectedState,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map),
                    ),
                    isExpanded: true,
                    items: SignupFormData.indianStates.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        formData.selectedState = newValue;
                        // Update the controller for backend submission
                        formData.stateController.text = newValue ?? '';
                      });
                      // Move focus to city field after selection
                      formData.cityFocus.requestFocus();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your state';
                      }
                      return null;
                    },
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: formData.cityController,
                focusNode: formData.cityFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => formData.aadhaarFocus.requestFocus(),
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: formData.aadhaarController,
                focusNode: formData.aadhaarFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Aadhaar Number',
                  prefixIcon: Icon(Icons.credit_card),
                  helperText: '12-digit Aadhaar number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Aadhaar number';
                  }
                  if (value.length != 12) {
                    return 'Aadhaar number must be 12 digits';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              StatefulBuilder(
                builder: (context, setState) {
                  return InkWell(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      SignupHelpers.selectDate(context, formData, setState);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        formData.selectedDate != null
                            ? '${formData.selectedDate!.day}/${formData.selectedDate!.month}/${formData.selectedDate!.year}'
                            : 'Select your date of birth',
                        style: TextStyle(
                          color: formData.selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildStep3(SignupFormData formData, BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('step3'),
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Form(
          key: formData.formKeys[2],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vehicle Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tell us about your delivery vehicle',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),
              
              StatefulBuilder(
                builder: (context, setState) {
                  return DropdownButtonFormField<String>(
                    value: formData.selectedVehicleType,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Type',
                      prefixIcon: Icon(Icons.motorcycle),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'bike', child: Text('Motorcycle/Bike')),
                      DropdownMenuItem(value: 'scooter', child: Text('Scooter')),
                      DropdownMenuItem(value: 'bicycle', child: Text('Bicycle')),
                      DropdownMenuItem(value: 'car', child: Text('Car')),
                    ],
                    onChanged: (value) {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        formData.selectedVehicleType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your vehicle type';
                      }
                      return null;
                    },
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: formData.vehicleModelController,
                focusNode: formData.vehicleModelFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => formData.numberPlateFocus.requestFocus(),
                decoration: const InputDecoration(
                  labelText: 'Vehicle Model',
                  prefixIcon: Icon(Icons.directions_car),
                  helperText: 'e.g., Honda Activa, Splendor Plus',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle model';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              TextFormField(
                controller: formData.numberPlateController,
                focusNode: formData.numberPlateFocus,
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  labelText: 'Number Plate',
                  prefixIcon: Icon(Icons.confirmation_number),
                  helperText: 'e.g., KL01AB1234 or KL-01-AB-1234',
                ),
                validator: validateNumberPlate,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildStep4(SignupFormData formData, BuildContext context) {
    return SingleChildScrollView(
      key: const PageStorageKey('step4'),
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Documents',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload your license and Aadhaar card',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                
                SignupHelpers.buildImageUploadCard(
                  'Driving License',
                  'Upload your driving license',
                  formData.licenseImage,
                  () => SignupHelpers.pickImage(true, formData, setState, context),
                  Icons.credit_card,
                ),
                
                const SizedBox(height: 20),
                
                SignupHelpers.buildImageUploadCard(
                  'Aadhaar Card',
                  'Upload your Aadhaar card',
                  formData.aadhaarImage,
                  () => SignupHelpers.pickImage(false, formData, setState, context),
                  Icons.contact_mail,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}