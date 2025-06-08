//
//  PerfilView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct PerfilView: View {
    @StateObject private var glucosaManager = GlucosaManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var perfil = PerfilUsuario()
    
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
                    if perfil.esDiabetico {
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
            
        } message: {
            Text("¿Estás seguro de que quieres resetear tu perfil? Esta acción no se puede deshacer.")
        }
    }
    
    // MARK: - Perfil Header
    private var perfilHeader: some View {
        VStack(spacing: 16) {
            
            // Nombre y edad
            VStack(spacing: 4) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width:150, height:150)
                
                Text(perfil.nombre.isEmpty ? "Usuario" : perfil.nombre)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("\(perfil.edad) años • \(perfil.genero.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .onAppear {
                let perfilUsuario : PerfilUsuario? = cargarPerfil()
                if perfilUsuario != nil {
                    perfil = perfilUsuario.unsafelyUnwrapped
                }
            }
            
            // Badge de diabetes
            if perfil.esDiabetico {
                HStack(spacing: 8) {
                    Image(systemName: "cross.fill")
                        .font(.caption)
                    
                    Text(perfil.tipoDiabetes?.rawValue ?? "Diabetes")
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
                InfoRow(label: "Peso", value: "\(perfil.peso) kg")
                InfoRow(label: "Altura", value: "\(perfil.altura) cm")
                InfoRow(label: "IMC", value: "\(perfil.imc)")
            }
        }
        .cardStyle()
        
    }
    
    // MARK: - Información Médica Card
    private var informacionMedicaCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            CardHeader(title: "Información Médica", icon: "cross.case")
            
            VStack(spacing: 12) {
                InfoRow(label: "Tipo de Diabetes", value: perfil.tipoDiabetes?.rawValue ?? "No especificado")
                
                if let glucosaObjetivo = perfil.glucosaObjetivo {
                    InfoRow(label: "Glucosa Objetivo", value: glucosaObjetivo.glucosaFormat)
                }
                
                if let insulina = perfil.insulinaBasalDiaria {
                    InfoRow(label: "Insulina Basal Diaria", value: insulina.insulinaFormat)
                    
                    
                }
                
                // Dispositivos
                if perfil.usaBombaInsulina || perfil.usaMonitorContinuo {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Dispositivos:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        if perfil.usaBombaInsulina {
                            Text("• Bomba de Insulina")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if perfil.usaMonitorContinuo {
                            Text("• Monitor Continuo de Glucosa")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Medicamentos
                if !perfil.medicamentos.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Medicamentos:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ForEach(perfil.medicamentos, id: \.self) { medicamento in
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
                        HorarioMiniCard(tipo: "🌅 Desayuno", hora: perfil.horarioDesayuno.horaFormat)
                        Spacer()
                        HorarioMiniCard(tipo: "☀️ Comida", hora: perfil.horarioComida.horaFormat)
                        Spacer()
                        HorarioMiniCard(tipo: "🌙 Cena", hora: perfil.horarioCena.horaFormat)
                    }
                }
                
                // Restricciones dietéticas
                if !perfil.restriccionesDieteticas.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Restricciones Dietéticas:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text(perfil.restriccionesDieteticas.map { $0.rawValue }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Alergias
                if !perfil.alergias.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alergias:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                        
                        Text(perfil.alergias.joined(separator: ", "))
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
