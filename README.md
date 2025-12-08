# GymPeople

A social fitness platform that connects gym-goers, helping you find workout partners and build your fitness community.

## Overview

GymPeople is an iOS social networking app designed specifically for fitness enthusiasts. Connect with people at your gym, discover new workout partners, and build a supportive fitness community. Whether you're looking for a gym buddy, exploring new gyms through guest passes, or sharing your fitness journey, GymPeople brings the social aspect back to working out.

## Key Features

### Authentication & Onboarding
- Secure sign-in with Apple and Google OAuth
- Comprehensive onboarding process collecting user information
- Location-based gym discovery and membership setup

<img width="147" height="319" alt="Authentication Screen" src="https://github.com/user-attachments/assets/a6a10042-24e9-41c3-8ffe-6c4f4737e680" />
<img width="147" height="319" alt="Sign In Screen" src="https://github.com/user-attachments/assets/b325dc7b-cf4d-4949-a6eb-9613b8959c48" />
<img width="147" height="319" alt="Welcome Screen" src="https://github.com/user-attachments/assets/904ca384-c97c-4e3c-8299-b4477d3e73cf" />

**Onboarding Flow:**

https://github.com/user-attachments/assets/3b765d55-54f6-4c91-876b-2fbf39423a21

### Gym Membership Verification
- Upload membership documentation for verification
- Verified member badges for enhanced trust and safety
- Support for all major gym chains and local facilities
- Track verification status (unverified, pending, verified)

<img width="147" height="319" alt="Membership Verification" src="https://github.com/user-attachments/assets/6d48b3e2-c800-4125-8a70-948014a9c511" />
<img width="147" height="319" alt="Upload Documents" src="https://github.com/user-attachments/assets/f0eb67f2-f854-4996-b008-8ff8f0e60954" />
<img width="147" height="319" alt="Verification Status" src="https://github.com/user-attachments/assets/43578b63-fa4b-4e87-8b52-0abd58b9fc7d" />

### Social Feed
- Share posts about your gym activities and fitness journey
- Like and comment on posts from people you follow
- Reply to comments with threaded conversations
- Explore feed for discovering new content from nearby users
- Following feed for updates from your connections

<img width="147" height="319" alt="Comments Feature" src="https://github.com/user-attachments/assets/381945f6-3d6a-46cb-8aed-bc8396f5fda5" />

### Discovery
- Find gyms near you with detailed information and member counts
- Discover users at your gym or in your area
- Filter users by location and activity
- View trending gyms based on activity and engagement
- Search for gyms by city or zip code

<img width="147" height="319" alt="Discover Interface" src="https://github.com/user-attachments/assets/b4d34957-717b-41f8-83ac-4bbf075e1cb7" />
<img width="147" height="319" alt="Gym Discovery" src="https://github.com/user-attachments/assets/9f381ceb-c223-453d-9e94-2f165b5e5d5b" />
<img width="147" height="319" alt="User Discovery" src="https://github.com/user-attachments/assets/3f1021df-0435-4ba1-80c5-771a110a1897" />

### User Profiles
- Customizable profiles with profile pictures and bios
- Display gym memberships and verification status
- View user posts and mentions
- Follow/unfollow functionality
- Track followers and following counts
- Profile privacy settings (public/private)

### Home Feed
- Personalized feed showing nearby gyms and users
- Quick actions for finding gym buddies and creating groups
- Location-based recommendations
- Filter users by distance and activity

## What Makes GymPeople Different

**Safety First**
- Gym membership verification ensures authentic users
- Verified badges build trust within the community
- Location-based connections keep interactions relevant

**Universal Compatibility**
- Works with any gym: Planet Fitness, LA Fitness, YMCA, climbing gyms, and more
- Support for independent and chain fitness facilities
- Easy gym switching for users with multiple memberships

**Guest Pass Sharing** (Coming Soon)
- Share guest passes with the community
- Help others try out your gym
- Great for people exploring new fitness facilities

## Tech Stack

### Frontend
- SwiftUI for native iOS development
- Modern MVVM architecture with ListViewModel pattern
- Custom UI components with consistent design system
- Smooth animations and transitions

### Backend
- Supabase for authentication and database
- PostgreSQL for data storage
- Row Level Security for data protection
- Cloudflare R2 for image and document storage

### Key Technologies
- MapKit for gym location services
- PhotosPicker for image uploads
- Async/await for modern Swift concurrency
- Combine for reactive programming

## App Icon

<img width="256" height="256" alt="Light Mode Icon" src="https://github.com/user-attachments/assets/4bd2cdc1-40cd-4e65-8ab1-77ffc52bd08b" />
<img width="256" height="256" alt="Dark Mode Icon" src="https://github.com/user-attachments/assets/e3f9212d-5aad-4338-9759-0d1edfd38432" />

## Roadmap

### In Development
- Direct messaging between users
- Group messaging for workout crews
- Push notifications for new followers and messages
- Guest pass management and sharing system

### Planned Features
- Gym check-ins and activity tracking
- Workout plans and progress sharing
- Event creation for group workouts
- Gym reviews and ratings
- Integration with fitness tracking apps

## Project Structure

```
gympeople/
├── gympeople/              # Main iOS app
│   ├── Views/             # SwiftUI views and components
│   ├── ViewModels/        # View models and business logic
│   ├── Models/            # Data models
│   ├── Services/          # API and service layers
│   └── Utilities/         # Helper functions and extensions
├── supabase_functions/    # Database functions and queries
└── gympeople-storage-upload/  # Cloudflare Worker for R2 uploads
```

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Supabase account for backend services
- Cloudflare account for storage

### Setup
1. Clone the repository
2. Open `gympeople.xcodeproj` in Xcode
3. Configure environment variables in `Info.plist`:
   - SUPABASE_URL
   - SUPABASE_ANON_KEY
   - R2_API_ENDPOINT
   - R2_UPLOAD_SECRET
4. Build and run on simulator or device

## Contributing

GymPeople is currently in active development. Contributions, issues, and feature requests are welcome.

## License

This project is proprietary and not open for public distribution.

## Contact

For questions or feedback, please open an issue in the repository.
