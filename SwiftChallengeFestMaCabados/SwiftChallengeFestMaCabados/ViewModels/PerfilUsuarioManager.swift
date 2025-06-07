//
//  PerfilUsuarioManager.swift
//  SwiftChallengeFestMaCabados
//
//  Created by Isaac Rojas on 07/06/25.
//
import Foundation
import SwiftUI

class PerfilUsuarioManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var perfil: PerfilUsuario = PerfilUsuario() {
        didSet {
            guardarPerfil()
            validarPerfil()
        }
    }
    
    @Published var configuracionCompleta: Bool = false
    @Published var errorValidacion: String?
    @Published var isLoading: Bool = false
    @Published var requiereOnboarding: Bool = true
    
    // MARK: - Computed Properties
    
    var perfilEsValido: Bool {
        return !perfil.nombre.isEmpty &&
               perfil.edad >= AppConstants.Usuario.edadMinima &&
               perfil.peso >= AppConstants.Usuario.pesoMinimo &&
               perfil.altura >= AppConstants.Usuario.alturaMinima
    }
    
    var configuracionDiabetesCompleta: Bool {
        guard perfil.esDiabetico else { return true }
        
        return perfil.tipoDiabetes != nil &&
               perfil.glucosaObjetivo != nil &&
               (perfil.insulinaBasalDiaria != nil || !requiereInsulinaConfig)
    }
    
    var requiereInsulinaConfig: Bool {
        return perfil.esDiabetico &&
               (perfil.tipoDiabetes == .tipo1 ||
                perfil.usaBombaInsulina)
    }
    
    var categoriaIMC: (categoria: String, color: Color) {
        let imc = perfil.imc
        switch imc {
        case ..<18.5:
            return ("Bajo peso", ColorHelper.Estados.advertencia)
        case 18.5..<25:
            return ("Normal", ColorHelper.Estados.exito)
        case 25..<30:
            return ("Sobrepeso", ColorHelper.Estados.advertencia)
        case 30..<35:
            return ("Obesidad I", ColorHelper.Estados.error)
        case 35..<40:
            return ("Obesidad II", ColorHelper.Estados.error)
        default:
            return ("Obesidad III", ColorHelper.Estados.error)
        }
    }
    
    var ratiosCalculados: (ic: Double?, sensibilidad: Double?) {
        guard let insulinaDiaria = perfil.insulinaBasalDiaria else {
            return (nil, nil)
        }
        
        let ratioIC = CalculadoraClinica.calcularRatioIC(insulinaDiaria: insulinaDiaria)
        let factorSensibilidad = CalculadoraClinica.calcularFactorSensibilidad(insulinaDiaria: insulinaDiaria)
        
        return (ratioIC, factorSensibilidad)
    }
    
    // MARK: - Singleton
    static let shared = PerfilUsuarioManager()
    
    // MARK: - Initialization
    private init() {
        cargarPerfil()
        validarPerfil()
        verificarOnboarding()
    }
    
    // MARK: - Public Methods
    
    /// Actualiza datos básicos del usuario
    func actualizarDatosBasicos(
        nombre: String,
        edad: Int,
        genero: Genero,
        peso: Double,
        altura: Double
    ) {
        guard validarDatosBasicos(edad: edad, peso: peso, altura: altura) else {
            return
        }
        
        perfil.nombre = nombre.limpio
        perfil.edad = edad
        perfil.genero = genero
        perfil.peso = peso
        perfil.altura = altura
        
        print("✅ Datos básicos actualizados para \(nombre)")
    }
    
    /// Configura información de diabetes
    func configurarDiabetes(
        esDiabetico: Bool,
        tipo: TipoDiabetes? = nil,
        glucosaObjetivo: Double? = nil,
        insulinaBasal: Double? = nil,
        usaBomba: Bool = false,
        usaMonitor: Bool = false,
        medicamentos: [String] = []
    ) {
        perfil.esDiabetico = esDiabetico
        
        if esDiabetico {
            perfil.tipoDiabetes = tipo
            perfil.glucosaObjetivo = glucosaObjetivo ?? AppConstants.Glucosa.objetivo
            perfil.insulinaBasalDiaria = insulinaBasal
            perfil.usaBombaInsulina = usaBomba
            perfil.usaMonitorContinuo = usaMonitor
            perfil.medicamentos = medicamentos
        } else {
            // Limpiar datos de diabetes si no es diabético
            perfil.tipoDiabetes = nil
            perfil.glucosaObjetivo = nil
            perfil.insulinaBasalDiaria = nil
            perfil.usaBombaInsulina = false
            perfil.usaMonitorContinuo = false
            perfil.medicamentos = []
        }
        
        print("✅ Configuración de diabetes actualizada")
    }
    
    /// Configura horarios de comidas
    func configurarHorarios(
        desayuno: Date,
        comida: Date,
        cena: Date
    ) {
        perfil.horarioDesayuno = desayuno
        perfil.horarioComida = comida
        perfil.horarioCena = cena
        
        print("✅ Horarios de comida configurados")
    }
    
    /// Configura preferencias alimentarias
    func configurarPreferencias(
        alimentosFrecuentes: [String],
        alergias: [String],
        restricciones: [RestriccionDietetica]
    ) {
        perfil.alimentosFrecuentes = alimentosFrecuentes
        perfil.alergias = alergias
        perfil.restriccionesDieteticas = restricciones
        
        print("✅ Preferencias alimentarias configuradas")
    }
    
    /// Estima insulina basal basada en peso (para usuarios tipo 1)
    func estimarInsulinaBasal() -> Double? {
        guard perfil.esDiabetico,
              perfil.tipoDiabetes == .tipo1 else {
            return nil
        }
        
        return CalculadoraClinica.estimarDosisBasePorPeso(pesoKg: perfil.peso)
    }
    
    /// Completa el onboarding
    func completarOnboarding() {
        guard perfilEsValido && configuracionDiabetesCompleta else {
            errorValidacion = "Perfil incompleto. Verifica todos los campos requeridos."
            return
        }
        
        configuracionCompleta = true
        requiereOnboarding = false
        
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.configuracionCompleta)
        UserDefaults.standard.set(false, forKey: AppConstants.UserDefaultsKeys.primeraVez)
        
        print("🎉 Onboarding completado para \(perfil.nombre)")
    }
    
    /// Resetea el perfil (para testing)
    func resetearPerfil() {
        perfil = PerfilUsuario()
        configuracionCompleta = false
        requiereOnboarding = true
        
        // Limpiar UserDefaults
        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.perfilUsuario)
        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.configuracionCompleta)
        UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.primeraVez)
        
        print("🔄 Perfil reseteado")
    }
    
    /// Genera reporte del perfil para exportar
    func generarReportePerfil() -> String {
        var reporte = """
        📋 REPORTE DE PERFIL - \(Date().fechaCompletaFormat)
        
        👤 DATOS PERSONALES:
        Nombre: \(perfil.nombre)
        Edad: \(perfil.edad) años
        Género: \(perfil.genero.rawValue)
        Peso: \(perfil.peso.gramosFormat.replacingOccurrences(of: "g", with: "kg"))
        Altura: \(perfil.altura) cm
        IMC: \(perfil.imc.imcFormat) (\(categoriaIMC.categoria))
        
        """
        
        if perfil.esDiabetico {
            reporte += """
            🩺 INFORMACIÓN MÉDICA:
            Tipo de diabetes: \(perfil.tipoDiabetes?.rawValue ?? "No especificado")
            Glucosa objetivo: \(perfil.glucosaObjetivo?.glucosaFormat ?? "No especificado")
            
            """
            
            if let insulina = perfil.insulinaBasalDiaria {
                reporte += """
                💉 INSULINA:
                Dosis basal diaria: \(insulina.insulinaFormat)
                Ratio I:C: \(ratiosCalculados.ic?.gramosFormat.replacingOccurrences(of: "g", with: ":1") ?? "No calculado")
                Factor sensibilidad: \(ratiosCalculados.sensibilidad?.glucosaFormat ?? "No calculado")
                
                """
            }
            
            if !perfil.medicamentos.isEmpty {
                reporte += "Medicamentos: \(perfil.medicamentos.joined(separator: ", "))\n\n"
            }
        }
        
        reporte += """
        🍽️ HORARIOS DE COMIDA:
        Desayuno: \(perfil.horarioDesayuno.horaFormat)
        Comida: \(perfil.horarioComida.horaFormat)
        Cena: \(perfil.horarioCena.horaFormat)
        """
        
        if !perfil.restriccionesDieteticas.isEmpty {
            reporte += "\n\n🥗 RESTRICCIONES: \(perfil.restriccionesDieteticas.map { $0.rawValue }.joined(separator: ", "))"
        }
        
        return reporte
    }
    
    // MARK: - Private Methods
    
    private func cargarPerfil() {
        if let data = UserDefaults.standard.data(forKey: AppConstants.UserDefaultsKeys.perfilUsuario),
           let perfilGuardado = try? JSONDecoder().decode(PerfilUsuario.self, from: data) {
            perfil = perfilGuardado
        }
    }
    
    private func guardarPerfil() {
        if let data = try? JSONEncoder().encode(perfil) {
            UserDefaults.standard.set(data, forKey: AppConstants.UserDefaultsKeys.perfilUsuario)
        }
    }
    
    private func validarPerfil() {
        errorValidacion = nil
        
        // Validar edad
        if perfil.edad < AppConstants.Usuario.edadMinima || perfil.edad > AppConstants.Usuario.edadMaxima {
            errorValidacion = AppConstants.Textos.validacionEdad
            return
        }
        
        // Validar peso
        if perfil.peso < AppConstants.Usuario.pesoMinimo || perfil.peso > AppConstants.Usuario.pesoMaximo {
            errorValidacion = AppConstants.Textos.validacionPeso
            return
        }
        
        // Validar insulina si es requerida
        if requiereInsulinaConfig {
            if let insulina = perfil.insulinaBasalDiaria {
                if insulina < AppConstants.Insulina.basalDiariaMin || insulina > AppConstants.Insulina.basalDiariaMax {
                    errorValidacion = "Dosis de insulina fuera de rango seguro"
                    return
                }
            } else {
                errorValidacion = "Dosis de insulina requerida para diabetes tipo 1"
                return
            }
        }
    }
    
    private func validarDatosBasicos(edad: Int, peso: Double, altura: Double) -> Bool {
        if edad < AppConstants.Usuario.edadMinima || edad > AppConstants.Usuario.edadMaxima {
            errorValidacion = AppConstants.Textos.validacionEdad
            return false
        }
        
        if peso < AppConstants.Usuario.pesoMinimo || peso > AppConstants.Usuario.pesoMaximo {
            errorValidacion = AppConstants.Textos.validacionPeso
            return false
        }
        
        if altura < AppConstants.Usuario.alturaMinima || altura > AppConstants.Usuario.alturaMaxima {
            errorValidacion = "Altura debe estar entre \(AppConstants.Usuario.alturaMinima) y \(AppConstants.Usuario.alturaMaxima) cm"
            return false
        }
        
        return true
    }
    
    private func verificarOnboarding() {
        configuracionCompleta = UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.configuracionCompleta)
        requiereOnboarding = UserDefaults.standard.object(forKey: AppConstants.UserDefaultsKeys.primeraVez) == nil ||
                           UserDefaults.standard.bool(forKey: AppConstants.UserDefaultsKeys.primeraVez)
        
        // Si hay perfil guardado pero no está marcado como completo, verificar
        if !configuracionCompleta && perfilEsValido && configuracionDiabetesCompleta {
            configuracionCompleta = true
            requiereOnboarding = false
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.configuracionCompleta)
        }
    }
}
