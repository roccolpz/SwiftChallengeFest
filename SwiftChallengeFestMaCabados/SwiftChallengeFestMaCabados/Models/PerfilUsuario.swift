//
//  PerfilUsuario.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation

struct PerfilUsuario: Codable {
    var nombre: String = ""
    var edad: Int = 25
    var genero: Genero = .masculino
    var peso: Double = 70.0            // kg
    var altura: Double = 170.0         // cm
    
    // Diabetes
    var esDiabetico: Bool = false
    var tipoDiabetes: TipoDiabetes? = nil
    
    // Datos para diabéticos
    var glucosaObjetivo: Double? = 110.0           // mg/dL
    var insulinaBasalDiaria: Double? = nil         // unidades/día
    var usaBombaInsulina: Bool = false
    var usaMonitorContinuo: Bool = false
    var medicamentos: [String] = []
    
    // Horarios
    var horarioDesayuno: Date = Calendar.current.date(from: DateComponents(hour: 8)) ?? Date()
    var horarioComida: Date = Calendar.current.date(from: DateComponents(hour: 14)) ?? Date()
    var horarioCena: Date = Calendar.current.date(from: DateComponents(hour: 20)) ?? Date()
    
    // Preferencias
    var alimentosFrecuentes: [String] = []
    var alergias: [String] = []
    var restriccionesDieteticas: [RestriccionDietetica] = []
    
    // Datos calculados
    var imc: Double { peso / ((altura/100) * (altura/100)) }
    var ratioIC: Double? {
        guard let insulina = insulinaBasalDiaria, insulina > 0 else { return nil }
        return 500 / insulina
    }
    var factorSensibilidad: Double? {
        guard let insulina = insulinaBasalDiaria, insulina > 0 else { return nil }
        return 1800 / insulina
    }
}

func guardarPerfil(_ perfil: PerfilUsuario) {
    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(perfil)
        UserDefaults.standard.set(data, forKey: "perfilUsuario")
        print("✅ Perfil guardado exitosamente")
    } catch {
        print("❌ Error al guardar perfil: \(error)")
    }
}

func cargarPerfil() -> PerfilUsuario? {
    if let data = UserDefaults.standard.data(forKey: "perfilUsuario") {
        do {
            let decoder = JSONDecoder()
            let perfil = try decoder.decode(PerfilUsuario.self, from: data)
            print("✅ Perfil cargado exitosamente")
            return perfil
        } catch {
            print("❌ Error al cargar perfil: \(error)")
        }
    }
    return nil
}

