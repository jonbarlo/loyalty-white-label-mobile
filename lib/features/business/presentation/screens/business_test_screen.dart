import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/business_provider.dart';
import '../../../../core/theme/app_theme.dart';

class BusinessTestScreen extends StatefulWidget {
  const BusinessTestScreen({super.key});

  @override
  State<BusinessTestScreen> createState() => _BusinessTestScreenState();
}

class _BusinessTestScreenState extends State<BusinessTestScreen> {
  String _testResults = '';

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    final businessProvider = context.read<BusinessProvider>();
    setState(() {
      _testResults = 'Running tests...\n';
    });

    try {
      // Test 1: Load businesses
      _addResult('Test 1: Loading businesses...');
      await businessProvider.loadBusinesses();
      _addResult('✓ Loaded ${businessProvider.businesses.length} businesses');

      // Test 2: Create a test business
      _addResult('\nTest 2: Creating test business...');
      final testBusinessData = {
        'name': 'Test Business ${DateTime.now().millisecondsSinceEpoch}',
        'description': 'This is a test business created by the Flutter app',
        'address': '123 Test Street, Test City',
        'phone': '+1234567890',
        'email': 'test@business.com',
        'website': 'https://testbusiness.com',
        'isActive': true,
      };

      final createSuccess = await businessProvider.createBusiness(testBusinessData);
      if (createSuccess) {
        _addResult('✓ Test business created successfully');
        
        // Test 3: Get the created business
        if (businessProvider.businesses.isNotEmpty) {
          final lastBusiness = businessProvider.businesses.last;
          _addResult('\nTest 3: Loading business details...');
          await businessProvider.loadBusiness(lastBusiness.id);
          _addResult('✓ Business details loaded: ${businessProvider.selectedBusiness?.name}');

          // Test 4: Update the business
          _addResult('\nTest 4: Updating business...');
          final updateData = {
            'name': '${lastBusiness.name} (Updated)',
            'description': 'This business has been updated',
            'isActive': true,
          };
          final updateSuccess = await businessProvider.updateBusiness(lastBusiness.id, updateData);
          if (updateSuccess) {
            _addResult('✓ Business updated successfully');

            // Test 5: Delete the test business
            _addResult('\nTest 5: Deleting test business...');
            final deleteSuccess = await businessProvider.deleteBusiness(lastBusiness.id);
            if (deleteSuccess) {
              _addResult('✓ Test business deleted successfully');
            } else {
              _addResult('✗ Failed to delete test business: ${businessProvider.error}');
            }
          } else {
            _addResult('✗ Failed to update business: ${businessProvider.error}');
          }
        }
      } else {
        _addResult('✗ Failed to create test business: ${businessProvider.error}');
      }

      // Test 6: Search functionality
      _addResult('\nTest 6: Testing search...');
      final searchResults = businessProvider.searchBusinesses('test');
      _addResult('✓ Search found ${searchResults.length} businesses with "test"');

      _addResult('\n🎉 All tests completed!');

    } catch (e) {
      _addResult('\n✗ Test failed with error: $e');
    }
  }

  void _addResult(String result) {
    setState(() {
      _testResults += '$result\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business API Test'),
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _testResults = '';
              });
              _runTests();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business API Integration Test',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This screen tests all business-related API endpoints to ensure proper integration.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<BusinessProvider>(
              builder: (context, businessProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Status:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Loading: ${businessProvider.isLoading}'),
                    Text('Error: ${businessProvider.error ?? 'None'}'),
                    Text('Businesses loaded: ${businessProvider.businesses.length}'),
                    if (businessProvider.selectedBusiness != null)
                      Text('Selected: ${businessProvider.selectedBusiness!.name}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 