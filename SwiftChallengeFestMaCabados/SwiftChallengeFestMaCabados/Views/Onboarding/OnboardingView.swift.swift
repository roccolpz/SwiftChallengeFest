//
//  OnboardingView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct OnboardingView: View {
    @StateObject private var perfilManager = PerfilUsuarioManager.shared
    @State private var currentStep: OnboardingStep = .bienvenida
    @State private var isCompleting = false
    @State private var showingCompleted = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo con gradiente
                LinearGradient(
                    colors: [
                        ColorHelper.Principal.primario.opacity(0.1),
                        ColorHelper.Principal.secundario.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress indicator
                    if currentStep != .bienvenida {
                        progressIndicator
                            .padding(.top, 20)
                            .padding(.horizontal, 20)
                    }
                    
                    // Content
                    TabView(selection: $currentStep) {
                        // Bienvenida
                        BienvenidaView(onNext: nextStep)
                            .tag(OnboardingStep.bienvenida)
                        
                        // Datos básicos
                        DatosBasicosView(
                            perfil: $perfilManager.perfil,
                            onNext: nextStep,
                            onBack: previousStep
                        )
                        .tag(OnboardingStep.datosBasicos)
                        
                        // Configuración diabetes
                        DiabetesConfigView(
                            perfil: $perfilManager.perfil,
                            onNext: nextStep,
                            onBack: previousStep
                        )
                        .tag(OnboardingStep.diabetes)
                        
                        // Horarios de comida
                        HorariosComidaView(
                            perfil: $perfilManager.perfil,
                            onNext: nextStep,
                            onBack: previousStep
                        )
                        .tag(OnboardingStep.horarios)
                        
                        // Alimentos frecuentes
                        
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
        }
        .navigationBarHidden(true)
        .overlay(
            // Loading overlay
            Group {
                if isCompleting {
                    completingOverlay
                }
            }
        )
        .fullScreenCover(isPresented: $showingCompleted) {
            OnboardingCompletadoView {
                // Cerrar completamente el onboarding
                showingCompleted = false
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases.filter { $0 != .bienvenida }, id: \.self) { step in
                Circle()
                    .fill(step.rawValue <= currentStep.rawValue ? ColorHelper.Principal.primario : Color(.systemGray4))
                    .frame(width: 12, height: 12)
                    .scaleEffect(step == currentStep ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.8), value: currentStep)
            }
        }
        .padding(.bottom, 20)
    }
    
    // MARK: - Completing Overlay
    private var completingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("Configurando tu perfil...")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("¡Ya casi terminamos!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            .padding(.horizontal, 40)
        }
    }
    
    // MARK: - Navigation Methods
    private func nextStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let nextStep = currentStep.next {
                currentStep = nextStep
            }
        }
    }
    
    private func previousStep() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let previousStep = currentStep.previous {
                currentStep = previousStep
            }
        }
    }
    
    private func completarOnboarding() {
        isCompleting = true
        
        // Simular tiempo de configuración
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            perfilManager.completarOnboarding()
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isCompleting = false
                showingCompleted = true
            }
        }
    }
}

// MARK: - Onboarding Steps
enum OnboardingStep: Int, CaseIterable {
    case bienvenida = 0
    case datosBasicos = 1
    case diabetes = 2
    case horarios = 3
    case alimentos = 4
    
    var next: OnboardingStep? {
        OnboardingStep(rawValue: self.rawValue + 1)
    }
    
    var previous: OnboardingStep? {
        OnboardingStep(rawValue: self.rawValue - 1)
    }
    
    var title: String {
        switch self {
        case .bienvenida: return "Bienvenido"
        case .datosBasicos: return "Datos Básicos"
        case .diabetes: return "Información Médica"
        case .horarios: return "Horarios de Comida"
        case .alimentos: return "Preferencias"
        }
    }
}

// MARK: - Bienvenida View
struct BienvenidaView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Logo y título
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(ColorHelper.Principal.primario.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(ColorHelper.Principal.primario)
                }
                
                VStack(spacing: 16) {
                    Text("GlucoPredict")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(ColorHelper.Principal.primario)
                    
                    Text("¡Bienvenido!")
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .lineLimit(4)
                        .padding(.horizontal, 20)
                }
            }
            
            // Características principales
            VStack(spacing: 20) {
                FeatureRowComida(
                    icon: "waveform.path.ecg",
                    title: "Predicciones Precisas",
                    description: "Predice tu glucosa antes de comer",
                    color: .blue
                )
                
                FeatureRowComida(
                    icon: "fork.knife",
                    title: "Orden Optimizado",
                    description: "Aprende el mejor orden para comer",
                    color: .green
                )
                
                FeatureRowComida(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Seguimiento Inteligente",
                    description: "Monitorea tus patrones de glucosa",
                    color: .orange
                )
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Botón comenzar
            Button(action: onNext) {
                HStack {
                    Text("Desliza para comenzar")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(ColorHelper.Principal.primario)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRowComida: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Navigation Button Style
struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingView()
}
