//
//  Extensions.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation
import SwiftUI

// MARK: - Double Extensions
extension Double {
    
    /// Formatea glucosa con 0 decimales (ej: "125 mg/dL")
    var glucosaFormat: String {
        return "\(Int(self.rounded())) mg/dL"
    }
    
    /// Formatea gramos con 1 decimal (ej: "15.5g")
    var gramosFormat: String {
        return String(format: "%.1fg", self)
    }
    
    /// Formatea carbohidratos para mostrar (ej: "45.2g carbos")
    var carbosFormat: String {
        return String(format: "%.1fg carbos", self)
    }
    
    /// Formatea calorías (ej: "285 kcal")
    var caloriasFormat: String {
        return "\(Int(self.rounded())) kcal"
    }
    
    /// Formatea insulina con 1 decimal (ej: "4.5 U")
    var insulinaFormat: String {
        return String(format: "%.1f U", self)
    }
    
    /// Formatea porcentaje (ej: "37%")
    var porcentajeFormat: String {
        return "\(Int(self.rounded()))%"
    }
    
    /// Formatea IMC con 1 decimal (ej: "24.3")
    var imcFormat: String {
        return String(format: "%.1f", self)
    }
    
    /// Redondea a la mitad más cercana (para insulina)
    var redondeadoAMediaUnidad: Double {
        return (self * 2).rounded() / 2
    }
}

// MARK: - Date Extensions
extension Date {
    
    /// Formatea hora como "14:30"
    var horaFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    /// Formatea fecha completa como "Sáb 7 Jun"
    var fechaCompletaFormat: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: self)
    }
    
    /// Formatea para mostrar tiempo relativo (ej: "hace 15 min")
    var tiempoRelativo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Verifica si es la mañana (6:00 - 11:59)
    var esMañana: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour >= 6 && hour < 12
    }
    
    /// Verifica si es la tarde (12:00 - 17:59)
    var esTarde: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour >= 12 && hour < 18
    }
    
    /// Verifica si es la noche (18:00 - 23:59)
    var esNoche: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour >= 18 || hour < 6
    }
    
    /// Crea una fecha con solo hora (para comparaciones)
    var soloHora: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: self)
        return calendar.date(from: components) ?? self
    }
}

// MARK: - String Extensions
extension String {
    
    /// Capitaliza la primera letra
    var capitalizandoPrimera: String {
        return prefix(1).capitalized + dropFirst()
    }
    
    /// Valida si es un número válido
    var esNumeroValido: Bool {
        return Double(self) != nil
    }
    
    /// Convierte a Double de forma segura
    var aDouble: Double? {
        return Double(self)
    }
    
    /// Convierte a Int de forma segura
    var aInt: Int? {
        return Int(self)
    }
    
    /// Elimina espacios y caracteres extraños
    var limpio: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Color Extensions
extension Color {
    
    /// Inicializa Color desde hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Array Extensions
extension Array where Element == AlimentoConPorcion {
    
    /// Calcula carbohidratos totales
    var carbohidratosTotales: Double {
        return self.reduce(0) { $0 + $1.carbohidratosReales }
    }
    
    /// Calcula proteínas totales
    var proteinasTotales: Double {
        return self.reduce(0) { $0 + $1.proteinasReales }
    }
    
    /// Calcula grasas totales
    var grasasTotales: Double {
        return self.reduce(0) { $0 + $1.grasasReales }
    }
    
    /// Calcula fibra total
    var fibraTotales: Double {
        return self.reduce(0) { $0 + $1.fibraReales }
    }
    
    /// Calcula calorías totales
    var caloriasTotales: Double {
        let carbos = carbohidratosTotales * 4
        let proteinas = proteinasTotales * 4
        let grasas = grasasTotales * 9
        return carbos + proteinas + grasas
    }
    
    /// Verifica si la comida está balanceada
    var estaBalanceada: Bool {
        let carbos = carbohidratosTotales
        let proteinas = proteinasTotales
        let total = carbos + proteinas + grasasTotales
        
        guard total > 0 else { return false }
        
        let porcentajeCarbos = (carbos / total) * 100
        let porcentajeProteinas = (proteinas / total) * 100
        
        // Balanceada si tiene 45-65% carbos y 10-35% proteínas
        return porcentajeCarbos >= 45 && porcentajeCarbos <= 65 &&
               porcentajeProteinas >= 10 && porcentajeProteinas <= 35
    }
}

// MARK: - View Extensions
extension View {
    
    /// Aplica esquinas redondeadas específicas
    func esquinasRedondeadas(_ radio: CGFloat, esquinas: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radio, corners: esquinas))
    }
    
    /// Condicionalmente aplica un modificador
    @ViewBuilder func condicional<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Shapes Helper
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
