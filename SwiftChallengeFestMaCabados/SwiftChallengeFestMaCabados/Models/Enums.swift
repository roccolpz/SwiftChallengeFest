//
//  Enums.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation

enum CategoriaAlimento: String, CaseIterable, Codable {
    case verduras = "Verduras"
    case frutas = "Frutas"
    case proteinas = "Proteínas"
    case carbohidratos = "Carbohidratos"
    case lacteos = "Lácteos"
    case grasas = "Grasas y Aceites"
    case bebidas = "Bebidas"
    case procesados = "Procesados"
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

enum OrdenComida: CaseIterable {
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
