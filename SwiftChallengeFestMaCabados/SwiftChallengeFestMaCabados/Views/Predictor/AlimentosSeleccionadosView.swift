//
//  AlimentosSeleccionadosView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct AlimentosSeleccionadosView: View {
    @ObservedObject var viewModel: PredictorViewModel
    @State private var alimentoEditando: AlimentoConPorcion?
    @State private var showingEliminarAlert = false
    @State private var alimentoParaEliminar: AlimentoConPorcion?
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.alimentosSeleccionados.isEmpty {
                estadoVacio
            } else {
                VStack(spacing: 16) {
                    // Resumen nutricional
                    resumenNutricional
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // Lista de alimentos seleccionados
                    listaAlimentosSeleccionados
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .sheet(item: $alimentoEditando) { alimento in
            EditarCantidadSheet(
                alimentoConPorcion: alimento,
                onGuardar: { nuevosGramos in
                    viewModel.actualizarGramos(alimento, nuevosGramos: nuevosGramos)
                    alimentoEditando = nil
                },
                onEliminar: {
                    viewModel.eliminarAlimento(alimento)
                    alimentoEditando = nil
                }
            )
        }
        .alert("Eliminar Alimento", isPresented: $showingEliminarAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                if let alimento = alimentoParaEliminar {
                    viewModel.eliminarAlimento(alimento)
                    alimentoParaEliminar = nil
                }
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar este alimento de tu selección?")
        }
    }
    
    // MARK: - Estado Vacío
    private var estadoVacio: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No hay alimentos seleccionados")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            Text("Busca y agrega alimentos para crear tu comida y generar una predicción de glucosa")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            // Consejos rápidos
            VStack(alignment: .leading, spacing: 12) {
                Text("💡 Consejos:")
                    .font(.headline)
                    .foregroundColor(ColorHelper.Principal.primario)
                
                ConsejosRow(icono: "🥬", texto: "Incluye verduras para reducir picos de glucosa")
                ConsejosRow(icono: "🍗", texto: "Agrega proteínas para mayor saciedad")
                ConsejosRow(icono: "🍚", texto: "Controla las porciones de carbohidratos")
                ConsejosRow(icono: "⏰", texto: "El orden de comida importa: verduras primero")
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(ColorHelper.Principal.primario.opacity(0.1))
            )
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }
    
    // MARK: - Resumen Nutricional
    private var resumenNutricional: some View {
        let macros = viewModel.macronutrientesTotales
        
        return VStack(spacing: 16) {
            // Header
            HStack {
                Text("Resumen Nutricional")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    viewModel.limpiarSeleccion()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.caption)
                        Text("Limpiar")
                            .font(.caption)
                    }
                    .foregroundColor(.red)
                }
            }
            
            // Gráfica circular de macronutrientes
            HStack(spacing: 24) {
                // Gráfica circular
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    MacroCircleChart(
                        carbohidratos: macros.carbohidratos,
                        proteinas: macros.proteinas,
                        grasas: macros.grasas
                    )
                    .frame(width: 80, height: 80)
                    
                    VStack(spacing: 2) {
                        Text("\(macros.calorias, specifier: "%.0f")")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("kcal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Detalles de macronutrientes
                VStack(alignment: .leading, spacing: 8) {
                    MacroDetailRow(
                        nombre: "Carbohidratos",
                        valor: macros.carbohidratos,
                        color: ColorHelper.Macronutrientes.carbohidratos
                    )
                    
                    MacroDetailRow(
                        nombre: "Proteínas",
                        valor: macros.proteinas,
                        color: ColorHelper.Macronutrientes.proteinas
                    )
                    
                    MacroDetailRow(
                        nombre: "Grasas",
                        valor: macros.grasas,
                        color: ColorHelper.Macronutrientes.grasas
                    )
                    
                    MacroDetailRow(
                        nombre: "Fibra",
                        valor: macros.fibra,
                        color: ColorHelper.Macronutrientes.fibra
                    )
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
    
    // MARK: - Lista de Alimentos Seleccionados
    private var listaAlimentosSeleccionados: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Alimentos (\(viewModel.alimentosSeleccionados.count))")
                    .font(.headline)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.alimentosSeleccionados, id: \.id) { alimentoConPorcion in
                    AlimentoSeleccionadoCard(
                        alimentoConPorcion: alimentoConPorcion,
                        onEdit: {
                            alimentoEditando = alimentoConPorcion
                        },
                        onDelete: {
                            alimentoParaEliminar = alimentoConPorcion
                            showingEliminarAlert = true
                        }
                    )
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}

// MARK: - Componentes Auxiliares

struct ConsejosRow: View {
    let icono: String
    let texto: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icono)
                .font(.title3)
            
            Text(texto)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

struct MacroCircleChart: View {
    let carbohidratos: Double
    let proteinas: Double
    let grasas: Double
    
    private var totalCalorias: Double {
        (carbohidratos * 4) + (proteinas * 4) + (grasas * 9)
    }
    
    private var porcentajes: (carbos: Double, proteinas: Double, grasas: Double) {
        guard totalCalorias > 0 else { return (0, 0, 0) }
        
        return (
            carbos: (carbohidratos * 4) / totalCalorias,
            proteinas: (proteinas * 4) / totalCalorias,
            grasas: (grasas * 9) / totalCalorias
        )
    }
    
    var body: some View {
        ZStack {
            // Carbohidratos
            Circle()
                .trim(from: 0, to: porcentajes.carbos)
                .stroke(
                    ColorHelper.Macronutrientes.carbohidratos,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Proteínas
            Circle()
                .trim(from: porcentajes.carbos, to: porcentajes.carbos + porcentajes.proteinas)
                .stroke(
                    ColorHelper.Macronutrientes.proteinas,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            // Grasas
            Circle()
                .trim(from: porcentajes.carbos + porcentajes.proteinas, to: 1.0)
                .stroke(
                    ColorHelper.Macronutrientes.grasas,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
    }
}

struct MacroDetailRow: View {
    let nombre: String
    let valor: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(nombre)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(valor, specifier: "%.1f")g")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct AlimentoSeleccionadoCard: View {
    let alimentoConPorcion: AlimentoConPorcion
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    private var alimento: Alimento {
        alimentoConPorcion.alimento
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono del alimento
            ZStack {
                Circle()
                    .fill(ColorHelper.Categorias.colorPorCategoria(alimento.categoria).opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: iconoPorCategoria(alimento.categoria))
                    .font(.title2)
                    .foregroundColor(ColorHelper.Categorias.colorPorCategoria(alimento.categoria))
            }
            
            // Información del alimento
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alimento.nombre)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(alimentoConPorcion.gramos, specifier: "%.0f")g")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(ColorHelper.Principal.primario)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(ColorHelper.Principal.primario.opacity(0.1))
                        )
                }
                
                // Macronutrientes calculados para la porción
                HStack(spacing: 16) {
                    MacroChip(
                        label: "C",
                        value: alimentoConPorcion.carbohidratosReales,
                        color: ColorHelper.Macronutrientes.carbohidratos
                    )
                    
                    MacroChip(
                        label: "P",
                        value: alimentoConPorcion.proteinasReales,
                        color: ColorHelper.Macronutrientes.proteinas
                    )
                    
                    MacroChip(
                        label: "G",
                        value: alimentoConPorcion.grasasReales,
                        color: ColorHelper.Macronutrientes.grasas
                    )
                    
                    Spacer()
                    
                    // Calorías
                    let calorias = (alimentoConPorcion.carbohidratosReales * 4) +
                                  (alimentoConPorcion.proteinasReales * 4) +
                                  (alimentoConPorcion.grasasReales * 9)
                    
                    Text("\(calorias, specifier: "%.0f") kcal")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                // Información adicional
                HStack {
                    Text("CG: \(alimento.cargaGlicemica * (alimentoConPorcion.gramos / 100), specifier: "%.1f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("IG: \(alimento.indiceGlicemico)")
                        .font(.caption)
                        .foregroundColor(colorPorIndiceGlicemico(alimento.indiceGlicemico))
                }
            }
            
            // Botones de acción
            VStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
    }
    
    private func iconoPorCategoria(_ categoria: CategoriaAlimento) -> String {
        switch categoria {
        case .verduras: return "leaf"
        case .frutas: return "apple"
        case .proteinas: return "fish"
        case .carbohidratos: return "grains"
        case .lacteos: return "milk"
        case .grasas: return "drop"
        case .bebidas: return "cup.and.saucer"
        case .procesados: return "box"
        }
    }
    
    private func colorPorIndiceGlicemico(_ indice: Int) -> Color {
        switch indice {
        case ..<55: return .green
        case 55..<70: return .orange
        default: return .red
        }
    }
}

struct MacroChip: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("\(value, specifier: "%.1f")")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .frame(minWidth: 32)
    }
}

// MARK: - Sheet para Editar Cantidad
struct EditarCantidadSheet: View {
    let alimentoConPorcion: AlimentoConPorcion
    let onGuardar: (Double) -> Void
    let onEliminar: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var gramos: String
    @State private var errorMessage: String?
    @State private var showingEliminarAlert = false
    
    init(alimentoConPorcion: AlimentoConPorcion, onGuardar: @escaping (Double) -> Void, onEliminar: @escaping () -> Void) {
        self.alimentoConPorcion = alimentoConPorcion
        self.onGuardar = onGuardar
        self.onEliminar = onEliminar
        self._gramos = State(initialValue: String(format: "%.0f", alimentoConPorcion.gramos))
    }
    
    private var gramosValidos: Double? {
        guard let valor = Double(gramos),
              valor >= 1.0,
              valor <= 500.0 else {
            return nil
        }
        return valor
    }
    
    private var macrosCalculados: (carbos: Double, proteinas: Double, grasas: Double, fibra: Double, calorias: Double) {
        let factor = (gramosValidos ?? alimentoConPorcion.gramos) / 100.0
        let alimento = alimentoConPorcion.alimento
        
        return (
            carbos: alimento.carbohidratos * factor,
            proteinas: alimento.proteinas * factor,
            grasas: alimento.grasas * factor,
            fibra: alimento.fibra * factor,
            calorias: ((alimento.carbohidratos * 4) + (alimento.proteinas * 4) + (alimento.grasas * 9)) * factor
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header del alimento
                VStack(spacing: 16) {
                    Image(systemName: iconoPorCategoria(alimentoConPorcion.alimento.categoria))
                        .font(.system(size: 48))
                        .foregroundColor(ColorHelper.Categorias.colorPorCategoria(alimentoConPorcion.alimento.categoria))
                    
                    Text(alimentoConPorcion.alimento.nombre)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                // Editor de cantidad
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cantidad")
                        .font(.headline)
                    
                    HStack {
                        TextField("100", text: $gramos)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title2)
                        
                        Text("gramos")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Slider para ajuste rápido
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ajuste rápido:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let gramosActuales = gramosValidos {
                            Slider(
                                value: Binding(
                                    get: { gramosActuales },
                                    set: { gramos = String(format: "%.0f", $0) }
                                ),
                                in: 10...500,
                                step: 10
                            ) {
                                Text("Gramos")
                            }
                            .accentColor(ColorHelper.Principal.primario)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Preview nutricional actualizado
                VStack(alignment: .leading, spacing: 16) {
                    Text("Información nutricional actualizada:")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        MacroPreviewRow(nombre: "Carbohidratos", valor: macrosCalculados.carbos, color: ColorHelper.Macronutrientes.carbohidratos)
                        MacroPreviewRow(nombre: "Proteínas", valor: macrosCalculados.proteinas, color: ColorHelper.Macronutrientes.proteinas)
                        MacroPreviewRow(nombre: "Grasas", valor: macrosCalculados.grasas, color: ColorHelper.Macronutrientes.grasas)
                        MacroPreviewRow(nombre: "Fibra", valor: macrosCalculados.fibra, color: ColorHelper.Macronutrientes.fibra)
                        
                        Divider()
                        
                        HStack {
                            Text("Calorías totales")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Spacer()
                            
                            Text("\(macrosCalculados.calorias, specifier: "%.0f") kcal")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(ColorHelper.Principal.primario)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .padding(.horizontal)
                
                // Botón eliminar
                Button(action: {
                    showingEliminarAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Eliminar alimento")
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.red.opacity(0.1))
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Editar Cantidad")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Guardar") {
                    guardarCambios()
                }
                .disabled(gramosValidos == nil)
            )
        }
        .alert("Eliminar Alimento", isPresented: $showingEliminarAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Eliminar", role: .destructive) {
                onEliminar()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("¿Estás seguro de que quieres eliminar este alimento?")
        }
        .onChange(of: gramos) {
            validarGramos()
        }
    }
    
    private func validarGramos() {
        errorMessage = nil
        
        guard let valor = Double(gramos) else {
            errorMessage = "Ingresa un número válido"
            return
        }
        
        if valor < 1.0 {
            errorMessage = "Mínimo 1 gramo"
        } else if valor > 500.0 {
            errorMessage = "Máximo 500 gramos"
        }
    }
    
    private func guardarCambios() {
        guard let gramos = gramosValidos else { return }
        onGuardar(gramos)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func iconoPorCategoria(_ categoria: CategoriaAlimento) -> String {
        switch categoria {
        case .verduras: return "leaf"
        case .frutas: return "apple"
        case .proteinas: return "fish"
        case .carbohidratos: return "grains"
        case .lacteos: return "milk"
        case .grasas: return "drop"
        case .bebidas: return "cup.and.saucer"
        case .procesados: return "box"
        }
    }
}

#Preview {
    AlimentosSeleccionadosView(viewModel: PredictorViewModel())
}
