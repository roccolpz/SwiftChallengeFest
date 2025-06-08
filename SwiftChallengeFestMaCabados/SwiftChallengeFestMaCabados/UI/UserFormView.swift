import SwiftUI

struct UserFormView: View {
    @State private var perfil = PerfilUsuario()
    @State private var nuevoAlimento = ""
    @State private var nuevaAlergia = ""
    @State private var nuevoMedicamento = ""
    @State private var showingIMCInfo = false
    @State private var currentStep = 0
    @State private var navigateToDashboard = false

    
    private let totalSteps = 7
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress bar
                if (currentStep > 0) {
                    ProgressView(value: Double(currentStep), total: Double(totalSteps))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal)
                }
                
                TabView(selection: $currentStep) {
                    BienvenidaView(onNext: {
                        print("next...")
                    })
                        .tag(0)
                    
                    // Paso 1: Información Personal
                    informacionPersonalView()
                        .tag(1)
                    
                    // Paso 2: Información Médica
                    informacionMedicaView()
                        .tag(2)
                    
                    // Paso 3: Configuración Diabetes
                    configuracionDiabetesView()
                        .tag(3)
                    
                    // Paso 4: Horarios
                    horariosView()
                        .tag(4)
                    
                    // Paso 5: Preferencias Alimentarias
                    preferenciasAlimentariasView()
                        .tag(5)
                    
                    OnboardingCompletadoView(onComplete: {
                        print("completed")
                    })
                        .tag(6)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onTapGesture {
                    self.hideKeyboard()
                }
                
                // Botones de navegación
                navegacionButtons()
            }
            .navigationTitle("Configurar Perfil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Paso 1: Información Personal
    @ViewBuilder
    private func informacionPersonalView() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView(
                    title: "Información Personal",
                    subtitle: "Cuéntanos sobre ti",
                    icon: "person.circle.fill"
                )
                
                VStack(spacing: 20) {
                    // Nombre
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Ingresa tu nombre completo", text: $perfil.nombre)
                            .textFieldStyle(ModernTextFieldStyle())
                    }
                    
                    // Edad y Género
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Edad")
                                .font(.headline)
                            
                            TextField("25", value: $perfil.edad, format: .number)
                                .textFieldStyle(ModernTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Género")
                                .font(.headline)
                            
                            Picker("Género", selection: $perfil.genero) {
                                ForEach(Genero.allCases, id: \.self) { genero in
                                    Text(genero.rawValue).tag(genero)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(.blue)
                        }
                    }
                    
                    // Peso y Altura
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Peso")
                                .font(.headline)
                            
                            HStack {
                                TextField("70", value: $perfil.peso, format: .number)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("kg")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Altura")
                                .font(.headline)
                            
                            HStack {
                                TextField("170", value: $perfil.altura, format: .number)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("cm")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // IMC Card
                    imcCardView()
                }
                .padding(.horizontal)
                
                Spacer(minLength: 80)
            }
        }
    }
    
    // MARK: - Paso 2: Información Médica
    @ViewBuilder
    private func informacionMedicaView() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView(
                    title: "Información Médica",
                    subtitle: "Tu salud es lo más importante",
                    icon: "cross.circle.fill"
                )
                
                VStack(spacing: 20) {
                    // ¿Eres diabético?
                    VStack(alignment: .leading, spacing: 12) {
                        Text("¿Tienes diabetes?")
                            .font(.headline)
                        
                        HStack(spacing: 20) {
                            Button(action: { perfil.esDiabetico = true }) {
                                HStack {
                                    Image(systemName: perfil.esDiabetico ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(perfil.esDiabetico ? .blue : .gray)
                                    Text("Sí")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                perfil.esDiabetico = false
                                perfil.tipoDiabetes = nil
                            }) {
                                HStack {
                                    Image(systemName: !perfil.esDiabetico ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(!perfil.esDiabetico ? .blue : .gray)
                                    Text("No")
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                    }
                    
                    // Tipo de diabetes (si aplica)
                    if perfil.esDiabetico {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tipo de diabetes")
                                .font(.headline)
                            
                            Picker("Tipo de diabetes", selection: $perfil.tipoDiabetes) {
                                Text("Selecciona").tag(nil as TipoDiabetes?)
                                ForEach(TipoDiabetes.allCases, id: \.self) { tipo in
                                    Text(tipo.rawValue).tag(tipo as TipoDiabetes?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .tint(.blue)
                        }
                    }
                    
                    // Medicamentos
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Medicamentos")
                            .font(.headline)
                        
                        // Lista de medicamentos
                        ForEach(perfil.medicamentos, id: \.self) { medicamento in
                            HStack {
                                Text(medicamento)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                Button(action: {
                                    perfil.medicamentos.removeAll { $0 == medicamento }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        // Agregar medicamento
                        HStack {
                            TextField("Agregar medicamento", text: $nuevoMedicamento)
                                .textFieldStyle(ModernTextFieldStyle())
                            
                            Button("Agregar") {
                                if !nuevoMedicamento.isEmpty {
                                    perfil.medicamentos.append(nuevoMedicamento)
                                    nuevoMedicamento = ""
                                }
                            }
                            .disabled(nuevoMedicamento.isEmpty)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 80)
            }
        }
    }
    
    // MARK: - Paso 3: Configuración Diabetes
    @ViewBuilder
    private func configuracionDiabetesView() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView(
                    title: "Configuración Diabetes",
                    subtitle: perfil.esDiabetico ? "Personaliza tu tratamiento" : "Información para el futuro",
                    icon: "heart.circle.fill"
                )
                
                if perfil.esDiabetico {
                    VStack(spacing: 20) {
                        // Glucosa objetivo
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Glucosa objetivo")
                                .font(.headline)
                            
                            HStack {
                                TextField("110", value: $perfil.glucosaObjetivo, format: .number)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("mg/dL")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Insulina basal
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Insulina basal diaria")
                                .font(.headline)
                            
                            HStack {
                                TextField("Opcional", value: $perfil.insulinaBasalDiaria, format: .number)
                                    .textFieldStyle(ModernTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                Text("unidades/día")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Dispositivos
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dispositivos que usas")
                                .font(.headline)
                            
                            Toggle("Bomba de insulina", isOn: $perfil.usaBombaInsulina)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                            
                            Toggle("Monitor continuo de glucosa", isOn: $perfil.usaMonitorContinuo)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        
                        // Ratios calculados
                        if let ratioIC = perfil.ratioIC, let factorSens = perfil.factorSensibilidad {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cálculos automáticos")
                                    .font(.headline)
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("Ratio I:C")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("1:\(Int(ratioIC))")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing) {
                                        Text("Factor Sensibilidad")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(Int(factorSens)) mg/dL")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding()
                                .background(Color.blue.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("¡Excelente!")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Mantén un estilo de vida saludable para prevenir la diabetes.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                Spacer(minLength: 80)
            }
        }
    }
    
    // MARK: - Paso 4: Horarios
    @ViewBuilder
    private func horariosView() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView(
                    title: "Horarios de Comida",
                    subtitle: "Ayúdanos a personalizar tus recordatorios",
                    icon: "clock.circle.fill"
                )
                
                VStack(spacing: 20) {
                    // Desayuno
                    horarioRow(
                        title: "Desayuno",
                        icon: "sun.max.fill",
                        color: .orange,
                        time: $perfil.horarioDesayuno
                    )
                    
                    // Comida
                    horarioRow(
                        title: "Comida",
                        icon: "sun.max.fill",
                        color: .yellow,
                        time: $perfil.horarioComida
                    )
                    
                    // Cena
                    horarioRow(
                        title: "Cena",
                        icon: "moon.fill",
                        color: .purple,
                        time: $perfil.horarioCena
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 80)
            }
        }
    }
    
    // MARK: - Paso 5: Preferencias Alimentarias
    @ViewBuilder
    private func preferenciasAlimentariasView() -> some View {
        ScrollView {
            VStack(spacing: 24) {
                headerView(
                    title: "Preferencias Alimentarias",
                    subtitle: "Personaliza tu experiencia nutricional",
                    icon: "leaf.circle.fill"
                )
                
                VStack(spacing: 24) {
                    // Restricciones dietéticas
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Restricciones dietéticas")
                            .font(.headline)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(RestriccionDietetica.allCases, id: \.self) { restriccion in
                                Button(action: {
                                    if perfil.restriccionesDieteticas.contains(restriccion) {
                                        perfil.restriccionesDieteticas.removeAll { $0 == restriccion }
                                    } else {
                                        perfil.restriccionesDieteticas.append(restriccion)
                                    }
                                }) {
                                    Text(restriccion.rawValue)
                                        .font(.subheadline)
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            perfil.restriccionesDieteticas.contains(restriccion)
                                            ? Color.blue.opacity(0.2)
                                            : Color.gray.opacity(0.1)
                                        )
                                        .foregroundColor(
                                            perfil.restriccionesDieteticas.contains(restriccion)
                                            ? .blue
                                            : .primary
                                        )
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Alimentos frecuentes
                    alimentosSection(
                        title: "Alimentos frecuentes",
                        items: $perfil.alimentosFrecuentes,
                        newItem: $nuevoAlimento,
                        placeholder: "Ej: Manzana, Pollo, Arroz"
                    )
                    
                    // Alergias
                    alimentosSection(
                        title: "Alergias alimentarias",
                        items: $perfil.alergias,
                        newItem: $nuevaAlergia,
                        placeholder: "Ej: Nueces, Mariscos, Lácteos"
                    )
                }
                .padding(.horizontal)
                
                Spacer(minLength: 80)
            }
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func headerView(title: String, subtitle: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
    
    @ViewBuilder
    private func imcCardView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Índice de Masa Corporal (IMC)")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingIMCInfo = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Tu IMC")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", perfil.imc))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(imcColor(perfil.imc))
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Categoría")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(imcCategory(perfil.imc))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(imcColor(perfil.imc))
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
        .alert("Información IMC", isPresented: $showingIMCInfo) {
            Button("Entendido") { }
        } message: {
            Text("El IMC es una medida que relaciona tu peso y altura. Valores normales están entre 18.5 y 24.9.")
        }
    }
    
    @ViewBuilder
    private func horarioRow(title: String, icon: String, color: Color, time: Binding<Date>) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text("Hora recomendada")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func alimentosSection(title: String, items: Binding<[String]>, newItem: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            // Lista de items
            ForEach(items.wrappedValue, id: \.self) { item in
                HStack {
                    Text(item)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    Button(action: {
                        items.wrappedValue.removeAll { $0 == item }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Agregar item
            HStack {
                TextField(placeholder, text: newItem)
                    .textFieldStyle(ModernTextFieldStyle())
                
                Button("Agregar") {
                    if !newItem.wrappedValue.isEmpty {
                        items.wrappedValue.append(newItem.wrappedValue)
                        newItem.wrappedValue = ""
                    }
                }
                .disabled(newItem.wrappedValue.isEmpty)
            }
        }
    }
    
    @ViewBuilder
    private func navegacionButtons() -> some View {
        HStack {
            if currentStep > 0 {
                Button("Anterior") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if (currentStep == totalSteps - 1) {
                NavigationLink(destination: DashboardView()
                    .navigationBarBackButtonHidden(true)) {
                        Text("Finalizar")
                            .padding()
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                    }.onAppear {
                        guardarPerfil(perfil)
                    }
            }else if (currentStep == 0) {
            }else{
                Button(currentStep == totalSteps - 1 ? "Finalizar" : "Siguiente") {
                    if currentStep == totalSteps - 1 {
                        // Guardar perfil
                        guardarPerfil(perfil)
                    } else {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isCurrentStepValid())
            }
            
            
            

            
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .shadow(radius: 1)
    }
    
    // MARK: - Helper Functions
    
    private func imcColor(_ imc: Double) -> Color {
        switch imc {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    private func imcCategory(_ imc: Double) -> String {
        switch imc {
        case ..<18.5: return "Bajo peso"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Sobrepeso"
        default: return "Obesidad"
        }
    }
    
    private func isCurrentStepValid() -> Bool {
        switch currentStep {
        case 0: return !perfil.nombre.isEmpty && perfil.edad > 0 && perfil.peso > 0 && perfil.altura > 0
        case 1: return perfil.esDiabetico ? perfil.tipoDiabetes != nil : true
        default: return true
        }
    }
    

}

// MARK: - Custom Styles

struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// MARK: - Preview
#Preview {
    UserFormView()
}
