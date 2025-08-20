// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class DateSelectorRow extends StatelessWidget {
//   final DateTime selectedDate;
//   final Function(DateTime) onDateSelected;

//   const DateSelectorRow({
//     super.key,
//     required this.selectedDate,
//     required this.onDateSelected,
//   });

//   bool _isSameDate(DateTime a, DateTime b) {
//     return a.year == b.year && a.month == b.month && a.day == b.day;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: List.generate(5, (index) {
//         DateTime date = DateTime.now().add(Duration(days: index));
//         String day = DateFormat('d').format(date);
//         String month = DateFormat('MMM').format(date);

//         bool isSelected = _isSameDate(date, selectedDate);

//         return GestureDetector(
//           onTap: () => onDateSelected(date),
//           child: Stack(
//             alignment: Alignment.topCenter,
//             children: [
//               Positioned(
//                 top: 0,
//                 child: Container(
//                   height: 6,
//                   width: 50,
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? const Color(0XFFDCDCDC)
//                         : Colors.black,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: const EdgeInsets.only(top: 4),
//                 height: 80,
//                 width: 60,
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? const Color(0XFF120698)
//                       : Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.black12),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       day,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       month,
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }










import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelectorRow extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DateSelectorRow({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          String day = DateFormat('d').format(date);
          String month = DateFormat('MMM').format(date);
          String weekday = DateFormat('E').format(date);

          bool isSelected = _isSameDate(date, selectedDate);
          bool isToday = _isSameDate(date, DateTime.now());

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Material(
                elevation: isSelected ? 4 : 0,
                borderRadius: BorderRadius.circular(12),
                shadowColor: Colors.black26,
                child: InkWell(
                  onTap: () => onDateSelected(date),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : isToday
                                ? Theme.of(context).primaryColor.withOpacity(0.3)
                                : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekday,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          day,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          month,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white70
                                : Colors.grey.shade600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}