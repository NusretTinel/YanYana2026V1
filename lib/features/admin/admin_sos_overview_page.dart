import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/sos_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/core/widgets/role_gate.dart';
import 'package:yanyana_p/shared/models/emergency_request.dart';

class AdminSosOverviewPage extends StatefulWidget {
  const AdminSosOverviewPage({super.key});

  @override
  State<AdminSosOverviewPage> createState() => _AdminSosOverviewPageState();
}

class _AdminSosOverviewPageState extends State<AdminSosOverviewPage> {
  List<EmergencyRequest> _requests = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await SOSService.instance.listAllForAdmin();
    if (!mounted) return;
    setState(() {
      _requests = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RoleGate(
      allowedRoles: {AppAuthRole.admin},
      child: Scaffold(
        backgroundColor: YanYanaColors.background,
        appBar: AppBar(
          backgroundColor: YanYanaColors.background,
          title: const Text('SOS Talepleri'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _requests.isEmpty
                ? const Center(
                    child: Text(
                      'Henüz SOS talebi yok.',
                      style: TextStyle(color: YanYanaColors.textMuted),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final r = _requests[i];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: YanYanaColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: YanYanaColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.userName.isEmpty ? 'Anonim' : r.userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Durum: ${r.status}',
                                style: const TextStyle(
                                  color: YanYanaColors.textMuted,
                                  fontSize: 13,
                                ),
                              ),
                              if (r.trustedContactName != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Acil kişi: ${r.trustedContactName}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
