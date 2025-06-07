//
//  PredictorViewModel.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//

import Foundation
import SwiftUI

class PredictorViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let predictor = PredictorGlucosa()
    private let glucosaManager = GlucosaManager.shared
    private let perfilManager = PerfilUsuarioManager.shared
    private let alimentosManager = AlimentosManager.shared
    
    // MARK: - Published Properties
    @Published var alimentosSeleccionados: [AlimentoConPorcion] = []
    @Published var ordenComidaSeleccionado: OrdenComida = .verdurasPrimero
    @Published var prediccionActual: PrediccionGlucosa?
    @Published var prediccionComparativa: [PrediccionComida] = []
    @Published var horaComidaSeleccionada: Date = Date()
    
    // Estados de UI
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showingComparacion: Bool = false
    @Published var modoComparacion: Bool = false
    
    // Búsqueda y filtros
    @Published var textoBusqueda: String = ""
    @Published var categoriaFiltro: CategoriaAlimento?
    @Published var mostrandoSugerencias: Bool = false
    
    // MARK: - Computed Properties
    
    var alimentosFiltrados: [Alimento] {
        var alimentos = alimentosManager.alimentos
        
        // Filtrar por categoría
        if let categoria = categoriaFiltro {
            alimentos = alimentos.filter { $0.categoria == categoria }
        }
        
        // Filtrar por búsqueda
        if !textoBusqueda.isEmpty {
            alimentos = alimentos.filter {
                $0.nombre.localizedCaseInsensitiveContains(textoBusqueda)
            }
        }
        
        return alimentos
    }
    
    var sugerenciasAlimentos: [Alimento] {
        let frecuentes = perfilManager.perfil.alimentosFrecuentes
        return alimentosManager.alimentos.filter { alimento in
            frecuentes.contains { frecuente in
                alimento.nombre.localizedCaseInsensitiveContains(frecuente)
            }
        }.prefix(5).map { $0 }
    }
    
    var macronutrientesTotales: Macronutrientes {
        return Macronutrientes(alimentos: alimentosSeleccionados)
    }
    
    var hayAlimentosSeleccionados: Bool {
        return !alimentosSeleccionados.isEmpty
    }
    
    var puedeGenerarPrediccion: Bool {
        return hayAlimentosSeleccionados && macronutrientesTotales.carbohidratos > 0
    }
    
    var resumenComida: ResumenComida {
        let macros = macronutrientesTotales
        let analisis = AlgoritmoOrdenComida.analizarComposicionComida(macros)
        
        return ResumenComida(
            totalAlimentos: alimentosSeleccionados.count,
            macronutrientes: macros,
            analisisComposicion: analisis,
            ordenRecomendado: analisis.recomendacionOrden,
            beneficioEstimado: analisis.beneficioMaximo
        )
    }
    
    // MARK: - Public Methods
    
    /// Agrega un alimento a la selección
    func agregarAlimento(_ alimento: Alimento, gramos: Double = 100.0) {
        let alimentoConPorcion = AlimentoConPorcion(
            alimento: alimento,
            gramos: max(1.0, min(500.0, gramos)) // Validar rango
        )
        
        // Verificar si ya existe
        if let index = alimentosSeleccionados.firstIndex(where: { $0.alimento.id == alimento.id }) {
            // Actualizar cantidad existente
            alimentosSeleccionados[index] = alimentoConPorcion
        } else {
            // Agregar nuevo
            alimentosSeleccionados.append(alimentoConPorcion)
        }
        
        // Auto-generar predicción si está habilitado
        if hayAlimentosSeleccionados {
            generarPrediccionAutomatica()
        }
        
        print("✅ Agregado: \(alimento.nombre) (\(gramos.gramosFormat))")
    }
    
    /// Elimina un alimento de la selección
    func eliminarAlimento(_ alimentoConPorcion: AlimentoConPorcion) {
        alimentosSeleccionados.removeAll { $0.id == alimentoConPorcion.id }
        
        if hayAlimentosSeleccionados {
            generarPrediccionAutomatica()
        } else {
            prediccionActual = nil
        }
        
        print("❌ Eliminado: \(alimentoConPorcion.alimento.nombre)")
    }
    
    /// Actualiza la cantidad de gramos de un alimento
    func actualizarGramos(_ alimentoConPorcion: AlimentoConPorcion, nuevosGramos: Double) {
        guard let index = alimentosSeleccionados.firstIndex(where: { $0.id == alimentoConPorcion.id }) else {
            return
        }
        
        let gramosValidados = max(1.0, min(500.0, nuevosGramos))
        var alimentoActualizado = alimentosSeleccionados[index]
        alimentoActualizado.gramos = gramosValidados
        alimentosSeleccionados[index] = alimentoActualizado
        
        generarPrediccionAutomatica()
        
        print("🔄 Actualizado: \(alimentoConPorcion.alimento.nombre) → \(gramosValidados.gramosFormat)")
    }
    
    /// Cambia el orden de comida seleccionado
    func cambiarOrdenComida(_ nuevoOrden: OrdenComida) {
        ordenComidaSeleccionado = nuevoOrden
        
        if hayAlimentosSeleccionados {
            generarPrediccionAutomatica()
        }
        
        print("🔄 Orden cambiado a: \(nuevoOrden.descripcion)")
    }
    
    /// Genera la predicción principal
    func generarPrediccion() {
        guard puedeGenerarPrediccion else {
            errorMessage = "Agrega alimentos con carbohidratos para generar predicción"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Simular delay de procesamiento (para UX realista)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.ejecutarPrediccion()
        }
    }
    
    /// Genera comparación entre diferentes órdenes
    func generarComparacion() {
        guard puedeGenerarPrediccion else {
            errorMessage = "Agrega alimentos para comparar órdenes"
            return
        }
        
        isLoading = true
        prediccionComparativa = []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.ejecutarComparacion()
        }
    }
    
    /// Aplica sugerencias automáticas según perfil
    func aplicarSugerenciasAutomaticas() {
        let macros = macronutrientesTotales
        let sugerencias = AlgoritmoOrdenComida.generarRecomendaciones(macros)
        
        // Aplicar la mejor recomendación automáticamente
        let analisis = AlgoritmoOrdenComida.analizarComposicionComida(macros)
        cambiarOrdenComida(analisis.recomendacionOrden)
        
        mostrandoSugerencias = true
        
        print("💡 Sugerencias aplicadas: \(analisis.recomendacionOrden.descripcion)")
    }
    
    /// Limpia toda la selección
    func limpiarSeleccion() {
        alimentosSeleccionados.removeAll()
        prediccionActual = nil
        prediccionComparativa.removeAll()
        errorMessage = nil
        mostrandoSugerencias = false
        
        print("🧹 Selección limpiada")
    }
    
    /// Guarda la predicción actual como favorita
    func guardarComoFavorita() {
        guard let prediccion = prediccionActual else { return }
        
        // Registrar en el historial
        glucosaManager.registrarPrediccionComida(prediccion)
        
        // TODO: Implementar guardado de comidas favoritas
        print("⭐ Comida guardada como favorita")
    }
    
    /// Busca alimentos por texto
    func buscarAlimentos(_ texto: String) {
        textoBusqueda = texto
        
        // Si el texto está vacío, mostrar sugerencias
        if texto.isEmpty {
            mostrandoSugerencias = true
        } else {
            mostrandoSugerencias = false
        }
    }
    
    /// Filtra por categoría
    func filtrarPorCategoria(_ categoria: CategoriaAlimento?) {
        categoriaFiltro = categoria
        textoBusqueda = "" // Limpiar búsqueda al filtrar por categoría
    }
    
    // MARK: - Private Methods
    
    private func generarPrediccionAutomatica() {
        // Solo auto-generar si hay datos suficientes
        guard puedeGenerarPrediccion else {
            prediccionActual = nil
            return
        }
        
        ejecutarPrediccion()
    }
    
    private func ejecutarPrediccion() {
        let glucosaActual = glucosaManager.glucosaActual
        let perfil = perfilManager.perfil
        
        do {
            let prediccion = predictor.predecirGlucosa(
                alimentos: alimentosSeleccionados,
                usuario: perfil,
                glucosaActual: glucosaActual,
                horaComida: horaComidaSeleccionada,
                ordenComida: ordenComidaSeleccionado
            )
            
            DispatchQueue.main.async { [weak self] in
                self?.prediccionActual = prediccion
                self?.isLoading = false
                self?.errorMessage = nil
            }
            
            print("📊 Predicción generada: pico \(prediccion.picoMaximo.glucosa.glucosaFormat)")
            
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "Error generando predicción: \(error.localizedDescription)"
                self?.isLoading = false
            }
        }
    }
    
    private func ejecutarComparacion() {
        let glucosaActual = glucosaManager.glucosaActual
        let perfil = perfilManager.perfil
        var comparaciones: [PrediccionComida] = []
        
        // Generar predicción para cada orden
        for orden in OrdenComida.allCases {
            let prediccion = predictor.predecirGlucosa(
                alimentos: alimentosSeleccionados,
                usuario: perfil,
                glucosaActual: glucosaActual,
                horaComida: horaComidaSeleccionada,
                ordenComida: orden
            )
            
            comparaciones.append(PrediccionComida(
                orden: orden,
                prediccion: prediccion
            ))
        }
        
        // Ordenar por mejor resultado (menor pico)
        comparaciones.sort { $0.prediccion.picoMaximo.glucosa < $1.prediccion.picoMaximo.glucosa }
        
        DispatchQueue.main.async { [weak self] in
            self?.prediccionComparativa = comparaciones
            self?.isLoading = false
            self?.showingComparacion = true
        }
        
        print("📊 Comparación generada para \(comparaciones.count) órdenes")
    }
}

