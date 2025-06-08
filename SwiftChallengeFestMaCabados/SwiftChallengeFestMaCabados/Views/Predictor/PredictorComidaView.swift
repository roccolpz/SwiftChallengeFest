//
//  PredictorComidaView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct PredictorComidaView: View {
    @StateObject private var viewModel = PredictorViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("🍽️")
                        .font(.system(size: 48))
                    
                    Text("Predictor de Glucosa")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Próximamente: Selecciona alimentos y ve cómo afectarán tu glucosa")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Características principales
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "fork.knife", title: "Selección de Alimentos", description: "Base de datos con 100+ alimentos")
                    FeatureRow(icon: "arrow.up.arrow.down", title: "Orden de Comida", description: "Verduras → Proteínas → Carbohidratos")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Predicción Precisa", description: "Algoritmos basados en estudios clínicos")
                    FeatureRow(icon: "lightbulb", title: "Recomendaciones", description: "Consejos personalizados para mejor control")
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Demo data
                VStack(spacing: 12) {
                    Text("Datos de demostración:")
                        .font(.headline)
                    
                    Text("Total alimentos: \(viewModel.alimentosSeleccionados.count)")
                    Text("Macronutrientes calculados: ✅")
                    Text("Predicción lista: ⏳")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                
                // Botón demo
                Button(action: {
                    // Demo: agregar un alimento
                    if let arroz = AlimentosManager.shared.alimentos.first(where: { $0.nombre.contains("Arroz") }) {
                        viewModel.agregarAlimento(arroz, gramos: 100)
                    }
                }) {
                    Text("🍚 Agregar Arroz (Demo)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ColorHelper.Principal.primario)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .navigationTitle("Predictor")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ColorHelper.Principal.primario)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    PredictorComidaView()
}
