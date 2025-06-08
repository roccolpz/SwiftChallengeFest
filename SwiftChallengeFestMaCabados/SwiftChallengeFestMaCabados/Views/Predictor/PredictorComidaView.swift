//
//  PredictorComidaView.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct PredictorComidaView: View {
    @StateObject private var viewModel = PredictorViewModel()
    @StateObject private var glucosaManager = GlucosaManager.shared
    @StateObject private var perfilManager = PerfilUsuarioManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentTab: PredictorTab = .seleccionar
    @State private var showingComparacion = false
    @State private var showingConfiguracion = false
    @State private var showingTipoComidaSelector = false
    @State private var tipoComidaSeleccionado: TipoComida?
    private let historialViewModel = HistorialComidasViewModel.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector personalizado
                tabSelector
                
                // Contenido principal
                TabView(selection: $currentTab) {
                    // Tab 1: Seleccionar Alimentos
                    SelectorAlimentosView(viewModel: viewModel)
                        .tag(PredictorTab.seleccionar)
                    
                    // Tab 2: Alimentos Seleccionados
                    AlimentosSeleccionadosView(viewModel: viewModel)
                        .tag(PredictorTab.seleccionados)
                    
                    // Tab 3: Predicción
                    prediccionView
                        .tag(PredictorTab.prediccion)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Bottom bar con acciones
                bottomActionBar
            }
            .navigationTitle("Predictor de Glucosa")
            .navigationBarItems(
                leading: Button("Cerrar") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: HStack {
                    // Botón comparación
                    if viewModel.puedeGenerarPrediccion {
                        Button(action: { showingComparacion = true }) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.title3)
                        }
                    }
                    
                    // Botón configuración
                    Button(action: { showingConfiguracion = true }) {
                        Image(systemName: "gearshape")
                            .font(.title3)
                    }
                }
            )
        }
        .sheet(isPresented: $showingComparacion) {
            PrediccionComparativaView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingConfiguracion) {
            ConfiguracionPredictorView(viewModel: viewModel)
        }
        .onAppear {
            // Auto-navegar a seleccionados si ya hay alimentos
            if viewModel.hayAlimentosSeleccionados && currentTab == .seleccionar {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        currentTab = .seleccionados
                    }
                }
            }
        }
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(PredictorTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        currentTab = tab
                    }
                }) {
                    VStack(spacing: 8) {
                        // Icono
                        Image(systemName: tab.icon)
                            .font(.title3)
                            .foregroundColor(currentTab == tab ? .accentColor : .secondary)
                        
                        // Título
                        Text(tab.title)
                            .font(.caption)
                            .fontWeight(currentTab == tab ? .semibold : .regular)
                            .foregroundColor(currentTab == tab ? .accentColor : .secondary)
                        
                        // Badge para alimentos seleccionados
                        if tab == .seleccionados && viewModel.alimentosSeleccionados.count > 0 {
                            Text("\(viewModel.alimentosSeleccionados.count)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .frame(width: 18, height: 18)
                                .background(ColorHelper.Principal.primario)
                                .clipShape(Circle())
                        } else {
                            Color.clear.frame(height: 18)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .disabled(!tab.isEnabled(viewModel: viewModel))
                .opacity(tab.isEnabled(viewModel: viewModel) ? 1.0 : 0.6)
            }
        }
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
    
    // MARK: - Vista de Predicción
    private var prediccionView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if let prediccion = viewModel.prediccionActual {
                    // Gráfica de predicción
                    GraficaPrediccionView(
                        prediccion: prediccion,
                        glucosaInicial: glucosaManager.glucosaActual
                    )
                    .padding(.horizontal)
                    
                    // Resumen de la comida
                    ResumenComidaCard(resumen: viewModel.resumenComida)
                        .padding(.horizontal)
                    
                    // Recomendaciones
                    RecomendacionesCard(recomendaciones: prediccion.recomendaciones)
                        .padding(.horizontal)
                    
                    // Información de insulina (si es diabético)
                    if let insulina = prediccion.insulinaNecesaria {
                        InsulinaCard(dosis: insulina)
                            .padding(.horizontal)
                    }
                    
                    // Acciones
                    accionesPrediccion
                        .padding(.horizontal)
                    
                } else if viewModel.isLoading {
                    // Estado de carga
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Generando predicción...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                    
                } else {
                    // Estado vacío
                    VStack(spacing: 20) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("Predicción Lista")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Selecciona alimentos para ver cómo afectarán tu glucosa")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation {
                                currentTab = .seleccionar
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Agregar Alimentos")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(ColorHelper.Principal.primario)
                            .cornerRadius(12)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 80)
                }
            }
            .padding(.bottom, 100) // Espacio para bottom bar
        }
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 16) {
                // Orden de comida selector
                OrdenComidaSelector(
                    ordenSeleccionado: $viewModel.ordenComidaSeleccionado,
                    isCompact: true
                )
                
                Spacer()
                
                // Botón generar predicción
                if viewModel.puedeGenerarPrediccion {
                    Button(action: {
                        viewModel.generarPrediccion()
                        withAnimation {
                            currentTab = .prediccion
                        }
                    }) {
                        HStack(spacing: 8) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "waveform.path.ecg")
                            }
                            
                            Text(viewModel.isLoading ? "Calculando..." : "Predecir")
                                .fontWeight(.semibold)
                        }
                        
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(ColorHelper.Principal.primario)
                        )
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Acciones de Predicción
    private var accionesPrediccion: some View {
        VStack(spacing: 12) {
            if viewModel.prediccionActual != nil {
                Button(action: { showingTipoComidaSelector = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Registrar Comida")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorHelper.Principal.primario)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                
                Button(action: { 
                    viewModel.generarComparacion()
                    showingComparacion = true
                }) {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                        Text("Comparar Órdenes")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorHelper.Principal.primario)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingTipoComidaSelector) {
            TipoComidaSelectorView { tipo in
                tipoComidaSeleccionado = tipo
                historialViewModel.registrarComida(
                    alimentos: viewModel.alimentosSeleccionados,
                    usuario: perfilManager.perfil,
                    glucosaInicial: viewModel.glucosaInicial,
                    tipoComida: tipo,
                    ordenComida: viewModel.ordenComidaSeleccionado
                )
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // MARK: - Tipo Comida Selector
    struct TipoComidaSelectorView: View {
        let onConfirm: (TipoComida) -> Void
        @Environment(\.presentationMode) var presentationMode
        
        var body: some View {
            NavigationView {
                List {
                    ForEach(TipoComida.allCases, id: \.self) { tipo in
                        Button(action: {
                            onConfirm(tipo)
                        }) {
                            HStack {
                                Text(tipo.emoji)
                                    .font(.title2)
                                
                                Text(tipo.rawValue)
                                    .font(.headline)
                                
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .navigationTitle("Tipo de Comida")
                .navigationBarItems(trailing: Button("Cancelar") {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

// MARK: - Tabs Enum
enum PredictorTab: CaseIterable {
    case seleccionar
    case seleccionados
    case prediccion
    
    var title: String {
        switch self {
        case .seleccionar: return "Buscar"
        case .seleccionados: return "Seleccionados"
        case .prediccion: return "Predicción"
        }
    }
    
    var icon: String {
        switch self {
        case .seleccionar: return "magnifyingglass"
        case .seleccionados: return "list.bullet"
        case .prediccion: return "chart.line.uptrend.xyaxis"
        }
    }
    
    func isEnabled(viewModel: PredictorViewModel) -> Bool {
        switch self {
        case .seleccionar: return true
        case .seleccionados: return true
        case .prediccion: return viewModel.hayAlimentosSeleccionados
        }
    }
}

// MARK: - Cards de Información

struct ResumenComidaCard: View {
    let resumen: ResumenComida
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Resumen de la Comida")
                .font(.headline)
            
            // Macronutrientes
            VStack(spacing: 12) {
                MacronutrienteRow(
                    nombre: "Carbohidratos",
                    valor: resumen.macronutrientes.carbohidratos,
                    color: ColorHelper.Macronutrientes.carbohidratos,
                    unidad: "g"
                )
                
                MacronutrienteRow(
                    nombre: "Proteínas",
                    valor: resumen.macronutrientes.proteinas,
                    color: ColorHelper.Macronutrientes.proteinas,
                    unidad: "g"
                )
                
                MacronutrienteRow(
                    nombre: "Grasas",
                    valor: resumen.macronutrientes.grasas,
                    color: ColorHelper.Macronutrientes.grasas,
                    unidad: "g"
                )
                
                MacronutrienteRow(
                    nombre: "Fibra",
                    valor: resumen.macronutrientes.fibra,
                    color: ColorHelper.Macronutrientes.fibra,
                    unidad: "g"
                )
            }
            
            Divider()
            
            // Información adicional
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calorías totales")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(resumen.macronutrientes.calorias.caloriasFormat)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Complejidad")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Text(resumen.nivelComplejidad.emoji)
                        Text(resumen.nivelComplejidad.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4)
        )
    }
}

struct MacronutrienteRow: View {
    let nombre: String
    let valor: Double
    let color: Color
    let unidad: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(nombre)
                .font(.subheadline)
            
            Spacer()
            
            Text("\(valor, specifier: "%.1f")\(unidad)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

struct RecomendacionesCard: View {
    let recomendaciones: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recomendaciones")
                .font(.headline)
            
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(recomendaciones, id: \.self) { recomendacion in
                    HStack(alignment: .top, spacing: 12) {
                        Text("💡")
                            .font(.title3)
                        
                        Text(recomendacion)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ColorHelper.Estados.infoSuave)
        )
    }
}

struct InsulinaCard: View {
    let dosis: Double
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "syringe")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Insulina Sugerida")
                    .font(.headline)
                
                Text("Basado en tu ratio I:C personal")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(dosis.insulinaFormat)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.1))
        )
    }
}

// MARK: - Vista de Configuración (Placeholder)
struct ConfiguracionPredictorView: View {
    @ObservedObject var viewModel: PredictorViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("⚙️")
                    .font(.system(size: 64))
                
                Text("Configuración del Predictor")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Próximamente: Ajustes avanzados, calibración personalizada y configuración de alertas")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Configuración")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

#Preview {
    PredictorComidaView()
}