// MARK: - Supporting Models

struct PrediccionComida: Identifiable {
    let id = UUID()
    let orden: OrdenComida
    let prediccion: PrediccionGlucosa
    
    var beneficio: Double {
        // Calcular beneficio vs orden simultáneo
        let baselinePico = 150.0 // Pico promedio con orden simultáneo
        let reduction = baselinePico - prediccion.picoMaximo.glucosa
        return max(0, (reduction / baselinePico) * 100)
    }
    
    var ranking: Int {
        switch orden {
        case .verdurasPrimero: return 1
        case .proteinasPrimero: return 2
        case .simultaneo: return 3
        case .carbohidratosPrimero: return 4
        }
    }
}

struct ResumenComida {
    let totalAlimentos: Int
    let macronutrientes: Macronutrientes
    let analisisComposicion: AnalisisComposicion
    let ordenRecomendado: OrdenComida
    let beneficioEstimado: Double
    
    var esComidaBalanceada: Bool {
        let totalMacros = macronutrientes.carbohidratos + macronutrientes.proteinas + macronutrientes.grasas
        guard totalMacros > 0 else { return false }
        
        let pctCarbos = (macronutrientes.carbohidratos / totalMacros) * 100
        let pctProteinas = (macronutrientes.proteinas / totalMacros) * 100
        
        return pctCarbos >= 45 && pctCarbos <= 65 && pctProteinas >= 10 && pctProteinas <= 35
    }
    
    var nivelComplejidad: NivelComplejidad {
        switch totalAlimentos {
        case 1...2: return .simple
        case 3...5: return .moderada
        default: return .compleja
        }
    }
}

