import 'package:flutter/material.dart';
import '../services/launcher_service.dart';
import '../utils/app_constants.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      AppAssets.logo,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.local_hospital,
                          color: Colors.white,
                          size: 40),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(AppStrings.appNameAr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(AppStrings.appTagline,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const ListTile(
              leading: Icon(Icons.people, color: AppColors.primary),
              title: Text('فريق التطوير - تواصل معنا',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            for (final member in AppTeam.members)
              _buildContactTile(context, member),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, DeveloperContact member) {
    // إصلاح جذري لمشكلة "BOTTOM OVERFLOWED": ListTile له ارتفاع مقيّد
    // داخلياً حتى مع isThreeLine: true، وهو لا يكفي لعرض صفين من
    // النصوص (هاتف + بريد) مع عمود من زرين في trailing في آن واحد.
    // الحل: استبداله بتخطيط حر بالكامل (Padding + Row/Column) يتمدد
    // ليلائم المحتوى الفعلي بدلاً من قصّه عند ارتفاع ثابت.
    return InkWell(
      onTap: () async {
        final success = await LauncherService.instance.callPhone(member.phone);
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تعذّر إجراء الاتصال')));
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.person, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(member.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone,
                          size: 13, color: AppColors.textSoft),
                      const SizedBox(width: 4),
                      Text(member.phone,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSoft)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 13, color: AppColors.textSoft),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          member.email,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSoft),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  // أخضر واتساب هنا مقصود (لون العلامة التجارية الرسمية
                  // للتطبيق نفسه)، وليس بقايا من الهوية اللونية القديمة.
                  icon: const Icon(Icons.chat,
                      color: Color(0xFF25D366), size: 20),
                  tooltip: 'واتساب',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () async {
                    final success = await LauncherService.instance
                        .openWhatsApp(member.phone);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذّر فتح واتساب')));
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.email,
                      color: AppColors.primary, size: 20),
                  tooltip: 'إرسال بريد',
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () async {
                    final success =
                        await LauncherService.instance.sendEmail(member.email);
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تعذّر فتح تطبيق البريد')));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
