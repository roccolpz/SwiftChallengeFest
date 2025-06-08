//
//  GlucosaActualCard.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct GlucosaActualCard: View {
    @ObservedObject var glucosaManager: GlucosaManager
    @State private var showingEditor = false
    @State private var tempGlucosa = ""
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    private var categoriaGlucosa: (categoria: String, color: Color, emoji: String) {
        return AppConstants.Glucosa.categoriaGlucosa(glucosaManager.glucosaActual)
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            // Header con estado
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Glucosa Actual")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text(categoriaGlucosa.emoji)
                            .font(.title2)
                        
                        Text(categoriaGlucosa.categoria)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(categoriaGlucosa.color)
                    }
                }
                
                Spacer()
                
                // Tendencia
                HStack(spacing: 4) {
                    Text(glucosaManager.tendencia.emoji)
                    Text(glucosaManager.tendencia.rawValue)
                        .font(.caption)
                        .foregroundColor(glucosaManager.tendencia.color)
                }
            }
            .padding(.bottom, 16)
            
            // Valor principal
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(Int(glucosaManager.glucosaActual.rounded()))")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(categoriaGlucosa.color)
                        
                        Text("mg/dL")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Última actualización: \(glucosaManager.ultimaActualizacion.tiempoRelativo)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Botón editar
                Button(action: {
                    tempGlucosa = String(Int(glucosaManager.glucosaActual))
                    showingEditor = true
                }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Indicador visual de rango
            RangoGlucosaIndicator(
                valorActual: glucosaManager.glucosaActual,
                colorActual: categoriaGlucosa.color
            )
            .padding(.top, 16)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: categoriaGlucosa.color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: glucosaManager.glucosaActual)
        .sheet(isPresented: $showingEditor) {
            GlucosaEditorSheet(
                glucosaActual: glucosaManager.glucosaActual,
                onSave: { nuevaGlucosa in
                    glucosaManager.actualizarGlucosa(nuevaGlucosa)
                }
            )                .presentationDetents([.fraction(0.70)])

        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
}

// MARK: - Rango Visual Indicator
struct RangoGlucosaIndicator: View {
    let valorActual: Double
    let colorActual: Color
    
    private let rangoMinimo: Double = 70
    private let rangoMaximo: Double = 180
    private let rangoTotal: Double = 400 - 50 // 50 to 400 mg/dL
    
    private var posicionIndicador: Double {
        let valor = max(50, min(400, valorActual))
        return (valor - 50) / rangoTotal
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Barra de rango
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fondo de la barra
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    // Zona normal (70-180)
                    let normalStart = (rangoMinimo - 50) / rangoTotal
                    let normalWidth = (rangoMaximo - rangoMinimo) / rangoTotal
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(ColorHelper.Estados.exito.opacity(0.3))
                        .frame(
                            width: geometry.size.width * normalWidth,
                            height: 8
                        )
                        .offset(x: geometry.size.width * normalStart)
                    
                    // Indicador actual
                    Circle()
                        .fill(colorActual)
                        .frame(width: 16, height: 16)
                        .offset(x: geometry.size.width * posicionIndicador - 8)
                        .shadow(color: colorActual.opacity(0.5), radius: 4)
                }
            }
            .frame(height: 16)
            
            // Labels de rango
            HStack {
                Text("50")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Normal: 70-180")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("400")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Editor Sheet
struct GlucosaEditorSheet: View {
    let glucosaActual: Double
    let onSave: (Double) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var nuevaGlucosa: String
    @State private var errorMessage: String?
    
    init(glucosaActual: Double, onSave: @escaping (Double) -> Void) {
        self.glucosaActual = glucosaActual
        self.onSave = onSave
        self._nuevaGlucosa = State(initialValue: String(Int(glucosaActual)))
    }
    
    private var glucosaValida: Double? {
        guard let valor = Double(nuevaGlucosa),
              valor >= AppConstants.Glucosa.minima,
              valor <= AppConstants.Glucosa.maxima else {
            return nil
        }
        return valor
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header
                VStack(spacing: 6) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    
                    Text("Actualizar Glucosa")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Ingresa tu nivel actual de glucosa en sangre")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                // Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Glucosa (mg/dL)")
                        .font(.headline)
                    
                    HStack {
                        TextField("110", text: $nuevaGlucosa)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title2)
                        
                        Text("mg/dL")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Text("Rango válido: \(Int(AppConstants.Glucosa.minima))-\(Int(AppConstants.Glucosa.maxima)) mg/dL")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Preview
                if let glucosaPreview = glucosaValida {
                    let categoria = AppConstants.Glucosa.categoriaGlucosa(glucosaPreview)
            
                    VStack(spacing: 8) {
                        Text("Vista previa:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(categoria.emoji)
                                .font(.title)
                            
                            VStack(alignment: .leading) {
                                Text("\(Int(glucosaPreview)) mg/dL")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(categoria.color)
                                
                                Text(categoria.categoria)
                                    .font(.caption)
                                    .foregroundColor(categoria.color)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(categoria.color.opacity(0.1))
                        )
                    }
                }

                
       
                
                // Botones rápidos
                VStack(spacing: 12) {
                    Text("Valores comunes:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach([80, 100, 120, 140, 160, 180], id: \.self) { valor in
                            Button(action: { nuevaGlucosa = String(valor) }) {
                                Text("\(valor)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Glucosa")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    guardarGlucosa()
                }
                .disabled(glucosaValida == nil)
            )
        }
        .onChange(of: nuevaGlucosa) { 
            validarGlucosa()
        }
    }
    
    private func validarGlucosa() {
        errorMessage = nil
        
        guard let valor = Double(nuevaGlucosa) else {
            errorMessage = "Ingresa un número válido"
            return
        }
        
        if valor < AppConstants.Glucosa.minima {
            errorMessage = "Valor muy bajo (mínimo: \(Int(AppConstants.Glucosa.minima)))"
        } else if valor > AppConstants.Glucosa.maxima {
            errorMessage = "Valor muy alto (máximo: \(Int(AppConstants.Glucosa.maxima)))"
        }
    }
    
    private func guardarGlucosa() {
        guard let glucosa = glucosaValida else { return }
        
        onSave(glucosa)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    GlucosaActualCard(glucosaManager: GlucosaManager.shared)
        .padding()
        .background(Color(.systemGroupedBackground))
}
