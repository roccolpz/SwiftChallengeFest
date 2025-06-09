<img src="Images/banner.png" alt="banner" width="100%">
<a id="readme-top"></a>
<h1 align="center">GlucoPredict - Predictor de Glucosa Inteligente</h1>
<div align="center">
  <a href="https://github.com/tu-usuario/GlucoPredict">
    <img src="Images/logo.png" alt="Logo" width="120" height="120">
  </a>

  <p align="center">
    Una aplicación iOS nativa desarrollada en SwiftUI que ayuda a personas con diabetes a predecir y controlar sus niveles de glucosa mediante inteligencia artificial y algoritmos basados en estudios clínicos.
    <br />
    <a href="#demo-video">Ver Demo</a>
    ·
    <a href="#screenshots">Capturas del Proyecto</a>
    ·
    <a href="#features">Características</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Tabla de Contenidos</summary>
  <ol>
    <li>
      <a href="#about-the-project">Acerca del Proyecto</a>
      <ul>
        <li><a href="#built-with">Tecnologías Utilizadas</a></li>
        <li><a href="#features">Características Principales</a></li>
      </ul>
    </li>
    <li><a href="#screenshots">Screenshots</a></li>
    <li><a href="#demo-video">Video Demostración</a></li>
    <li><a href="#features-detail">Características Detalladas</a></li>
    <li><a href="#authors">Autores</a></li>
    <li><a href="#features-detail">Validación Clinica</a></li>
    <li><a href="#features-detail">Disclaimers</a></li>
  </ol>
</details>

---

<!-- ABOUT THE PROJECT -->
## Acerca del Proyecto

GlucoPredict es una aplicación iOS innovadora diseñada específicamente para personas con diabetes que buscan un mejor control de sus niveles de glucosa. Utilizando algoritmos basados en estudios clínicos y machine learning, la app predice cómo diferentes alimentos y órdenes de comida afectarán los niveles de glucosa postprandial.

### Problema que Resuelve
- **37% de reducción** en picos de glucosa mediante el orden optimizado de alimentos
- **Predicciones precisas** de glucosa antes de comer
- **Planificación inteligente** de comidas personalizadas
- **Cálculo automático** de dosis de insulina

### Tecnologías Utilizadas

