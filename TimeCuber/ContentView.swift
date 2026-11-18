import SwiftUI
import SwiftData

struct ContentView: View {
    
    @StateObject var vm = RubikViewModel()
    
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
            
            //en preparacion
            //vistaAjustes()
            //.tabItem {Image(systemName: "gearshape")}
            
        }
        .tint(.cyan)
 
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
    
}

#Preview {
    ContentView()
}
