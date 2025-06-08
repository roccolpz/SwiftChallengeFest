import Foundation

struct MealPlanResponse: Codable {
    let mealPlan: MealPlan
    let alimentosUtilizados: AlimentosUtilizados
    let mealPlansAnterioresCount: Int
    
    enum CodingKeys: String, CodingKey {
        case mealPlan = "meal_plan"
        case alimentosUtilizados = "alimentos_utilizados"
        case mealPlansAnterioresCount = "meal_plans_anteriores_count"
    }
}

struct MealPlan: Codable {
    let metadatos: Metadatos
    let dias: [String: DiaPlan]
    let resumenSemanal: ResumenSemanal
    let listaCompras: ListaCompras
    let tipsNutricionales: [TipNutricional]
    
    enum CodingKeys: String, CodingKey {
        case metadatos
        case dias
        case resumenSemanal = "resumen_semanal"
        case listaCompras = "lista_compras"
        case tipsNutricionales = "tips_nutricionales"
    }
}

struct Metadatos: Codable {
    let usuario: String
    let fechaGeneracion: String
    let perfil: Perfil
    let horarios: Horarios
    let alimentosFavoritos: [String]
    
    enum CodingKeys: String, CodingKey {
        case usuario
        case fechaGeneracion = "fecha_generacion"
        case perfil
        case horarios
        case alimentosFavoritos = "alimentos_favoritos"
    }
}

struct Perfil: Codable {
    let edad: Int
    let peso: Double
    let imc: Double
    let esDiabetico: Bool
    let tipoDiabetes: String
    let nivelControl: String
    
    enum CodingKeys: String, CodingKey {
        case edad
        case peso
        case imc
        case esDiabetico = "es_diabetico"
        case tipoDiabetes = "tipo_diabetes"
        case nivelControl = "nivel_control"
    }
}

struct Horarios: Codable {
    let desayuno: String
    let almuerzo: String
    let cena: String
}

struct DiaPlan: Codable {
    let desayuno: Comida
    let snackMatutino: Comida
    let almuerzo: Comida
    let merienda: Comida
    let cena: Comida
    let balanceDiario: BalanceDiario
    
    enum CodingKeys: String, CodingKey {
        case desayuno
        case snackMatutino = "snack_matutino"
        case almuerzo
        case merienda
        case cena
        case balanceDiario = "balance_diario"
    }
}

struct Comida: Codable {
    let hora: String
    let alimentosEnOrden: [AlimentoPlan]
    let balanceNutricional: BalanceNutricional
    
    enum CodingKeys: String, CodingKey {
        case hora
        case alimentosEnOrden = "alimentos_en_orden"
        case balanceNutricional = "balance_nutricional"
    }
}

struct AlimentoPlan: Codable, Identifiable {
    let id = UUID()
    let nombre: String
    let porcionSugerida: String
    let ordenConsumo: Int
    let esFavorito: Bool
    let datosNutricionales: DatosNutricionales
    
    enum CodingKeys: String, CodingKey {
        case nombre
        case porcionSugerida = "porcion_sugerida"
        case ordenConsumo = "orden_consumo"
        case esFavorito = "es_favorito"
        case datosNutricionales = "datos_nutricionales"
    }
}

struct DatosNutricionales: Codable {
    let carbohidratos: Double
    let proteinas: Double
    let grasas: Double
    let fibra: Double
    let indiceGlucemico: Int
    let cargaGlucemica: Double
    
    enum CodingKeys: String, CodingKey {
        case carbohidratos
        case proteinas
        case grasas
        case fibra
        case indiceGlucemico = "indice_glucemico"
        case cargaGlucemica = "carga_glucemica"
    }
}

struct BalanceNutricional: Codable {
    let carbohidratosTotal: Double
    let proteinasTotal: Double
    let grasasTotal: Double
    let fibraTotal: Double
    let cargaGlucemicaTotal: Double
    
    enum CodingKeys: String, CodingKey {
        case carbohidratosTotal = "carbohidratos_total"
        case proteinasTotal = "proteinas_total"
        case grasasTotal = "grasas_total"
        case fibraTotal = "fibra_total"
        case cargaGlucemicaTotal = "carga_glucemica_total"
    }
}

