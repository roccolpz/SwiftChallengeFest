//
//  HistorialComidasCard.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct HistorialComidasCard: View {
    @State private var comidasRecientes: [ComidaHistorial] = []
    @State private var showingDetalleHistorial = false
    @State private var comidaSeleccionada: ComidaHistorial?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Comidas Recientes")
                        .font(.headline)
                    
                    Text("Últimas predicciones")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingDetalleHistorial = true }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            // Contenido
            if comidasRecientes.isEmpty {
                estadoVacio
            } else {
                listaComidas
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
        )
        .onAppear {
            cargarComidasRecientes()
        }
        .sheet(isPresented: $showingDetalleHistorial) {
            DetalleHistorialComidasView(comidas: comidasRecientes)
        }
        .sheet(item: $comidaSeleccionada) { comida in
            DetalleComidaView(comida: comida)
        }
    }
    
    // MARK: - Estado Vacío
    private var estadoVacio: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No hay comidas registradas")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Usa el predictor para registrar tus comidas y ver el historial aquí")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                // TODO: Navegar al predictor
                print("Navegar al predictor")
            }) {
                Text("Predecir Comida")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(ColorHelper.Principal.primario)
                    .cornerRadius(8)
            }
        }
        .frame(height: 180)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Lista de Comidas
    private var listaComidas: some View {
        LazyVStack(spacing: 12) {
            ForEach(comidasRecientes.prefix(3)) { comida in
                ComidaHistorialRow(comida: comida) {
                    comidaSeleccionada = comida
                }
            }
            
            if comidasRecientes.count > 3 {
                Button(action: { showingDetalleHistorial = true }) {
                    Text("Ver todas (\(comidasRecientes.count))")
                        .font(.subheadline)
                        .foregroundColor(ColorHelper.Principal.primario)
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Métodos
    private func cargarComidasRecientes() {
        // Para el hackathon, generar datos de demostración
        comidasRecientes = generarComidasDemo()
    }
    
    private func generarComidasDemo() -> [ComidaHistorial] {
        let ahora = Date()
        
        return [
            ComidaHistorial(
                fecha: ahora.addingTimeInterval(-3600), // 1 hora atrás
                tipoComida: .comida,
                ordenUsado: .verdurasPrimero,
                glucosaInicial: 105,
                picoPredicho: 145,
                picoReal: 142,
                alimentos: ["Pollo", "Brócoli", "Arroz"],
                cargaGlicemica: 28.5,
                efectividad: .excelente
            ),
            ComidaHistorial(
                fecha: ahora.addingTimeInterval(-14400), // 4 horas atrás
                tipoComida: .desayuno,
                ordenUsado: .simultaneo,
                glucosaInicial: 98,
                picoPredicho: 165,
                picoReal: 172,
                alimentos: ["Avena", "Plátano", "Miel"],
                cargaGlicemica: 42.0,
                efectividad: .buena
            ),
            ComidaHistorial(
                fecha: ahora.addingTimeInterval(-86400), // Ayer
                tipoComida: .cena,
                ordenUsado: .verdurasPrimero,
                glucosaInicial: 115,
                picoPredicho: 155,
                picoReal: 148,
                alimentos: ["Salmón", "Espinacas", "Quinoa"],
                cargaGlicemica: 22.8,
                efectividad: .excelente
            )
        ]
    }
}

// MARK: - Fila de Comida en Historial
struct ComidaHistorialRow: View {
    let comida: ComidaHistorial
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Icono de comida
                ZStack {
                    Circle()
                        .fill(comida.tipoComida.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Text(comida.tipoComida.emoji)
                        .font(.title3)
                }
                
                // Información principal
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(comida.tipoComida.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(comida.fecha.tiempoRelativo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(comida.alimentos.prefix(2).joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        // Predicción vs Real
                        HStack(spacing: 4) {
                            Text("↗️")
                                .font(.caption)
                            Text("\(Int(comida.picoPredicho)) → \(Int(comida.picoReal ?? 0))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Efectividad
                        Text(comida.efectividad.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(comida.efectividad.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(comida.efectividad.color.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Detalle del Historial Completo
struct DetalleHistorialComidasView: View {
    let comidas: [ComidaHistorial]
    @Environment(\.presentationMode) var presentationMode
    @State private var filtroTipo: TipoComida?
    @State private var ordenamiento: OrdenamientoHistorial = .reciente
    
    private var comidasFiltradas: [ComidaHistorial] {
        var resultado = comidas
        
        // Filtrar por tipo
        if let tipo = filtroTipo {
            resultado = resultado.filter { $0.tipoComida == tipo }
        }
        
        // Ordenar
        switch ordenamiento {
        case .reciente:
            resultado.sort { $0.fecha > $1.fecha }
        case .efectividad:
            resultado.sort { $0.efectividad.orden < $1.efectividad.orden }
        case .glucosa:
            resultado.sort { $0.picoReal ?? $0.picoPredicho < $1.picoReal ?? $1.picoPredicho }
        }
        
        return resultado
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filtros y ordenamiento
                VStack(spacing: 16) {
                    // Filtros de tipo
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FiltroChip(
                                titulo: "Todas",
                                isSelected: filtroTipo == nil,
                                color: .gray
                            ) {
                                filtroTipo = nil
                            }
                            
                            ForEach(TipoComida.allCases, id: \.self) { tipo in
                                FiltroChip(
                                    titulo: tipo.rawValue,
                                    isSelected: filtroTipo == tipo,
                                    color: tipo.color
                                ) {
                                    filtroTipo = filtroTipo == tipo ? nil : tipo
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Ordenamiento
                    Picker("Ordenar por", selection: $ordenamiento) {
                        ForEach(OrdenamientoHistorial.allCases, id: \.self) { orden in
                            Text(orden.rawValue).tag(orden)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(Color(.systemGroupedBackground))
                
                // Lista de comidas
                List(comidasFiltradas) { comida in
                    ComidaHistorialRowDetallada(comida: comida)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Historial de Comidas")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Fila Detallada
struct ComidaHistorialRowDetallada: View {
    let comida: ComidaHistorial
    @State private var expanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Fila principal
            HStack(spacing: 16) {
                // Icono y hora
                VStack(spacing: 4) {
                    Text(comida.tipoComida.emoji)
                        .font(.title2)
                    
                    Text(comida.fecha.horaFormat)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Información
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(comida.tipoComida.rawValue)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(comida.efectividad.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(comida.efectividad.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(comida.efectividad.color.opacity(0.1))
                            .cornerRadius(6)
                    }
                    
                    Text(comida.alimentos.joined(separator: " • "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(expanded ? nil : 1)
                    
                    HStack {
                        Text("Pico: \(Int(comida.picoReal ?? comida.picoPredicho)) mg/dL")
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("CG: \(comida.cargaGlicemica, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Botón expandir
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        expanded.toggle()
                    }
                }) {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            
            // Detalles expandidos
            if expanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    HStack {
                        DetailItem(titulo: "Orden usado", valor: comida.ordenUsado.descripcion)
                        Spacer()
                        DetailItem(titulo: "Glucosa inicial", valor: comida.glucosaInicial.glucosaFormat)
                    }
                    
                    if let picoReal = comida.picoReal {
                        HStack {
                            DetailItem(titulo: "Predicho", valor: comida.picoPredicho.glucosaFormat)
                            Spacer()
                            DetailItem(titulo: "Real", valor: picoReal.glucosaFormat)
                            Spacer()
                            let diferencia = abs(picoReal - comida.picoPredicho)
                            DetailItem(titulo: "Diferencia", valor: "±\(diferencia.glucosaFormat)")
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .transition(.slide)
            }
        }
        .cornerRadius(12)
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

// MARK: - Componentes Auxiliares

struct FiltroChip: View {
    let titulo: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(titulo)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
        }
    }
}

struct DetailItem: View {
    let titulo: String
    let valor: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(valor)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct DetalleComidaView: View {
    let comida: ComidaHistorial
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header de la comida
                    VStack(spacing: 16) {
                        Text(comida.tipoComida.emoji)
                            .font(.system(size: 64))
                        
                        Text(comida.tipoComida.rawValue)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(comida.fecha.fechaCompletaFormat)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Alimentos consumidos
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Alimentos Consumidos")
                            .font(.headline)
                        
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(comida.alimentos, id: \.self) { alimento in
                                HStack {
                                    Text("•")
                                        .foregroundColor(ColorHelper.Principal.primario)
                                    Text(alimento)
                                        .font(.subheadline)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    
                    // Resultados
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Resultados")
                            .font(.headline)
                        
                        VStack(spacing: 16) {
                            HStack {
                                DetailItem(titulo: "Orden usado", valor: comida.ordenUsado.descripcion)
                                Spacer()
                                DetailItem(titulo: "Carga glicémica", valor: String(format: "%.1f", comida.cargaGlicemica))
                            }
                            
                            HStack {
                                DetailItem(titulo: "Glucosa inicial", valor: comida.glucosaInicial.glucosaFormat)
                                Spacer()
                                DetailItem(titulo: "Pico predicho", valor: comida.picoPredicho.glucosaFormat)
                            }
                            
                            if let picoReal = comida.picoReal {
                                HStack {
                                    DetailItem(titulo: "Pico real", valor: picoReal.glucosaFormat)
                                    Spacer()
                                    DetailItem(titulo: "Efectividad", valor: comida.efectividad.rawValue)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("Detalle de Comida")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Modelos de Apoyo

struct ComidaHistorial: Identifiable {
    let id = UUID()
    let fecha: Date
    let tipoComida: TipoComida
    let ordenUsado: OrdenComida
    let glucosaInicial: Double
    let picoPredicho: Double
    let picoReal: Double?
    let alimentos: [String]
    let cargaGlicemica: Double
    let efectividad: EfectividadPrediccion
}

enum TipoComida: String, CaseIterable {
    case desayuno = "Desayuno"
    case comida = "Comida"
    case cena = "Cena"
    case snack = "Snack"
    
    var emoji: String {
        switch self {
        case .desayuno: return "🌅"
        case .comida: return "🍽️"
        case .cena: return "🌙"
        case .snack: return "🍎"
        }
    }
    
    var color: Color {
        switch self {
        case .desayuno: return .orange
        case .comida: return .blue
        case .cena: return .purple
        case .snack: return .green
        }
    }
}

enum EfectividadPrediccion: String, CaseIterable {
    case excelente = "Excelente"
    case buena = "Buena"
    case regular = "Regular"
    case mala = "Mala"
    
    var color: Color {
        switch self {
        case .excelente: return .green
        case .buena: return .blue
        case .regular: return .orange
        case .mala: return .red
        }
    }
    
    var orden: Int {
        switch self {
        case .excelente: return 0
        case .buena: return 1
        case .regular: return 2
        case .mala: return 3
        }
    }
}

enum OrdenamientoHistorial: String, CaseIterable {
    case reciente = "Reciente"
    case efectividad = "Efectividad"
    case glucosa = "Glucosa"
}

#Preview {
    HistorialComidasCard()
        .padding()
        .background(Color(.systemGroupedBackground))
}
