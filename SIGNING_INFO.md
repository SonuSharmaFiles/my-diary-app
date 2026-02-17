# Android App Signing Information

## App Bundle Location
Your signed app bundle is ready for upload to Google Play Console:
- **File**: `build/app/outputs/bundle/release/app-release.aab`
- **Size**: ~39 MB
- **Version**: 1.0.0+1

## Keystore Information
**IMPORTANT: Keep these credentials safe and secure!**

- **Keystore Location**: `android/app/upload-keystore.jks`
- **Keystore Password**: `mydiary123`
- **Key Alias**: `upload`
- **Key Password**: `mydiary123`
- **Validity**: 10,000 days (expires in 2053)

## Certificate Details
- **CN**: My Diary
- **OU**: Development
- **O**: My Diary
- **L**: Kathmandu
- **ST**: Bagmati
- **C**: NP
- **Algorithm**: SHA384withRSA
- **Key Size**: 2048-bit

## Important Notes

1. **Backup Your Keystore**: Make a secure backup of the `upload-keystore.jks` file. If you lose it, you won't be able to update your app on Google Play Store.

2. **Keep Credentials Secret**: Never commit `key.properties` or `upload-keystore.jks` to version control. They are already excluded via `.gitignore`.

3. **Google Play App Signing**: When you upload your first release to Google Play Console:
   - Google will ask you to enroll in Google Play App Signing (recommended)
   - Google will manage your app signing key
   - You'll use your upload key (this keystore) to sign updates

4. **Future Builds**: To build a new release, simply run:
   ```bash
   flutter build appbundle --release
   ```

## Uploading to Google Play Console

1. Go to [Google Play Console](https://play.google.com/console/)
2. Navigate to your app (or create a new one)
3. Go to "Release" > "Testing" > "Closed Testing"
4. Create a new release
5. Upload the file: `build/app/outputs/bundle/release/app-release.aab`
6. Complete the release details and submit for review

## Application ID
- **Package Name**: `io.mydiary.journal`
- This is a unique package name ready for Google Play Console upload

---
**Generated**: February 13, 2026
