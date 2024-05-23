## PawsPal 

A pet management app that combines AI to make it easy to record life with your furry babies.

🐾 Download from App store: [PawsPal](https://pawspal.pse.is/downloadfromappstore)

## Introduction

"PawsPal" is an app designed specifically for pet owners, helping you relive the wonderful moments spent with your furry babies. Through advanced AI technology, "PawsPal" provides many convenient features, allowing you to more easily care for and accompany your pets.

## Table of Contents

- [Description](#description)
- [Key Features](#key-features)
- [Getting Started](#getting-started)
- [Architecture](#architecture)
- [Structure](#structure) 
- [Built With](#built-with)
- [Running the Tests](#running-the-tests)
- [Dependencies](#dependencies)
- [Design](#design)
- [API](#api)
- [Contact Me](#contact-me)

## Description

"PawsPal" aims to be a comprehensive pet management app that fills a gap in the market. It provides customized diary, AI-powered diary summary and review, instant pet health consultation, nearby animal hospital finder, and monthly pet activity calendar overview. 📆 These features make it easy for pet owners to record and manage all aspects of their pet's life in one place.

The app leverages the latest AI technologies to provide intelligent assistance. For example, it uses Apple's Journaling Suggestions framework to automatically organize photos and activity records into engaging diary entries. 📚 The built-in AI pet assistant can provide professional, unbiased answers to pet-related questions anytime, anywhere. 🤖

"PawsPal" also focuses on pet health management. It allows tracking important dates like vet appointments, vaccinations, grooming etc. in a calendar. 🗓️ The map feature powered by Google Places API enables quickly finding nearby animal hospitals, pet-friendly places to walk the pet, and pet stores. 🏥

To help pet owners better manage expenses, the app provides spending charts that give a clear overview of monthly costs. 💰 This allows maintaining the pet's quality of life while staying within budget.

## Key Features

![pawspal_diary_calendar_chatbot](https://github.com/kkylelu/chongAiTa/assets/61376338/7307ebc4-9b79-4131-abd5-a5728721eeff)
![Pawspal Stickers Map Chart](https://github.com/kkylelu/chongAiTa/assets/61376338/59dc6fc3-0cda-4d94-b95d-c2a50f55a3bb)

- **AI Diary Summary**: Review lively memories with one click. Diary leverages Apple's latest Journaling Suggestions technology to automatically organize photos and activity records.

- **Calendar Reminders**: Never miss any important events! Record important schedules like weekly grooming, monthly vet follow-ups, so you can accompany your furry baby's growth with peace of mind.  

- **AI Pet Assistant**: Don't worry when encountering pet-related issues, get professional, unbiased answers from the AI pet assistant anytime, anywhere.

- **Nearby Services Map**: Whether urgently looking for a nearby animal hospital, wanting to take your furry baby for a walk, or needing to buy pet supplies, the built-in map uses Google Places technology to immediately provide the nearest options.

- **Spending Charts**: Let you see monthly expenses at a glance, easily maintaining your furry baby's quality of life.

- **Pet Stickers**: You can customize pet stickers, create unique profile pictures by dragging, scaling, and applying filters.

## Getting Started

1. Download "PawsPal" from the App Store.

2. Create your account and log in.

3. Set up your pet's information.

4. Start using various features like diary, calendar, finding nearby services etc.

5. View your pet expenses through charts.

## Architecture

- The project primarily uses the Model-View-Controller (MVC) architecture, with some pages refactored to the Model-View-ViewModel (MVVM) architecture.

- **Model**: Contains necessary data models and business logic.

- **View**: Responsible for presenting the user interface.

- **Controller**: Handles user interactions and updates the Model and View.

- **ViewModel**: Responsible for data processing, transformation, and business logic.

## Structure

- **Extension**: Shared functionality used across different view controllers in the project, such as color conversion, date formatting, loading animation effects, etc.

- **Resources**: Non-code files used by the project, including images, audio files, video files, and other types of assets.

- **Network**: Files or classes related to communicating with external APIs, including code for making HTTP requests, parsing responses, and handling errors.

## Built With

- Utilized the Journaling Suggestions Framework introduced at WWDC23 for personalized diary suggestions.

- Integrated OpenAI API for Chatbot and diary summaries.

- Developed custom calendar instead of using frameworks.

- Implemented expense charts with SwiftUI.

- Refactored architecture from MVC to MVVM for better maintainability and testability.

- Used Google Maps and Places APIs to display user location, nearby animal hospitals and landmarks.

- Integrated Local JSON, Firebase Firestore and Storage for fast data access.

- Reduced photo loading time and storage by 50% through compression techniques.

- Utilized Kingfisher for optimized image loading.

- Adopted FirebaseAuth and Sign in with Apple for secure authentication.

- Applied Lottie animation for enhanced visual appeal and UX.

## Running the Tests

The "PawsPal" project uses the XCTest framework for testing. To start testing:

1. Create a new test target in Xcode and add test files to it.

2. Place test files in the "test" folder, following the project structure.

3. Write test functions using XCTest.

4. Run the tests from Xcode.

## Dependencies

- **Alamofire**: A popular networking library for Swift that simplifies HTTP networking tasks, ensuring reliable communication with servers and APIs. 

- **Firebase**: A comprehensive app development platform provided by Google, offering various services like real-time database, cloud storage, authentication, and more.

- **GoogleAppMeasurement**: A library from Google that provides app measurement and analytics capabilities, helping you understand user behavior and app performance. 

- **GoogleDataTransport**: A Google library that facilitates the batching and transmission of data from client apps to backend servers. 

- **GoogleUtilities**: A set of utilities and helper classes provided by Google for use with their libraries and services. 

## Design

- Design tool are Figma and Canva.

- Link to the design is [Figma](https://www.figma.com/design/ZM1Pz1zPeuHNLdSWU0hR0F/PawsPal-%E5%AF%B5%E6%84%9B%E7%89%A0-App?node-id=408%3A27625&t=dH2VDQxp4MiKv9Dr-1)

## API

- REST API 

- HTTP networking library: Alamofire

## Contact Me

If you have any questions, suggestions or collaboration needs regarding "PawsPal", please contact me through:

Email: hi@kylelu.com 

🔎 Download "[PawsPal](https://pawspal.pse.is/downloadfromappstore)" now and create wonderful memories with your furry babies! 
