import 'package:flutter/material.dart';
import '../../../../domain/models/distress_signal_input.dart';

class DistressSignalForm extends StatefulWidget {
  final ValueChanged<DistressSignalInput> onSubmit;

  const DistressSignalForm({
    super.key,
    required this.onSubmit,
  });

  @override
  State<DistressSignalForm> createState() => _DistressSignalFormState();
}

class _DistressSignalFormState extends State<DistressSignalForm> {
  final _formKey = GlobalKey<FormState>();
  final _trappedCountsController = TextEditingController();
  final _childrenNumbersController = TextEditingController();
  final _elderlyNumbersController = TextEditingController();
  final _otherController = TextEditingController();
  bool _hasFood = false;
  bool _hasWater = false;

  @override
  void dispose() {
    _trappedCountsController.dispose();
    _childrenNumbersController.dispose();
    _elderlyNumbersController.dispose();
    _otherController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        DistressSignalInput(
          trappedCounts: int.tryParse(_trappedCountsController.text) ?? 0,
          childrenNumbers: int.tryParse(_childrenNumbersController.text) ?? 0,
          elderlyNumbers: int.tryParse(_elderlyNumbersController.text) ?? 0,
          hasFood: _hasFood,
          hasWater: _hasWater,
          other: _otherController.text,
        ),
      );
    }
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.red[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[700]!, width: 2),
        ),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange[800], size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Fill in the information about your current situation',
                    style: TextStyle(
                      color: Colors.orange[900],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNumberField(
            label: 'Trapped Counts',
            controller: _trappedCountsController,
            icon: Icons.people,
          ),
          const SizedBox(height: 16),
          _buildNumberField(
            label: 'Children Numbers',
            controller: _childrenNumbersController,
            icon: Icons.child_care,
          ),
          const SizedBox(height: 16),
          _buildNumberField(
            label: 'Elderly Numbers',
            controller: _elderlyNumbersController,
            icon: Icons.elderly,
          ),
          const SizedBox(height: 24),
          Text(
            'Resources Available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CheckboxListTile(
                  title: const Text('Has Food', style: TextStyle(color: Colors.black87)),
                  secondary: const Icon(Icons.restaurant, color: Colors.green),
                  value: _hasFood,
                  onChanged: (value) {
                    setState(() {
                      _hasFood = value ?? false;
                    });
                  },
                  activeColor: Colors.green,
                ),
                Divider(height: 1, color: Colors.grey[300]),
                CheckboxListTile(
                  title: const Text('Has Water', style:TextStyle(color: Colors.black87)),
                  secondary: const Icon(Icons.water_drop, color: Colors.blue),
                  value: _hasWater,
                  onChanged: (value) {
                    setState(() {
                      _hasWater = value ?? false;
                    });
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _otherController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Other Information (Optional)',
              hintText: 'Describe your situation in detail...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[700]!, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleSubmit,
              icon: const Icon(Icons.broadcast_on_personal),
              label: const Text('Broadcast Signal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
