//
//  HorariosComidaView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct HorariosComidaView: View {
    @Binding var perfil: PerfilUsuario
    let onNext: () -> Void
    let onBack: () -> Void
    
    @State private var horarioDesayuno = Date()
    @State private var horarioComida = Date()
    @State private var horarioCena = Date()
    @State private var configuracionAutomatica = true
    @State private var showingTimePickerFor: TipoComidaHorario?
    
    private var datosValidos: Bool {
        // Verificar que los horarios tengan sentido cronológico
        let calendar = Calendar.current
        let desayunoHour = calendar.component(.hour, from: horarioDesayuno)
        let comidaHour = calendar.component(.hour, from: horarioComida)
        let cenaHour = calendar.component(.hour, from: horarioCena)
        
        return desayunoHour < comidaHour && comidaHour < cenaHour
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("⏰")
                    .font(.system(size: 64))
                
                Text("Horarios de Comida")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Establece tus horarios habituales para personalizar las predicciones")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Configuración automática toggle
                    ConfiguracionAutomaticaCard(
                        configuracionAutomatica: $configuracionAutomatica,
                        onToggle: aplicarHorariosPorDefecto
                    )
                    
                    // Horarios personalizados
                    if !configuracionAutomatica {
                        VStack(spacing: 20) {
                            HorarioComidaCard(
                                tipo: .desayuno,
                                horario: $horarioDesayuno,
                                onEdit: { showingTimePickerFor = .desayuno }
                            )
                            
                            HorarioComidaCard(
                                tipo: .comida,
                                horario: $horarioComida,
                                onEdit: { showingTimePickerFor = .comida }
                            )
                            
                            HorarioComidaCard(
                                tipo: .cena,
                                horario: $horarioCena,
                                onEdit: { showingTimePickerFor = .cena }
                            )
                        }
                    } else {
                        // Vista previa de horarios automáticos
                        VStack(spacing: 16) {
                            Text("Horarios sugeridos:")
                                .font(.headline)
                                .padding(.top, 16)
                            
                            HorarioPreviewCard(tipo: .desayuno, horario: horarioDesayuno)
                            HorarioPreviewCard(tipo: .comida, horario: horarioComida)
                            HorarioPreviewCard(tipo: .cena, horario: horarioCena)
                            
                            Button(action: {
                                configuracionAutomatica = false
                            }) {
                                Text("Personalizar horarios")
                                    .font(.subheadline)
                                    .foregroundColor(ColorHelper.Principal.primario)
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    // Beneficios de horarios regulares
                    BeneficiosHorariosCard()
                    
                    // Validación visual
                    if !datosValidos {
                        ValidationWarningCard()
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Navigation buttons
            OnboardingNavigationBar(
                showBack: true,
                nextEnabled: datosValidos,
                onBack: onBack,
                onNext: guardarYContinuar
            )
        }
        .onAppear {
            cargarDatosExistentes()
        }
        .sheet(item: $showingTimePickerFor) { tipo in
            TimePickerSheet(
                tipo: tipo,
                selectedTime: bindingForTipo(tipo),
                onSave: { showingTimePickerFor = nil }
            )
        }
    }
    
    private func cargarDatosExistentes() {
        horarioDesayuno = perfil.horarioDesayuno
        horarioComida = perfil.horarioComida
        horarioCena = perfil.horarioCena
        
        // Verificar si son horarios por defecto
        let calendar = Calendar.current
        let defaultDesayuno = calendar.date(from: DateComponents(hour: 8)) ?? Date()
        let defaultComida = calendar.date(from: DateComponents(hour: 14)) ?? Date()
        let defaultCena = calendar.date(from: DateComponents(hour: 20)) ?? Date()
        
        configuracionAutomatica = (
            calendar.component(.hour, from: horarioDesayuno) == 8 &&
            calendar.component(.hour, from: horarioComida) == 14 &&
            calendar.component(.hour, from: horarioCena) == 20
        )
    }
    
    private func aplicarHorariosPorDefecto() {
        if configuracionAutomatica {
            let calendar = Calendar.current
            horarioDesayuno = calendar.date(from: DateComponents(hour: 8)) ?? Date()
            horarioComida = calendar.date(from: DateComponents(hour: 14)) ?? Date()
            horarioCena = calendar.date(from: DateComponents(hour: 20)) ?? Date()
        }
    }
    
    private func bindingForTipo(_ tipo: TipoComidaHorario) -> Binding<Date> {
        switch tipo {
        case .desayuno: return $horarioDesayuno
        case .comida: return $horarioComida
        case .cena: return $horarioCena
        }
    }
    
    private func guardarYContinuar() {
        perfil.horarioDesayuno = horarioDesayuno
        perfil.horarioComida = horarioComida
        perfil.horarioCena = horarioCena
        
        onNext()
    }
}

// MARK: - Tipo Comida Horario
enum TipoComidaHorario: Identifiable, CaseIterable {
    case desayuno, comida, cena
    
    var id: Self { self }
    
    var nombre: String {
        switch self {
        case .desayuno: return "Desayuno"
        case .comida: return "Comida"
        case .cena: return "Cena"
        }
    }
    
    var emoji: String {
        switch self {
        case .desayuno: return "🌅"
        case .comida: return "☀️"
        case .cena: return "🌙"
        }
    }
    
    var descripcion: String {
        switch self {
        case .desayuno: return "Primera comida del día"
        case .comida: return "Comida principal"
        case .cena: return "Última comida del día"
        }
    }
    
    var horarioSugerido: (min: Int, max: Int) {
        switch self {
        case .desayuno: return (6, 10)
        case .comida: return (12, 15)
        case .cena: return (18, 21)
        }
    }
}

// MARK: - Configuración Automática Card
struct ConfiguracionAutomaticaCard: View {
    @Binding var configuracionAutomatica: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "gear.badge.questionmark")
                    .font(.title2)
                    .foregroundColor(ColorHelper.Principal.primario)
                
                Text("Configuración Automática")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Toggle("", isOn: $configuracionAutomatica)
                    .onChange(of: configuracionAutomatica) { _ in
                        onToggle()
                    }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(configuracionAutomatica ? "Usaremos horarios típicos:" : "Personaliza tus horarios:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if configuracionAutomatica {
                    VStack(alignment: .leading, spacing: 4) {
                        HorarioSugeridoRow(emoji: "🌅", nombre: "Desayuno", hora: "8:00 AM")
                        HorarioSugeridoRow(emoji: "☀️", nombre: "Comida", hora: "2:00 PM")
                        HorarioSugeridoRow(emoji: "🌙", nombre: "Cena", hora: "8:00 PM")
                    }
                } else {
                    Text("Ajusta cada horario según tu rutina personal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(configuracionAutomatica ? ColorHelper.Principal.primario.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(configuracionAutomatica ? ColorHelper.Principal.primario.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Horario Sugerido Row
struct HorarioSugeridoRow: View {
    let emoji: String
    let nombre: String
    let hora: String
    
    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.subheadline)
            
            Text(nombre)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(hora)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(ColorHelper.Principal.primario)
        }
    }
}

// MARK: - Horario Comida Card
struct HorarioComidaCard: View {
    let tipo: TipoComidaHorario
    @Binding var horario: Date
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon y tipo
            VStack(spacing: 8) {
                Text(tipo.emoji)
                    .font(.title2)
                
                Text(tipo.nombre)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .frame(minWidth: 80)
            
            // Información
            VStack(alignment: .leading, spacing: 4) {
                Text(tipo.descripcion)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(horario.horaFormat)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(ColorHelper.Principal.primario)
            }
            
            Spacer()
            
            // Botón editar
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundColor(ColorHelper.Principal.primario)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
    }
}

// MARK: - Horario Preview Card
struct HorarioPreviewCard: View {
    let tipo: TipoComidaHorario
    let horario: Date
    
    var body: some View {
        HStack(spacing: 16) {
            Text(tipo.emoji)
                .font(.title3)
            
            Text(tipo.nombre)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(horario.horaFormat)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(ColorHelper.Principal.primario)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Beneficios Horarios Card
struct BeneficiosHorariosCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                Text("¿Por qué importan los horarios?")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                BeneficioHorarioRow(
                    icon: "clock.badge.checkmark",
                    text: "Predicciones más precisas basadas en tu rutina",
                    color: .blue
                )
                
                BeneficioHorarioRow(
                    icon: "waveform.path.ecg",
                    text: "Ajustes circadianos en sensibilidad a insulina",
                    color: .green
                )
                
                BeneficioHorarioRow(
                    icon: "bell.badge",
                    text: "Recordatorios personalizados para mediciones",
                    color: .orange
                )
                
                BeneficioHorarioRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: "Análisis de patrones glucémicos por horario",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Beneficio Horario Row
struct BeneficioHorarioRow: View {
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
        }
    }
}

// MARK: - Validation Warning Card
struct ValidationWarningCard: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                
                Text("Horarios Inconsistentes")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
            }
            
            Text("Los horarios deben seguir el orden cronológico: Desayuno < Comida < Cena")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                )
        )
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    let tipo: TipoComidaHorario
    @Binding var selectedTime: Date
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var tempTime: Date
    
    init(tipo: TipoComidaHorario, selectedTime: Binding<Date>, onSave: @escaping () -> Void) {
        self.tipo = tipo
        self._selectedTime = selectedTime
        self.onSave = onSave
        self._tempTime = State(initialValue: selectedTime.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Text(tipo.emoji)
                        .font(.system(size: 64))
                    
                    Text("Horario de \(tipo.nombre)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(tipo.descripcion)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                
                // Time picker
                VStack(spacing: 16) {
                    Text("Selecciona la hora:")
                        .font(.headline)
                    
                    DatePicker(
                        "",
                        selection: $tempTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                }
                
                // Horario sugerido
                VStack(spacing: 12) {
                    Text("Horario sugerido:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    let sugerido = tipo.horarioSugerido
                    Text("Entre \(sugerido.min):00 y \(sugerido.max):00")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ColorHelper.Principal.primario)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ColorHelper.Principal.primario.opacity(0.1))
                        )
                }
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    selectedTime = tempTime
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    HorariosComidaView(
        perfil: .constant(PerfilUsuario()),
        onNext: { print("Next") },
        onBack: { print("Back") }
    )
}