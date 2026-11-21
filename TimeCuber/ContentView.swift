import SwiftUI

enum PestanaTimeCuber: CaseIterable {
    case cronometro, tiempos, estadisticas, sesiones, ajustes
}

struct ContentView: View {
    @StateObject var vm = RubikViewModel()
    @AppStorage("temaApp") private var temaElegido: TemaApp = .claro
    @AppStorage("temaDelSistema") private var temaDelSistema = true
    @AppStorage(AparienciaRetro.claveActivada) private var retroActivo = false
    @AppStorage(AparienciaRetro.claveOscura) private var retroOscuro = false
    @State private var pestana: PestanaTimeCuber = .cronometro
    @Environment(\.colorScheme) private var colorScheme

    private var temaEfectivo: TemaApp {
        guard temaDelSistema else { return temaElegido }
        return colorScheme == .dark ? .oscuro : .claro
    }

    private var esquemaManual: ColorScheme {
        retroActivo ? (retroOscuro ? .dark : .light) : temaElegido.colorScheme
    }

    var body: some View {
        Group {
            if retroActivo {
                RetroContenedor(vm: vm, pestana: $pestana)
            } else {
                interfazOriginal
            }
        }
        .preferredColorScheme(temaDelSistema ? nil : esquemaManual)
    }

    private var interfazOriginal: some View {
        TabView(selection: $pestana) {
            CronometroView(vm: vm)
                .onAppear { vm.actualizarVista() }
                .tabItem { Image(systemName: "stopwatch.fill") }
                .tag(PestanaTimeCuber.cronometro)

            ListaTiemposView(vm: vm)
                .onAppear { vm.actualizarVista() }
                .tabItem { Image(systemName: "tray") }
                .tag(PestanaTimeCuber.tiempos)

            EstadisticasView(vm: vm)
                .onAppear { vm.actualizarVista() }
                .tabItem { Image(systemName: "chart.bar") }
                .tag(PestanaTimeCuber.estadisticas)

            CategoriasView(vm: vm)
                .onAppear { vm.actualizarVista() }
                .tabItem { Image(systemName: "archivebox") }
                .tag(PestanaTimeCuber.sesiones)

            AjustesView(vm: vm)
                .tabItem {
                    Image(systemName: "gearshape")
                        .accessibilityLabel("Ajustes")
                        .accessibilityIdentifier("tab-ajustes")
                }
                .tag(PestanaTimeCuber.ajustes)
        }
        .tint(temaEfectivo.acento)
        .background(temaEfectivo.fondo.ignoresSafeArea())
        .foregroundStyle(temaEfectivo.texto)
        .toolbarBackground(temaEfectivo.fondo, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(temaEfectivo.colorScheme, for: .tabBar)
        .environment(\.temaApp, temaEfectivo)
        .environment(\.colorScheme, temaEfectivo.colorScheme)
    }
}

#Preview {
    ContentView()
}
