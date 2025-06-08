//
//  DashboardView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct DashboardView: View {
    @StateObject private var glucosaManager = GlucosaManager.shared
    @StateObject private var perfilManager = PerfilUsuarioManager.shared
    @State private var showingPredictor = false
    @State private var showingPerfil = false
    @State private var showingNoticias = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Header personalizado
                    headerPersonalizado
                    
                    // Acciones rápidas
                    accionesRapidas
                    
                    // Card principal de glucosa
                    GlucosaActualCard(glucosaManager: glucosaManager)
                    
                    // Gráfica de historial
                    GraficaGlucosaCard(glucosaManager: glucosaManager)
                    
                    // Botón principal - Predictor
                    botonPredictor
                    
                    HistorialComidasCard()
                    
                    
                    
                    // Resumen del día
                    resumenDelDia
                    
                    // Spacer final
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("")
            .navigationBarHidden(true)
            .refreshable {
                await actualizarDatos()
            }
        }
        .sheet(isPresented: $showingPredictor) {
            PredictorComidaView()
        }
        .sheet(isPresented: $showingPerfil) {
            // TODO: Vista de perfil
            PerfilView()
        }
        .sheet(isPresented: $showingNoticias) {
            DiabetesNewsView()
        }
        .onAppear {
            verificarConfiguracion()
        }
    }
    
    // MARK: - Header Personalizado
    private var headerPersonalizado: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(saludoPersonalizado)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if !perfilManager.perfil.nombre.isEmpty {
                    Text(perfilManager.perfil.nombre)
                        .font(.title)
                        .fontWeight(.bold)
                } else {
                    Text("Bienvenido")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Text("¿Cómo está tu glucosa hoy?")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Avatar/Perfil
            Button(action: { showingPerfil = true }) {
                ZStack {
                    Circle()
                        .fill(ColorHelper.Principal.primario.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    if perfilManager.perfil.esDiabetico {
                        Image(systemName: "cross.fill")
                            .font(.title3)
                            .foregroundColor(ColorHelper.Principal.primario)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.title3)
                            .foregroundColor(ColorHelper.Principal.primario)
                    }
                }
            }
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Botón Predictor
    private var botonPredictor: some View {
        Button(action: { showingPredictor = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.orange)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Registra tu Comida")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Predice tu glucosa antes de comer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: ColorHelper.Principal.primario.opacity(0.2), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PresionadoButtonStyle())
    }
    
    // MARK: - Acciones Rápidas
    private var accionesRapidas: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Acciones Rápidas")
                .font(.headline)
                .padding(.horizontal, 4)
            
            // Primera fila
            HStack(spacing: 12) {
                AccionRapidaCard(
                    titulo: "Simular",
                    subtitulo: "Medición",
                    icono: "chart.bar.fill",
                    color: .blue
                ) {
                    glucosaManager.simularMedicionAutomatica()
                }
                
                AccionRapidaCard(
                    titulo: "Meal Planner",
                    subtitulo: "Recomendación del chef",
                    icono: "frying.pan",
                    color: .green
                ) {
                    print("📊 Estadísticas del día")
                }
            }
            
            HStack(spacing: 12) {
                AccionRapidaCard(
                    titulo: "Noticias",
                    subtitulo: "Diabetes",
                    icono: "newspaper.fill",
                    color: .orange
                ) {
                    showingNoticias = true
                }
                
                AccionRapidaCard(
                    titulo: "Configurar",
                    subtitulo: "Perfil",
                    icono: "person.fill",
                    color: .gray
                ) {
                    showingPerfil = true
                }
            }
        }
    }
    
    // MARK: - Resumen del Día
    private var resumenDelDia: some View {
        let estadisticas = glucosaManager.estadisticasDelDia()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Resumen del Día")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                // Tiempo en rango
                HStack {
                    Text("Tiempo en rango (70-180)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(estadisticas.tiempoEnRango))%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(estadisticas.tiempoEnRango >= 70 ? .green : .orange)
                }
                
                // Barra de progreso
                ProgressView(value: estadisticas.tiempoEnRango, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: estadisticas.tiempoEnRango >= 70 ? .green : .orange))
                
                Divider()
                
                // Estadísticas adicionales
                HStack {
                    StatCard(titulo: "Promedio", valor: estadisticas.promedio.glucosaFormat)
                    Spacer()
                    StatCard(titulo: "Mínimo", valor: estadisticas.minimo.glucosaFormat)
                    Spacer()
                    StatCard(titulo: "Máximo", valor: estadisticas.maximo.glucosaFormat)
                }
                
                if perfilManager.perfil.esDiabetico {
                    Divider()
                    
                    HStack {
                        Text("Objetivo: \(perfilManager.perfil.glucosaObjetivo?.glucosaFormat ?? "110 mg/dL")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(estadisticas.mediciones) mediciones")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
    }
    
    // MARK: - Computed Properties
    private var saludoPersonalizado: String {
        let hora = Calendar.current.component(.hour, from: Date())
        
        switch hora {
        case 5..<12: return "Buenos días"
        case 12..<18: return "Buenas tardes"
        default: return "Buenas noches"
        }
    }
    
    // MARK: - Methods
    private func verificarConfiguracion() {
        if perfilManager.requiereOnboarding {
            // TODO: Mostrar onboarding
            print("🚀 Requiere onboarding")
        }
    }
    
    @MainActor
    private func actualizarDatos() async {
        // Simular actualización de datos
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 segundo
        glucosaManager.simularMedicionAutomatica()
    }
}

// MARK: - Componentes Auxiliares

struct AccionRapidaCard: View {
    let titulo: String
    let subtitulo: String
    let icono: String
    let color: Color
    let accion: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    private var shadowColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.3)
            : Color.black.opacity(0.1)
    }

    
    var body: some View {
        Button(action: accion) {
            VStack(spacing: 8) {
                Image(systemName: icono)
                    .font(.title2)
                    .foregroundColor(color)
                
                VStack(spacing: 2) {
                    Text(titulo)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitulo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(PresionadoButtonStyle())
        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)

    }
}

struct StatCard: View {
    let titulo: String
    let valor: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(valor)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Button Style
struct PresionadoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    DashboardView()
}
