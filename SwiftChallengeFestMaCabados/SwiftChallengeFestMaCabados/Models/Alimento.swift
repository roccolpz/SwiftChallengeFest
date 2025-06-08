//
//  Alimento.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation

struct Alimento: Codable, Identifiable, Hashable {
    let id = UUID()
    let nombre: String
    let carbohidratos: Double      // gramos por 100g
    let proteinas: Double          // gramos por 100g
    let grasas: Double            // gramos por 100g
    let fibra: Double             // gramos por 100g
    let indiceGlicemico: Int      // 0-100
    let cargaGlicemica: Double    // IG × carbos ÷ 100
    let categoria: CategoriaAlimento
    let imagen: String?
    let subcategoria: String?
    
    
    private enum CodingKeys: String, CodingKey {
        case nombre, carbohidratos, proteinas, grasas, fibra
        case indiceGlicemico, cargaGlicemica, categoria, subcategoria, imagen
    }
}

struct AlimentoConPorcion: Identifiable, Hashable {
    let id = UUID()
    let alimento: Alimento
    var gramos: Double = 100.0
    
    var carbohidratosReales: Double {
        return (gramos / 100.0) * alimento.carbohidratos
    }
    
    var proteinasReales: Double {
        return (gramos / 100.0) * alimento.proteinas
    }
    
    var grasasReales: Double {
        return (gramos / 100.0) * alimento.grasas
    }
    
    var fibraReales: Double {
        return (gramos / 100.0) * alimento.fibra
    }
}
