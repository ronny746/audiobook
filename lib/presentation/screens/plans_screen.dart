import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  List<dynamic> _plans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    final plans = await AuthService.getPlans();
    setState(() {
      _plans = plans;
      _isLoading = false;
    });
  }

  Future<void> _handleSubscribe(String planId) async {
    setState(() => _isLoading = true);
    final result = await AuthService.subscribe(planId);
    setState(() => _isLoading = false);

    if (result['msg'] == 'Subscription successful') {
      // Refresh dynamic user data
      context.read<AuthProvider>().fetchProfile();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Subscription Successful! Enjoy unlimited music.")),
      );
      Navigator.pop(context, true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['msg'] ?? "Subscription failed")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Premium Plans", style: TextStyle(color: AppColors.deepMaroon, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.deepMaroon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffron))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   const Text(
                    "Choose Your Journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.deepMaroon),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Unlock unlimited stories and music with our affordable plans.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  ..._plans.map((plan) => _buildPlanCard(plan)).toList(),
                  const SizedBox(height: 20),
                  const Text(
                    "Secure payment processing via major cards and UPI.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPlanCard(dynamic plan) {
    IconData planIcon = Icons.star_border_rounded;
    if (plan['name'].contains('Weekly')) planIcon = Icons.bolt_rounded;
    if (plan['name'].contains('Monthly')) planIcon = Icons.auto_awesome_rounded;
    if (plan['name'].contains('Yearly')) planIcon = Icons.workspace_premium_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepMaroon.withOpacity(0.08), 
            blurRadius: 30, 
            offset: const Offset(0, 15)
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.saffron.withOpacity(0.02),
          ],
        ),
        border: Border.all(color: AppColors.saffron.withOpacity(0.15), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.saffron.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(planIcon, color: AppColors.saffron, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['name'],
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepMaroon),
                    ),
                    Text(
                      "Validity: ${plan['durationInDays']} Days",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${plan['price']}",
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: AppColors.saffron),
                  ),
                  const Text("one-time", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.saffron.withOpacity(0.1)),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  plan['description'] ?? "Unlimited access to all content",
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            onPressed: () => _handleSubscribe(plan['_id']),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepMaroon,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              elevation: 4,
              shadowColor: AppColors.deepMaroon.withOpacity(0.4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              "UPGRADE NOW", 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }
}
