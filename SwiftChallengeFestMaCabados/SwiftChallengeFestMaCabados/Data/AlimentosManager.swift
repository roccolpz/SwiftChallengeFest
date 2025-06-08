//
//  AlimentosManager.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation

class AlimentosManager: ObservableObject {
    @Published var alimentos: [Alimento] = []
    @Published var isLoading = false
    
    static let shared = AlimentosManager()
    
    init() {
        cargarAlimentos()
    }
    
    func cargarAlimentos() {
        isLoading = true
        
        guard let url = Bundle.main.url(forResource: "alimentos", withExtension: "json") else {
            print("❌ No se encontró alimentos.json")
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let response = try JSONDecoder().decode(AlimentosResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.alimentos = response.alimentos
                self.isLoading = false
                print("✅ Cargados \(self.alimentos.count) alimentos")
            }
        } catch {
            print("❌ Error cargando alimentos: \(error)")
            isLoading = false
        }
    }
    
    func buscarAlimentos(texto: String) -> [Alimento] {
        if texto.isEmpty {
            return alimentos
        }
        return alimentos.filter {
            $0.nombre.localizedCaseInsensitiveContains(texto)
        }
    }
    
    func alimentosPorCategoria(_ categoria: CategoriaAlimento) -> [Alimento] {
        return alimentos.filter { $0.categoria == categoria }
    }
    
    func getAlimentoImageURL(for nombre: String) -> String? {
        return alimentos.first { $0.nombre.lowercased() == nombre.lowercased() }?.imagen
    }
}

struct AlimentosResponse: Codable {
    let alimentos: [Alimento]
}
