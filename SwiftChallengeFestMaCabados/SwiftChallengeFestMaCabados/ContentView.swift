import SwiftUI
import CoreML

struct ContentView: View {
    @State private var perfilUsuario: PerfilUsuario? = cargarPerfil()
    
    var body: some View {
        if perfilUsuario != nil {
            DashboardView()
//                .onAppear {
//                    UserDefaults.standard.removeObject(forKey: "perfilUsuario")
//                }
        } else {
            UserFormView()
        }
    }
}

#Preview {
    ContentView()
}
