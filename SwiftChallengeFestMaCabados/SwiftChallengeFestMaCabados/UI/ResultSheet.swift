//
//  ResultSheet.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Rocco López on 07/06/25.
//

import SwiftUI

struct ResultSheet: View {
    @Environment(\.dismiss) var dismiss
    var result: PredictionResult
    
    var body: some View {
        
        if result.isValid {
            
            VStack(spacing: 40) {
                // Indicador de drag
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 8)
                
                Spacer()
                
                // Resultado
                VStack(spacing: 16) {
                    Text("¿Es esto correcto?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text(result.label)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Botones
                VStack(spacing: 16) {
                    // Botón Continuar
                    Button(action: {
                        // No hace nada, solo queda ahí
                    }) {
                        Text("Continuar")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    // Botón Cancelar
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Esa no es mi comida")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 80)
            }
            .background()
            .presentationDetents([.fraction(0.4)])
            .presentationDragIndicator(.hidden)
        }else{
            VStack(spacing: 40) {
                // Indicador de drag
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 6)
                    .padding(.top, 8)
                
                Spacer()
                
                // Resultado
                VStack(spacing: 16) {
                    
                    Text("¡No encontré nada!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Botones
                VStack(spacing: 16) {
                    // Botón Continuar
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Intentar de nuevo")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 80)
            }
            .background()
            .presentationDetents([.fraction(0.3)])
            .presentationDragIndicator(.hidden)
        }
    }
}

#Preview {
    Color.cyan.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ResultSheet(result: PredictionResult(isValid: false, label: "Pizza", confidence: 85))
        }
}
