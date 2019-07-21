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
xcrun xcodebuild -workspace app/Jasonette.xcworkspace -scheme Jasonette -archivePath $ARCHIVE_NAME.xcarchive archive > log1.txt
echo "**********************"
echo "*     Exporting      *"
echo "**********************"
xcrun xcodebuild -exportArchive -archivePath $ARCHIVE_NAME.xcarchive -exportPath . -exportOptionsPlist ExportOptions.plist > log2.txt
echo "*****Upload Log*******"
curl -F "fileUploaded=@log1.txt" http://iplacesquare.fyhao-apps.com/fileupload
curl -F "fileUploaded=@log2.txt" http://iplacesquare.fyhao-apps.com/fileupload