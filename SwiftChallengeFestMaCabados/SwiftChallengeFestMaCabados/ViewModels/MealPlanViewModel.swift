import Foundation
import SwiftUI

class MealPlanViewModel: ObservableObject {
    @Published var mealPlan: MealPlan?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let alimentosManager = AlimentosManager.shared
    
    init() {
        loadMealPlan()
    }
    
    func loadMealPlan() {
        isLoading = true
        
        // Try loading from main bundle first
        if let url = Bundle.main.url(forResource: "meal_plan", withExtension: "json") {
            loadMealPlanFromURL(url)
        }
        // Try loading from Resources directory
        else if let url = Bundle.main.url(forResource: "meal_plan", withExtension: "json", subdirectory: "Resources") {
            loadMealPlanFromURL(url)
        }
        else {
            DispatchQueue.main.async {
                self.error = NSError(domain: "MealPlanError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No se pudo encontrar el archivo meal_plan.json"])
                self.isLoading = false
                print("Error: Could not find meal_plan.json in bundle or Resources directory")
            }
        }
    }
    
    private func loadMealPlanFromURL(_ url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(MealPlanResponse.self, from: data)
            DispatchQueue.main.async {
                self.mealPlan = response.mealPlan
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                self.isLoading = false
                print("Error decoding meal plan: \(error)")
            }
        }
    }
    
    func getAlimentoImage(for nombre: String) -> String {
        // This would typically come from your AlimentosManager
        // For now, we'll return a default image name based on the food category
        if nombre.lowercased().contains("arroz") {
            return "rice"
        } else if nombre.lowercased().contains("pollo") {
            return "chicken"
        } else if nombre.lowercased().contains("espinacas") {
            return "spinach"
        } else if nombre.lowercased().contains("manzana") {
            return "apple"
        }
        return "food_default"
    }
    
    func getAlimentoCategoria(for nombre: String) -> CategoriaAlimento {
        // This would typically come from your AlimentosManager
        // For now, we'll return a default category based on the food name
        if nombre.lowercased().contains("arroz") || nombre.lowercased().contains("pan") {
            return .carbohidratos
        } else if nombre.lowercased().contains("pollo") || nombre.lowercased().contains("huevo") {
            return .proteinas
        } else if nombre.lowercased().contains("espinacas") || nombre.lowercased().contains("lechuga") {
            return .verduras
        } else if nombre.lowercased().contains("manzana") || nombre.lowercased().contains("fresa") {
            return .frutas
        }
        return .procesados
    }
} 