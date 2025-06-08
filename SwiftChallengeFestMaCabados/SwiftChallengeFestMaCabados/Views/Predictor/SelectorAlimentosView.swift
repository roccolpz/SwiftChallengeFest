//
//  SelectorAlimentosView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct SelectorAlimentosView: View {
    @ObservedObject var viewModel: PredictorViewModel
    @StateObject private var alimentosManager = AlimentosManager.shared
    @State private var showingAgregarPersonalizado = false
    @State private var alimentoParaAgregar: Alimento?
    @State private var gramosPersonalizados: String = "100"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con búsqueda y filtros
            VStack(spacing: 16) {
                // Búsqueda principal
                SearchBarWithFilters(
                    searchText: $viewModel.textoBusqueda,
                    selectedCategory: $viewModel.categoriaFiltro,
                    placeholder: "Buscar alimentos...",
                    onSearchChanged: { texto in
                        viewModel.buscarAlimentos(texto)
                    },
                    onCategoryChanged: { categoria in
                        viewModel.filtrarPorCategoria(categoria)
                    }
                )
                
                // Sugerencias rápidas
                if viewModel.mostrandoSugerencias && !viewModel.sugerenciasAlimentos.isEmpty {
                    sugerenciasRapidas
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .background(Color(.systemGroupedBackground))
            
            // Lista de alimentos
            if alimentosManager.isLoading {
                loadingState
            } else if viewModel.alimentosFiltrados.isEmpty {
                estadoVacio
            } else {
                listaAlimentos
            }
        }
        .onAppear {
            if viewModel.textoBusqueda.isEmpty {
                viewModel.mostrandoSugerencias = true
            }
        }
        .sheet(item: $alimentoParaAgregar) { alimento in
            AgregarAlimentoSheet(
                alimento: alimento,
                gramosIniciales: gramosPersonalizados,
                onAgregar: { gramos in
                    viewModel.agregarAlimento(alimento, gramos: gramos)
                    alimentoParaAgregar = nil
                }
            )
        }
        .sheet(isPresented: $showingAgregarPersonalizado) {
            // TODO: Vista para agregar alimento personalizado
            AgregarAlimentoPersonalizadoView { alimento in
                // Agregar alimento personalizado
                print("Agregar alimento personalizado: \(alimento.nombre)")
            }
        }
    }
    
    // MARK: - Sugerencias Rápidas
    private var sugerenciasRapidas: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sugerencias frecuentes")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.sugerenciasAlimentos, id: \.id) { alimento in
                        SugerenciaAlimentoCard(alimento: alimento) {
                            viewModel.agregarAlimento(alimento, gramos: 100)
                        }
                    }
                    
                    // Botón para agregar personalizado
                    Button(action: { showingAgregarPersonalizado = true }) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.dashed")
                                .font(.title2)
                                .foregroundColor(ColorHelper.Principal.primario)
                            
                            Text("Agregar\nPersonalizado")
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .foregroundColor(ColorHelper.Principal.primario)
                        }
                        .frame(width: 100, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(ColorHelper.Principal.primario, style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
    
    // MARK: - Loading State
    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Cargando alimentos...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Estado Vacío
    private var estadoVacio: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("No se encontraron alimentos")
                .font(.headline)
                .foregroundColor(.secondary)
            
            if !viewModel.textoBusqueda.isEmpty {
                Text("Intenta con otros términos de búsqueda")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    viewModel.buscarAlimentos("")
                    viewModel.filtrarPorCategoria(nil)
                }) {
                    Text("Limpiar filtros")
                        .font(.subheadline)
                        .foregroundColor(ColorHelper.Principal.primario)
                }
            } else {
                Text("Prueba buscando un alimento específico")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Lista de Alimentos
    private var listaAlimentos: some View {
        List {
            ForEach(viewModel.alimentosFiltrados, id: \.id) { alimento in
                AlimentoRow(
                    alimento: alimento,
                    isSelected: viewModel.alimentosSeleccionados.contains(where: { $0.alimento.id == alimento.id }),
                    onTap: {
                        // Agregar directamente con 100g
                        viewModel.agregarAlimento(alimento, gramos: 100)
                    },
                    onCustomTap: {
                        // Abrir sheet para personalizar gramos
                        alimentoParaAgregar = alimento
                    }
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Sugerencia Alimento Card
struct SugerenciaAlimentoCard: View {
    let alimento: Alimento
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Icono de categoría
                AsyncImage(url: URL(string: alimento.imagen ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: iconoPorCategoria(alimento.categoria))
                        .font(.title2)
                        .foregroundColor(ColorHelper.Categorias.colorPorCategoria(alimento.categoria))
                }
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Nombre
                Text(alimento.nombre)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                // Carbohidratos
                Text("\(alimento.carbohidratos, specifier: "%.1f")g carbos")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(width: 100, height: 80)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 4)
            )
        }
        .buttonStyle(BouncyButtonStyle())
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

// MARK: - Fila de Alimento
struct AlimentoRow: View {
    let alimento: Alimento
    let isSelected: Bool
    let onTap: () -> Void
    let onCustomTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icono y categoría
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(ColorHelper.Categorias.colorPorCategoria(alimento.categoria).opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    AsyncImage(url: URL(string: alimento.imagen ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: iconoPorCategoria(alimento.categoria))
                            .font(.title3)
                            .foregroundColor(ColorHelper.Categorias.colorPorCategoria(alimento.categoria))
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                }
                
                Text(alimento.categoria.displayName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            // Información del alimento
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(alimento.nombre)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                    }
                }
                
                // Macronutrientes principales
                HStack(spacing: 12) {
                    MacroInfo(label: "C", value: alimento.carbohidratos, color: ColorHelper.Macronutrientes.carbohidratos)
                    MacroInfo(label: "P", value: alimento.proteinas, color: ColorHelper.Macronutrientes.proteinas)
                    MacroInfo(label: "G", value: alimento.grasas, color: ColorHelper.Macronutrientes.grasas)
                    
                    Spacer()
                    
                    // Carga glicémica
                    HStack(spacing: 4) {
                        Text("CG:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(alimento.cargaGlicemica, specifier: "%.1f")")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(colorPorCargaGlicemica(alimento.cargaGlicemica))
                    }
                }
                
                // Índice glicémico y fibra
                HStack {
                    HStack(spacing: 4) {
                        Text("IG:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(alimento.indiceGlicemico)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(colorPorIndiceGlicemico(alimento.indiceGlicemico))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Fibra:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(alimento.fibra, specifier: "%.1f")g")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(ColorHelper.Macronutrientes.fibra)
                    }
                }
            }
            
            // Botones de acción
            VStack(spacing: 8) {
                // Botón agregar rápido (100g)
                Button(action: onTap) {
                    Image(systemName: isSelected ? "checkmark" : "plus")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(isSelected ? .green : ColorHelper.Principal.primario)
                        )
                }
                .buttonStyle(BouncyButtonStyle())
                
                // Botón personalizar
                Button(action: onCustomTap) {
                    Image(systemName: "gear")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color(.systemGray5))
                        )
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
    
    // Helper functions
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
    
    private func colorPorCargaGlicemica(_ carga: Double) -> Color {
        switch carga {
        case ..<10: return .green
        case 10..<20: return .orange
        default: return .red
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

// MARK: - Componente de Macro Info
struct MacroInfo: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(color)
            
            Text("\(value, specifier: "%.1f")")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Sheet para Agregar Alimento
struct AgregarAlimentoSheet: View {
    let alimento: Alimento
    let gramosIniciales: String
    let onAgregar: (Double) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @State private var gramos: String
    @State private var errorMessage: String?
    
    init(alimento: Alimento, gramosIniciales: String, onAgregar: @escaping (Double) -> Void) {
        self.alimento = alimento
        self.gramosIniciales = gramosIniciales
        self.onAgregar = onAgregar
        self._gramos = State(initialValue: gramosIniciales)
    }
    
    private var gramosValidos: Double? {
        guard let valor = Double(gramos),
              valor >= 1.0,
              valor <= 500.0 else {
            return nil
        }
        return valor
    }
    
    private var macrosCalculados: (carbos: Double, proteinas: Double, grasas: Double, calorias: Double) {
        let factor = (gramosValidos ?? 100.0) / 100.0
        return (
            carbos: alimento.carbohidratos * factor,
            proteinas: alimento.proteinas * factor,
            grasas: alimento.grasas * factor,
            calorias: ((alimento.carbohidratos * 4) + (alimento.proteinas * 4) + (alimento.grasas * 9)) * factor
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header del alimento
                VStack(spacing: 16) {
                    Image(systemName: iconoPorCategoria(alimento.categoria))
                        .font(.system(size: 48))
                        .foregroundColor(ColorHelper.Categorias.colorPorCategoria(alimento.categoria))
                    
                    Text(alimento.nombre)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(alimento.categoria.displayName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                
                // Selector de gramos
                VStack(alignment: .leading, spacing: 16) {
                    Text("Cantidad (gramos)")
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
                    
                    // Porciones comunes
                    Text("Porciones comunes:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                        ForEach([50, 100, 150, 200], id: \.self) { porcion in
                            Button(action: { gramos = String(porcion) }) {
                                Text("\(porcion)g")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(gramos == String(porcion) ? .white : ColorHelper.Principal.primario)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(gramos == String(porcion) ? ColorHelper.Principal.primario : ColorHelper.Principal.primario.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Preview nutricional
                if gramosValidos != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Información nutricional:")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            MacroPreviewRow(nombre: "Carbohidratos", valor: macrosCalculados.carbos, color: ColorHelper.Macronutrientes.carbohidratos)
                            MacroPreviewRow(nombre: "Proteínas", valor: macrosCalculados.proteinas, color: ColorHelper.Macronutrientes.proteinas)
                            MacroPreviewRow(nombre: "Grasas", valor: macrosCalculados.grasas, color: ColorHelper.Macronutrientes.grasas)
                            
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
                }
                
                Spacer()
            }
            .navigationTitle("Agregar Alimento")
            .navigationBarItems(
                leading: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Agregar") {
                    agregarAlimento()
                }
                .disabled(gramosValidos == nil)
            )
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
    
    private func agregarAlimento() {
        guard let gramos = gramosValidos else { return }
        onAgregar(gramos)
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

struct MacroPreviewRow: View {
    let nombre: String
    let valor: Double
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(nombre)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(valor, specifier: "%.1f")g")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

// MARK: - Vista para Agregar Alimento Personalizado (Placeholder)
struct AgregarAlimentoPersonalizadoView: View {
    let onAgregar: (Alimento) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("🍽️")
                    .font(.system(size: 64))
                
                Text("Agregar Alimento Personalizado")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Próximamente: Crea tus propios alimentos con información nutricional personalizada")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Alimento Personalizado")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Button Style
struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    SelectorAlimentosView(viewModel: PredictorViewModel())
}
