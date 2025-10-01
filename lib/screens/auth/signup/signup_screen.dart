import 'package:flutter/material.dart';
import 'package:naivedhya_delivery_app/provider/auth_provider.dart';
import 'package:naivedhya_delivery_app/provider/user_provider.dart';
import 'package:naivedhya_delivery_app/screens/auth/login_screen.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'signup_form_data.dart';
import 'signup_steps.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form data instance
  late SignupFormData _formData;

  @override
  void initState() {
    super.initState();
    _formData = SignupFormData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _formData.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_validateCurrentStep()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Clear any previous errors
    userProvider.clearError();

    try {
      // First create account
      final signupSuccess = await authProvider.signUp(
        _formData.emailController.text.trim(),
        _formData.passwordController.text,
      );

      if (!signupSuccess) {
        // Check if AuthProvider has an errorMessage property instead of error
        String errorMessage = 'Failed to create account';
        
        // Try different possible error property names
        try {
          final dynamic provider = authProvider;
          if (provider.runtimeType.toString().contains('errorMessage')) {
            errorMessage = provider.errorMessage ?? errorMessage;
          } else if (provider.runtimeType.toString().contains('error')) {
            errorMessage = provider.error ?? errorMessage;
          }
        } catch (e) {
          // If accessing error properties fails, use default message
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (authProvider.user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created but user data not available'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Then save profile data
      final profileSuccess = await userProvider.saveUserProfile(
        userId: authProvider.user!.id,
        name: _formData.nameController.text.trim(),
        email: _formData.emailController.text.trim(),
        fullName: _formData.fullNameController.text.trim(),
        phone: _formData.phoneController.text.trim(),
        state: _formData.stateController.text.trim(),
        city: _formData.cityController.text.trim(),
        aadhaarNumber: _formData.aadhaarController.text.trim(),
        dateOfBirth: _formData.selectedDate!,
        vehicleType: _formData.selectedVehicleType!,
        vehicleModel: _formData.vehicleModelController.text.trim(),
        numberPlate: _formData.numberPlateController.text.trim(),
        licenseImagePath: _formData.licenseImage?.path,
        aadhaarImagePath: _formData.aadhaarImage?.path,
      );

      if (mounted) {
        if (profileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/onboarding'); 
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.errorMessage ?? 'Failed to save profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Progress indicator
              _buildProgressIndicator(),
              
              // Form content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  children: [
                    SignupSteps.buildStep1(_formData),
                    SignupSteps.buildStep2(_formData, context),
                    SignupSteps.buildStep3(_formData, context),
                    SignupSteps.buildStep4(_formData, context),
                  ],
                ),
              ),
              
              // Navigation buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(   
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                  );
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Expanded(
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= _currentStep ? Colors.white : Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _goToPreviousStep();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Back'),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            child: Consumer2<AuthProvider, UserProvider>(
              builder: (context, authProvider, userProvider, child) {
                final isLoading = authProvider.isLoading || userProvider.isLoading;
                
                return ElevatedButton(
                  onPressed: isLoading ? null : () {
                    FocusScope.of(context).unfocus();
                    if (_currentStep == _totalSteps - 1) {
                      _handleSignup();
                    } else {
                      _goToNextStep();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_currentStep == _totalSteps - 1 ? 'Create Account' : 'Next'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextStep() {
    if (_validateCurrentStep()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _goToPreviousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formData.formKeys[0].currentState!.validate();
      case 1:
        if (_formData.selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your date of birth')),
          );
          return false;
        }
        return _formData.formKeys[1].currentState!.validate();
      case 2:
        return _formData.formKeys[2].currentState!.validate();
      case 3:
        if (_formData.licenseImage == null || _formData.aadhaarImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload both license and Aadhaar images')),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }
}