# CompGenie - Flutter App

A comprehensive Flutter application for CompGenie featuring authentication screens and sensor monitoring dashboard.

## Features

- **Complete Authentication Flow**: Login and signup screens with seamless navigation
- **Sensor Dashboard**: Real-time monitoring of environmental sensors and air quality
- **Custom Components**: Reusable UI components with consistent design language
- **Interactive Elements**: Password visibility toggles, status indicators, trend analysis
- **Responsive Design**: Optimized for mobile devices with Material Design principles

## Project Structure

```
lib/
├── main.dart                     # App entry point
├── screens/
│   ├── login_screen.dart         # User authentication screen
│   ├── signup_screen.dart        # User registration screen
│   └── sensor_values_screen.dart # Sensor monitoring dashboard
└── widgets/
    ├── custom_input_field.dart   # Custom input field component
    ├── custom_button.dart        # Custom button component
    ├── custom_checkbox.dart      # Custom checkbox component
    ├── sensor_card.dart          # Sensor data display card
    └── status_indicator.dart     # System status indicator
```

## Screens Overview

### Authentication Screens

#### Login Screen
- Username/email input field with pre-filled example
- Password input with visibility toggle
- Remember me checkbox functionality
- Forgot password link with gradient styling
- Navigation to signup screen
- Custom gradient button design

#### Signup Screen
- Complete registration form with validation-ready structure
- First name, last name, email, password, and confirm password fields
- Password visibility toggles for both password fields
- Terms & Conditions agreement with styled rich text
- Navigation back to login screen
- Consistent design language with login screen

### Dashboard Screen

#### Sensor Values Screen
- **System Status Overview**: Real-time status indicator with last update timestamp
- **Environmental Sensors**: Temperature, humidity, atmospheric pressure, and light levels
- **Air Quality Monitoring**: CO₂, PM2.5, VOC, and ozone measurements
- **Motion & Sound Detection**: Activity monitoring and sound level tracking
- **Trend Analysis**: Visual indicators showing data trends with color-coded arrows
- **Action Buttons**: Export data and view history functionality
- **Refresh Capability**: Manual data refresh option

## Key Components

### Authentication Components

#### CustomInputField
- Consistent styling across all forms
- Label and input text with proper typography
- Optional suffix icon support (password visibility)
- Rounded corners with subtle background

#### CustomButton
- Gradient background (#0D986A to #0B8A5F)
- Custom shadow effects for depth
- Ripple effect on interaction
- Consistent padding and border radius

#### CustomCheckbox
- Custom styling matching brand colors
- Shadow effects and border styling
- Check mark icon with smooth transitions
- Proper touch targets for accessibility

### Dashboard Components

#### SensorCard
- **Flexible Data Display**: Shows sensor readings with units and trends
- **Color-Coded Icons**: Each sensor type has a unique color and icon
- **Trend Indicators**: Up/down/stable arrows with color coding
- **Comparison Data**: Shows change vs. last hour
- **Responsive Layout**: Adapts to different screen sizes

#### StatusIndicator
- **Real-time Status**: Online/offline system status
- **Color-Coded Badges**: Green for online, red for offline
- **Animated Dot**: Pulsing indicator for active status
- **Compact Design**: Minimal space usage

## Sensor Data Types

### Environmental Sensors
- **Temperature**: Celsius readings with trend analysis
- **Humidity**: Percentage readings with change indicators
- **Pressure**: Atmospheric pressure in hPa
- **Light**: Ambient light levels in lux

### Air Quality Sensors
- **CO₂**: Carbon dioxide levels in ppm
- **PM2.5**: Particulate matter concentration
- **VOC**: Volatile organic compounds in ppb
- **Ozone**: Ground-level ozone measurements

### Activity Sensors
- **Motion**: Binary activity detection
- **Sound**: Decibel level monitoring

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation
1. Clone or download this Flutter project
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```

### Assets Setup
Create the following directory structure and add assets:

```
assets/
├── images/
│   ├── rectangle-495.png          # Header background image
│   └── greengenielogocropped-1.png # CompGenie logo
└── fonts/
    ├── Poppins-Regular.ttf
    ├── Poppins-Medium.ttf
    ├── Poppins-SemiBold.ttf
    ├── Roboto-Regular.ttf
    ├── Roboto-Bold.ttf
    └── Quicksand-Bold.ttf
```

### Running the App
```bash
flutter run
```

## Navigation Flow

The app implements a complete navigation system:
- **Login ↔ Signup**: Seamless authentication flow
- **Login → Dashboard**: After successful authentication
- **Dashboard → Back**: Return to previous screen

## Design System

### Color Palette
- **Primary Green**: `#0D986A` (buttons, accents)
- **Secondary Green**: `#159148` (logo, highlights)
- **Accent Green**: `#98C13F` (logo, special text)
- **Background**: `#F5F5F5` (input fields)
- **Text Colors**: Various shades for hierarchy
- **Sensor Colors**: Unique colors for each sensor type

### Typography
- **Poppins**: Primary font for UI elements, headings, body text
- **Roboto**: Secondary font for specific elements
- **Quicksand**: Logo and brand text

### Spacing System
- Consistent 8px grid system
- Proper padding and margins throughout
- Responsive spacing for different screen sizes

## State Management

### Local State Management
- `StatefulWidget` for screen-level state
- Text controllers for form inputs
- Boolean states for toggles and checkboxes
- Real-time sensor data updates

### Future Enhancements
- State management with Provider/Bloc
- API integration for real sensor data
- Local storage for user preferences
- Push notifications for alerts

## Data Integration

### Sensor Data Structure
The app is designed to handle real sensor data with:
- Real-time updates via WebSocket or polling
- Historical data storage and retrieval
- Trend calculation and analysis
- Alert thresholds and notifications

### API Ready
- Structured for easy API integration
- Error handling and loading states
- Data validation and sanitization
- Offline capability planning

## Customization

### Sensor Configuration
- Easy addition of new sensor types
- Configurable alert thresholds
- Custom color schemes per sensor
- Flexible unit conversions

### UI Theming
- Consistent design tokens
- Easy color scheme modifications
- Responsive breakpoints
- Dark mode ready structure

## Future Features

### Authentication Enhancements
- Biometric authentication
- Social login integration
- Password strength validation
- Email verification flow

### Dashboard Features
- Interactive charts and graphs
- Historical data visualization
- Custom alert configuration
- Data export in multiple formats
- Sharing and collaboration features

### Advanced Monitoring
- Predictive analytics
- Machine learning insights
- Automated reporting
- Integration with IoT platforms