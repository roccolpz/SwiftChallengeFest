//
//  MealPlanner.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Rodrigo Garcia on 08/06/25.
//

import SwiftUI

struct MealPlanner: View {
    @StateObject private var viewModel = MealPlanViewModel()
    @State private var selectedDay = "lunes"
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Cargando plan de comidas...")
                } else if let error = viewModel.error {
                    VStack {
                        Text("Error al cargar el plan de comidas")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                } else if let mealPlan = viewModel.mealPlan {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Daily Meal Plan Section
                            DailyMealPlanSection(dias: mealPlan.dias, selectedDay: $selectedDay, viewModel: viewModel)
                            
                            // Shopping List Section
                            ShoppingListSection(listaCompras: mealPlan.listaCompras)
                            
                            // Nutrition Tips Section
                            NutritionTipsSection(tips: mealPlan.tipsNutricionales)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Plan de Comidas")
        }
    }
}

struct UserProfileSection: View {
    let usuario: String
    let perfil: Perfil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Perfil de Usuario")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Usuario: \(usuario)")
                Text("Edad: \(perfil.edad) años")
                Text("Peso: \(String(format: "%.1f", perfil.peso)) kg")
                Text("IMC: \(String(format: "%.1f", perfil.imc))")
                Text("Tipo de Diabetes: \(perfil.tipoDiabetes)")
                Text("Nivel de Control: \(perfil.nivelControl)")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct WeeklySummarySection: View {
    let resumenSemanal: ResumenSemanal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Resumen Semanal")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Carbohidratos: \(String(format: "%.1f", resumenSemanal.totalesSemanales.carbohidratos))g")
                Text("Proteínas: \(String(format: "%.1f", resumenSemanal.totalesSemanales.proteinas))g")
                Text("Grasas: \(String(format: "%.1f", resumenSemanal.totalesSemanales.grasas))g")
                Text("Fibra: \(String(format: "%.1f", resumenSemanal.totalesSemanales.fibra))g")
                Text("Carga Glucémica: \(String(format: "%.1f", resumenSemanal.totalesSemanales.cargaGlucemica))")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct DailyMealPlanSection: View {
    let dias: [String: DiaPlan]
    @Binding var selectedDay: String
    let viewModel: MealPlanViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Plan Diario")
                .font(.headline)
            
            // Day Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(["lunes", "martes", "miercoles", "jueves", "viernes", "sabado", "domingo"], id: \.self) { day in
                        Button(action: {
                            selectedDay = day
                        }) {
                            Text(day.capitalized)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 8)
                                .background(selectedDay == day ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedDay == day ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
            }
            
            // Meal Cards
            if let plan = dias[selectedDay] {
                VStack(spacing: 15) {
                    MealCard(title: "Desayuno", comida: plan.desayuno, viewModel: viewModel)
                    MealCard(title: "Snack Matutino", comida: plan.snackMatutino, viewModel: viewModel)
                    MealCard(title: "Almuerzo", comida: plan.almuerzo, viewModel: viewModel)
                    MealCard(title: "Merienda", comida: plan.merienda, viewModel: viewModel)
                    MealCard(title: "Cena", comida: plan.cena, viewModel: viewModel)
                }
            } else {
                Text("No hay plan disponible para este día")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct MealCard: View {
    let title: String
    let comida: Comida
    let viewModel: MealPlanViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            Text("Hora: \(comida.hora)")
                .font(.subheadline)
            
            ForEach(comida.alimentosEnOrden) { alimento in
                HStack {
                    if let imageUrl = AlimentosManager.shared.getAlimentoImageURL(for: alimento.nombre) {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                            .frame(width: 40, height: 40)
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading) {
                        Text(alimento.nombre)
                            .font(.subheadline)
                        Text("Porción: \(alimento.porcionSugerida)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    if alimento.esFavorito {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            // Nutritional Balance
            VStack(alignment: .leading, spacing: 5) {
                Text("Balance Nutricional:")
                    .font(.subheadline)
                Text("Carbohidratos: \(String(format: "%.1f", comida.balanceNutricional.carbohidratosTotal))g")
                Text("Proteínas: \(String(format: "%.1f", comida.balanceNutricional.proteinasTotal))g")
                Text("Grasas: \(String(format: "%.1f", comida.balanceNutricional.grasasTotal))g")
                Text("Fibra: \(String(format: "%.1f", comida.balanceNutricional.fibraTotal))g")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ShoppingListSection: View {
    let listaCompras: ListaCompras
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Lista de Compras")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 15) {
                ShoppingListCategory(title: "🥩 Proteínas", items: listaCompras.proteinas)
                ShoppingListCategory(title: "🍞 Carbohidratos", items: listaCompras.carbohidratos)
                ShoppingListCategory(title: "🥬 Verduras y Vegetales", items: listaCompras.verdurasYVegetales)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

struct ShoppingListCategory: View {
    let title: String
    let items: [ItemCompra]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
            
            ForEach(items, id: \.alimento) { item in
                HStack {
                    Text(item.alimento)
                    Spacer()
                    Text("\(item.cantidadSemanal) unidades")
                        .foregroundColor(.gray)
                    if item.esFavorito {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .font(.caption)
            }
        }
    }
}

struct NutritionTipsSection: View {
    let tips: [TipNutricional]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tips Nutricionales")
                .font(.headline)
            
            ForEach(tips, id: \.titulo) { tip in
                VStack(alignment: .leading, spacing: 5) {
                    Text(tip.titulo)
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    Text(tip.descripcion)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    ForEach(tip.instrucciones, id: \.self) { instruccion in
                        Text(instruccion)
                            .font(.caption)
                    }
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    MealPlanner()
}
