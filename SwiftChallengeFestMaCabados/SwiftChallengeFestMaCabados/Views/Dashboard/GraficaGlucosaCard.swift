//
//  GraficaGlucosaCard.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct GraficaGlucosaCard: View {
    @ObservedObject var glucosaManager: GlucosaManager
    @State private var selectedPoint: MedicionGlucosa?
    @State private var showingDetalle = false
    
    private var medicionesRecientes: [MedicionGlucosa] {
        let ultimasHoras = glucosaManager.historialGlucosa.filter {
            $0.fecha.timeIntervalSinceNow > -3600 * 6 // Últimas 6 horas
        }
        return ultimasHoras.suffix(10) // Máximo 10 puntos
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Historial de Glucosa")
                        .font(.headline)
                    
                    Text("Últimas 6 horas")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { showingDetalle = true }) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            }
            
            if medicionesRecientes.count >= 2 {
                // Gráfica
                GraficaSimpleView(
                    mediciones: medicionesRecientes,
                    selectedPoint: $selectedPoint
                )
                .frame(height: 180)
                
                // Información del punto seleccionado
                if let punto = selectedPoint {
                    PuntoSeleccionadoInfo(medicion: punto)
                        .transition(.slide)
                }
                
                // Leyenda
                leyendaRangos
                
            } else {
                // Estado vacío
                estadoVacio
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
        )
        .sheet(isPresented: $showingDetalle) {
            DetalleHistorialView(glucosaManager: glucosaManager)
        }
    }
    
    // MARK: - Estado Vacío
    private var estadoVacio: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No hay suficientes datos")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Agrega más mediciones para ver el historial")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                glucosaManager.simularMedicionAutomatica()
            }) {
                Text("Simular Medición")
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
    
    // MARK: - Leyenda de Rangos
    private var leyendaRangos: some View {
        HStack(spacing: 16) {
            LeyendaItem(color: .red, label: "< 70", descripcion: "Bajo")
            LeyendaItem(color: .green, label: "70-180", descripcion: "Normal")
            LeyendaItem(color: .orange, label: "> 180", descripcion: "Alto")
        }
        .font(.caption)
    }
}

// MARK: - Gráfica Simple
struct GraficaSimpleView: View {
    let mediciones: [MedicionGlucosa]
    @Binding var selectedPoint: MedicionGlucosa?
    
    private let rangoMinimo: Double = 50
    private let rangoMaximo: Double = 300
    
    private func yPosition(for valor: Double, in height: CGFloat) -> CGFloat {
        let normalizedValue = (valor - rangoMinimo) / (rangoMaximo - rangoMinimo)
        return height * (1 - normalizedValue)
    }
    
    private func xPosition(for index: Int, in width: CGFloat) -> CGFloat {
        guard mediciones.count > 1 else { return width / 2 }
        return width * CGFloat(index) / CGFloat(mediciones.count - 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Líneas de referencia
                lineasReferencia(geometry: geometry)
                
                // Línea de la gráfica
                lineaGrafica(geometry: geometry)
                
                // Puntos de datos
                puntosGrafica(geometry: geometry)
                
                // Área bajo la curva
                areaGrafica(geometry: geometry)
            }
        }
        .clipped()
    }
    
    private func lineasReferencia(geometry: GeometryProxy) -> some View {
        ZStack {
            // Línea 70 mg/dL
            let y70 = yPosition(for: 70, in: geometry.size.height)
            Path { path in
                path.move(to: CGPoint(x: 0, y: y70))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y70))
            }
            .stroke(Color.green.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
            
            // Línea 180 mg/dL
            let y180 = yPosition(for: 180, in: geometry.size.height)
            Path { path in
                path.move(to: CGPoint(x: 0, y: y180))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y180))
            }
            .stroke(Color.orange.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [5]))
        }
    }
    
    private func lineaGrafica(geometry: GeometryProxy) -> some View {
        Path { path in
            for (index, medicion) in mediciones.enumerated() {
                let x = xPosition(for: index, in: geometry.size.width)
                let y = yPosition(for: medicion.valor, in: geometry.size.height)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(
            LinearGradient(
                colors: [ColorHelper.Principal.primario, ColorHelper.Principal.secundario],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
    }
    
    private func areaGrafica(geometry: GeometryProxy) -> some View {
        Path { path in
            guard !mediciones.isEmpty else { return }
            
            // Comenzar desde la base
            let firstX = xPosition(for: 0, in: geometry.size.width)
            let firstY = yPosition(for: mediciones[0].valor, in: geometry.size.height)
            path.move(to: CGPoint(x: firstX, y: geometry.size.height))
            path.addLine(to: CGPoint(x: firstX, y: firstY))
            
            // Trazar la línea
            for (index, medicion) in mediciones.enumerated() {
                let x = xPosition(for: index, in: geometry.size.width)
                let y = yPosition(for: medicion.valor, in: geometry.size.height)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            // Cerrar el área
            let lastX = xPosition(for: mediciones.count - 1, in: geometry.size.width)
            path.addLine(to: CGPoint(x: lastX, y: geometry.size.height))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [
                    ColorHelper.Principal.primario.opacity(0.3),
                    ColorHelper.Principal.primario.opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func puntosGrafica(geometry: GeometryProxy) -> some View {
        ForEach(Array(mediciones.enumerated()), id: \.element.id) { index, medicion in
            let x = xPosition(for: index, in: geometry.size.width)
            let y = yPosition(for: medicion.valor, in: geometry.size.height)
            let categoria = AppConstants.Glucosa.categoriaGlucosa(medicion.valor)
            
            Circle()
                .fill(categoria.color)
                .frame(width: selectedPoint?.id == medicion.id ? 12 : 8,
                       height: selectedPoint?.id == medicion.id ? 12 : 8)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(color: categoria.color.opacity(0.5), radius: 4)
                .position(x: x, y: y)
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedPoint = medicion
                    }
                }
                .scaleEffect(selectedPoint?.id == medicion.id ? 1.2 : 1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedPoint?.id)
        }
    }
}

// MARK: - Componentes Auxiliares

struct PuntoSeleccionadoInfo: View {
    let medicion: MedicionGlucosa
    
    private var categoria: (categoria: String, color: Color, emoji: String) {
        return AppConstants.Glucosa.categoriaGlucosa(medicion.valor)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(categoria.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(Int(medicion.valor)) mg/dL")
                    .font(.headline)
                    .foregroundColor(categoria.color)
                
                Text(medicion.fecha.horaFormat)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(categoria.categoria)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(categoria.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(categoria.color.opacity(0.1))
                .cornerRadius(8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct LeyendaItem: View {
    let color: Color
    let label: String
    let descripcion: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .fontWeight(.medium)
            
            Text(descripcion)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Vista de Detalle (Placeholder)
struct DetalleHistorialView: View {
    @ObservedObject var glucosaManager: GlucosaManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Historial Detallado")
                    .font(.title)
                    .padding()
                
                Text("Próximamente: Gráfica detallada con más opciones")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Historial")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    GraficaGlucosaCard(glucosaManager: GlucosaManager.shared)
        .padding()
        .background(Color(.systemGroupedBackground))
}
