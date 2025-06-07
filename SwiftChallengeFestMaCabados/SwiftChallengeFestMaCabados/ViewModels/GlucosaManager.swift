//
//  GlucosaManager.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation
import SwiftUI

class GlucosaManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var glucosaActual: Double = 110.0 {
        didSet {
            guardarGlucosaActual()
            actualizarEstadoGlucosa()
        }
    }
    
    @Published var historialGlucosa: [MedicionGlucosa] = []
    @Published var estadoActual: EstadoGlucosa = .normal
    @Published var tendencia: TendenciaGlucosa = .estable
    @Published var ultimaActualizacion: Date = Date()
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    var categoriaGlucosa: (categoria: String, color: Color, emoji: String) {
        return AppConstants.Glucosa.categoriaGlucosa(glucosaActual)
    }
    
    var requiereAtencion: Bool {
        return glucosaActual < 80 || glucosaActual > 180
    }
    
    var promedioUltimasHoras: Double {
        let ultimasHoras = historialGlucosa.filter {
            $0.fecha.timeIntervalSinceNow > -3600 * 3 // Últimas 3 horas
        }
        
        guard !ultimasHoras.isEmpty else { return glucosaActual }
        
        let suma = ultimasHoras.reduce(0) { $0 + $1.valor }
        return suma / Double(ultimasHoras.count)
    }
    
    // MARK: - Singleton
    static let shared = GlucosaManager()
    
    // MARK: - Initialization
    private init() {
        cargarDatos()
        configurarNotificaciones()
    }
    
    // MARK: - Public Methods
    
    /// Actualiza la glucosa actual
    func actualizarGlucosa(_ nuevaGlucosa: Double) {
        guard nuevaGlucosa >= AppConstants.Glucosa.minima &&
              nuevaGlucosa <= AppConstants.Glucosa.maxima else {
            errorMessage = AppConstants.Textos.validacionGlucosaMinima
            return
        }
        
        // Calcular tendencia antes de actualizar
        calcularTendencia(nuevaGlucosa)
        
        // Agregar al historial
        let nuevaMedicion = MedicionGlucosa(
            valor: nuevaGlucosa,
            fecha: Date(),
            fuente: .manual
        )
        
        historialGlucosa.append(nuevaMedicion)
        
        // Actualizar valor actual
        glucosaActual = nuevaGlucosa
        ultimaActualizacion = Date()
        
        // Limpiar errores
        errorMessage = nil
        
        print("✅ Glucosa actualizada: \(nuevaGlucosa.glucosaFormat)")
    }
    
    /// Simula una medición automática (para demo)
    func simularMedicionAutomatica() {
        // Generar variación realista (-15 a +15 mg/dL)
        let variacion = Double.random(in: -15...15)
        let nuevaGlucosa = max(70, min(300, glucosaActual + variacion))
        
        let medicion = MedicionGlucosa(
            valor: nuevaGlucosa,
            fecha: Date(),
            fuente: .automatica
        )
        
        historialGlucosa.append(medicion)
        actualizarGlucosa(nuevaGlucosa)
    }
    
    /// Registra una predicción de comida
    func registrarPrediccionComida(_ prediccion: PrediccionGlucosa) {
        _ = RegistroComida(
            fecha: Date(),
            glucosaPrevia: glucosaActual,
            prediccion: prediccion,
            alimentos: [] // Se puede expandir después
        )
        
        // Guardar en historial de comidas (se puede implementar después)
        print("📝 Predicción registrada: pico de \(prediccion.picoMaximo.glucosa.glucosaFormat)")
    }
    
    /// Obtiene mediciones de un rango de tiempo
    func medicionesEnRango(desde: Date, hasta: Date) -> [MedicionGlucosa] {
        return historialGlucosa.filter { medicion in
            medicion.fecha >= desde && medicion.fecha <= hasta
        }.sorted { $0.fecha < $1.fecha }
    }
    
    /// Obtiene estadísticas del día actual
    func estadisticasDelDia() -> EstadisticasGlucosa {
        let hoy = Calendar.current.startOfDay(for: Date())
        let medicionesHoy = medicionesEnRango(
            desde: hoy,
            hasta: Date()
        )
        
        guard !medicionesHoy.isEmpty else {
            return EstadisticasGlucosa(
                promedio: glucosaActual,
                minimo: glucosaActual,
                maximo: glucosaActual,
                desviacion: 0,
                tiempoEnRango: 100,
                mediciones: 1
            )
        }
        
        let valores = medicionesHoy.map { $0.valor }
        let promedio = valores.reduce(0, +) / Double(valores.count)
        let minimo = valores.min() ?? glucosaActual
        let maximo = valores.max() ?? glucosaActual
        
        // Calcular desviación estándar
        let sumaCuadrados = valores.reduce(0) { sum, valor in
            sum + pow(valor - promedio, 2)
        }
        let desviacion = sqrt(sumaCuadrados / Double(valores.count))
        
        // Tiempo en rango (70-180 mg/dL)
        let enRango = valores.filter { $0 >= 70 && $0 <= 180 }.count
        let tiempoEnRango = (Double(enRango) / Double(valores.count)) * 100
        
        return EstadisticasGlucosa(
            promedio: promedio,
            minimo: minimo,
            maximo: maximo,
            desviacion: desviacion,
            tiempoEnRango: tiempoEnRango,
            mediciones: medicionesHoy.count
        )
    }
    
    // MARK: - Private Methods
    
    private func cargarDatos() {
        // Cargar glucosa guardada
        if let glucosaGuardada = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.glucosaActual) as? Double {
            glucosaActual = glucosaGuardada
        }
        
        // Cargar historial (simplificado para el hackathon)
        generarHistorialDemo()
        
        actualizarEstadoGlucosa()
    }
    
    private func guardarGlucosaActual() {
        UserDefaults.standard.set(glucosaActual, forKey: AppConstants.UserDefaultsKeys.glucosaActual)
    }
    
    private func actualizarEstadoGlucosa() {
        estadoActual = EstadoGlucosa.desde(glucosaActual)
    }
    
    private func calcularTendencia(_ nuevaGlucosa: Double) {
        guard !historialGlucosa.isEmpty else {
            tendencia = .estable
            return
        }
        
        let ultimasMediciones = historialGlucosa.suffix(3) // Últimas 3 mediciones
        guard ultimasMediciones.count >= 2 else {
            tendencia = .estable
            return
        }
        
        let valores = ultimasMediciones.map { $0.valor }
        let diferencias = zip(valores.dropFirst(), valores).map { $0 - $1 }
        let promedioDiferencia = diferencias.reduce(0, +) / Double(diferencias.count)
        
        if promedioDiferencia > 5 {
            tendencia = .subiendo
        } else if promedioDiferencia < -5 {
            tendencia = .bajando
        } else {
            tendencia = .estable
        }
    }
    
    private func configurarNotificaciones() {
        // TODO: Configurar notificaciones locales para alertas de glucosa
        // Por ahora, solo logging
        print("🔔 Notificaciones de glucosa configuradas")
    }
    
    private func generarHistorialDemo() {
        // Generar algunas mediciones de las últimas horas para demo
        let ahora = Date()
        let medicionesDemo: [MedicionGlucosa] = [
            MedicionGlucosa(valor: 105, fecha: ahora.addingTimeInterval(-7200), fuente: .automatica), // 2h atrás
            MedicionGlucosa(valor: 118, fecha: ahora.addingTimeInterval(-3600), fuente: .automatica), // 1h atrás
            MedicionGlucosa(valor: glucosaActual, fecha: ahora, fuente: .manual) // Ahora
        ]
        
        historialGlucosa = medicionesDemo
    }
}

struct MedicionGlucosa: Identifiable, Codable {
    let id = UUID()
    let valor: Double
    let fecha: Date
    let fuente: FuenteMedicion
}


struct EstadisticasGlucosa {
    let promedio: Double
    let minimo: Double
    let maximo: Double
    let desviacion: Double
    let tiempoEnRango: Double // Porcentaje
    let mediciones: Int
}

struct RegistroComida: Identifiable {
    let id = UUID()
    let fecha: Date
    let glucosaPrevia: Double
    let prediccion: PrediccionGlucosa
    let alimentos: [AlimentoConPorcion]
}

