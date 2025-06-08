import Foundation
import Combine

class HistorialComidasViewModel: ObservableObject {
    static let shared = HistorialComidasViewModel()
    
    @Published var comidasRecientes: [ComidaHistorial] = []
    private let predictor = PredictorGlucosa()
    
    init() {
        cargarComidasRecientes()
    }
    
    func registrarComida(
        alimentos: [AlimentoConPorcion],
        usuario: PerfilUsuario,
        glucosaInicial: Double,
        tipoComida: TipoComida,
        ordenComida: OrdenComida
    ) {
        print("📝 Registrando nueva comida...")
        
        // Obtener predicción
        let prediccion = predictor.predecirGlucosa(
            alimentos: alimentos,
            usuario: usuario,
            glucosaActual: glucosaInicial,
            horaComida: Date(),
            ordenComida: ordenComida
        )
        
        // Crear nuevo registro
        let nuevaComida = ComidaHistorial(
            fecha: Date(),
            tipoComida: tipoComida,
            ordenUsado: ordenComida,
            glucosaInicial: glucosaInicial,
            picoPredicho: prediccion.picoMaximo.glucosa,
            picoReal: nil, // Se actualizará cuando el usuario ingrese el valor real
            alimentos: alimentos.map { $0.alimento.nombre },
            cargaGlicemica: prediccion.cargaGlicemica,
            efectividad: .buena // Se actualizará cuando se ingrese el valor real
        )
        
        print("🍽️ Nueva comida creada: \(nuevaComida.alimentos.joined(separator: ", "))")
        
        // Agregar a la lista y guardar
        DispatchQueue.main.async { [weak self] in
            self?.comidasRecientes.insert(nuevaComida, at: 0)
            self?.guardarComidas()
            print("💾 Comida guardada. Total de comidas: \(self?.comidasRecientes.count ?? 0)")
        }
    }
    
    func actualizarPicoReal(para comida: ComidaHistorial, picoReal: Double) {
        if let index = comidasRecientes.firstIndex(where: { $0.id == comida.id }) {
            var comidaActualizada = comida
            comidaActualizada.picoReal = picoReal
            
            // Calcular efectividad basada en la diferencia
            let diferencia = abs(picoReal - comida.picoPredicho)
            comidaActualizada.efectividad = calcularEfectividad(diferencia: diferencia)
            
            comidasRecientes[index] = comidaActualizada
            guardarComidas()
            print("📊 Pico real actualizado: \(picoReal) mg/dL")
        }
    }
    
    private func calcularEfectividad(diferencia: Double) -> EfectividadPrediccion {
        switch diferencia {
        case ..<10: return .excelente
        case 10..<20: return .buena
        case 20..<30: return .regular
        default: return .mala
        }
    }
    
    private func cargarComidasRecientes() {
        print("📂 Cargando comidas guardadas...")
        if let data = UserDefaults.standard.data(forKey: "comidasRecientes"),
           let comidas = try? JSONDecoder().decode([ComidaHistorial].self, from: data) {
            self.comidasRecientes = comidas
            print("✅ Comidas cargadas: \(comidas.count)")
        } else {
            print("ℹ️ No hay comidas guardadas")
        }
    }
    
    private func guardarComidas() {
        print("💾 Guardando \(comidasRecientes.count) comidas...")
        if let data = try? JSONEncoder().encode(comidasRecientes) {
            UserDefaults.standard.set(data, forKey: "comidasRecientes")
            print("✅ Comidas guardadas exitosamente")
        } else {
            print("❌ Error al guardar comidas")
        }
    }
} 