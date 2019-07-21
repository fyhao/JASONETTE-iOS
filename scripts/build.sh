#!/bin/sh
if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "This is a pull request. No deployment will be done."
  exit 0
fi
cd app && pod install
cd ../
security list-keychains -s ios-build.keychain
rm ~/Library/MobileDevice/Provisioning\ Profiles/$PROFILE_NAME.mobileprovision 
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles/
cp ./scripts/profile/$PROFILE_NAME.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
echo "*********************"
echo "*     Archiving     *"
echo "*********************"
#xcrun xcodebuild -workspace app/Jasonette.xcworkspace -scheme Jasonette -archivePath $ARCHIVE_NAME.xcarchive archive DEVELOPMENT_TEAM="C4F7EVGZVS" CODE_SIGN_IDENTITY="iPhone Distribution: Khor Yong Hao (C4F7EVGZVS)" PROVISIONING_PROFILE="b3c27c8a-4dda-4202-8f53-a752e20add13" > log1.txt
xcrun xcodebuild -scheme Jasonette -configuration Release build -project app/Jasonette.xcodeproj -target Jasonette ARCHS="armv7 arm64" VALID_ARCHS="armv7 arm64" -sdk iphoneos DEVELOPMENT_TEAM="C4F7EVGZVS" > log1.txt

echo "**********************"
echo "*     Exporting      *"
echo "**********************"
xcrun xcodebuild -exportArchive -archivePath $ARCHIVE_NAME.xcarchive -exportPath . -exportOptionsPlist ExportOptions.plist > log2.txt
echo "*****Upload Log*******"
tail -n 15 log1.txt > log1_100.txt
curl -F "fileUploaded=@log1_100.txt" http://iplacesquare.fyhao-apps.com/fileupload