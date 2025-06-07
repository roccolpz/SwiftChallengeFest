//
//  DashboardView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct DashboardView: View {
    @StateObject private var glucosaManager = GlucosaManager()
    @State private var showingPredictor = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Glucosa actual
                    GlucosaActualCard(glucosa: glucosaManager.glucosaActual)
                    
                    // Botón principal
                    Button(action: { showingPredictor = true }) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .font(.title2)
                            Text("¿Qué vas a comer?")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Placeholder para otras cards
                    Text("Más funciones próximamente...")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("Tu Glucosa")
            .sheet(isPresented: $showingPredictor) {
                PredictorComidaView()
            }
        }
    }
}

#Preview {
    DashboardView()
}
