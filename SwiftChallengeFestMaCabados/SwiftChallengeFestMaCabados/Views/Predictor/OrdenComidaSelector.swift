//
//  OrdenComidaSelector.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import SwiftUI

struct OrdenComidaSelector: View {
    @Binding var ordenSeleccionado: OrdenComida
    let isCompact: Bool
    @State private var showingDetalles = false
    
    init(ordenSeleccionado: Binding<OrdenComida>, isCompact: Bool = false) {
        self._ordenSeleccionado = ordenSeleccionado
        self.isCompact = isCompact
    }
    
    var body: some View {
        if isCompact {
            compactSelector
        } else {
            fullSelector
        }
    }
    
    // MARK: - Selector Compacto (para bottom bar)
    private var compactSelector: some View {
        HStack(spacing: 12) {
            // Icono y texto
            VStack(alignment: .leading, spacing: 4) {
                Text("Orden:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(ordenSeleccionado.descripcion)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ordenSeleccionado.color)
                    .lineLimit(1)
            }
            
            // Selector de opciones
            Menu {
                ForEach(OrdenComida.allCases, id: \.self) { orden in
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            ordenSeleccionado = orden
                        }
                    }) {
                        HStack {
                            Text(orden.descripcion)
                            
                            if orden == ordenSeleccionado {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                
                Divider()
                
                Button(action: { showingDetalles = true }) {
                    HStack {
                        Text("Ver beneficios detallados")
                        Image(systemName: "info.circle")
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text("Cambiar")
                        .font(.caption)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundColor(ColorHelper.Principal.primario)
            }
        }
        .sheet(isPresented: $showingDetalles) {
            OrdenComidaDetallesView(ordenSeleccionado: $ordenSeleccionado)
        }
    }
    
    // MARK: - Selector Completo
    private var fullSelector: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header con información
            VStack(alignment: .leading, spacing: 8) {
                Text("Orden de Comida")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("El orden en que comes puede reducir los picos de glucosa hasta 37%. Elige el orden que mejor se adapte a tu comida.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(action: { showingDetalles = true }) {
                    HStack(spacing: 4) {
                        Text("Ver estudios científicos")
                        Image(systemName: "link")
                    }
                    .font(.caption)
                    .foregroundColor(ColorHelper.Principal.primario)
                }
            }
            
            // Opciones de orden
            VStack(spacing: 16) {
                ForEach(OrdenComida.allCases, id: \.self) { orden in
                    OrdenComidaCard(
                        orden: orden,
                        isSelected: ordenSeleccionado == orden,
                        onTap: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                ordenSeleccionado = orden
                            }
                        }
                    )
                }
            }
        }
        .sheet(isPresented: $showingDetalles) {
            OrdenComidaDetallesView(ordenSeleccionado: $ordenSeleccionado)
        }
    }
}

// MARK: - Card de Orden de Comida
struct OrdenComidaCard: View {
    let orden: OrdenComida
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Indicador visual del orden
                OrdenVisualIndicator(orden: orden)
                
                // Información del orden
                VStack(alignment: .leading, spacing: 6) {
                    Text(orden.descripcion)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(beneficioTexto(orden))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    // Badge de efectividad
                    HStack {
                        efectividadBadge(orden)
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? orden.color.opacity(0.1) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? orden.color : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func beneficioTexto(_ orden: OrdenComida) -> String {
        switch orden {
        case .verdurasPrimero:
            return "Reduce picos de glucosa hasta 37%. Método más efectivo respaldado por estudios."
        case .proteinasPrimero:
            return "Reduce picos hasta 20%. Buena opción cuando hay pocas verduras."
        case .simultaneo:
            return "Orden tradicional. Sin beneficios específicos en control de glucosa."
        case .carbohidratosPrimero:
            return "⚠️ Puede aumentar picos hasta 25%. No recomendado para diabéticos."
        }
    }
    
    private func efectividadBadge(_ orden: OrdenComida) -> some View {
        let (texto, color) = efectividadInfo(orden)
        
        return Text(texto)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color.opacity(0.15))
            )
    }
    
    private func efectividadInfo(_ orden: OrdenComida) -> (String, Color) {
        switch orden {
        case .verdurasPrimero:
            return ("⭐ MÁS EFECTIVO", .green)
        case .proteinasPrimero:
            return ("✓ BUENO", .blue)
        case .simultaneo:
            return ("○ NEUTRAL", .gray)
        case .carbohidratosPrimero:
            return ("⚠️ NO RECOMENDADO", .red)
        }
    }
}

