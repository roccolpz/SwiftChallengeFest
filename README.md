<img src="Images/banner.png" alt="banner" width="100%">
<a id="readme-top"></a>
<h1 align="center"> GlucoPredict - Intelligent Glucose Predictor </h1>
<div align="center">
  <a href="https://github.com/tu-usuario/GlucoPredict">
    <img src="Images/logo.png" alt="Logo" width="120" height="120">
  </a>

  <p align="center">
    A native iOS application developed in SwiftUI that helps people with diabetes predict and control their glucose levels using artificial intelligence and algorithms based on clinical studies.
    <br />
    <a href="#demo-video">View Demo</a>
    ·
    <a href="#screenshots">Project Screenshots</a>
    ·
    <a href="#features">Features</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#key-features">Key Features</a></li>
      </ul>
    </li>
    <li><a href="#screenshots">Screenshots</a></li>
    <li><a href="#demo-video">Demo Video</a></li>
    <li><a href="#detailed-features">Detailed Features</a></li>
    <li><a href="#authors">Authors</a></li>
    <li><a href="#clinical-validation">Clinical Validation</a></li>
    <li><a href="#disclaimers">Disclaimers</a></li>
  </ol>
</details>

---

<!-- ABOUT THE PROJECT -->
## About The Project

GlucoPredict is an innovative iOS application designed specifically for people with diabetes seeking better control of their glucose levels. Using algorithms based on clinical studies and machine learning, the app predicts how different foods and meal orders will affect postprandial glucose levels.

### Problem it solves
- **37% reduction**  in glucose spikes through optimized food ordering
- **Accurate predictions** of glucose before eating
- **Inteligent meal planning** with personalized recommendations
- **Automatic calculation** of insulin doses

