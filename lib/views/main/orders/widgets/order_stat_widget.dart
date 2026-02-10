// import 'package:flutter/material.dart';
// import 'package:naivedhya_delivery_app/utils/app_colors.dart';

// class OrderStatWidget extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;

//   const OrderStatWidget({
//     super.key,
//     required this.title,
//     required this.value,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, size: 16, color: AppColors.textSecondary),
//         const SizedBox(width: 4),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 12,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }