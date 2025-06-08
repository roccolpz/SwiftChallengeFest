//
//  ColorHelper.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct ColorHelper {
    
    // MARK: - Colores Principales de la App
    struct Principal {
        static let primario = Color( "007AFF")        // Azul iOS
        static let secundario = Color( "34C759")      // Verde iOS
        static let acento = Color( "FF9500")          // Naranja iOS
        static let fondo = Color( "F2F2F7")           // Gris claro iOS
        static let superficie = Color.white
        static let texto = Color.primary
        static let textoSecundario = Color.secondary
    }
    
    // MARK: - Colores de Glucosa (Basados en Rangos Clínicos)
    struct Glucosa {
        // Críticos
        static let hipoSevera = Color( "FF3B30")      // Rojo intenso
        static let hiperSevera = Color( "D70015")     // Rojo oscuro
        
        // Alertas
        static let hipoLeve = Color( "FF9500")        // Naranja
        static let hiperModerada = Color( "FF6B35")   // Naranja rojizo
        static let hiperLeve = Color( "FFCC02")       // Amarillo
        
        // Normal
        static let normal = Color( "34C759")          // Verde
        static let excelente = Color( "30D158")       // Verde brillante
        
        // Función para obtener color por valor
        static func colorPorValor(_ glucosa: Double) -> Color {
            switch glucosa {
            case ..<70: return hipoSevera
            case 70..<80: return hipoLeve
            case 80..<140: return normal
            case 140..<180: return hiperLeve
            case 180..<250: return hiperModerada
            default: return hiperSevera
            }
        }
        
        // Gradientes para gráficas
        static let gradienteNormal = LinearGradient(
            colors: [normal.opacity(0.6), normal.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let gradienteAlerta = LinearGradient(
            colors: [hiperLeve.opacity(0.6), hiperLeve.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        static let gradientePeligro = LinearGradient(
            colors: [hiperSevera.opacity(0.6), hiperSevera.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // MARK: - Colores de Macronutrientes
    struct Macronutrientes {
        static let carbohidratos = Color( "FF6B35")   // Naranja cálido
        static let proteinas = Color( "007AFF")       // Azul
        static let grasas = Color( "FFD60A")          // Amarillo dorado
        static let fibra = Color( "34C759")           // Verde
        static let calorias = Color( "AF52DE")        // Púrpura
        
        // Versiones suaves para fondos
        static let carbohidratosSuave = carbohidratos.opacity(0.2)
        static let proteinasSuave = proteinas.opacity(0.2)
        static let grasasSuave = grasas.opacity(0.2)
        static let fibraSuave = fibra.opacity(0.2)
    }
    
    // MARK: - Colores de Categorías de Alimentos
    struct Categorias {
        static let verduras = Color( "34C759")        // Verde
        static let frutas = Color( "FF9500")          // Naranja
        static let proteinas = Color( "007AFF")       // Azul
        static let carbohidratos = Color( "FFD60A")   // Amarillo
        static let lacteos = Color( "00C7BE")         // Turquesa
        static let grasas = Color( "FF6B35")          // Naranja rojizo
        static let bebidas = Color( "5AC8FA")         // Azul claro
        static let procesados = Color( "FF3B30")      // Rojo
        
        static func colorPorCategoria(_ categoria: CategoriaAlimento) -> Color {
            switch categoria {
            case .verduras: return verduras
            case .frutas: return frutas
            case .proteinas: return proteinas
            case .carbohidratos: return carbohidratos
            case .lacteos: return lacteos
            case .grasas: return grasas
            case .bebidas: return bebidas
            case .procesados: return procesados
            }
        }
    }
    
    // MARK: - Colores de Estados
    struct Estados {
        static let exito = Color("34C759")           // Verde
        static let advertencia = Color( "FF9500")     // Naranja
        static let error = Color( "FF3B30")           // Rojo
        static let info = Color( "007AFF")            // Azul
        static let neutro = Color( "8E8E93")          // Gris
        
        // Con opacidad para fondos
        static let exitoSuave = exito.opacity(0.1)
        static let advertenciaSuave = advertencia.opacity(0.1)
        static let errorSuave = error.opacity(0.1)
        static let infoSuave = info.opacity(0.1)
    }
    
    // MARK: - Gradientes Especiales
    struct Gradientes {
        // Gradiente principal de la app
        static let principal = LinearGradient(
            colors: [Principal.primario, Principal.secundario],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Gradiente de glucosa saludable
        static let saludable = LinearGradient(
            colors: [Glucosa.excelente, Glucosa.normal],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Gradiente de alerta
        static let alerta = LinearGradient(
            colors: [Estados.advertencia, Color("FF6B35")],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Gradiente de fondo sutil
        static let fondoSutil = LinearGradient(
            colors: [Principal.fondo, Color.white],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Gradiente para cards
        static let card = LinearGradient(
            colors: [Color.white, Principal.fondo.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    
    // MARK: - Colores Adaptativos (Modo Oscuro)
    struct Adaptativo {
        static let fondoPrimario = Color(.systemBackground)
        static let fondoSecundario = Color(.secondarySystemBackground)
        static let fondoTerciario = Color(.tertiarySystemBackground)
        static let texto = Color(.label)
        static let textoSecundario = Color(.secondaryLabel)
        static let separador = Color(.separator)
        static let enlace = Color(.link)
    }
    
    
    
    // MARK: - Funciones Utilitarias
    
    /// Obtiene el color de fondo apropiado para un valor de glucosa
    static func fondoGlucosa(_ valor: Double) -> Color {
        let color = Glucosa.colorPorValor(valor)
        return color.opacity(0.1)
    }
    
    /// Obtiene el color de texto contrastante para un fondo
    static func textoContrastante(para fondo: Color) -> Color {
        // Simplificado: usar blanco para colores oscuros, negro para claros
        return .primary // SwiftUI maneja esto automáticamente
    }
    
    /// Crea un gradiente personalizado de dos colores
    static func gradientePersonalizado(
        desde: Color,
        hasta: Color,
        direccion: GradientDirection = .vertical
    ) -> LinearGradient {
        let (inicio, fin) = direccion.puntos
        return LinearGradient(
            colors: [desde, hasta],
            startPoint: inicio,
            endPoint: fin
        )
    }
    
    /// Obtiene colores para gráfica de predicción
    static func coloresGraficaPrediccion(picoMaximo: Double) -> (linea: Color, area: LinearGradient) {
        let colorLinea = Glucosa.colorPorValor(picoMaximo)
        let gradienteArea = LinearGradient(
            colors: [colorLinea.opacity(0.6), colorLinea.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        return (colorLinea, gradienteArea)
    }
    
    struct OrdenComidaHelper {
        static func colorPorOrden(_ orden: OrdenComida) -> Color {
            switch orden {
            case .verdurasPrimero:
                return ColorHelper.Categorias.verduras
            case .proteinasPrimero:
                return ColorHelper.Categorias.proteinas
            case .carbohidratosPrimero:
                return ColorHelper.Categorias.carbohidratos
            case .simultaneo:
                return ColorHelper.Categorias.lacteos
            }
        }
    }
    
}

