//
//  OnboardingCompletadoView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct OnboardingCompletadoView: View {
    @StateObject private var perfilManager = PerfilUsuarioManager.shared
    let onComplete: () -> Void
    
    @State private var showingAnimation = false
    @State private var currentFeatureIndex = 0
    
    private let features = [
        FeatureHighlight(
            icon: "waveform.path.ecg",
            title: "Predicciones Precisas",
            description: "Predice tu glucosa antes de comer con algoritmos basados en estudios clínicos",
            color: .blue
        ),
        FeatureHighlight(
            icon: "fork.knife",
            title: "Orden Optimizado",
            description: "Aprende el mejor orden para comer y reduce picos de glucosa hasta 37%",
            color: .green
        ),
        FeatureHighlight(
            icon: "chart.line.uptrend.xyaxis",
            title: "Seguimiento Inteligente",
            description: "Monitorea tus patrones y mejora el control de tu glucosa día a día",
            color: .orange
        )
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo con gradiente animado
                AnimatedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Animación de éxito
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(ColorHelper.Estados.exito.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .scaleEffect(showingAnimation ? 1.2 : 0.8)
                                .opacity(showingAnimation ? 0.6 : 0.2)
                                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: showingAnimation)
                            
                            Circle()
                                .fill(ColorHelper.Estados.exito)
                                .frame(width: 80, height: 80)
                                .scaleEffect(showingAnimation ? 1.0 : 0.6)
                                .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: showingAnimation)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(showingAnimation ? 1.0 : 0.0)
                                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.8), value: showingAnimation)
                        }
                        
                        VStack(spacing: 16) {
                            Text("¡Perfil Completado!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .scaleEffect(showingAnimation ? 1.0 : 0.8)
                                .opacity(showingAnimation ? 1.0 : 0.0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(1.0), value: showingAnimation)
                            
                            Text("Tu cuenta está lista, \(perfilManager.perfil.nombre)")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .scaleEffect(showingAnimation ? 1.0 : 0.8)
                                .opacity(showingAnimation ? 1.0 : 0.0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(1.2), value: showingAnimation)
                        }
                    }
                    
                    // Features carousel
                    VStack(spacing: 20) {
                        Text("¿Qué puedes hacer ahora?")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .opacity(showingAnimation ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.6).delay(1.5), value: showingAnimation)
                        
                        TabView(selection: $currentFeatureIndex) {
                            ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                                FeatureHighlightCard(feature: feature)
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: 200)
                        .opacity(showingAnimation ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.6).delay(1.8), value: showingAnimation)
                        
                        // Auto-advance features
                        .onReceive(Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()) { _ in
                            withAnimation(.easeInOut(duration: 0.5)) {
                                currentFeatureIndex = (currentFeatureIndex + 1) % features.count
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Call to action
                    VStack(spacing: 16) {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                onComplete()
                            }
                        }) {
                            HStack {
                                Text("Comenzar a usar GlucoPredict")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "arrow.right")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [ColorHelper.Principal.primario, ColorHelper.Principal.secundario],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                        }
                        .scaleEffect(showingAnimation ? 1.0 : 0.8)
                        .opacity(showingAnimation ? 1.0 : 0.0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(2.2), value: showingAnimation)
                        
                        Text("Siempre puedes cambiar tu configuración desde el perfil")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(showingAnimation ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.6).delay(2.5), value: showingAnimation)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            withAnimation {
                showingAnimation = true
            }
        }
    }
}

// MARK: - Feature Highlight
struct FeatureHighlight {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Feature Highlight Card
struct FeatureHighlightCard: View {
    let feature: FeatureHighlight
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(feature.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(feature.color)
            }
            
            VStack(spacing: 8) {
                Text(feature.title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(feature.color.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - Animated Background
struct AnimatedBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                ColorHelper.Principal.primario.opacity(animateGradient ? 0.3 : 0.1),
                ColorHelper.Principal.secundario.opacity(animateGradient ? 0.2 : 0.05),
                ColorHelper.Principal.acento.opacity(animateGradient ? 0.1 : 0.03)
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Confetti Effect (Bonus)
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                ConfettiPiece()
                    .offset(
                        x: animate ? CGFloat.random(in: -200...200) : 0,
                        y: animate ? CGFloat.random(in: -300...500) : -50
                    )
                    .rotationEffect(.degrees(animate ? Double.random(in: 0...360) : 0))
                    .scaleEffect(animate ? CGFloat.random(in: 0.5...1.5) : 1)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2...4))
                        .delay(Double.random(in: 0...2))
                        .repeatForever(autoreverses: false),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    private let colors: [Color] = [
        .red, .blue, .green, .yellow, .purple, .orange, .pink
    ]
    
    var body: some View {
        Rectangle()
            .fill(colors.randomElement() ?? .blue)
            .frame(width: 10, height: 10)
            .cornerRadius(2)
    }
}

#Preview {
    OnboardingCompletadoView(onComplete: {
        print("Onboarding completed!")
    })
}