//
//  PredictorGlucosa.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation

class PredictorGlucosa {
    
    func predecirGlucosa(
        alimentos: [AlimentoConPorcion],
        usuario: PerfilUsuario,
        glucosaActual: Double,
        horaComida: Date = Date(),
        ordenComida: OrdenComida = .simultaneo
    ) -> PrediccionGlucosa {
        
        // 1. Calcular macronutrientes
        let macros = Macronutrientes(alimentos: alimentos)
        
        // 2. Calcular carga glicémica total
        let cargaTotal = calcularCargaGlicemica(alimentos)
        
        // 3. Aplicar ajustes personalizados
        let factorEdad = CalculadoraClinica.ajustarPorEdad(edad: usuario.edad)
        let factorHora = CalculadoraClinica.ajusteCircadiano(hora: horaComida)
        let factorIMC = calcularAjustePorIMC(usuario.imc)
        
        // 4. Predicción base
        let subidaBase = calcularSubidaBase(
            cargaGlicemica: cargaTotal,
            fibra: macros.fibra
        )
        
        // 5. Aplicar factores
        let subidaAjustada = subidaBase * factorEdad * factorHora * factorIMC
        
        // 6. Aplicar beneficios del orden
        let factorOrden = AlgoritmoOrdenComida.calcularFactorOrden(ordenComida, macros)
        let subidaFinal = subidaAjustada * factorOrden
        
        // 7. Generar curva temporal
        let curva = generarCurvaPrediccion(
            glucosaInicial: glucosaActual,
            subidaMaxima: subidaFinal,
            ordenComida: ordenComida
        )
        
        // 8. Calcular insulina si es diabético
        var insulinaNecesaria: Double? = nil
        if usuario.esDiabetico, let ratio = usuario.ratioIC {
            insulinaNecesaria = CalculadoraClinica.calcularInsulinaParaComida(
                carbohidratos: macros.carbohidratos,
                ratioIC: ratio,
                glucosaActual: glucosaActual,
                glucosaObjetivo: usuario.glucosaObjetivo ?? 110,
                factorSensibilidad: usuario.factorSensibilidad ?? 50
            )
        }
        
        // 9. Generar recomendaciones
        let recomendaciones = generarRecomendaciones(
            pico: curva.max { $0.glucosa < $1.glucosa }!,
            usuario: usuario,
            ordenActual: ordenComida
        )
        
        return PrediccionGlucosa(
            curvaPrediccion: curva,
            picoMaximo: curva.max { $0.glucosa < $1.glucosa }!,
            cargaGlicemica: cargaTotal,
            insulinaNecesaria: insulinaNecesaria,
            recomendaciones: recomendaciones,
            macronutrientes: macros,
            ordenComida: ordenComida
        )
    }
    
    // MARK: - Métodos privados
    
    private func calcularCargaGlicemica(_ alimentos: [AlimentoConPorcion]) -> Double {
        return alimentos.reduce(0) { total, item in
            let cargaPorPorcion = (item.gramos / 100.0) * item.alimento.cargaGlicemica
            return total + cargaPorPorcion
        }
    }
    
    private func calcularSubidaBase(cargaGlicemica: Double, fibra: Double) -> Double {
        // Subida base: 3 mg/dL por punto de carga glicémica
        let subidaBase = cargaGlicemica * 3.0
        
        // Reducción por fibra (cada gramo de fibra reduce 2%)
        let reduccionFibra = min(0.3, fibra * 0.02) // Máximo 30% reducción
        
        return subidaBase * (1 - reduccionFibra)
    }
    
    private func calcularAjustePorIMC(_ imc: Double) -> Double {
        switch imc {
        case ..<18.5: return 0.9    // Bajo peso: -10%
        case 18.5..<25: return 1.0  // Normal: 0%
        case 25..<30: return 1.1    // Sobrepeso: +10%
        default: return 1.2         // Obesidad: +20%
        }
    }
    
    private func generarCurvaPrediccion(
        glucosaInicial: Double,
        subidaMaxima: Double,
        ordenComida: OrdenComida
    ) -> [PuntoGlucosa] {
        
        var puntos: [PuntoGlucosa] = []
        let tiempoPico = ordenComida == .verdurasPrimero ? 90 : 75 // Verduras retrasan pico
        
        for minuto in stride(from: 0, through: 180, by: 15) {
            let factor = calcularFactorTiempo(minuto, tiempoPico: tiempoPico)
            let glucosa = glucosaInicial + (subidaMaxima * factor)
            
            puntos.append(PuntoGlucosa(
                tiempoMinutos: minuto,
                glucosa: max(70, glucosa) // Mínimo 70 mg/dL
            ))
        }
        
        return puntos
    }
    
    private func calcularFactorTiempo(_ minuto: Int, tiempoPico: Int) -> Double {
        let tiempo = Double(minuto)
        let pico = Double(tiempoPico)
        
        if tiempo <= pico {
            // Subida: curva suave hasta el pico
            return sin((tiempo / pico) * .pi / 2)
        } else {
            // Bajada: exponencial
            let tiempoDescenso = tiempo - pico
            return exp(-tiempoDescenso / 90.0)
        }
    }
    
    private func generarRecomendaciones(
        pico: PuntoGlucosa,
        usuario: PerfilUsuario,
        ordenActual: OrdenComida
    ) -> [String] {
        
        var recomendaciones: [String] = []
        
        // Recomendación por nivel de pico
        switch pico.glucosa {
        case ..<140:
            recomendaciones.append("✅ Excelente control de glucosa")
        case 140..<180:
            recomendaciones.append("⚠️ Pico moderado, considera cambiar el orden")
        case 180..<250:
            recomendaciones.append("🚨 Pico alto, come verduras primero")
        default:
            recomendaciones.append("🆘 Pico muy alto, consulta a tu médico")
        }
        
        // Recomendación de orden
        if ordenActual != .verdurasPrimero {
            recomendaciones.append("💡 Tip: Come verduras primero para reducir el pico 37%")
        }
        
        // Recomendación de ejercicio
        recomendaciones.append("🚶‍♀️ Camina 10 minutos después de comer para reducir glucosa")
        
        return recomendaciones
    }
}
