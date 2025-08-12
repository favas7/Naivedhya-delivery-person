import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:naivedhya_delivery_app/utils/app_colors.dart';
import 'dart:io';
import 'signup_form_data.dart';

class SignupHelpers {
  static Future<void> selectDate(BuildContext context, SignupFormData formData, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    
    if (picked != null) {
      setState(() {
        formData.selectedDate = picked;
      });
    }
  }

  static Future<void> pickImage(bool isLicense, SignupFormData formData, StateSetter setState, BuildContext context) async {
    // Unfocus before opening image picker
    FocusScope.of(context).unfocus();
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        if (isLicense) {
          formData.licenseImage = File(image.path);
        } else {
          formData.aadhaarImage = File(image.path);
        }
      });
    }
  }

  static Widget buildImageUploadCard(
    String title, 
    String subtitle, 
    File? imageFile, 
    VoidCallback onTap, 
    IconData icon
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            if (imageFile != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  imageFile,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap to change image',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Icon(
                icon,
                size: 48,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}