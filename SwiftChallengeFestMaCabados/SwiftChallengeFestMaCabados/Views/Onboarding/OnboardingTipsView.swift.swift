//
//  OnboardingTipsView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct OnboardingTipsView: View {
    let step: OnboardingStep
    @Environment(\.presentationMode) var presentationMode
    
    private var stepTips: [OnboardingTip] {
        switch step {
        case .bienvenida:
            return []
        case .datosBasicos:
            return [
                OnboardingTip(
                    icon: "person.circle",
                    title: "Información Personal",
                    description: "Usamos tu peso y altura para cálculos precisos de insulina y metabolismo",
                    color: .blue
                ),
                OnboardingTip(
                    icon: "scalemass",
                    title: "Peso Actual",
                    description: "Usa tu peso más reciente. Puedes actualizarlo después en el perfil",
                    color: .green
                ),
                OnboardingTip(
                    icon: "ruler",
                    title: "Altura",
                    description: "Tu altura nos ayuda a calcular el IMC y ajustar recomendaciones",
                    color: .orange
                )
            ]
        case .diabetes:
            return [
                OnboardingTip(
                    icon: "cross.case",
                    title: "Tipo de Diabetes",
                    description: "Diferentes tipos requieren estrategias distintas de manejo",
                    color: .red
                ),
                OnboardingTip(
                    icon: "target",
                    title: "Glucosa Objetivo",
                    description: "Un rango típico es 80-130 mg/dL antes de comidas",
                    color: .blue
                ),
                OnboardingTip(
                    icon: "syringe",
                    title: "Dosis de Insulina",
                    description: "Si no la conoces, revisa con tu médico o farmacia",
                    color: .purple
                ),
                OnboardingTip(
                    icon: "gear.badge",
                    title: "Dispositivos Médicos",
                    description: "Bombas y monitores mejoran la precisión de las predicciones",
                    color: .green
                )
            ]
        case .horarios:
            return [
                OnboardingTip(
                    icon: "clock",
                    title: "Horarios Regulares",
                    description: "Comidas a la misma hora mejoran el control glucémico",
                    color: .blue
                ),
                OnboardingTip(
                    icon: "sunrise",
                    title: "Fenómeno del Amanecer",
                    description: "La glucosa tiende a subir en las mañanas naturalmente",
                    color: .orange
                ),
                OnboardingTip(
                    icon: "moon",
                    title: "Cenas Tempranas",
                    description: "Evita comer muy tarde para mejor control nocturno",
                    color: .purple
                ),
                OnboardingTip(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Patrones Personales",
                    description: "Cada persona tiene ritmos circadianos únicos",
                    color: .green
                )
            ]
        case .alimentos:
            return [
                OnboardingTip(
                    icon: "fork.knife",
                    title: "Alimentos Frecuentes",
                    description: "Selecciona comidas que consumes regularmente para sugerencias personalizadas",
                    color: .blue
                ),
                OnboardingTip(
                    icon: "shield.checkered",
                    title: "Restricciones Dietéticas",
                    description: "Ayudan a filtrar alimentos y recetas no adecuadas para ti",
                    color: .green
                ),
                OnboardingTip(
                    icon: "exclamationmark.triangle",
                    title: "Alergias Alimentarias",
                    description: "Importante para evitar ingredientes peligrosos en recomendaciones",
                    color: .red
                ),
                OnboardingTip(
                    icon: "leaf",
                    title: "Verduras Primero",
                    description: "El orden de comida puede reducir picos de glucosa hasta 37%",
                    color: .green
                )
            ]
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Text("💡")
                            .font(.system(size: 64))
                        
                        Text("Consejos y Tips")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Información útil para completar este paso")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Tips
                    LazyVStack(spacing: 16) {
                        ForEach(Array(stepTips.enumerated()), id: \.offset) { index, tip in
                            OnboardingTipCard(tip: tip, index: index)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // General tips
                    if !stepTips.isEmpty {
                        generalTipsSection
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Ayuda - \(step.title)")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var generalTipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                
                Text("Consejos Generales")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                GeneralTipRow(
                    icon: "checkmark.circle",
                    text: "Puedes cambiar cualquier configuración después en tu perfil",
                    color: .green
                )
                
                GeneralTipRow(
                    icon: "arrow.left.arrow.right",
                    text: "Usa los botones 'Anterior' y 'Siguiente' para navegar",
                    color: .blue
                )
                
                GeneralTipRow(
                    icon: "questionmark.circle",
                    text: "Si tienes dudas médicas, consulta con tu profesional de salud",
                    color: .orange
                )
                
                GeneralTipRow(
                    icon: "shield.checkered",
                    text: "Tu información se guarda de forma segura en tu dispositivo",
                    color: .purple
                )
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
    }
}

// MARK: - Onboarding Tip Model
struct OnboardingTip {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Onboarding Tip Card
struct OnboardingTipCard: View {
    let tip: OnboardingTip
    let index: Int
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(tip.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: tip.icon)
                    .font(.title3)
                    .foregroundColor(tip.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(tip.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(tip.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: tip.color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isVisible ? 1.0 : 0.8)
        .opacity(isVisible ? 1.0 : 0.0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8)
            .delay(Double(index) * 0.1),
            value: isVisible
        )
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - General Tip Row
struct GeneralTipRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Tips Button Component (for use in onboarding views)
struct OnboardingTipsButton: View {
    let step: OnboardingStep
    @State private var showingTips = false
    
    var body: some View {
        Button(action: { showingTips = true }) {
            HStack(spacing: 6) {
                Image(systemName: "questionmark.circle")
                Text("Tips")
            }
            .font(.subheadline)
            .foregroundColor(ColorHelper.Principal.primario)
        }
        .sheet(isPresented: $showingTips) {
            OnboardingTipsView(step: step)
        }
    }
}

#Preview {
    OnboardingTipsView(step: .diabetes)
}