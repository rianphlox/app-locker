import 'package:flutter/material.dart';
import '../models/app_info.dart';

class AppListItem extends StatelessWidget {
  final AppInfo app;
  final VoidCallback onToggle;

  const AppListItem({
    super.key,
    required this.app,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: app.icon != null
                ? Image.memory(
                    app.icon!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xFF4DB6AC),
                    child: const Icon(
                      Icons.android,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
          ),
        ),
        title: Text(
          app.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.packageName,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
              ),
            ),
            if (app.isSystemApp)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SYSTEM',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: Switch(
          value: app.isLocked,
          onChanged: (_) => onToggle(),
          activeColor: const Color(0xFF4DB6AC),
          activeTrackColor: const Color(0xFF4DB6AC).withOpacity(0.3),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
        ),
      ),
    );
  }
}