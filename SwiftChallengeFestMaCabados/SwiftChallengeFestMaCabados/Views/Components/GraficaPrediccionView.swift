//
//  GraficaPrediccionView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct GraficaPrediccionView: View {
    let prediccion: PrediccionGlucosa
    let glucosaInicial: Double
    @State private var selectedPoint: PuntoGlucosa?
    @State private var showingAnimation = false
    
    private let rangoMinimo: Double = 70
    private let rangoMaximo: Double = 250
    private let tiempoMaximo: Double = 180 // 3 horas
    
    var body: some View {
        VStack(spacing: 16) {
            // Header con información clave
            headerInformacion
            
            // Gráfica principal
            graficaPrincipal
                .frame(height: 200)
            
            // Información del punto seleccionado
            if let punto = selectedPoint {
                informacionPunto(punto)
                    .transition(.slide)
            }
            
            // Leyenda y controles
            leyendaYControles
        }
        .onAppear {
            iniciarAnimacion()
        }
    }
    
    // MARK: - Header con Información Clave
    private var headerInformacion: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Predicción de Glucosa")
                    .font(.headline)
                
                HStack(spacing: 12) {
                    // Pico máximo
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pico máximo")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(prediccion.picoMaximo.glucosa.glucosaFormat)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(ColorHelper.Glucosa.colorPorValor(prediccion.picoMaximo.glucosa))
                    }
                    
                    // Tiempo al pico
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tiempo al pico")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(prediccion.picoMaximo.tiempoMinutos) min")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            Spacer()
            
            // Orden de comida
            VStack(alignment: .trailing, spacing: 4) {
                Text(prediccion.ordenComida.descripcion)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("CG: \(prediccion.cargaGlicemica, specifier: "%.1f")")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ColorHelper.Principal.primario)
            }
        }
    }
    
    // MARK: - Gráfica Principal
    private var graficaPrincipal: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo y líneas de referencia
                lineasReferencia(geometry: geometry)
                
                // Área bajo la curva
                areaPrediccion(geometry: geometry)
                
                // Línea de predicción
                lineaPrediccion(geometry: geometry)
                
                // Puntos interactivos
                puntosInteractivos(geometry: geometry)
                
                // Línea vertical del pico
                lineaPico(geometry: geometry)
            }
        }
        .clipped()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 0.5)
        )
    }
    
    private func lineasReferencia(geometry: GeometryProxy) -> some View {
        ZStack {
            // Línea de glucosa normal (140 mg/dL)
            let yNormal = yPosition(for: 140, in: geometry.size.height)
            Path { path in
                path.move(to: CGPoint(x: 0, y: yNormal))
                path.addLine(to: CGPoint(x: geometry.size.width, y: yNormal))
            }
            .stroke(ColorHelper.Estados.advertencia.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            
            // Línea de hiperglucemia (180 mg/dL)
            let yHiper = yPosition(for: 180, in: geometry.size.height)
            Path { path in
                path.move(to: CGPoint(x: 0, y: yHiper))
                path.addLine(to: CGPoint(x: geometry.size.width, y: yHiper))
            }
            .stroke(ColorHelper.Estados.error.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            
            // Etiquetas de referencia
            VStack {
                HStack {
                    Spacer()
                    Text("180 mg/dL")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                }
                .position(x: geometry.size.width - 40, y: yHiper)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Text("140 mg/dL")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                }
                .position(x: geometry.size.width - 40, y: yNormal)
                
                Spacer()
            }
        }
    }
    
    private func areaPrediccion(geometry: GeometryProxy) -> some View {
        let puntos = prediccion.curvaPrediccion
        
        return Path { path in
            guard !puntos.isEmpty else { return }
            
            // Comenzar desde la base
            let firstX = xPosition(for: puntos[0].tiempoMinutos, in: geometry.size.width)
            let firstY = yPosition(for: puntos[0].glucosa, in: geometry.size.height)
            path.move(to: CGPoint(x: firstX, y: geometry.size.height))
            path.addLine(to: CGPoint(x: firstX, y: firstY))
            
            // Agregar puntos de la curva
            for punto in puntos {
                let x = xPosition(for: punto.tiempoMinutos, in: geometry.size.width)
                let y = yPosition(for: punto.glucosa, in: geometry.size.height)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            // Cerrar el área
            let lastX = xPosition(for: puntos.last!.tiempoMinutos, in: geometry.size.width)
            path.addLine(to: CGPoint(x: lastX, y: geometry.size.height))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [
                    ColorHelper.Glucosa.colorPorValor(prediccion.picoMaximo.glucosa).opacity(0.3),
                    ColorHelper.Glucosa.colorPorValor(prediccion.picoMaximo.glucosa).opacity(0.1),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .opacity(showingAnimation ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 1.0).delay(0.5), value: showingAnimation)
    }
    
    private func lineaPrediccion(geometry: GeometryProxy) -> some View {
        let puntos = prediccion.curvaPrediccion
        
        return Path { path in
            for (index, punto) in puntos.enumerated() {
                let x = xPosition(for: punto.tiempoMinutos, in: geometry.size.width)
                let y = yPosition(for: punto.glucosa, in: geometry.size.height)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .trim(from: 0, to: showingAnimation ? 1.0 : 0.0)
        .stroke(
            ColorHelper.Glucosa.colorPorValor(prediccion.picoMaximo.glucosa),
            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
        )
        .animation(.easeInOut(duration: 1.5), value: showingAnimation)
    }
    
    private func puntosInteractivos(geometry: GeometryProxy) -> some View {
        ForEach(prediccion.curvaPrediccion.indices, id: \.self) { index in
            let punto = prediccion.curvaPrediccion[index]
            let x = xPosition(for: punto.tiempoMinutos, in: geometry.size.width)
            let y = yPosition(for: punto.glucosa, in: geometry.size.height)
            
            // Solo mostrar algunos puntos para no saturar
            if index % 2 == 0 || punto.id == prediccion.picoMaximo.id {
                Circle()
                    .fill(ColorHelper.Glucosa.colorPorValor(punto.glucosa))
                    .frame(width: selectedPoint?.id == punto.id ? 12 : 8,
                           height: selectedPoint?.id == punto.id ? 12 : 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .position(x: x, y: y)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedPoint = punto
                        }
                    }
                    .scaleEffect(showingAnimation ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: showingAnimation)
            }
        }
    }
    
    private func lineaPico(geometry: GeometryProxy) -> some View {
        let picoX = xPosition(for: prediccion.picoMaximo.tiempoMinutos, in: geometry.size.width)
        let picoY = yPosition(for: prediccion.picoMaximo.glucosa, in: geometry.size.height)
        
        return VStack {
            // Línea vertical
            Path { path in
                path.move(to: CGPoint(x: picoX, y: 0))
                path.addLine(to: CGPoint(x: picoX, y: geometry.size.height))
            }
            .stroke(
                ColorHelper.Glucosa.colorPorValor(prediccion.picoMaximo.glucosa).opacity(0.5),
                style: StrokeStyle(lineWidth: 1, dash: [2, 2])
            )
            
            // Etiqueta del pico
            Text("PICO")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(ColorHelper.Glucosa.colorPorValor(prediccion.picoMaximo.glucosa))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorHelper.Glucosa.colorPorValor(prediccion.picoMaximo.glucosa).opacity(0.1))
                )
                .position(x: picoX, y: max(20, picoY - 25))
        }
        .opacity(showingAnimation ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.5).delay(1.5), value: showingAnimation)
    }
    
    // MARK: - Información del Punto Seleccionado
    private func informacionPunto(_ punto: PuntoGlucosa) -> some View {
        let categoria = AppConstants.Glucosa.categoriaGlucosa(punto.glucosa)
        
        return HStack(spacing: 16) {
            // Icono y valor
            HStack(spacing: 8) {
                Text(categoria.emoji)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(Int(punto.glucosa)) mg/dL")
                        .font(.headline)
                        .foregroundColor(categoria.color)
                    
                    Text("T+\(punto.tiempoMinutos) min")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Estado
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
    
    // MARK: - Leyenda y Controles
    private var leyendaYControles: some View {
        VStack(spacing: 12) {
            // Leyenda de tiempo
            HStack {
                Text("0h")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("1h")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("2h")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("3h")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Información adicional
            if let insulina = prediccion.insulinaNecesaria {
                HStack {
                    Image(systemName: "syringe")
                        .foregroundColor(.blue)
                    
                    Text("Insulina sugerida: \(insulina.insulinaFormat)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func xPosition(for tiempo: Int, in width: CGFloat) -> CGFloat {
        return width * CGFloat(tiempo) / CGFloat(tiempoMaximo)
    }
    
    private func yPosition(for glucosa: Double, in height: CGFloat) -> CGFloat {
        let normalizedValue = (glucosa - rangoMinimo) / (rangoMaximo - rangoMinimo)
        return height * (1 - normalizedValue)
    }
    
    private func iniciarAnimacion() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showingAnimation = true
        }
    }
}

// MARK: - Vista Comparativa
struct GraficaComparativaView: View {
    let predicciones: [PrediccionComida]
    let glucosaInicial: Double
    @State private var prediccionSeleccionada: PrediccionComida?
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            Text("Comparación de Órdenes")
                .font(.headline)
            
            // Gráfica con múltiples líneas
            graficaComparativa
                .frame(height: 200)
            
            // Lista de predicciones
            listaPredicciones
        }
    }
    
    private var graficaComparativa: some View {
        GeometryReader { geometry in
            ZStack {
                // Líneas de referencia
                lineasReferenciaComparativa(geometry: geometry)
                
                // Líneas de predicción
                ForEach(predicciones) { prediccionComida in
                    lineaPrediccionComparativa(
                        prediccion: prediccionComida.prediccion,
                        color: ColorHelper.OrdenComidaHelper.colorPorOrden(prediccionComida.orden),
                        geometry: geometry
                    )
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }
    
    private func lineasReferenciaComparativa(geometry: GeometryProxy) -> some View {
        let y140 = yPosition(for: 140, in: geometry.size.height)
        let y180 = yPosition(for: 180, in: geometry.size.height)
        
        return ZStack {
            Path { path in
                path.move(to: CGPoint(x: 0, y: y140))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y140))
                path.move(to: CGPoint(x: 0, y: y180))
                path.addLine(to: CGPoint(x: geometry.size.width, y: y180))
            }
            .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
    }
    
    private func lineaPrediccionComparativa(
        prediccion: PrediccionGlucosa,
        color: Color,
        geometry: GeometryProxy
    ) -> some View {
        Path { path in
            for (index, punto) in prediccion.curvaPrediccion.enumerated() {
                let x = xPosition(for: punto.tiempoMinutos, in: geometry.size.width)
                let y = yPosition(for: punto.glucosa, in: geometry.size.height)
                
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }
    
    private var listaPredicciones: some View {
        VStack(spacing: 8) {
            ForEach(predicciones) { prediccionComida in
                PrediccionRow(
                    prediccionComida: prediccionComida,
                    isSelected: prediccionSeleccionada?.id == prediccionComida.id
                ) {
                    prediccionSeleccionada = prediccionComida
                }
            }
        }
    }
    
    private func xPosition(for tiempo: Int, in width: CGFloat) -> CGFloat {
        return width * CGFloat(tiempo) / 180.0
    }
    
    private func yPosition(for glucosa: Double, in height: CGFloat) -> CGFloat {
        let normalizedValue = (glucosa - 70) / (250 - 70)
        return height * (1 - normalizedValue)
    }
}

// MARK: - Vistas Auxiliares

private struct PrediccionRow: View {
    let prediccionComida: PrediccionComida
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            // Color indicator
            Circle()
                .fill(ColorHelper.OrdenComidaHelper.colorPorOrden(prediccionComida.orden))
                .frame(width: 12, height: 12)
            
            // Orden
            Text(prediccionComida.orden.descripcion)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            // Pico
            Text(prediccionComida.prediccion.picoMaximo.glucosa.glucosaFormat)
                .font(.subheadline)
                .foregroundColor(ColorHelper.Glucosa.colorPorValor(prediccionComida.prediccion.picoMaximo.glucosa))
            
            // Beneficio
            if prediccionComida.beneficio > 0 {
                beneficioView
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color(.systemGray6) : Color.clear)
        )
        .onTapGesture(perform: onTap)
    }
    
    private var beneficioView: some View {
        Text("-\(prediccionComida.beneficio, specifier: "%.0f")%")
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.green)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.green.opacity(0.1))
            .cornerRadius(4)
    }
}

#Preview {
    // Crear datos de prueba
    let puntosDemo = [
        PuntoGlucosa(tiempoMinutos: 0, glucosa: 110),
        PuntoGlucosa(tiempoMinutos: 15, glucosa: 125),
        PuntoGlucosa(tiempoMinutos: 30, glucosa: 145),
        PuntoGlucosa(tiempoMinutos: 45, glucosa: 165),
        PuntoGlucosa(tiempoMinutos: 60, glucosa: 155),
        PuntoGlucosa(tiempoMinutos: 75, glucosa: 140),
        PuntoGlucosa(tiempoMinutos: 90, glucosa: 125),
        PuntoGlucosa(tiempoMinutos: 120, glucosa: 115),
        PuntoGlucosa(tiempoMinutos: 180, glucosa: 110)
    ]
    
    let prediccionDemo = PrediccionGlucosa(
        curvaPrediccion: puntosDemo,
        picoMaximo: puntosDemo[3],
        cargaGlicemica: 35.5,
        insulinaNecesaria: 4.5,
        recomendaciones: ["Verduras primero reduce el pico"],
        macronutrientes: Macronutrientes(alimentos: []),
        ordenComida: .verdurasPrimero
    )
    
    return GraficaPrediccionView(
        prediccion: prediccionDemo,
        glucosaInicial: 110
    )
    .padding()
}
