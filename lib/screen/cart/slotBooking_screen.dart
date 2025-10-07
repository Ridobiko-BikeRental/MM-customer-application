import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../app_colors.dart';
import '../../models/MealBox_model.dart';
import '../../models/subcategory.dart';

class SlotBookingScreen extends StatefulWidget {
  final List<dynamic> cartItems;

  SlotBookingScreen({Key? key, required this.cartItems}) : super(key: key);

  @override
  State<SlotBookingScreen> createState() => _SlotBookingScreenState();
}

class _SlotBookingScreenState extends State<SlotBookingScreen> {
  DateTime? selectedDate;
  String? selectedSlot;

  late DateTime firstAllowedDate;
  late DateTime lastAllowedDate;
  late DateTime focusedDay; // for controlling calendar

  final List<String> slotTimes = [
    '9:00 AM - 12:00 PM',
    '12:00 PM - 3:00 PM',
    '3:00 PM - 6:00 PM',
    '6:00 PM - 9:00 PM',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    int minDay = 0, maxDay = 0;
    if (widget.cartItems.length == 1) {
      final item = widget.cartItems.first.product;
      if (item is MealBox) {
        minDay = item.minPrepareOrderDays ?? 0;
        maxDay = item.maxPrepareOrderDays ?? 0;
      } else if (item is SubCategory) {
        minDay = item.minDeliveryDays ?? 0;
        maxDay = item.maxDeliveryDays ?? 0;
      }
    } else {
      for (final cartItem in widget.cartItems) {
        final item = cartItem.product;
        if (item is MealBox) {
          if ((item.minPrepareOrderDays ?? 0) > minDay) minDay = item.minPrepareOrderDays!;
          if ((item.maxPrepareOrderDays ?? 0) > maxDay) maxDay = item.maxPrepareOrderDays!;
        }
        if (item is SubCategory) {
          if ((item.minDeliveryDays ?? 0) > minDay) minDay = item.minDeliveryDays!;
          if ((item.maxDeliveryDays ?? 0) > maxDay) maxDay = item.maxDeliveryDays!;
        }
      }
    }

    firstAllowedDate = now.add(Duration(days: minDay));
    lastAllowedDate = firstAllowedDate.add(Duration(days: maxDay)); // range is min→min+max
    focusedDay = firstAllowedDate;
    selectedDate = firstAllowedDate;
  }

  bool _isDayEnabled(DateTime day) {
    return !day.isBefore(firstAllowedDate) && !day.isAfter(lastAllowedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Slot Booking',
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pick a delivery date:", style: TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600)),
            SizedBox(height: 12),
            // Month header row with center text and chevrons
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      focusedDay = DateTime(focusedDay.year, focusedDay.month - 1, 1);
                    });
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "${_monthYear(focusedDay)}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      focusedDay = DateTime(focusedDay.year, focusedDay.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 3),
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(Duration(days: 365)),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) => isSameDay(day, selectedDate),
              calendarFormat: CalendarFormat.month,
              rowHeight: 38,
              headerVisible: false,
              calendarBuilders: CalendarBuilders(
  defaultBuilder: (context, day, focusedDay) {
    if (_isDayEnabled(day)) {
      return Center(
        child: Text(
          day.day.toString(),
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),  // change to your enabled date color
        ),
      );
    }
    return Center(
      child: Text(
        day.day.toString(),
        style: TextStyle(color: Colors.grey.shade400),  // disabled color
      ),
    );
  },
  selectedBuilder: (context, day, focusedDay) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.primary,  // change to your selected day background color
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: const TextStyle(color: Colors.white), // selected day text color
      ),
    );
  },
),

              enabledDayPredicate: _isDayEnabled,
              onPageChanged: (d) {
                setState(() {
                  focusedDay = d;
                });
              },
              onDaySelected: (day, _) {
                if (_isDayEnabled(day)) {
                  setState(() {
                    selectedDate = day;
                  });
                }
              },
            ),
            SizedBox(height: 28),
            Text("Pick a slot:", style: TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondary, width: 1)
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButton<String>(
                value: selectedSlot,
                isExpanded: true,
                hint: Text('Select time slot', style: TextStyle(color: AppColors.primary)),
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
                underline: SizedBox.shrink(),
                items: slotTimes.map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        slot,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (slot) {
                  setState(() {
                    selectedSlot = slot;
                  });
                },
              ),
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                  elevation: 0,
                ),
                onPressed: selectedDate != null && selectedSlot != null
                    ? () {
                        Navigator.pop(context, {
                          'date': selectedDate,
                          'slot': selectedSlot,
                        });
                      }
                    : null,
                child: Text(
                  "Confirm Slot",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthYear(DateTime date) {
    return "${_monthName(date.month)} ${date.year}";
  }

  String _monthName(int m) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December'
    ];
    return months[m - 1];
  }
}
