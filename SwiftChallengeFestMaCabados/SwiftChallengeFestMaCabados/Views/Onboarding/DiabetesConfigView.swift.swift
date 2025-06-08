//
//  DiabetesConfigView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct DiabetesConfigView: View {
    @Binding var perfil: PerfilUsuario
    let onNext: () -> Void
    let onBack: () -> Void
    
    @State private var esDiabetico = false
    @State private var tipoSeleccionado: TipoDiabetes?
    @State private var glucosaObjetivo = ""
    @State private var insulinaBasal = ""
    @State private var usaBombaInsulina = false
    @State private var usaMonitorContinuo = false
    @State private var medicamentos: [String] = []
    @State private var nuevoMedicamento = ""
    @State private var showingMedicamentoInput = false
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    
    private var datosValidos: Bool {
        if !esDiabetico {
            return true
        }
        
        // Si es diabético, necesita tipo y glucosa objetivo
        guard tipoSeleccionado != nil,
              glucosaObjetivoValida != nil else {
            return false
        }
        
        // Si es tipo 1 o usa bomba, necesita insulina basal
        if (tipoSeleccionado == .tipo1 || usaBombaInsulina) {
            return insulinaBasalValida != nil
        }
        
        return true
    }
    
    private var glucosaObjetivoValida: Double? {
        guard let valor = Double(glucosaObjetivo),
              valor >= 80,
              valor <= 140 else {
            return nil
        }
        return valor
    }
    
    private var insulinaBasalValida: Double? {
        guard !insulinaBasal.isEmpty,
              let valor = Double(insulinaBasal),
              valor >= AppConstants.Insulina.basalDiariaMin,
              valor <= AppConstants.Insulina.basalDiariaMax else {
            return nil
        }
        return valor
    }
    
    private var ratiosCalculados: (ic: Double?, sensibilidad: Double?) {
        guard let insulina = insulinaBasalValida else { return (nil, nil) }
        return (
            ic: CalculadoraClinica.calcularRatioIC(insulinaDiaria: insulina),
            sensibilidad: CalculadoraClinica.calcularFactorSensibilidad(insulinaDiaria: insulina)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("🩺")
                    .font(.system(size: 64))
                
                Text("Información Médica")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Esta información nos ayuda a calcular dosis de insulina y objetivos personalizados")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Tips button
                OnboardingTipsButton(step: .diabetes)
            }
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            // Form
            ScrollView {
                VStack(spacing: 24) {
                    // ¿Eres diabético?
                    DiabetesToggleCard(
                        esDiabetico: $esDiabetico,
                        onToggle: { resetDiabetesData() }
                    )
                    
                    if esDiabetico {
                        // Tipo de diabetes
                        OnboardingPicker(
                            title: "Tipo de Diabetes",
                            selection: $tipoSeleccionado,
                            options: TipoDiabetes.allCases,
                            icon: "medical.thermometer",
                            placeholder: "Selecciona tu tipo"
                        )
                        
                        // Glucosa objetivo
                        OnboardingTextField(
                            title: "Glucosa Objetivo (mg/dL)",
                            placeholder: "Ej: 110",
                            text: $glucosaObjetivo,
                            icon: "target",
                            keyboardType: .decimalPad,
                            validation: glucosaObjetivoValida != nil || glucosaObjetivo.isEmpty,
                            errorText: glucosaObjetivo.isEmpty ? nil : "Debe estar entre 80 y 140 mg/dL"
                        )
                        
                        // Insulina (solo para tipo 1 o bomba)
                        if tipoSeleccionado == .tipo1 || usaBombaInsulina {
                            VStack(spacing: 16) {
                                OnboardingTextField(
                                    title: "Insulina Basal Diaria (U)",
                                    placeholder: "Ej: 24",
                                    text: $insulinaBasal,
                                    icon: "syringe",
                                    keyboardType: .decimalPad,
                                    validation: insulinaBasalValida != nil || insulinaBasal.isEmpty,
                                    errorText: insulinaBasal.isEmpty ? nil : "Debe estar entre \(AppConstants.Insulina.basalDiariaMin) y \(AppConstants.Insulina.basalDiariaMax) U"
                                )
                                
                                // Estimación automática
                                if insulinaBasal.isEmpty {
                                    let estimacion = CalculadoraClinica.estimarDosisBasePorPeso(pesoKg: perfil.peso)
                                    
                                    Button(action: {
                                        insulinaBasal = String(format: "%.0f", estimacion)
                                    }) {
                                        HStack {
                                            Image(systemName: "wand.and.rays")
                                            Text("Estimar basado en peso (\(estimacion, specifier: "%.0f") U)")
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(ColorHelper.Principal.primario)
                                    }
                                }
                                
                                // Ratios calculados
                                if let ic = ratiosCalculados.ic, let sensibilidad = ratiosCalculados.sensibilidad {
                                    InsulinaRatiosCard(ic: ic, sensibilidad: sensibilidad)
                                }
                            }
                        }
                        
                        // Dispositivos médicos
                        DispositivosMedicosSection(
                            usaBomba: $usaBombaInsulina,
                            usaMonitor: $usaMonitorContinuo
                        )
                        
                        // Medicamentos
                        MedicamentosSection(
                            medicamentos: $medicamentos,
                            nuevoMedicamento: $nuevoMedicamento,
                            showingInput: $showingMedicamentoInput
                        )
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
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? "Error desconocido")
        }
    }
    
    private func cargarDatosExistentes() {
        esDiabetico = perfil.esDiabetico
        tipoSeleccionado = perfil.tipoDiabetes
        glucosaObjetivo = perfil.glucosaObjetivo != nil ? String(format: "%.0f", perfil.glucosaObjetivo!) : ""
        insulinaBasal = perfil.insulinaBasalDiaria != nil ? String(format: "%.0f", perfil.insulinaBasalDiaria!) : ""
        usaBombaInsulina = perfil.usaBombaInsulina
        usaMonitorContinuo = perfil.usaMonitorContinuo
        medicamentos = perfil.medicamentos
    }
    
    private func resetDiabetesData() {
        if !esDiabetico {
            tipoSeleccionado = nil
            glucosaObjetivo = ""
            insulinaBasal = ""
            usaBombaInsulina = false
            usaMonitorContinuo = false
            medicamentos = []
        }
    }
    
    private func guardarYContinuar() {
        perfil.esDiabetico = esDiabetico
        
        if esDiabetico {
            perfil.tipoDiabetes = tipoSeleccionado
            perfil.glucosaObjetivo = glucosaObjetivoValida
            perfil.insulinaBasalDiaria = insulinaBasalValida
            perfil.usaBombaInsulina = usaBombaInsulina
            perfil.usaMonitorContinuo = usaMonitorContinuo
            perfil.medicamentos = medicamentos
        } else {
            // Limpiar datos de diabetes
            perfil.tipoDiabetes = nil
            perfil.glucosaObjetivo = nil
            perfil.insulinaBasalDiaria = nil
            perfil.usaBombaInsulina = false
            perfil.usaMonitorContinuo = false
            perfil.medicamentos = []
        }
        
        onNext()
    }
}

// MARK: - Diabetes Toggle Card
struct DiabetesToggleCard: View {
    @Binding var esDiabetico: Bool
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "cross.case")
                    .font(.title2)
                    .foregroundColor(ColorHelper.Principal.primario)
                
                Text("¿Tienes diabetes?")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Toggle("", isOn: $esDiabetico)
                    .onChange(of: esDiabetico) { _ in
                        onToggle()
                    }
            }
            
            if esDiabetico {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Perfecto, te ayudaremos a:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        BenefitRow(text: "Calcular dosis de insulina precisas")
                        BenefitRow(text: "Optimizar el control de glucosa")
                        BenefitRow(text: "Personalizar recomendaciones")
                    }
                }
                .padding(.top, 8)
            } else {
                Text("También puedes usar la app para monitorear tu glucosa y aprender sobre nutrición")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(esDiabetico ? ColorHelper.Principal.primario.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(esDiabetico ? ColorHelper.Principal.primario.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Benefit Row
struct BenefitRow: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Onboarding Picker
struct OnboardingPicker<T: CaseIterable & RawRepresentable & Hashable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T?
    let options: [T]
    let icon: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(ColorHelper.Principal.primario)
                    .frame(width: 24)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selection = option
                    }) {
                        HStack {
                            Text(option.rawValue)
                            if selection == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selection?.rawValue ?? placeholder)
                        .foregroundColor(selection != nil ? .primary : .secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.secondary)
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
}

// MARK: - Insulina Ratios Card
struct InsulinaRatiosCard: View {
    let ic: Double
    let sensibilidad: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "calculator")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Ratios Calculados")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Ratio I:C")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("1:\(ic, specifier: "%.0f")g")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Sensibilidad")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(sensibilidad, specifier: "%.0f") mg/dL/U")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            
            Text("Estos valores se usarán para calcular dosis de insulina personalizadas")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Dispositivos Médicos Section
