//
//  Enums.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation
import SwiftUI

enum CategoriaAlimento: String, CaseIterable, Codable {
    case verduras = "verduras"
    case frutas = "frutas"
    case proteinas = "proteinas"
    case carbohidratos = "carbohidratos"
    case lacteos = "lacteos"
    case grasas = "grasas"
    case bebidas = "bebidas"
    case procesados = "procesados"
    
    // Agregar esta propiedad para mostrar nombres bonitos en la UI
    var displayName: String {
        switch self {
        case .verduras: return "Verduras"
        case .frutas: return "Frutas"
        case .proteinas: return "Proteínas"
        case .carbohidratos: return "Carbohidratos"
        case .lacteos: return "Lácteos"
        case .grasas: return "Grasas y Aceites"
        case .bebidas: return "Bebidas"
        case .procesados: return "Procesados"
        }
    }
}

enum Genero: String, CaseIterable, Codable {
    case masculino = "Masculino"
    case femenino = "Femenino"
    case otro = "Otro"
}

enum TipoDiabetes: String, CaseIterable, Codable {
    case tipo1 = "Tipo 1"
    case tipo2 = "Tipo 2"
    case gestacional = "Gestacional"
    case prediabetes = "Prediabetes"
}

enum RestriccionDietetica: String, CaseIterable, Codable {
    case vegetariano = "Vegetariano"
    case vegano = "Vegano"
    case sinGluten = "Sin Gluten"
    case bajaSal = "Baja en Sal"
    case bajoCarbohidrato = "Bajo en Carbohidratos"
}

enum OrdenComida: String, CaseIterable, Codable {
    case verdurasPrimero
    case proteinasPrimero
    case carbohidratosPrimero
    case simultaneo
    
    var descripcion: String {
        switch self {
        case .verdurasPrimero: return "🥬➡️🍗➡️🍚 Verduras primero"
        case .proteinasPrimero: return "🍗➡️🥬➡️🍚 Proteínas primero"
        case .carbohidratosPrimero: return "🍚➡️🥬➡️🍗 Carbohidratos primero"
        case .simultaneo: return "🍽️ Todo junto"
        }
    }
    
    var color: Color {
            switch self {
            case .verdurasPrimero:     return ColorHelper.Glucosa.normal
            case .proteinasPrimero:    return ColorHelper.Estados.info
            case .carbohidratosPrimero:return ColorHelper.Estados.error
            case .simultaneo:          return ColorHelper.Estados.neutro
            }
    }
}
enum RiesgoGlucosa: String, CaseIterable {
    case hipoglucemiaSevera = "🚨 Hipoglucemia Severa"
    case hipoglucemiaLeve = "⚠️ Hipoglucemia Leve"
    case normal = "✅ Normal"
    case hiperglucemiaLeve = "⚠️ Hiperglucemia Leve"
    case hiperglucemiaModerada = "🚨 Hiperglucemia Moderada"
    case hiperglucemiaSevera = "🆘 Hiperglucemia Severa"
    
    var color: String {
        switch self {
        case .hipoglucemiaSevera, .hiperglucemiaSevera: return "red"
        case .hipoglucemiaLeve, .hiperglucemiaModerada: return "orange"
        case .hiperglucemiaLeve: return "yellow"
        case .normal: return "green"
        }
    }
}

enum RecomendacionOrden: String, CaseIterable {
    case carbohidratosAltos = "🍚 Alta carga de carbohidratos: verduras primero es crucial"
    case pocaFibra = "🥬 Poca fibra: añade verduras y cómelas primero"
    case altaFibra = "✅ Buena fibra: cualquier orden con verduras primero funcionará bien"
    case altasProteinas = "🍗 Altas proteínas: proteínas primero también es efectivo"
    case pocasProteinas = "⚠️ Pocas proteínas: considera añadir más para mejor control"
    case ordenGeneral = "💡 Regla de oro: verduras → proteínas → carbohidratos"
    
    var icono: String {
        switch self {
        case .carbohidratosAltos: return "🍚"
        case .pocaFibra: return "🥬"
        case .altaFibra: return "✅"
        case .altasProteinas: return "🍗"
        case .pocasProteinas: return "⚠️"
        case .ordenGeneral: return "💡"
        }
    }
}

enum NivelComplejidad: String {
    case simple = "Simple"
    case moderada = "Moderada"
    case compleja = "Compleja"
    
    var emoji: String {
        switch self {
        case .simple: return "🟢"
        case .moderada: return "🟡"
        case .compleja: return "🔴"
        }
    }
}

enum GradientDirection {
    case vertical
    case horizontal
    case diagonal
    case radial
    
    var puntos: (UnitPoint, UnitPoint) {
        switch self {
        case .vertical:
            return (.top, .bottom)
        case .horizontal:
            return (.leading, .trailing)
        case .diagonal:
            return (.topLeading, .bottomTrailing)
        case .radial:
            return (.center, .bottom)
        }
    }
}

enum FuenteMedicion: String, Codable {
    case manual = "Manual"
    case automatica = "Monitor Continuo"
    case estimada = "Estimada"
}

enum EstadoGlucosa: String, CaseIterable {
    case hipoSevera = "Hipoglucemia Severa"
    case hipoLeve = "Hipoglucemia Leve"
    case normal = "Normal"
    case hiperLeve = "Hiperglucemia Leve"
    case hiperModerada = "Hiperglucemia Moderada"
    case hiperSevera = "Hiperglucemia Severa"
    
    static func desde(_ glucosa: Double) -> EstadoGlucosa {
        switch glucosa {
        case ..<70: return .hipoSevera
        case 70..<80: return .hipoLeve
        case 80..<140: return .normal
        case 140..<180: return .hiperLeve
        case 180..<250: return .hiperModerada
        default: return .hiperSevera
        }
    }
    
    var color: Color {
        switch self {
        case .hipoSevera, .hiperSevera: return ColorHelper.Estados.error
        case .hipoLeve, .hiperModerada: return ColorHelper.Estados.advertencia
        case .hiperLeve: return .yellow
        case .normal: return ColorHelper.Estados.exito
        }
    }
    
    var emoji: String {
        switch self {
        case .hipoSevera, .hiperSevera: return "🚨"
        case .hipoLeve, .hiperModerada: return "⚠️"
        case .hiperLeve: return "⚠️"
        case .normal: return "✅"
        }
    }
}

enum TendenciaGlucosa: String, CaseIterable {
    case subiendo = "Subiendo"
    case bajando = "Bajando"
    case estable = "Estable"
    
    var emoji: String {
        switch self {
        case .subiendo: return "📈"
        case .bajando: return "📉"
        case .estable: return "➡️"
        }
    }
    
    var color: Color {
        switch self {
        case .subiendo: return .red
        case .bajando: return .orange
        case .estable: return .green
        }
    }
}


