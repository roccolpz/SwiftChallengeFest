//
//  DatosBasicosView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct DatosBasicosView: View {
    @Binding var perfil: PerfilUsuario
    let onNext: () -> Void
    let onBack: () -> Void
    
    @State private var nombre = ""
    @State private var edad = ""
    @State private var peso = ""
    @State private var altura = ""
    @State private var generoSeleccionado: Genero = .masculino
    @State private var errorMessage: String?
    @State private var showingErrorAlert = false
    
    private var datosValidos: Bool {
        return !nombre.isEmpty &&
               edadValida != nil &&
               pesoValido != nil &&
               alturaValida != nil
    }
    
    private var edadValida: Int? {
        guard let edad = Int(edad),
              edad >= AppConstants.Usuario.edadMinima,
              edad <= AppConstants.Usuario.edadMaxima else {
            return nil
        }
        return edad
    }
    
    private var pesoValido: Double? {
        guard let peso = Double(peso),
              peso >= AppConstants.Usuario.pesoMinimo,
              peso <= AppConstants.Usuario.pesoMaximo else {
            return nil
        }
        return peso
    }
    
    private var alturaValida: Double? {
        guard let altura = Double(altura),
              altura >= AppConstants.Usuario.alturaMinima,
              altura <= AppConstants.Usuario.alturaMaxima else {
            return nil
        }
        return altura
    }
    
    private var imcCalculado: Double? {
        guard let peso = pesoValido, let altura = alturaValida else { return nil }
        return peso / ((altura/100) * (altura/100))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                Text("👤")
                    .font(.system(size: 64))
                
                Text("Cuéntanos sobre ti")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Esta información nos ayuda a personalizar tus predicciones de glucosa")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                // Tips button
                OnboardingTipsButton(step: .datosBasicos)
            }
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            // Form
            ScrollView {
                VStack(spacing: 24) {
                    // Nombre
                    OnboardingTextField(
                        title: "Nombre",
                        placeholder: "Ingresa tu nombre",
                        text: $nombre,
                        icon: "person"
                    )
                    
                    // Edad
                    OnboardingTextField(
                        title: "Edad",
                        placeholder: "Ej: 25",
                        text: $edad,
                        icon: "calendar",
                        keyboardType: .numberPad,
                        validation: edadValida != nil || edad.isEmpty,
                        errorText: edad.isEmpty ? nil : "Edad debe estar entre \(AppConstants.Usuario.edadMinima) y \(AppConstants.Usuario.edadMaxima) años"
                    )
                    
                    // Género
                    OnboardingSegmentedPicker(
                        title: "Género",
                        selection: $generoSeleccionado,
                        options: Genero.allCases,
                        icon: "person.2"
                    )
                    
                    // Peso
                    OnboardingTextField(
                        title: "Peso (kg)",
                        placeholder: "Ej: 70",
                        text: $peso,
                        icon: "scalemass",
                        keyboardType: .decimalPad,
                        validation: pesoValido != nil || peso.isEmpty,
                        errorText: peso.isEmpty ? nil : "Peso debe estar entre \(AppConstants.Usuario.pesoMinimo) y \(AppConstants.Usuario.pesoMaximo) kg"
                    )
                    
                    // Altura
                    OnboardingTextField(
                        title: "Altura (cm)",
                        placeholder: "Ej: 170",
                        text: $altura,
                        icon: "ruler",
                        keyboardType: .decimalPad,
                        validation: alturaValida != nil || altura.isEmpty,
                        errorText: altura.isEmpty ? nil : "Altura debe estar entre \(AppConstants.Usuario.alturaMinima) y \(AppConstants.Usuario.alturaMaxima) cm"
                    )
                    
                    // IMC Preview
                    if let imc = imcCalculado {
                        IMCPreviewCard(imc: imc)
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
        nombre = perfil.nombre
        edad = perfil.edad > 0 ? String(perfil.edad) : ""
        peso = perfil.peso > 0 ? String(format: "%.0f", perfil.peso) : ""
        altura = perfil.altura > 0 ? String(format: "%.0f", perfil.altura) : ""
        generoSeleccionado = perfil.genero
    }
    
    private func guardarYContinuar() {
        guard let edadValida = edadValida,
              let pesoValido = pesoValido,
              let alturaValida = alturaValida else {
            errorMessage = "Por favor, verifica que todos los campos sean válidos"
            showingErrorAlert = true
            return
        }
        
        // Actualizar perfil
        perfil.nombre = nombre.trimmingCharacters(in: .whitespacesAndNewlines)
        perfil.edad = edadValida
        perfil.genero = generoSeleccionado
        perfil.peso = pesoValido
        perfil.altura = alturaValida
        
        onNext()
    }
}

// MARK: - TextField Component
struct OnboardingTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var validation: Bool = true
    var errorText: String?
    
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
            
            TextField(placeholder, text: $text)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(validation ? Color.clear : Color.red, lineWidth: 1)
                        )
                )
                .keyboardType(keyboardType)
            
            if let errorText = errorText, !validation {
                Text(errorText)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 8)
            }
        }
    }
}

// MARK: - Segmented Picker Component
struct OnboardingSegmentedPicker<T: CaseIterable & RawRepresentable & Hashable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T
    let options: [T]
    let icon: String
    
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
            
            Picker(title, selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}

// MARK: - IMC Preview Card
struct IMCPreviewCard: View {
    let imc: Double
    
    private var categoriaIMC: (categoria: String, color: Color) {
        switch imc {
        case ..<18.5:
            return ("Bajo peso", ColorHelper.Estados.advertencia)
        case 18.5..<25:
            return ("Normal", ColorHelper.Estados.exito)
        case 25..<30:
            return ("Sobrepeso", ColorHelper.Estados.advertencia)
        case 30..<35:
            return ("Obesidad I", ColorHelper.Estados.error)
        case 35..<40:
            return ("Obesidad II", ColorHelper.Estados.error)
        default:
            return ("Obesidad III", ColorHelper.Estados.error)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square")
                    .font(.title3)
                    .foregroundColor(categoriaIMC.color)
                
                Text("Índice de Masa Corporal")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("IMC: \(imc, specifier: "%.1f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(categoriaIMC.color)
                    
                    Text(categoriaIMC.categoria)
                        .font(.subheadline)
                        .foregroundColor(categoriaIMC.color)
                }
                
                Spacer()
                
                Image(systemName: "info.circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(categoriaIMC.color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(categoriaIMC.color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Navigation Bar
struct OnboardingNavigationBar: View {
    let showBack: Bool
    let nextEnabled: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            if showBack {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Anterior")
                    }
                    .font(.headline)
                    .foregroundColor(ColorHelper.Principal.primario)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(ColorHelper.Principal.primario, lineWidth: 2)
                    )
                }
                .buttonStyle(OnboardingButtonStyle())
            }
            
            Button(action: onNext) {
                HStack {
                    Text("Siguiente")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(nextEnabled ? ColorHelper.Principal.primario : Color(.systemGray4))
                )
            }
            .disabled(!nextEnabled)
            .buttonStyle(OnboardingButtonStyle())
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
    }
}

#Preview {
    DatosBasicosView(
        perfil: .constant(PerfilUsuario()),
        onNext: { print("Next") },
        onBack: { print("Back") }
    )
}