struct BalanceDiario: Codable {
    let carbohidratosTotal: Double
    let proteinasTotal: Double
    let grasasTotal: Double
    let fibraTotal: Double
    let cargaGlucemicaTotal: Double
    let evaluacion: String
    
    enum CodingKeys: String, CodingKey {
        case carbohidratosTotal = "carbohidratos_total"
        case proteinasTotal = "proteinas_total"
        case grasasTotal = "grasas_total"
        case fibraTotal = "fibra_total"
        case cargaGlucemicaTotal = "carga_glucemica_total"
        case evaluacion
    }
}

struct ResumenSemanal: Codable {
    let totalesSemanales: TotalesSemanales
    let promediosDiarios: PromediosDiarios
    let beneficioOrdenOptimo: String
    let cumplimientoObjetivos: CumplimientoObjetivos
    
    enum CodingKeys: String, CodingKey {
        case totalesSemanales = "totales_semanales"
        case promediosDiarios = "promedios_diarios"
        case beneficioOrdenOptimo = "beneficio_orden_optimo"
        case cumplimientoObjetivos = "cumplimiento_objetivos"
    }
}

struct TotalesSemanales: Codable {
    let carbohidratos: Double
    let proteinas: Double
    let grasas: Double
    let fibra: Double
    let cargaGlucemica: Double
    
    enum CodingKeys: String, CodingKey {
        case carbohidratos
        case proteinas
        case grasas
        case fibra
        case cargaGlucemica = "carga_glucemica"
    }
}

struct PromediosDiarios: Codable {
    let carbohidratosPromedioDiario: Double
    let proteinasPromedioDiario: Double
    let grasasPromedioDiario: Double
    let fibraPromedioDiario: Double
    let cargaGlucemicaPromedioDiario: Double
    
    enum CodingKeys: String, CodingKey {
        case carbohidratosPromedioDiario = "carbohidratos_promedio_diario"
        case proteinasPromedioDiario = "proteinas_promedio_diario"
        case grasasPromedioDiario = "grasas_promedio_diario"
        case fibraPromedioDiario = "fibra_promedio_diario"
        case cargaGlucemicaPromedioDiario = "carga_glucemica_promedio_diario"
    }
}

struct CumplimientoObjetivos: Codable {
    let objetivosIndividuales: ObjetivosIndividuales
    let porcentajeCumplimiento: Double
    let estadoGeneral: String
    
    enum CodingKeys: String, CodingKey {
        case objetivosIndividuales = "objetivos_individuales"
        case porcentajeCumplimiento = "porcentaje_cumplimiento"
        case estadoGeneral = "estado_general"
    }
}

struct ObjetivosIndividuales: Codable {
    let carbohidratos: Bool
    let proteinas: Bool
    let fibra: Bool
    let cargaGlucemica: Bool
    
    enum CodingKeys: String, CodingKey {
        case carbohidratos
        case proteinas
        case fibra
        case cargaGlucemica = "carga_glucemica"
    }
}

struct ListaCompras: Codable {
    let proteinas: [ItemCompra]
    let carbohidratos: [ItemCompra]
    let verdurasYVegetales: [ItemCompra]
    
    enum CodingKeys: String, CodingKey {
        case proteinas = "🥩 Proteínas"
        case carbohidratos = "🍞 Carbohidratos"
        case verdurasYVegetales = "🥬 Verduras y Vegetales"
    }
}

struct ItemCompra: Codable {
    let alimento: String
    let cantidadSemanal: Int
    let esFavorito: Bool
    
    enum CodingKeys: String, CodingKey {
        case alimento
        case cantidadSemanal = "cantidad_semanal"
        case esFavorito = "es_favorito"
    }
}

struct TipNutricional: Codable {
    let categoria: String
    let titulo: String
    let descripcion: String
    let instrucciones: [String]
}

struct AlimentosUtilizados: Codable {
    let desayunos: [String]
    let almuerzos: [String]
    let cenas: [String]
    let snacks: [String]
} 