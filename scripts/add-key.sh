#!/bin/sh

# decrypt key
openssl version
openssl smime -decrypt -in scripts/certs/dist.cer.enc -binary -inform DEM -inkey scripts/key/private-key.pem -out scripts/certs/dist.cer
openssl smime -decrypt -in scripts/certs/dist.p12.enc -binary -inform DEM -inkey scripts/key/private-key.pem -out scripts/certs/dist.p12
openssl smime -decrypt -in scripts/profile/$PROFILE_NAME.mobileprovision.enc -binary -inform DEM -inkey scripts/key/private-key.pem -out scripts/profile/$PROFILE_NAME.mobileprovision

# Create a custom keychain
security create-keychain -p travis ios-build.keychain
# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s ios-build.keychain
# Unlock the keychain
security unlock-keychain -p travis ios-build.keychain
# Set keychain timeout to 1 hour for long builds
security set-keychain-settings -t 3600 -l ~/Library/Keychains/ios-build.keychain
# Add certificates to keychain and allow codesign to access them
security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./scripts/certs/dist.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign 
security import ./scripts/certs/dist.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign
# Set Key partition list
security set-key-partition-list -S apple-tool:,apple: -s -k travis ios-build.keychain
# Put the provisioning profile in place 
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
echo "My profile name is $PROFILE_NAME"
cp "./scripts/profile/$PROFILE_NAME.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/