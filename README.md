# WeCount
![WeCount](https://user-images.githubusercontent.com/74561850/170664617-7d3dd16f-f65d-45e1-85f7-e29ae89a9a44.png)


## Introduction

<p align="left">
    <img src="https://img.shields.io/badge/release-v1.0.1-brightgreen">
    <img src="https://img.shields.io/badge/license-MIT-blue">
</p>

WeCount is dedicated to solving the problem of bill splitting.

You can record shared costs for friends, follow the debt relationship in groups, and update subscribed expenses automatically.

WeCount make it more convenient for multiple people to spilt bills.


[![Download_on_the_App_Store_Badge_US-UK_blk_092917](https://user-images.githubusercontent.com/74561850/170664940-460e0b24-a5db-4962-9401-fbc1a2c1beed.png)](https://apps.apple.com/tw/app/wecount/id1619743121)

## Features

### Create groups
Create your own group with friends to split bills. There are two types of group could be chosen:
 
* Multiple payees: Groups for bills paid by different members in the group. Designed for bills splitting when traveling or hanging out with friends and family. 

* Single payee: Groups for all bills paid by the same person. Support for sharing the subscription plan of streaming platforms(ex. Netflix, Spotify…).


![1](https://user-images.githubusercontent.com/74561850/170664660-30516f1c-452b-4f3e-aa1a-cfc37656ab32.png)


### Add items

Add items in the group. Choose the payer and members to share the bill for each items. Offer multiple splitting options to split bills. Calculate payment for each member in groups. Update periodic group expenses automatically for single payer group.

![2](https://user-images.githubusercontent.com/74561850/170664693-6d3628e8-4801-430d-bacc-4e486c982d98.png)


### Set bank accounts

Add links to bank accounts in personal information for group members to transfer the money.

![3](https://user-images.githubusercontent.com/74561850/170664737-128f7a60-c947-4647-832a-7ab20b373aaf.png)


### Invite friends

Send friend requests by searching email or scanning QRCode.


![4](https://user-images.githubusercontent.com/74561850/170664772-8d621df5-807a-465a-a92d-5529b1f69e1c.png)

### Add reminders
Set reminders on specific time to push notifications and remind yourself about the debts in groups.

![5](https://user-images.githubusercontent.com/74561850/170664802-fd94be5d-456c-4796-a57b-47af9c7b37ab.png)

## Techniques


* Implemented **MVC Design Pattern** to enhance code maintainability.
* Stored data in **Firebase Cloud Firestore**. Listened for realtime updates of data and updated UI
synchronously. Aligned group data between group members immediately.
* Used **GCD** to execute data fetching asynchronously on various threads. Fetched data from different
collections on Firebase with dispatch queues concurrently to improve app’s responsiveness.
* Adopted **NWPathMonitor** for network monitoring and error handling. Detected network connection
before making requests for uploading data and provided hints if internet disconnect to improve
user experience.
* Established QRCode for each user with **CoreImage** and implemented **AVFoundation**** to build the
QRCode scanner with device camera.
* Set notifications with **Local Notification**, and push the notification at the time specified by the user.
* Identified subscriptions with **DateComponents**, **DateFormatter** and **Calendar** to update periodic subscription items automatically.

## Libraries 

* [Firebase](https://github.com/firebase/firebase-ios-sdk)
* [Firebase/Crashlytics](https://github.com/firebase/quickstart-ios)
* [Kingfisher](https://github.com/onevcat/Kingfisher)
* [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager)
* [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD)
* [Charts](https://github.com/danielgindi/Charts)
* [Lottie](https://github.com/airbnb/lottie-ios)
* [SwiftLint](https://github.com/realm/SwiftLint)

## Requirements

* Xcode 13.1
* Swift 5
* iOS 13 +

## Version

1.0.1

## Release Notes

| Version | Date | Note |
| ------- | :---- | :---- |
| 1.0.1   | 2022.05.17 | Fixed bugs of QRCode resolution. |
| 1.0     | 2022.05.11 | Released on the App Store. |

## License

See [LICENSE](https://github.com/Rileytw/Bill-Splitting/blob/develop/LICENSE.md).

## Contact
Riley Lei
> wecounttw@gmail.com