// MARK: - Indicador Visual del Orden
struct OrdenVisualIndicator: View {
    let orden: OrdenComida
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                ForEach(Array(iconosOrden(orden).enumerated()), id: \.offset) { index, icono in
                    VStack(spacing: 2) {
                        Text(icono.emoji)
                            .font(.title3)
                        
                        if index < iconosOrden(orden).count - 1 {
                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if orden == .simultaneo {
                Text("Todo junto")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: 80)
    }
    
    private func iconosOrden(_ orden: OrdenComida) -> [(emoji: String, nombre: String)] {
        switch orden {
        case .verdurasPrimero:
            return [("🥬", "Verduras"), ("🍗", "Proteínas"), ("🍚", "Carbohidratos")]
        case .proteinasPrimero:
            return [("🍗", "Proteínas"), ("🥬", "Verduras"), ("🍚", "Carbohidratos")]
        case .carbohidratosPrimero:
            return [("🍚", "Carbohidratos"), ("🥬", "Verduras"), ("🍗", "Proteínas")]
        case .simultaneo:
            return [("🍽️", "Todo")]
        }
    }
}

// MARK: - Vista de Detalles Científicos
struct OrdenComidaDetallesView: View {
    @Binding var ordenSeleccionado: OrdenComida
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        Text("🔬")
                            .font(.system(size: 48))
                        
                        Text("Ciencia del Orden de Comida")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Estudios científicos demuestran que el orden en que consumes los alimentos puede tener un impacto significativo en tus niveles de glucosa postprandial.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Estudios científicos
                    VStack(alignment: .leading, spacing: 20) {
                        EstudioCard(
                            titulo: "Verduras Primero",
                            reduccion: "17-37%",
                            descripcion: "Estudios clínicos muestran que comer verduras y proteínas antes que carbohidratos puede reducir significativamente los picos de glucosa postprandial.",
                            beneficios: [
                                "Fibra soluble ralentiza absorción de carbohidratos",
                                "Incrementa incretinas (GLP-1) que mejoran sensibilidad a insulina",
                                "Retrasa vaciado gástrico",
                                "Reduce área bajo la curva de glucosa"
                            ],
                            color: .green,
                            recomendado: true
                        )
                        
                        EstudioCard(
                            titulo: "Proteínas Primero",
                            reduccion: "10-20%",
                            descripcion: "Las proteínas consumidas antes de carbohidratos estimulan la secreción de insulina y mejoran el control glucémico.",
                            beneficios: [
                                "Estimula secreción temprana de insulina",
                                "Aumenta saciedad",
                                "Ralentiza digestión de carbohidratos",
                                "Mejora sensibilidad a insulina"
                            ],
                            color: .blue,
                            recomendado: false
                        )
                        
                        EstudioCard(
                            titulo: "Carbohidratos Primero",
                            reduccion: "+15-25%",
                            descripcion: "Consumir carbohidratos al inicio de la comida resulta en los picos de glucosa más altos y prolongados.",
                            beneficios: [
                                "⚠️ Absorción rápida de glucosa",
                                "⚠️ Picos de glucosa elevados",
                                "⚠️ Mayor demanda de insulina",
                                "⚠️ Peor control glucémico"
                            ],
                            color: .red,
                            recomendado: false
                        )
                    }
                    .padding(.horizontal)
                    
                    // Recomendaciones personalizadas
                    recomendacionesPersonalizadas
                        .padding(.horizontal)
                    
                    // Referencias
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Referencias Científicas")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ReferenciaRow(texto: "Diabetes Care. 2015;38(9):e143-4. 'Food order has a significant impact on postprandial glucose'")
                            ReferenciaRow(texto: "Diabetes Care. 2016;39(9):e119-20. 'Vegetable and protein first strategy'")
                            ReferenciaRow(texto: "BMJ Open Diabetes Res Care. 2020;8(1):e001162. 'Meal sequence effects on glucose'")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Orden de Comida")
            .navigationBarItems(trailing: Button("Cerrar") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var recomendacionesPersonalizadas: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💡 Recomendación Personalizada")
                .font(.headline)
                .foregroundColor(ColorHelper.Principal.primario)
            
            VStack(alignment: .leading, spacing: 12) {
                RecomendacionRow(
                    icono: "🥬",
                    titulo: "Para mejor control de glucosa",
                    descripcion: "Verduras primero es la estrategia más efectiva"
                )
                
                RecomendacionRow(
                    icono: "🍗",
                    titulo: "Si tienes pocas verduras",
                    descripcion: "Proteínas primero es tu segunda mejor opción"
                )
                
                RecomendacionRow(
                    icono: "⏰",
                    titulo: "Tiempo entre porciones",
                    descripcion: "Espera 10-15 minutos entre cada grupo de alimentos"
                )
                
                RecomendacionRow(
                    icono: "🚰",
                    titulo: "Hidratación",
                    descripcion: "Bebe agua con las verduras para aumentar la fibra soluble"
                )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorHelper.Principal.primario.opacity(0.1))
            )
        }
    }
}

// MARK: - Componentes Auxiliares

struct EstudioCard: View {
    let titulo: String
    let reduccion: String
    let descripcion: String
    let beneficios: [String]
    let color: Color
    let recomendado: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(titulo)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text("Impacto: \(reduccion)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(color)
                        
                        if recomendado {
                            Text("⭐ RECOMENDADO")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(color)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
            }
            
            // Descripción
            Text(descripcion)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Beneficios
            VStack(alignment: .leading, spacing: 8) {
                ForEach(beneficios, id: \.self) { beneficio in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(color)
                            .fontWeight(.bold)
                        
                        Text(beneficio)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct RecomendacionRow: View {
    let icono: String
    let titulo: String
    let descripcion: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icono)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(descripcion)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct ReferenciaRow: View {
    let texto: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("📄")
                .font(.caption)
            
            Text(texto)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview("Selector Completo") {
    OrdenComidaSelector(ordenSeleccionado: .constant(.verdurasPrimero))
        .padding()
}

#Preview("Selector Compacto") {
    OrdenComidaSelector(ordenSeleccionado: .constant(.verdurasPrimero), isCompact: true)
        .padding()
}