- [![Swift](https://img.shields.io/badge/Swift-F54A2A?logo=swift&logoColor=white)](#)
- [![SwiftUI](https://img.shields.io/badge/SwiftUI-42C8F4?logo=swift&logoColor=white)](#)
- [![CoreML](https://img.shields.io/badge/CoreML-0A84FF?logo=swift&logoColor=white)](#)
- [![Charts](https://img.shields.io/badge/Swift_Charts-FF6B35?logo=swift&logoColor=white)](#)
- [![UserDefaults](https://img.shields.io/badge/UserDefaults-34C759?logo=swift&logoColor=white)](#)
- [![JSON](https://img.shields.io/badge/JSON-000000?logo=json&logoColor=white)](#)

### Características Principales

🩸 **Predictor de Glucosa**
- Predicciones basadas en algoritmos clínicos
- Análisis de 1,000+ alimentos
- Factores personalizados (edad, IMC, tipo de diabetes)

🍽️ **Orden Optimizado de Comida**
- Verduras primero: hasta 37% menos pico de glucosa
- Recomendaciones basadas en estudios científicos
- Comparación visual de diferentes órdenes

📊 **Seguimiento Inteligente**
- Gráficas interactivas de predicción
- Historial de comidas y efectividad
- Estadísticas personalizadas

🤖 **Meal Planner con IA**
- Planes semanales personalizados
- Lista de compras automática
- Tips nutricionales específicos

💉 **Calculadora de Insulina**
- Ratios I:C personalizados
- Factor de sensibilidad automático
- Recomendaciones de dosis seguras

---
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
  <img src="Images/Dashboard1.PNG" alt="QuickActions" width="180"/>
  <img src="Images/Dashboard2.PNG" alt="GlucoseTracker and Predict Glucose" width="180"/>
  <img src="Images/Dashboard3.PNG" alt="Recent Meals and day summary" width="180"/>
</div>

### Predictor de Glucosa
<div align="center">
  <img src="Images/food_selector.png" alt="Selector de Alimentos" width="250"/>
  <img src="Images/selected_foods.png" alt="Alimentos Seleccionados" width="250"/>
  <img src="Images/prediction_graph.png" alt="Gráfica de Predicción" width="250"/>
</div>

### Orden de Comida y Comparación
<div align="center">
  <img src="Images/meal_order.png" alt="Orden de Comida" width="250"/>
  <img src="Images/order_comparison.png" alt="Comparación de Órdenes" width="250"/>
  <img src="Images/scientific_studies.png" alt="Estudios Científicos" width="250"/>
</div>

### Meal Planner
<div align="center">
  <img src="Images/meal_planner.png" alt="Planificador de Comidas" width="250"/>
  <img src="Images/weekly_plan.png" alt="Plan Semanal" width="250"/>
  <img src="Images/shopping_list.png" alt="Lista de Compras" width="250"/>
</div>

### Noticias y Perfil
<div align="center">
  <img src="Images/diabetes_news.png" alt="Noticias sobre Diabetes" width="250"/>
  <img src="Images/user_profile.png" alt="Perfil de Usuario" width="250"/>
</div>

---

## Demo Video

¡Mira la aplicación en acción!  
[![GlucoPredict Demo](https://img.youtube.com/vi/YOUR_VIDEO_ID/0.jpg)](https://youtu.be/YOUR_VIDEO_ID)

Haz clic en la imagen o [aquí](https://youtu.be/YOUR_VIDEO_ID) para ver la demostración.

---

## Características Detalladas

### 🩸 Predictor de Glucosa Avanzado

El corazón de la aplicación utiliza algoritmos basados en estudios clínicos para predecir niveles de glucosa:

- **Algoritmo de Orden de Comida**: Implementa findings de estudios que muestran reducciones de 17-37% en picos de glucosa
- **Factores Circadianos**: Ajusta predicciones según la hora del día (fenómeno del amanecer)
- **Personalización por Usuario**: Considera edad, IMC, tipo de diabetes y medicamentos
- **Base de Datos Nutricional**: Más de 1,000 alimentos con índice glicémico y carga glicémica

### 📊 Visualización Interactiva

- **Gráficas de Predicción**: Curvas de glucosa predichas en tiempo real
- **Comparación de Órdenes**: Visualización lado a lado de diferentes secuencias
- **Historial Inteligente**: Tracking de efectividad de predicciones anteriores

### 🤖 Meal Planner Personalizado

El planificador de comidas utiliza JSON estructurado para generar:

- **Planes Semanales**: Desayuno, snacks, comida, merienda y cena
- **Balance Nutricional**: Optimizado para control glucémico
- **Lista de Compras**: Generada automáticamente por frecuencia de uso
- **Tips Personalizados**: Basados en el perfil del usuario



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

## Validación Clínica

### Estudios Base

La aplicación se fundamenta en investigación peer-reviewed:

1. **Shukla et al. (2015)** - Diabetes Care
  - 37% reducción en pico glucémico con verduras primero
  - Estudio con 16 participantes con diabetes tipo 2

2. **Shukla et al. (2016)** - Diabetes Care
  - 20% reducción en insulina postprandial
  - Protocolo: Verduras/proteínas → esperar 15 min → carbohidratos

3. **Imai et al. (2013)** - European Journal of Clinical Nutrition
  - Validación en población japonesa
  - Confirmación de efectos en diferentes etnias


### Limitaciones y Disclaimers

⚠️ **Importante**:
- Esta app es una **herramienta educativa**, no un dispositivo médico
- Las predicciones son **estimaciones** basadas en promedios poblacionales
- **Siempre consulta** con tu equipo médico antes de cambios en tratamiento
- **No reemplaza** la medición real de glucosa


---

[🔼 Back to top](#readme-top)


