import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sultan_app/app/routes.dart';
import 'package:sultan_app/core/constants/app_constants.dart';
import 'package:sultan_app/core/theme/app_colors.dart';
import 'package:sultan_app/core/utils/arabic_time_formatter.dart';
import 'package:sultan_app/core/widgets/custom_button.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_cubit.dart';
import 'package:sultan_app/features/checkout/cubit/checkout_state.dart';
import 'package:sultan_app/features/product_details/widgets/quantity_selector.dart';

class BookingOrderScreen extends StatefulWidget {
  const BookingOrderScreen({super.key});

  @override
  State<BookingOrderScreen> createState() => _BookingOrderScreenState();
}

class _BookingOrderScreenState extends State<BookingOrderScreen> {
  late int _peopleCount;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final booking = context.read<CheckoutCubit>().state.booking;
    _peopleCount = booking?.peopleCount ?? 2;
    _notesController = TextEditingController(text: booking?.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(CheckoutState state) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: state.selectedDate ?? today.add(const Duration(days: 1)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
    );
    if (date != null && mounted) {
      context.read<CheckoutCubit>().selectBookingDate(date);
    }
  }

  Future<void> _pickTime(CheckoutState state) async {
    final now = TimeOfDay.now();
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: state.selectedHour ?? now.hour,
        minute: state.selectedMinute ?? now.minute,
      ),
    );
    if (time != null && mounted) {
      context.read<CheckoutCubit>().selectBookingTime(
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  void _continue() {
    final saved = context.read<CheckoutCubit>().saveBooking(
      peopleCount: _peopleCount,
      notes: _notesController.text,
    );
    if (saved) Navigator.pushNamed(context, AppRoutes.confirmOrder);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('حجز طاولة')),
    body: SafeArea(
      bottom: false,
      child: BlocBuilder<CheckoutCubit, CheckoutState>(
        builder: (context, state) => ListView(
          padding: const EdgeInsets.all(AppConstants.pagePadding),
          children: [
            Text('التاريخ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              onTap: () => _pickDate(state),
              tileColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                side: const BorderSide(color: AppColors.border),
              ),
              leading: const Icon(Icons.calendar_today_outlined),
              title: Text(_formatSelectedDate(state.selectedDate)),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
            const SizedBox(height: 20),
            Text('الوقت', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              onTap: () => _pickTime(state),
              tileColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                side: const BorderSide(color: AppColors.border),
              ),
              leading: const Icon(Icons.schedule_outlined),
              title: Text(_formatSelectedTime(state)),
              trailing: const Icon(Icons.arrow_drop_down),
            ),
            if (state.bookingValidationMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                state.bookingValidationMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'عدد الأشخاص',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                QuantitySelector(
                  quantity: _peopleCount,
                  onDecrement: () => setState(() {
                    if (_peopleCount > 1) _peopleCount--;
                  }),
                  onIncrement: () => setState(() => _peopleCount++),
                ),
              ],
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _notesController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'ملاحظات اختيارية',
                hintText: 'أي ملاحظات خاصة بالحجز...',
              ),
            ),
            const SizedBox(height: 12),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.payments_outlined, color: AppColors.primary),
              title: Text('طريقة الدفع'),
              subtitle: Text('الدفع في الكافيه'),
            ),
          ],
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      minimum: const EdgeInsets.all(AppConstants.pagePadding),
      child: BlocBuilder<CheckoutCubit, CheckoutState>(
        builder: (context, state) => CustomButton(
          label: 'متابعة إلى تأكيد الطلب',
          onPressed: state.canContinueBooking ? _continue : null,
          icon: Icons.arrow_back,
        ),
      ),
    ),
  );

  String _formatSelectedDate(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    return '${date.day} / ${date.month} / ${date.year}';
  }

  String _formatSelectedTime(CheckoutState state) {
    final hour = state.selectedHour;
    final minute = state.selectedMinute;
    if (hour == null || minute == null) return 'اختر الوقت';
    return ArabicTimeFormatter.formatHourMinute(hour, minute);
  }
}
