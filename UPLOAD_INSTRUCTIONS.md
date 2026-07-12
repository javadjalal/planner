# Upload Instructions for GitHub

تمام فایل‌های پروژه برای تو ساخته شده‌اند. حالا باید اینا رو به GitHub آپلود کنی.

## روش 1: GitHub Web Interface (ساده‌ترین)

1. برو `github.com/javadjalal/planner`
2. دکمه **Code** → **Add file** → **Upload files**
3. تمام فایل‌ها رو select کن:
   - `lib/main.dart`
   - `lib/services/` (تمام فایل‌ها)
   - `lib/screens/` (تمام فایل‌ها)
   - `lib/models/activity.dart`
   - `lib/widgets/activity_tile.dart`
   - `pubspec.yaml` (replace کن)

## روش 2: Command Line (سریع‌تر)

```bash
cd /path/to/your/local/planner
git pull origin main
cp -r /home/claude/planner_complete/lib/* ./lib/
cp /home/claude/planner_complete/pubspec.yaml ./pubspec.yaml
git add .
git commit -m "Add complete Flutter implementation with all screens and services"
git push origin main
```

## پس از Upload

1. برو **Actions** tab
2. یک workflow جدید شروع می‌شه
3. انتظار بکش ۳-۵ دقیقه تا build تموم بشه
4. اگر موفق بود ✅: APK فایل download می‌شه

## اگر Error داد

بگو کدام error رو دیدی تا fix کنم.

---

## فایل‌های ساخته‌شده:

✅ `lib/main.dart` - Main entry point
✅ `lib/services/theme.dart` - Theme and colors
✅ `lib/services/storage_service.dart` - Data persistence
✅ `lib/services/notification_service.dart` - Notifications
✅ `lib/models/activity.dart` - Activity model
✅ `lib/screens/schedule_screen.dart` - Schedule management
✅ `lib/screens/challenges_screen.dart` - Daily challenges
✅ `lib/screens/analysis_screen.dart` - Statistics
✅ `lib/screens/focus_screen.dart` - Pomodoro timer
✅ `lib/screens/notes_screen.dart` - Note taking
✅ `lib/screens/settings_screen.dart` - Settings
✅ `lib/widgets/activity_tile.dart` - Activity widget
✅ `pubspec.yaml` - Dependencies
