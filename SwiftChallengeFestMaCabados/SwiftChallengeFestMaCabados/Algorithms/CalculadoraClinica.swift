//
//  CalculadoraClinica.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//

import Foundation

class CalculadoraClinica {
        
    /// Regla del 500 - Ratio Insulina:Carbohidratos
    /// Fórmula: 500 ÷ dosis total diaria de insulina
    static func calcularRatioIC(insulinaDiaria: Double) -> Double {
        guard insulinaDiaria > 0 else { return 15.0 } // Valor por defecto seguro
        return 500 / insulinaDiaria
    }
    
    /// Regla del 1800 - Factor de Sensibilidad a la Insulina
    /// Indica cuánto baja la glucosa con 1 unidad de insulina
    static func calcularFactorSensibilidad(insulinaDiaria: Double) -> Double {
        guard insulinaDiaria > 0 else { return 50.0 } // Valor por defecto seguro
        return 1800 / insulinaDiaria
    }
    
    /// Estimación de dosis total diaria por peso
    /// Fórmula aproximada: peso en libras ÷ 4
    static func estimarDosisBasePorPeso(pesoKg: Double) -> Double {
        let pesoLibras = pesoKg * 2.20462 // Convertir kg a libras
        return pesoLibras / 4.0
    }
    
    
    /// Ajuste de sensibilidad por edad
    /// Los niños y adolescentes tienen mayor sensibilidad
    /// Los adultos mayores pueden tener resistencia
    static func ajustarPorEdad(edad: Int) -> Double {
        switch edad {
        case 0...12: return 0.85    // Niños: +15% sensibilidad (factor 0.85)
        case 13...17: return 0.9    // Adolescentes: +10% sensibilidad
        case 18...25: return 0.95   // Jóvenes adultos: +5% sensibilidad
        case 26...64: return 1.0    // Adultos: línea base
        case 65...74: return 1.05   // Adultos mayores: -5% sensibilidad
        case 75...Int.max: return 1.1 // Muy mayores: -10% sensibilidad
        default: return 1.0
        }
    }
    
    /// Ajuste circadiano - La sensibilidad varía según la hora del día
    /// Fenómeno del amanecer: resistencia matutina
    /// Mayor sensibilidad en la tarde
    static func ajusteCircadiano(hora: Date) -> Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: hora)
        
        switch hour {
        case 6...8: return 1.3     // Amanecer: resistencia máxima
        case 9...11: return 1.15   // Media mañana: resistencia moderada
        case 12...14: return 1.0   // Mediodía: línea base
        case 15...17: return 0.9   // Tarde: mayor sensibilidad
        case 18...20: return 0.95  // Cena: sensibilidad moderada
        case 21...23: return 1.05  // Noche: ligera resistencia
        case 0...5: return 1.1     // Madrugada: resistencia nocturna
        default: return 1.0
        }
    }
    
    /// Ajuste por índice de masa corporal
    /// El sobrepeso/obesidad aumenta la resistencia a la insulina
    static func ajustePorIMC(imc: Double) -> Double {
        switch imc {
        case ..<16: return 0.9      // Bajo peso severo: +10% sensibilidad
        case 16..<18.5: return 0.95 // Bajo peso: +5% sensibilidad
        case 18.5..<25: return 1.0  // Normal: línea base
        case 25..<30: return 1.1    // Sobrepeso: -10% sensibilidad
        case 30..<35: return 1.2    // Obesidad I: -20% sensibilidad
        case 35..<40: return 1.3    // Obesidad II: -30% sensibilidad
        case 40...: return 1.4      // Obesidad III: -40% sensibilidad
        default: return 1.0
        }
    }
        
    /// Cálculo completo de insulina necesaria para una comida
    /// Incluye insulina para carbohidratos + corrección por glucosa alta
    static func calcularInsulinaParaComida(
        carbohidratos: Double,
        ratioIC: Double,
        glucosaActual: Double,
        glucosaObjetivo: Double,
        factorSensibilidad: Double
    ) -> Double {
        
        // Insulina para carbohidratos
        let insulinaParaCarbos = carbohidratos / ratioIC
        
        // Insulina para corrección (solo si glucosa está alta)
        let diferencia = glucosaActual - glucosaObjetivo
        let corrección = max(0, diferencia / factorSensibilidad)
        
        let totalInsulina = insulinaParaCarbos + corrección
        
        // Redondear a 0.5 unidades (práctica clínica común)
        return round(totalInsulina * 2) / 2
    }
    
    /// Estimación rápida de insulina solo por carbohidratos
    /// Para usuarios sin configuración completa
    static func insulinaEstimadaPorCarbos(carbohidratos: Double, peso: Double) -> Double {
        let dosisEstimada = estimarDosisBasePorPeso(pesoKg: peso)
        let ratioEstimado = calcularRatioIC(insulinaDiaria: dosisEstimada)
        return carbohidratos / ratioEstimado
    }
        
    /// Verifica si una dosis de insulina está en rango seguro
    static func validarDosisSegura(dosis: Double, pesoKg: Double) -> Bool {
        let dosisMaximaSegura = pesoKg * 1.5 // 1.5 U/kg como límite superior
        return dosis <= dosisMaximaSegura && dosis >= 0
    }
    
    /// Categoriza el riesgo de una predicción de glucosa
    static func evaluarRiesgoGlucosa(_ glucosa: Double) -> RiesgoGlucosa {
        switch glucosa {
        case ..<70: return .hipoglucemiaSevera
        case 70..<80: return .hipoglucemiaLeve
        case 80..<140: return .normal
        case 140..<180: return .hiperglucemiaLeve
        case 180..<250: return .hiperglucemiaModerada
        case 250...: return .hiperglucemiaSevera
        default: return .normal
        }
    }
    
    
    /// Convierte glucosa de mg/dL a mmol/L
    static func mgDLToMmolL(_ mgdl: Double) -> Double {
        return mgdl / 18.0
    }
    
    /// Convierte glucosa de mmol/L a mg/dL
    static func mmolLToMgDL(_ mmol: Double) -> Double {
        return mmol * 18.0
    }
}


