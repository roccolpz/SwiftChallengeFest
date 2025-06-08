//
//  OnboardingConfiguration.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct OnboardingConfiguration {
    
    // MARK: - Steps Configuration
    static let totalSteps = OnboardingStep.allCases.count - 1 // Exclude welcome
    
    // MARK: - Animation Configuration
    static let stepTransitionDuration: Double = 0.3
    static let progressAnimationDuration: Double = 0.5
    static let completionAnimationDuration: Double = 2.0
    
    // MARK: - Validation Rules
    struct ValidationRules {
        static let minNombreLength = 2
        static let maxNombreLength = 50
        static let minEdad = AppConstants.Usuario.edadMinima
        static let maxEdad = AppConstants.Usuario.edadMaxima
        static let minPeso = AppConstants.Usuario.pesoMinimo
        static let maxPeso = AppConstants.Usuario.pesoMaximo
        static let minAltura = AppConstants.Usuario.alturaMinima
        static let maxAltura = AppConstants.Usuario.alturaMaxima
        static let minGlucosaObjetivo = 80.0
        static let maxGlucosaObjetivo = 140.0
        static let minInsulinaBasal = AppConstants.Insulina.basalDiariaMin
        static let maxInsulinaBasal = AppConstants.Insulina.basalDiariaMax
        static let maxAlimentosFrecuentes = 20
        static let maxAlergias = 10
    }
    
    // MARK: - Default Values
    struct DefaultValues {
        static let glucosaObjetivo = 110.0
        static let horarioDesayuno = DateComponents(hour: 8, minute: 0)
        static let horarioComida = DateComponents(hour: 14, minute: 0)
        static let horarioCena = DateComponents(hour: 20, minute: 0)
    }
    
    // MARK: - UI Configuration
    struct UI {
        static let cardPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 24
        static let buttonHeight: CGFloat = 50
        static let progressIndicatorSize: CGFloat = 12
        static let avatarSize: CGFloat = 100
        static let iconSize: CGFloat = 48
    }
    
    // MARK: - Tips and Suggestions
    struct Tips {
        static let datosBasicos = [
            "💡 Usa tu peso actual para cálculos más precisos",
            "📏 La altura nos ayuda a calcular tu IMC",
            "🎂 La edad afecta la sensibilidad a la insulina"
        ]
        
        static let diabetes = [
            "🩺 Si no conoces tu dosis de insulina, consulta con tu médico",
            "🎯 Un objetivo de glucosa típico es 110 mg/dL",
            "📱 Los dispositivos médicos mejoran la precisión"
        ]
        
        static let horarios = [
            "⏰ Horarios regulares mejoran el control glucémico",
            "🌅 El fenómeno del amanecer afecta la glucosa matutina",
            "🌙 Evita cenas muy tardías para mejor descanso"
        ]
        
        static let alimentos = [
            "🍎 Selecciona alimentos que consumes regularmente",
            "⚠️ Las alergias ayudan a filtrar recomendaciones",
            "🥗 Las restricciones dietéticas personalizan la experiencia"
        ]
    }
    
    // MARK: - Error Messages
    struct ErrorMessages {
        static let nombreRequerido = "El nombre es requerido"
        static let nombreMuyCorto = "El nombre debe tener al menos \(ValidationRules.minNombreLength) caracteres"
        static let nombreMuyLargo = "El nombre debe tener menos de \(ValidationRules.maxNombreLength) caracteres"
        static let edadInvalida = "La edad debe estar entre \(ValidationRules.minEdad) y \(ValidationRules.maxEdad) años"
        static let pesoInvalido = "El peso debe estar entre \(ValidationRules.minPeso) y \(ValidationRules.maxPeso) kg"
        static let alturaInvalida = "La altura debe estar entre \(ValidationRules.minAltura) y \(ValidationRules.maxAltura) cm"
        static let glucosaObjetivoInvalida = "La glucosa objetivo debe estar entre \(ValidationRules.minGlucosaObjetivo) y \(ValidationRules.maxGlucosaObjetivo) mg/dL"
        static let insulinaBasalInvalida = "La insulina basal debe estar entre \(ValidationRules.minInsulinaBasal) y \(ValidationRules.maxInsulinaBasal) U"
        static let horarioInconsistente = "Los horarios deben seguir el orden: Desayuno < Comida < Cena"
        static let tiposDiabetesRequerido = "Selecciona el tipo de diabetes"
        static let demasiadosAlimentos = "Máximo \(ValidationRules.maxAlimentosFrecuentes) alimentos frecuentes"
        static let demasiadasAlergias = "Máximo \(ValidationRules.maxAlergias) alergias"
    }
    
    // MARK: - Helper Functions
    
    /// Valida un nombre de usuario
    static func validarNombre(_ nombre: String) -> (isValid: Bool, error: String?) {
        let nombreLimpio = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if nombreLimpio.isEmpty {
            return (false, ErrorMessages.nombreRequerido)
        }
        
        if nombreLimpio.count < ValidationRules.minNombreLength {
            return (false, ErrorMessages.nombreMuyCorto)
        }
        
        if nombreLimpio.count > ValidationRules.maxNombreLength {
            return (false, ErrorMessages.nombreMuyLargo)
        }
        
        return (true, nil)
    }
    
    /// Valida edad
    static func validarEdad(_ edad: Int) -> (isValid: Bool, error: String?) {
        if edad < ValidationRules.minEdad || edad > ValidationRules.maxEdad {
            return (false, ErrorMessages.edadInvalida)
        }
        return (true, nil)
    }
    
    /// Valida peso
    static func validarPeso(_ peso: Double) -> (isValid: Bool, error: String?) {
        if peso < ValidationRules.minPeso || peso > ValidationRules.maxPeso {
            return (false, ErrorMessages.pesoInvalido)
        }
        return (true, nil)
    }
    
    /// Valida altura
    static func validarAltura(_ altura: Double) -> (isValid: Bool, error: String?) {
        if altura < ValidationRules.minAltura || altura > ValidationRules.maxAltura {
            return (false, ErrorMessages.alturaInvalida)
        }
        return (true, nil)
    }
    
    /// Valida glucosa objetivo
    static func validarGlucosaObjetivo(_ glucosa: Double) -> (isValid: Bool, error: String?) {
        if glucosa < ValidationRules.minGlucosaObjetivo || glucosa > ValidationRules.maxGlucosaObjetivo {
            return (false, ErrorMessages.glucosaObjetivoInvalida)
        }
        return (true, nil)
    }
    
    /// Valida insulina basal
    static func validarInsulinaBasal(_ insulina: Double) -> (isValid: Bool, error: String?) {
        if insulina < ValidationRules.minInsulinaBasal || insulina > ValidationRules.maxInsulinaBasal {
            return (false, ErrorMessages.insulinaBasalInvalida)
        }
        return (true, nil)
    }
    
    /// Valida horarios de comida
    static func validarHorarios(desayuno: Date, comida: Date, cena: Date) -> (isValid: Bool, error: String?) {
        let calendar = Calendar.current
        let desayunoHour = calendar.component(.hour, from: desayuno)
        let comidaHour = calendar.component(.hour, from: comida)
        let cenaHour = calendar.component(.hour, from: cena)
        
        if !(desayunoHour < comidaHour && comidaHour < cenaHour) {
            return (false, ErrorMessages.horarioInconsistente)
        }
        
        return (true, nil)
    }
    
    /// Obtiene fecha por defecto para horario
    static func fechaPorDefecto(para componentes: DateComponents) -> Date {
        return Calendar.current.date(from: componentes) ?? Date()
    }
    
    /// Calcula progreso del onboarding
    static func calcularProgreso(step actual: OnboardingStep) -> Double {
        guard actual != .bienvenida else { return 0.0 }
        
        let stepIndex = actual.rawValue - 1 // Exclude welcome step
        return Double(stepIndex) / Double(totalSteps)
    }
    
    /// Determina si un paso requiere configuración especial
    static func requiereConfiguracionEspecial(step: OnboardingStep, perfil: PerfilUsuario) -> Bool {
        switch step {
        case .diabetes:
            return perfil.esDiabetico
        default:
            return false
        }
    }
    
    /// Obtiene tip aleatorio para un paso
    static func tipAleatorio(para step: OnboardingStep) -> String? {
        let tips: [String]
        
        switch step {
        case .datosBasicos:
            tips = Tips.datosBasicos
        case .diabetes:
            tips = Tips.diabetes
        case .horarios:
            tips = Tips.horarios
        case .alimentos:
            tips = Tips.alimentos
        default:
            return nil
        }
        
        return tips.randomElement()
    }
}

// MARK: - Onboarding Analytics (for future implementation)
struct OnboardingAnalytics {
    static func trackStepCompleted(_ step: OnboardingStep) {
        // TODO: Implement analytics tracking
        print("📊 Onboarding step completed: \(step)")
    }
    
    static func trackStepStarted(_ step: OnboardingStep) {
        // TODO: Implement analytics tracking
        print("📊 Onboarding step started: \(step)")
    }
    
    static func trackOnboardingCompleted(timeSpent: TimeInterval) {
        // TODO: Implement analytics tracking
        print("📊 Onboarding completed in \(timeSpent) seconds")
    }
    
    static func trackValidationError(_ error: String, step: OnboardingStep) {
        // TODO: Implement analytics tracking
        print("📊 Validation error in \(step): \(error)")
    }
}