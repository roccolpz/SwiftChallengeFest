//
//  PrediccionGlucosa.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation

struct PrediccionGlucosa {
    let curvaPrediccion: [PuntoGlucosa]
    let picoMaximo: PuntoGlucosa
    let cargaGlicemica: Double
    let insulinaNecesaria: Double?
    let recomendaciones: [String]
    let macronutrientes: Macronutrientes
    let ordenComida: OrdenComida
}

struct PuntoGlucosa: Identifiable {
    let id = UUID()
    let tiempoMinutos: Int
    let glucosa: Double
}

struct Macronutrientes {
    let carbohidratos: Double
    let proteinas: Double
    let grasas: Double
    let fibra: Double
    let calorias: Double
    
    init(alimentos: [AlimentoConPorcion]) {
        self.carbohidratos = alimentos.reduce(0) { $0 + $1.carbohidratosReales }
        self.proteinas = alimentos.reduce(0) { $0 + $1.proteinasReales }
        self.grasas = alimentos.reduce(0) { $0 + $1.grasasReales }
        self.fibra = alimentos.reduce(0) { $0 + $1.fibraReales }
        self.calorias = (carbohidratos * 4) + (proteinas * 4) + (grasas * 9)
    }
}
