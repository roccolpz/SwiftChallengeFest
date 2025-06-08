//
//  PrediccionComparativaView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct PrediccionComparativaView: View {
    @ObservedObject var viewModel: PredictorViewModel
    @StateObject private var glucosaManager = GlucosaManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedOrden: OrdenComida?
    @State private var showingDetallesOrden = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    loadingView
                } else if viewModel.prediccionComparativa.isEmpty {
                    estadoError
                } else {
                    VStack(spacing: 0) {
                        // Header con información
                        headerComparacion
                            .padding()
                            .background(Color(.systemGroupedBackground))
                        
                        // Gráfica comparativa
//                        graficaComparativa
//                            .padding()
//                            .background(Color(.systemGroupedBackground))
//                        
//                        // Lista de resultados
                        listaResultados
                    }
                }
            }
            .navigationTitle("Comparar Órdenes")
            .navigationBarItems(
                leading: Button("Cerrar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    regenerarComparacion()
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(isLoading)
            )
        }
        .onAppear {
            generarComparacion()
        }
//        .sheet(isPresented: $showingDetallesOrden) {
//            if let orden = selectedOrden {
//                DetalleOrdenSheet(
//                    orden: orden,
//                    prediccionComparativa: viewModel.prediccionComparativa,
//                    glucosaInicial: glucosaManager.glucosaActual
//                )
//            }
//        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Comparando órdenes de comida...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Calculando predicciones para cada secuencia")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Estado de Error
    private var estadoError: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error en la Comparación")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("No se pudieron generar las predicciones. Verifica que tengas alimentos seleccionados.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                regenerarComparacion()
            }) {
                Text("Intentar de Nuevo")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(ColorHelper.Principal.primario)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .padding()
    }
    
    // MARK: - Header de Comparación
    private var headerComparacion: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Impacto del Orden en tu Glucosa")
                .font(.headline)
            
            Text("Basado en \(viewModel.alimentosSeleccionados.count) alimentos seleccionados")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Resumen rápido
            if let mejor = viewModel.prediccionComparativa.first,
               let peor = viewModel.prediccionComparativa.last {
                
                HStack(spacing: 16) {
                    ComparisonSummaryCard(
                        titulo: "Mejor Opción",
                        orden: mejor.orden,
                        pico: mejor.prediccion.picoMaximo.glucosa,
                        color: .green,
                        esMejor: true
                    )
                    
                    ComparisonSummaryCard(
                        titulo: "Peor Opción",
                        orden: peor.orden,
                        pico: peor.prediccion.picoMaximo.glucosa,
                        color: .red,
                        esMejor: false
                    )
                }
            }
        }
    }
    
    // MARK: - Gráfica Comparativa
    private var graficaComparativa: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Curvas de Predicción")
                .font(.headline)
            
            if !viewModel.prediccionComparativa.isEmpty {
                GraficaComparativaView(
                    predicciones: viewModel.prediccionComparativa,
                    glucosaInicial: glucosaManager.glucosaActual
                )
                .frame(height: 200)
            }
        }
    }
    
    // MARK: - Lista de Resultados
    private var listaResultados: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Resultados Detallados")
                    .font(.headline)
                    .padding(.horizontal)
                
                Spacer()
            }
            
            List {
                ForEach(Array(viewModel.prediccionComparativa.enumerated()), id: \.element.id) { index, prediccionComida in
                    ResultadoOrdenRow(
                        prediccionComida: prediccionComida,
                        ranking: index + 1,
                        glucosaInicial: glucosaManager.glucosaActual,
                        onTap: {
                            selectedOrden = prediccionComida.orden
                            showingDetallesOrden = true
                        },
                        onSelect: {
                            viewModel.cambiarOrdenComida(prediccionComida.orden)
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
    
    // MARK: - Methods
    private func generarComparacion() {
        isLoading = true
        viewModel.generarComparacion()
        
        // Simular tiempo de cálculo para mejor UX
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                isLoading = false
            }
        }
    }
    
    private func regenerarComparacion() {
        withAnimation {
            isLoading = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.generarComparacion()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Componentes Auxiliares

struct ComparisonSummaryCard: View {
    let titulo: String
    let orden: OrdenComida
    let pico: Double
    let color: Color
    let esMejor: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(titulo)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            Text(pico.glucosaFormat)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(orden.descripcion)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            if esMejor {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct ResultadoOrdenRow: View {
    let prediccionComida: PrediccionComida
    let ranking: Int
    let glucosaInicial: Double
    let onTap: () -> Void
    let onSelect: () -> Void
    
    private var beneficioTexto: String {
        let diferencia = prediccionComida.prediccion.picoMaximo.glucosa - glucosaInicial
        if diferencia > 0 {
            return String(format: "+%.0f mg/dL", diferencia)
        } else {
            return String(format: "%.0f mg/dL", diferencia)
        }
    }
    
    private var colorRanking: Color {
        switch ranking {
        case 1: return .green
        case 2: return .blue
        case 3: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Ranking
                ZStack {
                    Circle()
                        .fill(colorRanking)
                        .frame(width: 32, height: 32)
                    
                    Text("\(ranking)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // Información del orden
                VStack(alignment: .leading, spacing: 6) {
                    Text(prediccionComida.orden.descripcion)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 16) {
                        // Pico máximo
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pico máximo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(prediccionComida.prediccion.picoMaximo.glucosa.glucosaFormat)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(ColorHelper.Glucosa.colorPorValor(prediccionComida.prediccion.picoMaximo.glucosa))
                        }
                        
                        // Tiempo al pico
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tiempo al pico")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(prediccionComida.prediccion.picoMaximo.tiempoMinutos) min")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        // Beneficio vs baseline
                        if prediccionComida.beneficio > 0 {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Beneficio")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("-\(prediccionComida.beneficio, specifier: "%.0f")%")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    // Recomendación
                    recomendacionBadge
                }
                
                Spacer()
                
                // Botón seleccionar
                Button(action: onSelect) {
                    Text("Usar")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(colorRanking)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private var recomendacionBadge: some View {
        Group {
            switch ranking {
            case 1:
                Text("⭐ RECOMENDADO")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green)
                    .cornerRadius(6)
                
            case 2:
                Text("✓ BUENA OPCIÓN")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
                
            case 3:
                Text("○ ACEPTABLE")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(6)
                
            default:
                Text("⚠️ NO RECOMENDADO")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(6)
            }
        }
    }
}

// MARK: - Sheet de Detalle de Orden
struct DetalleOrdenSheet: View {
    let orden: OrdenComida
    let prediccionComparativa: [PrediccionComida]
    let glucosaInicial: Double
    @Environment(\.presentationMode) var presentationMode
    
    private var prediccionOrden: PrediccionComida? {
        prediccionComparativa.first { $0.orden == orden }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let prediccion = prediccionOrden {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            OrdenVisualIndicator(orden: orden)
                                .scaleEffect(1.5)
                            
                            Text(orden.descripcion)
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Gráfica individual
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Predicción de Glucosa")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            
                        }
                        
                        // Estadísticas detalladas
                        estadisticasDetalladas(prediccion.prediccion)
                            .padding(.horizontal)
                        
                        // Comparación con otros órdenes
                        comparacionOrdenes
                            .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                } else {
                    Text("Error: No se encontró la predicción")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Detalle del Orden")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func estadisticasDetalladas(_ prediccion: PrediccionGlucosa) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Estadísticas Detalladas")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                EstadisticaCard(
                    titulo: "Pico Máximo",
                    valor: prediccion.picoMaximo.glucosa.glucosaFormat,
                    subtitulo: "en \(prediccion.picoMaximo.tiempoMinutos) min",
                    color: ColorHelper.Glucosa.colorPorValor(prediccion.picoMaximo.glucosa)
                )
                
                EstadisticaCard(
                    titulo: "Carga Glicémica",
                    valor: String(format: "%.1f", prediccion.cargaGlicemica),
                    subtitulo: "índice glucémico",
                    color: ColorHelper.Principal.primario
                )
                
                if let insulina = prediccion.insulinaNecesaria {
                    EstadisticaCard(
                        titulo: "Insulina Sugerida",
                        valor: insulina.insulinaFormat,
                        subtitulo: "dosis calculada",
                        color: .blue
                    )
                }
                
                let duracionElevada = calcularDuracionElevada(prediccion.curvaPrediccion)
                EstadisticaCard(
                    titulo: "Tiempo Elevado",
                    valor: "\(duracionElevada) min",
                    subtitulo: "> 140 mg/dL",
                    color: .orange
                )
            }
        }
    }
    
    private var comparacionOrdenes: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Comparación con Otros Órdenes")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(prediccionComparativa.prefix(3), id: \.id) { prediccionComida in
                    ComparacionRow(
                        orden: prediccionComida.orden,
                        pico: prediccionComida.prediccion.picoMaximo.glucosa,
                        esActual: prediccionComida.orden == orden
                    )
                }
            }
        }
    }
    
    private func calcularDuracionElevada(_ curva: [PuntoGlucosa]) -> Int {
        let puntosElevados = curva.filter { $0.glucosa > 140 }
        return puntosElevados.count * 15 // 15 minutos por punto
    }
}

struct EstadisticaCard: View {
    let titulo: String
    let valor: String
    let subtitulo: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(valor)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitulo)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct ComparacionRow: View {
    let orden: OrdenComida
    let pico: Double
    let esActual: Bool
    
    var body: some View {
        HStack {
            Text(orden.descripcion)
                .font(.subheadline)
                .fontWeight(esActual ? .bold : .regular)
            
            Spacer()
            
            Text(pico.glucosaFormat)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ColorHelper.Glucosa.colorPorValor(pico))
            
            if esActual {
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(esActual ? Color(.systemGray6) : Color.clear)
        )
    }
}

#Preview {
    PrediccionComparativaView(viewModel: PredictorViewModel())
}
