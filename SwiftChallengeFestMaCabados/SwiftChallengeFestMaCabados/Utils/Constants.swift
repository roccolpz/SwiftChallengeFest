//
//  Constants.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation
import SwiftUI

struct AppConstants {
    
    // MARK: - Valores de Glucosa
    struct Glucosa {
        static let minima: Double = 50.0
        static let maxima: Double = 400.0
        static let objetivo: Double = 110.0
        static let hipoSevera: Double = 70.0
        static let hipoLeve: Double = 80.0
        static let normal: Double = 140.0
        static let hiperLeve: Double = 180.0
        static let hiperModerada: Double = 250.0
    }
    
    // MARK: - Rangos Nutricionales
    struct Nutricion {
        static let carbohidratosMin: Double = 0.0
        static let carbohidratosMax: Double = 150.0
        static let proteinasMin: Double = 0.0
        static let proteinasMax: Double = 100.0
        static let grasasMin: Double = 0.0
        static let grasasMax: Double = 80.0
        static let fibraMin: Double = 0.0
        static let fibraMax: Double = 50.0
        static let gramosMin: Double = 1.0
        static let gramosMax: Double = 500.0
    }
    
    // MARK: - Valores de Insulina
    struct Insulina {
        static let dosisMinima: Double = 0.0
        static let dosisMaxima: Double = 100.0
        static let ratioICDefault: Double = 15.0
        static let factorSensibilidadDefault: Double = 50.0
        static let basalDiariaMin: Double = 5.0
        static let basalDiariaMax: Double = 80.0
    }
    
    // MARK: - Datos de Usuario
    struct Usuario {
        static let edadMinima: Int = 1
        static let edadMaxima: Int = 120
        static let pesoMinimo: Double = 10.0
        static let pesoMaximo: Double = 300.0
        static let alturaMinima: Double = 50.0
        static let alturaMaxima: Double = 250.0
        static let imcMin: Double = 10.0
        static let imcMax: Double = 60.0
    }
    
    // MARK: - Tiempos de Predicción
    struct Tiempo {
        static let duracionPrediccionMinutos: Int = 180 // 3 horas
        static let intervaloPuntosMinutos: Int = 15
        static let tiempoPicoPromedio: Int = 75 // minutos
        static let tiempoPicoVerduras: Int = 90 // retraso con verduras
    }
    
    // MARK: - Factores de Ajuste
    struct Factores {
        static let reduccionVerdurasPrimero: Double = 0.25 // 25% reducción base
        static let reduccionProteinasPrimero: Double = 0.15 // 15% reducción base
        static let aumentoCarbohidratosPrimero: Double = 0.20 // 20% aumento base
        static let ajusteCircadianoMaximo: Double = 0.30 // 30% variación máxima
        static let ajusteEdadMaximo: Double = 0.20 // 20% variación máxima
        static let ajusteIMCMaximo: Double = 0.40 // 40% variación máxima
        static let reduccionFibraMaxima: Double = 0.30 // 30% reducción máxima por fibra
    }
    
    // MARK: - UI Constants
    struct UI {
        static let esquinasRedondeadas: CGFloat = 12.0
        static let paddingStandard: CGFloat = 16.0
        static let paddingPequeño: CGFloat = 8.0
        static let paddingGrande: CGFloat = 24.0
        static let alturaCard: CGFloat = 120.0
        static let alturaBoton: CGFloat = 50.0
        static let anchoMaximoCard: CGFloat = 400.0
    }
    
    // MARK: - Animaciones
    struct Animaciones {
        static let duracionRapida: Double = 0.2
        static let duracionNormal: Double = 0.3
        static let duracionLenta: Double = 0.5
        static let springDamping: Double = 0.8
        static let springResponse: Double = 0.6
    }
    
    // MARK: - Strings Localizados
    struct Textos {
        static let glucosaActual = "Glucosa Actual"
        static let prediccionComida = "Predicción de Comida"
        static let seleccionarAlimentos = "Seleccionar Alimentos"
        static let ordenComida = "Orden de Comida"
        static let macronutrientes = "Macronutrientes"
        static let recomendaciones = "Recomendaciones"
        static let perfil = "Perfil"
        static let configuracion = "Configuración"
        
        // Errores comunes
        static let errorCargaAlimentos = "Error cargando alimentos"
        static let errorPrediccion = "Error en predicción"
        static let errorDatosIncompletos = "Datos incompletos"
        static let errorRangoInvalido = "Valor fuera de rango"
        
        // Validaciones
        static let validacionGlucosaMinima = "Glucosa debe ser mayor a \(Glucosa.minima) mg/dL"
        static let validacionGlucosaMaxima = "Glucosa debe ser menor a \(Glucosa.maxima) mg/dL"
        static let validacionEdad = "Edad debe estar entre \(Usuario.edadMinima) y \(Usuario.edadMaxima) años"
        static let validacionPeso = "Peso debe estar entre \(Usuario.pesoMinimo) y \(Usuario.pesoMaximo) kg"
    }
    
    // MARK: - Configuración de Gráficas
    struct Graficas {
        static let alturaGrafica: CGFloat = 200.0
        static let margenHorizontal: CGFloat = 20.0
        static let margenVertical: CGFloat = 10.0
        static let grosorLinea: CGFloat = 3.0
        static let radioCirculo: CGFloat = 6.0
        static let opacidadArea: Double = 0.3
    }
    
    // MARK: - Keys para UserDefaults
    struct UserDefaultsKeys {
        static let perfilUsuario = "perfil_usuario"
        static let glucosaActual = "glucosa_actual"
        static let primeraVez = "primera_vez"
        static let configuracionCompleta = "configuracion_completa"
        static let historialComidas = "historial_comidas"
        static let preferenciasNotificaciones = "preferencias_notificaciones"
    }
    
    // MARK: - Emojis y Iconos
    struct Emojis {
        static let verduras = "🥬"
        static let proteinas = "🍗"
        static let carbohidratos = "🍚"
        static let grasas = "🥑"
        static let fibra = "🌾"
        static let glucosa = "🩸"
        static let insulina = "💉"
        static let reloj = "⏰"
        static let tendenciaSubida = "📈"
        static let tendenciaBajada = "📉"
        static let alerta = "⚠️"
        static let exito = "✅"
        static let critico = "🚨"
        static let info = "💡"
    }
    
    // MARK: - Configuración de la App
    struct App {
        static let nombre = "GlucoPredict"
        static let version = "1.0.0"
        static let desarrollador = "Team MaCabados"
        static let email = "support@glucopredict.com"
        static let website = "https://glucopredict.com"
    }
}

// MARK: - Extensión para acceso rápido
extension AppConstants.Glucosa {
    static func categoriaGlucosa(_ valor: Double) -> (categoria: String, color: Color, emoji: String) {
        switch valor {
        case ..<hipoSevera:
            return ("Hipoglucemia Severa", .red, "🚨")
        case hipoSevera..<hipoLeve:
            return ("Hipoglucemia Leve", .orange, "⚠️")
        case hipoLeve..<normal:
            return ("Normal", .green, "✅")
        case normal..<hiperLeve:
            return ("Hiperglucemia Leve", .yellow, "⚠️")
        case hiperLeve..<hiperModerada:
            return ("Hiperglucemia Moderada", .orange, "🚨")
        default:
            return ("Hiperglucemia Severa", .red, "🆘")
        }
    }
}
