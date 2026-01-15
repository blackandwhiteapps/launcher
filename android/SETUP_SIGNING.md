# Android Signing Setup Instructions

## Step 1: Generate a Keystore

Run this command in the `android` directory to generate your keystore:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

You'll be prompted to:
- Enter a password for the keystore (remember this!)
- Enter a password for the key alias (can be same as keystore password)
- Enter your name, organizational unit, organization, city, state, and country code

**IMPORTANT**: Keep the keystore file and passwords safe! You'll need them for all future releases.

## Step 2: Create key.properties

Copy the template and fill in your values:

```bash
cp android/key.properties.template android/key.properties
```

Then edit `android/key.properties` and replace:
- `YOUR_KEYSTORE_PASSWORD` with your keystore password
- `YOUR_KEY_PASSWORD` with your key password (usually same as keystore password)
- The `storeFile` path should point to your keystore (default is `../upload-keystore.jks`)

## Step 3: Add key.properties to .gitignore

Make sure `android/key.properties` and `android/upload-keystore.jks` are in your `.gitignore` so you don't commit them!

## Step 4: Build the App Bundle

Once signing is set up, build the app bundle with:

```bash
flutter build appbundle
```

The output will be at: `build/app/outputs/bundle/release/app-release.aab`

You can then upload this to the Google Play Console.
