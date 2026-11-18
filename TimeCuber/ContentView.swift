import SwiftUI
import SwiftData

struct ContentView: View {
    
    @StateObject var vm = RubikViewModel()
    @AppStorage("temaApp") private var temaElegido: TemaApp = .claro
    @AppStorage("temaDelSistema") private var temaDelSistema = true
    @Environment(\.colorScheme) private var colorScheme

    private var temaEfectivo: TemaApp {
        guard temaDelSistema else { return temaElegido }
        return colorScheme == .dark ? .oscuro : .claro
    }

    var body: some View {
   
        TabView{
            vistaCronometro()
            .tabItem {Image(systemName: "stopwatch.fill")}
            
            vistaListaTiempos()
            .tabItem {Image(systemName: "tray")}
            
            vistaEstadisticas()
            .tabItem {Image(systemName: "chart.bar")}
            
            vistaCategorias()
                .tabItem {Image(systemName: "archivebox")}
            
            vistaAjustes()
            .tabItem {
                Image(systemName: "gearshape")
                    .accessibilityLabel("Ajustes")
                    .accessibilityIdentifier("tab-ajustes")
            }
            
        }
        .tint(temaEfectivo.acento)
        .background(temaEfectivo.fondo.ignoresSafeArea())
        .foregroundStyle(temaEfectivo.texto)
        .toolbarBackground(temaEfectivo.fondo, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(temaEfectivo.colorScheme, for: .tabBar)
        .preferredColorScheme(temaDelSistema ? nil : temaElegido.colorScheme)
        .environment(\.temaApp, temaEfectivo)
        .environment(\.colorScheme, temaEfectivo.colorScheme)
 
    }
    
    
    func vistaCronometro() -> some View {
        CronometroView(vm: vm)
        .onAppear {
            vm.actualizarVista()
        }
    }

    func vistaListaTiempos() -> some View {
        ListaTiemposView(vm: vm)
        .onAppear {
            vm.actualizarVista()
        }
    }
    
    func vistaEstadisticas() -> some View {
        EstadisticasView(vm: vm)
        .onAppear {
            vm.actualizarVista()
        }
    }
    
    func vistaCategorias() -> some View {
        CategoriasView(vm: vm)
        .onAppear {
            vm.actualizarVista()
        }
    }
    
    func vistaAjustes() -> some View {
        AjustesView()
    }

}

#Preview {
    ContentView()
}
