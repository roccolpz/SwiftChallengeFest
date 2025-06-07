//
//  AlgoritmoOrdenComida.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
//

import Foundation

class AlgoritmoOrdenComida {
        
    /// Calcula el factor de reducción de glucosa basado en el orden de comida
    /// Basado en estudios clínicos que muestran reducciones de 17-37% con verduras primero
    static func calcularFactorOrden(_ orden: OrdenComida, _ macros: Macronutrientes) -> Double {
        
        // Si no hay carbohidratos significativos, el orden no importa tanto
        guard macros.carbohidratos > 5.0 else { return 1.0 }
        
        switch orden {
        case .verdurasPrimero:
            return calcularFactorVerdurasPrimero(macros)
            
        case .proteinasPrimero:
            return calcularFactorProteinasPrimero(macros)
            
        case .carbohidratosPrimero:
            return calcularFactorCarbohidratosPrimero(macros)
            
        case .simultaneo:
            return 1.0 // Factor neutro - línea base
        }
    }
        
    /// Verduras primero: El método más efectivo
    /// Estudios muestran reducciones de 17-37% en picos de glucosa
    private static func calcularFactorVerdurasPrimero(_ macros: Macronutrientes) -> Double {
        
        // Base: 25% de reducción promedio
        var factor = 0.75
        
        // Mayor reducción si hay más fibra (verduras)
        let ratioFibra = macros.fibra / max(macros.carbohidratos, 1.0)
        let bonusFibra = min(0.15, ratioFibra * 0.3) // Hasta 15% adicional
        factor -= bonusFibra
        
        // Mayor reducción si hay más proteínas
        let ratioProteina = macros.proteinas / max(macros.carbohidratos, 1.0)
        let bonusProteina = min(0.1, ratioProteina * 0.2) // Hasta 10% adicional
        factor -= bonusProteina
        
        // Límite mínimo: máximo 40% de reducción
        return max(0.6, factor)
    }
    
    /// Proteínas primero: Efectivo pero menos que verduras
    /// Reduce picos alrededor de 10-20%
    private static func calcularFactorProteinasPrimero(_ macros: Macronutrientes) -> Double {
        
        // Base: 15% de reducción
        var factor = 0.85
        
        // Mayor efecto si hay buena cantidad de proteínas
        let ratioProteina = macros.proteinas / max(macros.carbohidratos, 1.0)
        if ratioProteina > 0.3 { // Más de 30% proteínas vs carbos
            factor -= 0.05 // 5% adicional
        }
        
        // Menor efecto si hay pocas proteínas
        if macros.proteinas < 10.0 {
            factor += 0.05 // Reduce beneficio
        }
        
        return max(0.75, factor)
    }
    
    /// Carbohidratos primero: El peor orden posible
    /// Puede aumentar picos hasta 15-25%
    private static func calcularFactorCarbohidratosPrimero(_ macros: Macronutrientes) -> Double {
        
        // Base: 20% de aumento
        var factor = 1.2
        
        // Peor si son carbohidratos refinados (poca fibra)
        let ratioFibra = macros.fibra / max(macros.carbohidratos, 1.0)
        if ratioFibra < 0.05 { // Menos de 5% fibra
            factor += 0.1 // 10% adicional de aumento
        }
        
        // Mejor si hay proteínas que ayuden
        let ratioProteina = macros.proteinas / max(macros.carbohidratos, 1.0)
        if ratioProteina > 0.4 {
            factor -= 0.05 // 5% menos aumento
        }
        
        return min(1.3, factor) // Máximo 30% de aumento
    }
        
    /// Analiza si una comida es adecuada para diferentes órdenes
    static func analizarComposicionComida(_ macros: Macronutrientes) -> AnalisisComposicion {
        
        let totalMacros = macros.carbohidratos + macros.proteinas + macros.grasas
        
        let porcentajeCarbos = (macros.carbohidratos / totalMacros) * 100
        let porcentajeProteinas = (macros.proteinas / totalMacros) * 100
        let porcentajeGrasas = (macros.grasas / totalMacros) * 100
        let ratioFibra = macros.fibra / max(macros.carbohidratos, 1.0)
        
        return AnalisisComposicion(
            porcentajeCarbohidratos: porcentajeCarbos,
            porcentajeProteinas: porcentajeProteinas,
            porcentajeGrasas: porcentajeGrasas,
            ratioFibraCarbohidratos: ratioFibra,
            recomendacionOrden: obtenerMejorOrden(macros),
            beneficioMaximo: calcularBeneficioMaximo(macros)
        )
    }
    
    /// Determina el mejor orden para una composición específica
    private static func obtenerMejorOrden(_ macros: Macronutrientes) -> OrdenComida {
        
        // Si hay poca fibra y muchos carbos: verduras primero es crítico
        let ratioFibra = macros.fibra / max(macros.carbohidratos, 1.0)
        if macros.carbohidratos > 30 && ratioFibra < 0.1 {
            return .verdurasPrimero
        }
        
        // Si hay muchas proteínas: proteínas primero puede ser bueno
        let ratioProteina = macros.proteinas / max(macros.carbohidratos, 1.0)
        if ratioProteina > 0.5 {
            return .proteinasPrimero
        }
        
        // Por defecto: verduras primero (siempre beneficioso)
        return .verdurasPrimero
    }
    
    /// Calcula el beneficio máximo posible con el mejor orden
    private static func calcularBeneficioMaximo(_ macros: Macronutrientes) -> Double {
        let factorVerduras = calcularFactorVerdurasPrimero(macros)
        let factorProteinas = calcularFactorProteinasPrimero(macros)
        
        let mejorFactor = min(factorVerduras, factorProteinas)
        return (1.0 - mejorFactor) * 100 // Porcentaje de reducción
    }
        
    /// Genera recomendaciones específicas basadas en la comida
    static func generarRecomendaciones(_ macros: Macronutrientes) -> [RecomendacionOrden] {
        
        var recomendaciones: [RecomendacionOrden] = []
        
        // Análisis de carbohidratos
        if macros.carbohidratos > 45 {
            recomendaciones.append(.carbohidratosAltos)
        }
        
        // Análisis de fibra
        let ratioFibra = macros.fibra / max(macros.carbohidratos, 1.0)
        if ratioFibra < 0.05 {
            recomendaciones.append(.pocaFibra)
        } else if ratioFibra > 0.15 {
            recomendaciones.append(.altaFibra)
        }
        
        // Análisis de proteínas
        if macros.proteinas > 25 {
            recomendaciones.append(.altasProteinas)
        } else if macros.proteinas < 10 {
            recomendaciones.append(.pocasProteinas)
        }
        
        // Recomendación general
        recomendaciones.append(.ordenGeneral)
        
        return recomendaciones
    }
}

struct AnalisisComposicion {
    let porcentajeCarbohidratos: Double
    let porcentajeProteinas: Double
    let porcentajeGrasas: Double
    let ratioFibraCarbohidratos: Double
    let recomendacionOrden: OrdenComida
    let beneficioMaximo: Double // Porcentaje de reducción posible
}
