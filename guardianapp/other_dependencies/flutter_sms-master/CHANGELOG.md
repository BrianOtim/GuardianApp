# 2.3.3

* Adding ability to send SMS directly on Android (#57).

# 2.3.2

* Update Android plugin to use V2 embedding.

## 2.3.1

* Full null safety
* Fixing support for web
* Removing macos folder
* Fixing example

## 2.3.0

* Null Safety (1 dependency needs to be upgraded for full null safety: flutter_user_agent)

## 2.2.0

* Upgrading dependencies
* Updating example (lint issues)

## 2.1.1

* Fixing Issue with Web

## 2.1.0

* Fixing Bugs with iOS
* Adding URL fallback

## 2.0.0

* Adding Online Demo
* Adding Support for Web

## 1.1.0

* Updating for latest ios/android flutter plugin template

## 1.0.1

* Android result added

## 1.0.0 * 04.29.2019

* Reduce minSdkVersion to 16
* Fix crash on android when `recipients` is empty (substring on empty string)
* Add `canSendSMS` API
  - Checks if device is SMS capable (iOS and Android)
  - Checks if `smsto:` Intent is resolved and resulting activity exported (Android)
* sendSMS: Return error when device is not SMS capable (Android)
* Remove unused AndroidX dependency
* Use Intent.ACTION_SENDTO and Intent.EXTRA_TEXT to increase message app support coverage

## 0.2.0 * 04.06.2019

* Updating example to be desktop aware

## 0.1.0

* Fix for Android Multiple People
* Fixes Issues #8 and #4

## 0.0.5

* Removed SMS Permissions on Android

## 0.0.4

* Bug Fix Send Result
* Added Can Send Text

## 0.0.3

* Bug Fix for iOS Simulator Error

## 0.0.2

* Fixing Version

## 0.0.1

* SMS and MMS for Android and iOS