struct DispositivosMedicosSection: View {
    @Binding var usaBomba: Bool
    @Binding var usaMonitor: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "gear.badge")
                    .font(.title3)
                    .foregroundColor(ColorHelper.Principal.primario)
                    .frame(width: 24)
                
                Text("Dispositivos Médicos")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            VStack(spacing: 12) {
                DispositivoToggle(
                    title: "Bomba de Insulina",
                    description: "Para cálculos más precisos de basales",
                    icon: "medical.thermometer",
                    isOn: $usaBomba
                )
                
                DispositivoToggle(
                    title: "Monitor Continuo de Glucosa",
                    description: "Para seguimiento en tiempo real",
                    icon: "waveform.path.ecg",
                    isOn: $usaMonitor
                )
            }
        }
    }
}

// MARK: - Dispositivo Toggle
struct DispositivoToggle: View {
    let title: String
    let description: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isOn ? ColorHelper.Principal.primario : .secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isOn ? ColorHelper.Principal.primario.opacity(0.1) : Color(.systemGray6))
        )
    }
}

// MARK: - Medicamentos Section
struct MedicamentosSection: View {
    @Binding var medicamentos: [String]
    @Binding var nuevoMedicamento: String
    @Binding var showingInput: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "pills")
                    .font(.title3)
                    .foregroundColor(ColorHelper.Principal.primario)
                    .frame(width: 24)
                
                Text("Medicamentos")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: { showingInput.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(ColorHelper.Principal.primario)
                }
            }
            
            if showingInput {
                HStack {
                    TextField("Nombre del medicamento", text: $nuevoMedicamento)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Agregar") {
                        if !nuevoMedicamento.isEmpty {
                            medicamentos.append(nuevoMedicamento)
                            nuevoMedicamento = ""
                            showingInput = false
                        }
                    }
                    .foregroundColor(ColorHelper.Principal.primario)
                }
            }
            
            if medicamentos.isEmpty {
                Text("No hay medicamentos agregados")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(medicamentos.enumerated()), id: \.offset) { index, medicamento in
                    HStack {
                        Text("• \(medicamento)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Button(action: {
                            medicamentos.remove(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

#Preview {
    DiabetesConfigView(
        perfil: .constant(PerfilUsuario()),
        onNext: { print("Next") },
        onBack: { print("Back") }
    )
}
