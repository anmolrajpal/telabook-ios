# Telabook
An application to communicate with clients via SMS and receive calls


[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)


<p align="center">
<img src="Resources/Assets/menu.PNG", width=250, height=450>
</p>


## Description
Telabook provides unified communication through SMS/MMS and Voice modules. It helps teams stay connected and provide a single point of contact for clients. Whether you are a single user or a call center, Telabook is the right tool for you. It will help scale your business effectively and easily.

## Features

* SMS, Quick Replies, Auto Replies, Notifications 
* SIP based VOIP Calling, Call Recording
* State of the art Call UI


## Usage

### To enable VOIP services:
In `AppDelegate.swift` file, set the following value to `true`:
```swift
let isVOIPEnabled = true
```

## Requirements

- iOS 13.0+ 
- Xcode 11+

## Installation

### Step 1:

Clone the repo. Open Terminal, go to directory where you want to clone the project, and run:
% `git pull <repo>`

### Step 2:

Install required Pods. Enter project directory and run:
% `pod install`
If the above command fails, then you may need to install cocoapods first.

### Step 3:

Setup Firebase configuration files. Request the team to provide `GoogleService-Info.plist` file for all 4 targets: Debug, Staging, PreRelease and Production.
Move all 4 files in their respected folders located in:
`Telabook/Support Files/Firebase/`

### Step 4:

Setup config values for each environment. Ask team for these secret values for each environment and fill them as per required fields. The config files are located at:
`Telabook/Support Files/Config/`

### Step 5: 

Run the project



## Meta

### Home Page
[https://www.telabook.com](https://www.telabook.com)

### Support Page
[https://www.telabook.com/support](https://www.telabook.com/support)

### Privacy Policy
[https://www.telabook.com/privacy-policy](https://www.telabook.com/privacy-policy)

### Terms of Service
[https://www.telabook.com/terms-and-conditions](https://www.telabook.com/terms-and-conditions)

### Repository
[https://corona.aimservices.tech/telabook/apps/messenger-app-ios](https://corona.aimservices.tech/telabook/apps/messenger-app-ios)

### Copyright
## 2020 BEE RAD TECH LLC

## Developer

[@ArAnmol](https://twitter.com/ArAnmol)

[https://github.com/anmolrajpal](https://github.com/anmolrajpal)


[swift-image]:https://img.shields.io/badge/swift-5.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE.txt