<a id="built-with"></a>
### Build witth
- [![Swift](https://img.shields.io/badge/Swift-F54A2A?logo=swift&logoColor=white)](#)
- [![SwiftUI](https://img.shields.io/badge/SwiftUI-42C8F4?logo=swift&logoColor=white)](#)
- [![CoreML](https://img.shields.io/badge/CoreML-0A84FF?logo=swift&logoColor=white)](#)
- [![Charts](https://img.shields.io/badge/Swift_Charts-FF6B35?logo=swift&logoColor=white)](#)
- [![UserDefaults](https://img.shields.io/badge/UserDefaults-34C759?logo=swift&logoColor=white)](#)
- [![JSON](https://img.shields.io/badge/JSON-000000?logo=json&logoColor=white)](#)

<a id="key-features"></a>
### Key Features

🩸 **Glucose Predictor**
- Predictions based on clinical algorithms
- Analysis of 1,000+ foods
- Personalized factors (age, BMI, diabetes type)

🍽️ **Optimized Meal Order**
- Vegetables first: up to 37% less glucose spike
- Recommendations based on scientific studies
- Visual comparison of different orders

📊 **Intelligent Tracking**
- Interactive prediction graphs
- Meal history and effectiveness
- Personalized statistics

🤖 **AI-Powered Meal Planner**
- Personalized weekly plans
- Automatic shopping list
- Specific nutritional tips

💉 **Insulin Calculator**
- Personalized I:C ratios
- Automatic sensitivity factor
- Safe dose recommendations

---
<a id="screenshots"></a>
### Screenshots 

### Onboarding
<div align="center">
  <img src="Images/OB1.PNG" alt="Onboarding" width="120"/>
  <img src="Images/OB2.PNG" alt="Onboarding" width="120"/>
  <img src="Images/OB3.PNG" alt="Onboarding" width="120"/>
  <img src="Images/OB4.PNG" alt="Onboarding" width="120"/>
  <img src="Images/OB5.PNG" alt="Onboarding" width="120"/>
  <img src="Images/OB6.PNG" alt="Onboarding" width="120"/>
  <img src="Images/OB7.PNG" alt="Onboarding" width="120"/>
</div>

### Dashboard
<div align="center">
  <img src="Images/Dashboard1.PNG" alt="QuickActions" width="120"/>
  <img src="Images/Dashboard4.PNG" alt="Update Glucose" width="120"/>
  <img src="Images/Dashboard2.PNG" alt="GlucoseTracker and Predict Glucose" width="120"/>
  <img src="Images/Dashboard3.PNG" alt="Recent Meals and day summary" width="120"/>
</div>

### Glucose Predictor
<div align="center">
  <img src="Images/GP1.PNG" alt="Glucose Predictor" width="120"/>
  <img src="Images/GP2.PNG" alt="Glucose Predictor" width="120"/>
  <img src="Images/GP3.PNG" alt="Glucose Predictor" width="120"/>
  <img src="Images/GP4.PNG" alt="Glucose Predictor" width="120"/>
  <img src="Images/GP5.PNG" alt="Glucose Predictor" width="120"/>  
</div>

### Recent Meals & Meal Planner
<div align="center">
  <img src="Images/RM.PNG" alt="Recent Meals" width="120"/>
  <img src="Images/MP1.PNG" alt="Meal Planner" width="120"/>
  <img src="Images/MP2.PNG" alt="Meal Planner" width="120"/>
  <img src="Images/MP3.PNG" alt="Meal Planner" width="120"/>
</div>

### Noticias y Perfil
<div align="center">
  <img src="Images/News.PNG" alt="News" width="120"/>
  <img src="Images/Profile1.PNG" alt="Profile1" width="120"/>
  <img src="Images/Profile2.PNG" alt="Profile2" width="120"/>
</div>

---
<a id="demo-video"></a>
## Demo Video

Watch the application in action!
[![GlucoPredict Demo](https://img.youtube.com/vi/YOUR_VIDEO_ID/0.jpg)](https://youtu.be/YOUR_VIDEO_ID)

Click on the image on [aquí](https://youtu.be/YOUR_VIDEO_ID) to view the demonstration.

---
<a id="detailed-features"></a>
## Detailed Features

### 🩸 Advanced Glucose Predictor
The heart of the application uses algorithms based on clinical studies to predict glucose levels:

- **Meal Order Algorithm**: Implementa findings de estudios que muestran reducciones de 17-37% en picos de glucosa
- **Circadian Factors**: Adjusts predictions based on time of day (dawn phenomenon)
- **User Personalization**: Considers age, BMI, diabetes type, and medications
- **Nutritional Database**: Over 1,000 foods with glycemic index and glycemic load

### 📊 Interactive Visualization

- **Prediction Graphs**: Real-time predicted glucose curves
- **Order Comparison**: Side-by-side visualization of different sequences
- **Ingelligent History**: Tracking effectiveness of previous predictions

### 🤖 Personalized Meal Planner

The meal planner uses structured JSON to generate:

- **Weekly Planss**: Breakfast, snacks, lunch, afternoon snack, and dinnerc
- **Nutritional Balance**: Optimized for glycemic control
- **Shopping List**: Automatically generated by frequency of use
- **Personalized Tips**: Based on user profile

<a id="authors"></a>
## Authors 
### MacAbados team 🦧

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/IsaacRoSosa">
        <img src="https://avatars.githubusercontent.com/IsaacRoSosa" width="100px;" alt=""/>
        <br /><sub><b>Isaac Rojas </b></sub>
      </a>
      <br />
      <a style="padding-top: 40px;" href="https://github.com/IsaacRoSosa" title="GitHub"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"></a>
      <a href="https://www.linkedin.com/in/isaacrojassosa/" title="LinkedIn"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a>
    </td> 
    <td align="center">
      <a href="https://github.com/santiagosauma">
        <img src="https://avatars.githubusercontent.com/santiagosauma" width="100px;" alt=""/>
        <br /><sub><b>Luis Santiago Sauma</b></sub>
      </a>
      <br />
      <a style="padding-top: 40px;" href="https://github.com/santiagosauma" title="GitHub"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"></a>
      <a href="https://www.linkedin.com/in/santiagosauma/" title="LinkedIn"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a>
    </td>
      <td align="center">
      <a href="https://github.com/roccolpz">
        <img src="https://avatars.githubusercontent.com/roccolpz" width="100px;" alt=""/>
        <br /><sub><b>Rodrigo López</b></sub>
      </a>
      <br />
      <a style="padding-top: 40px;" href="https://github.com/roccolpz" title="GitHub"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"></a>
      <a href="https://www.linkedin.com/in/rodrigo-l%C3%B3pez-murgu%C3%ADa-6240761b8/" title="LinkedIn"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a>
    </td>
      </td>
      <td align="center">
      <a href="https://github.com/RodrigoGarciaT">
        <img src="https://avatars.githubusercontent.com/RodrigoGarciaT" width="100px;" alt=""/>
        <br /><sub><b>Rodrigo Garcia</b></sub>
      </a>
      <br />
      <a style="padding-top: 40px;" href="https://github.com/LeoPeque" title="GitHub"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"></a>
      <a href="https://www.linkedin.com/in/rodrigo-garcia-torres/" title="LinkedIn"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"></a>
    
    
  </tr>
</table>

<a id="clinical-validation"></a>
## Validación Clínica

### Base Studies

The application is based on peer-reviewed research:

1. **Shukla et al. (2015)** - Diabetes Care
  - 37% reduction in glucose peak with vegetables first
  - Study with 16 participants with type 2 diabetes

2. **Shukla et al. (2016)** - Diabetes Care
  - 20% reduction in postprandial insulin
  - Protocol: Vegetables/proteins → wait 15 min → carbohydrates

3. **Imai et al. (2013)** - European Journal of Clinical Nutrition
  - Validation in Japanese population
  - Confirmation of effects across different ethnicities

<a id="disclaimers"></a>
### Limitaciones y Disclaimers

⚠️ **Importante**:
- This app is an **educational tool**, not a medical device
- Predictions are **estimates** based on population averages
- **Always consult** with your medical team before treatment changes
- **Does not replace** actual glucose measurement
---

[🔼 Back to top](#readme-top)


