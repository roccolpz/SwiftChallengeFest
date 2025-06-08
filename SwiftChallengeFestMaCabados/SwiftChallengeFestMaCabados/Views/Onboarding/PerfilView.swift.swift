//
//  PerfilView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct PerfilView: View {
    @StateObject private var perfilManager = PerfilUsuarioManager.shared
    @StateObject private var glucosaManager = GlucosaManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showingEditPerfil = false
    @State private var showingResetAlert = false
    @State private var showingExportSheet = false
    @State private var reporteGenerado = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header del perfil
                    perfilHeader
                    
                    // Información personal
                    informacionPersonalCard
                    
                    // Información médica (si es diabético)
                    if perfilManager.perfil.esDiabetico {
                        informacionMedicaCard
                    }
                    
                    // Estadísticas de uso
                    estadisticasUsoCard
                    
                    // Preferencias y configuración
                    preferenciasCard
                    
                    // Acciones
                    accionesCard
                    
                    // Información de la app
                    infoAppCard
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Mi Perfil")
            .navigationBarItems(
                leading: Button("Cerrar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Editar") {
                    showingEditPerfil = true
                }
            )
        }
        .sheet(isPresented: $showingEditPerfil) {
            EditarPerfilView()
        }
        .sheet(isPresented: $showingExportSheet) {
            ShareSheet(activityItems: [reporteGenerado])
        }
        .alert("Resetear Perfil", isPresented: $showingResetAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Resetear", role: .destructive) {
                perfilManager.resetearPerfil()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("¿Estás seguro de que quieres resetear tu perfil? Esta acción no se puede deshacer.")
        }
    }
    
    // MARK: - Perfil Header
    private var perfilHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ColorHelper.Principal.primario, ColorHelper.Principal.secundario],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(perfilManager.perfil.nombre.prefix(1).uppercased())
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Nombre y edad
            VStack(spacing: 4) {
                Text(perfilManager.perfil.nombre.isEmpty ? "Usuario" : perfilManager.perfil.nombre)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(perfilManager.perfil.edad) años • \(perfilManager.perfil.genero.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Badge de diabetes
            if perfilManager.perfil.esDiabetico {
                HStack(spacing: 8) {
                    Image(systemName: "cross.fill")
                        .font(.caption)
                    
                    Text(perfilManager.perfil.tipoDiabetes?.rawValue ?? "Diabetes")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ColorHelper.Estados.info)
                )
            }
        }
    }
    
    // MARK: - Información Personal Card
    private var informacionPersonalCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader(title: "Información Personal", icon: "person.circle")
            
            VStack(spacing: 12) {
                InfoRow(label: "Peso", value: "\(perfilManager.perfil.peso) kg")
                InfoRow(label: "Altura", value: "\(perfilManager.perfil.altura) cm")
                InfoRow(label: "IMC", value: "\(perfilManager.perfil.imc) (\(perfilManager.categoriaIMC.categoria))")
            }
        }
        .cardStyle()
    }
    
    // MARK: - Información Médica Card
    private var informacionMedicaCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader(title: "Información Médica", icon: "cross.case")
            
            VStack(spacing: 12) {
                InfoRow(label: "Tipo de Diabetes", value: perfilManager.perfil.tipoDiabetes?.rawValue ?? "No especificado")
                
                if let glucosaObjetivo = perfilManager.perfil.glucosaObjetivo {
                    InfoRow(label: "Glucosa Objetivo", value: glucosaObjetivo.glucosaFormat)
                }
                
                if let insulina = perfilManager.perfil.insulinaBasalDiaria {
                    InfoRow(label: "Insulina Basal Diaria", value: insulina.insulinaFormat)
                    
                    let ratios = perfilManager.ratiosCalculados
                    if let ic = ratios.ic {
                        InfoRow(label: "Ratio I:C", value: "1:\(ic)g")
                    }
                    if let sensibilidad = ratios.sensibilidad {
                        InfoRow(label: "Factor Sensibilidad", value: "\(sensibilidad) mg/dL/U")
                    }
                }
                
                // Dispositivos
                if perfilManager.perfil.usaBombaInsulina || perfilManager.perfil.usaMonitorContinuo {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dispositivos:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        if perfilManager.perfil.usaBombaInsulina {
                            Text("• Bomba de Insulina")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if perfilManager.perfil.usaMonitorContinuo {
                            Text("• Monitor Continuo de Glucosa")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Medicamentos
                if !perfilManager.perfil.medicamentos.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Medicamentos:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ForEach(perfilManager.perfil.medicamentos, id: \.self) { medicamento in
                            Text("• \(medicamento)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - Estadísticas de Uso Card
    private var estadisticasUsoCard: some View {
        let estadisticas = glucosaManager.estadisticasDelDia()
        
        return VStack(alignment: .leading, spacing: 16) {
            CardHeader(title: "Estadísticas de Hoy", icon: "chart.bar")
            
            VStack(spacing: 12) {
                HStack {
                    StatMiniCard(titulo: "Promedio", valor: estadisticas.promedio.glucosaFormat, color: .blue)
                    Spacer()
                    StatMiniCard(titulo: "Tiempo en Rango", valor: "\(Int(estadisticas.tiempoEnRango))%", color: .green)
                }
                
                HStack {
                    StatMiniCard(titulo: "Mínimo", valor: estadisticas.minimo.glucosaFormat, color: .orange)
                    Spacer()
                    StatMiniCard(titulo: "Máximo", valor: estadisticas.maximo.glucosaFormat, color: .red)
                }
                
                InfoRow(label: "Mediciones", value: "\(estadisticas.mediciones)")
            }
        }
        .cardStyle()
    }
    
    // MARK: - Preferencias Card
    private var preferenciasCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader(title: "Preferencias", icon: "gear")
            
            VStack(spacing: 12) {
                // Horarios
                VStack(alignment: .leading, spacing: 8) {
                    Text("Horarios de Comida:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        HorarioMiniCard(tipo: "🌅 Desayuno", hora: perfilManager.perfil.horarioDesayuno.horaFormat)
                        Spacer()
                        HorarioMiniCard(tipo: "☀️ Comida", hora: perfilManager.perfil.horarioComida.horaFormat)
                        Spacer()
                        HorarioMiniCard(tipo: "🌙 Cena", hora: perfilManager.perfil.horarioCena.horaFormat)
                    }
                }
                
                // Restricciones dietéticas
                if !perfilManager.perfil.restriccionesDieteticas.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Restricciones Dietéticas:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(perfilManager.perfil.restriccionesDieteticas.map { $0.rawValue }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Alergias
                if !perfilManager.perfil.alergias.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alergias:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                        
                        Text(perfilManager.perfil.alergias.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .cardStyle()
    }
    
    // MARK: - Acciones Card
    private var accionesCard: some View {
        VStack(spacing: 12) {
            // Exportar reporte
            Button(action: {
                reporteGenerado = perfilManager.generarReportePerfil()
                showingExportSheet = true
            }) {
                ActionButton(
                    icon: "square.and.arrow.up",
                    title: "Exportar Reporte",
                    subtitle: "Comparte tu información médica",
                    color: .blue
                )
            }
            
            // Reconfigurar
            Button(action: {
                perfilManager.requiereOnboarding = true
                presentationMode.wrappedValue.dismiss()
            }) {
                ActionButton(
                    icon: "arrow.clockwise",
                    title: "Reconfigurar Perfil",
                    subtitle: "Volver a hacer el setup inicial",
                    color: .orange
                )
            }
            
            // Reset (peligroso)
            Button(action: {
                showingResetAlert = true
            }) {
                ActionButton(
                    icon: "trash",
                    title: "Resetear Perfil",
                    subtitle: "Eliminar todos los datos",
                    color: .red
                )
            }
        }
        .cardStyle()
    }
    
    // MARK: - Info App Card
    private var infoAppCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardHeader(title: "Información de la App", icon: "info.circle")
            
            VStack(spacing: 8) {
                InfoRow(label: "Versión", value: AppConstants.App.version)
                InfoRow(label: "Desarrollado por", value: AppConstants.App.desarrollador)
                InfoRow(label: "Soporte", value: AppConstants.App.email)
            }
        }
        .cardStyle()
    }
}

// MARK: - Card Components

struct CardHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(ColorHelper.Principal.primario)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct StatMiniCard: View {
    let titulo: String
    let valor: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(valor)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(titulo)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HorarioMiniCard: View {
    let tipo: String
    let hora: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(tipo)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(hora)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(ColorHelper.Principal.primario)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Card Style Extension
extension View {
    func cardStyle() -> some View {
        self
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
    }
}

// MARK: - Edit Perfil View (Placeholder)
struct EditarPerfilView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("✏️")
                    .font(.system(size: 64))
                
                Text("Editar Perfil")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Próximamente: Edición rápida de datos personales y configuración médica")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Editar")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    PerfilView()
}
