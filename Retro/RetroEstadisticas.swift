import SwiftUI
import Charts

struct RetroEstadisticas: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.retro) private var paleta
    @State private var seleccionado: VentanaRetro?

    private let cantidades = [3, 5, 12, 25, 50, 100, 200, 500, 1000]
    private var tiempos: [Tiempo] { vm.sesionActual.tiempos }

    var body: some View {
        PantallaRetro {
            EncabezadoRetro(titulo: "Estadísticas") {
                SelloRetro(texto: vm.sesionActual.categoria, color: paleta.lavanda)
            }
            if tiempos.isEmpty {
                VacioRetro(icono: "chart.xyaxis.line", titulo: "Aún no hay estadísticas", mensaje: "Registra tu primera resolución para ver tu progreso.")
            } else {
                resumen
                promedios
                records
                progreso
            }
        }
        .sheet(item: $seleccionado) { ventana in
            RetroListaPromedio(vm: vm, titulo: ventana.titulo, tiempos: ventana.tiempos, esAo: ventana.esAo)
        }
    }

    private var resumen: some View {
        SeccionRetro(titulo: "RESUMEN", color: paleta.lima, tituloDestacado: true) {
            cuadricula {
                metrica("Solves", valor: "\(tiempos.count)", estiloValor: .title3)
                metrica("Media", valor: EstiloVisual.promedio(mediaTotal(tiempos: tiempos)))
                metrica("Mejor tiempo", valor: mejorTiempo(tiempos: tiempos)?.texto(largo: false) ?? "—")
                metrica("Peor tiempo", valor: peorTiempo(tiempos: tiempos)?.texto(largo: false) ?? "—")
            }
        }
    }

    private var promedios: some View {
        SeccionRetro(titulo: "PROMEDIOS ACTUALES", color: paleta.amarillo, tituloDestacado: true) {
            cuadricula {
                metrica("Último", valor: tiempos.last?.texto(largo: false) ?? "—")
                ForEach(cantidades, id: \.self) { cantidad in
                    let resultado = cantidad == 3 ? mo3(tiempos: tiempos) : avg(tiempos: tiempos, cantidad: cantidad)
                    let ventana = tiempos.count >= cantidad ? Array(tiempos.suffix(cantidad)) : []
                    promedio(cantidad, resultado: resultado, resoluciones: ventana)
                }
            }
        }
    }

    private var records: some View {
        SeccionRetro(titulo: "RÉCORDS PERSONALES", color: paleta.lavanda, tituloDestacado: true) {
            cuadricula {
                ForEach(cantidades, id: \.self) { cantidad in
                    let pb = cantidad == 3 ? PBmo3(tiempos: tiempos) : PBavg(tiempos: tiempos, cantidad: cantidad)
                    promedio(cantidad, resultado: pb.resultado, resoluciones: pb.tiempos)
                }
                metrica("Desviación", valor: desviacion(tiempos: tiempos))
            }
        }
    }

    private var progreso: some View {
        SeccionRetro(titulo: "PROGRESO", color: paleta.menta, tituloDestacado: true) {
            let puntos = grafica(tiempos: tiempos)
            if puntos.isEmpty {
                Text("Aún no hay tiempos válidos para graficar.").font(.subheadline)
            } else {
                Chart(puntos) { punto in
                    LineMark(x: .value("Resolución", punto.indice), y: .value("Segundos", punto.value))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(paleta.oscura ? paleta.menta : paleta.tinta)
                    PointMark(x: .value("Resolución", punto.indice), y: .value("Segundos", punto.value))
                        .symbolSize(22)
                        .foregroundStyle(paleta.oscura ? paleta.lima : paleta.tinta)
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxisLabel("Resolución")
                .chartYAxisLabel("Segundos")
                .frame(height: 178)
                .accessibilityLabel("Gráfica de progreso")
            }
        }
    }

    private func cuadricula<Contenido: View>(@ViewBuilder _ contenido: () -> Contenido) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8, content: contenido)
    }

    private func promedio(_ cantidad: Int, resultado: ResultadoPromedio, resoluciones: [Tiempo]) -> some View {
        let titulo = cantidad == 3 ? "Mo3" : "Ao\(cantidad)"
        let valor = EstiloVisual.promedio(resultado)

        return Group {
            if resoluciones.isEmpty {
                metrica(titulo, valor: valor)
            } else {
                Button {
                    seleccionado = VentanaRetro(titulo: titulo, tiempos: resoluciones, esAo: cantidad != 3)
                } label: {
                    metrica(titulo, valor: valor, detalle: true)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Muestra los tiempos del promedio")
            }
        }
    }

    private func metrica(
        _ titulo: String, valor: String, detalle: Bool = false, estiloValor: Font.TextStyle = .title
    ) -> some View {
        let titulos = ["Solves", "Media", "Mejor tiempo", "Peor tiempo", "Último", "Mo3", "Ao5", "Ao12", "Ao25", "Ao50", "Ao100", "Ao200", "Ao500", "Ao1000", "Desviación"]
        let colores: [Color] = [
            paleta.lima, paleta.amarillo, paleta.menta, paleta.coral,
            paleta.naranja, paleta.lavanda,
            Color(red: 0.67, green: 0.83, blue: 0.97),
            Color(red: 0.98, green: 0.72, blue: 0.77),
            Color(red: 0.76, green: 0.88, blue: 0.68),
            Color(red: 0.94, green: 0.80, blue: 0.62)
        ]
        let fondo = colores[(titulos.firstIndex(of: titulo) ?? 0) % colores.count]

        return VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 3) {
                Text(titulo).font(.subheadline.weight(.bold))
                    .foregroundStyle(paleta.tinta)
                Spacer(minLength: 0)
                if detalle {
                    Image(systemName: "arrow.up.right").font(.caption2.weight(.bold)).accessibilityHidden(true)
                }
            }
            Text(valor)
                .font(.system(estiloValor, design: .monospaced, weight: .black))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .foregroundStyle(paleta.tinta)
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 55, alignment: .leading)
        .cajaRetro(fondo, radio: 10, desplazamiento: 1.5)
        .accessibilityElement(children: .combine)
    }

    private struct VentanaRetro: Identifiable {
        var id: String { titulo }
        let titulo: String
        let tiempos: [Tiempo]
        let esAo: Bool
    }
}


private struct RetroListaPromedio: View {
    let vm: RubikViewModel
    let titulo: String
    let tiempos: [Tiempo]
    let esAo: Bool
    @Environment(\.retro) private var paleta
    @State private var seleccionado: Tiempo?

    var body: some View {
        PanelRetro(titulo: titulo) {
            if esAo {
                extremos
            }
        } contenido: {
            ForEach(tiempos.reversed()) { tiempo in
                RetroFilaTiempo(tiempo: tiempo) { seleccionado = tiempo }
            }
        }
        .sheet(item: $seleccionado) { tiempo in
            RetroDetalleTiempo(vm: vm, original: tiempo, soloLectura: true)
        }
    }

    private var extremos: some View {
        let peor = tiempos.first { $0.penalizacion == .dnf } ?? peorTiempo(tiempos: tiempos)
        let mejor = mejorTiempo(tiempos: tiempos)
        return ViewThatFits(in: .horizontal) {
            HStack(spacing: 5) {
                sello("Peor tiempo", tiempo: peor, color: paleta.coral)
                sello("Mejor tiempo", tiempo: mejor, color: paleta.menta)
            }
            VStack(alignment: .trailing, spacing: 4) {
                sello("Peor tiempo", tiempo: peor, color: paleta.coral)
                sello("Mejor tiempo", tiempo: mejor, color: paleta.menta)
            }
        }
    }

    private func sello(_ titulo: String, tiempo: Tiempo?, color: Color) -> some View {
        SelloRetro(texto: tiempo?.texto(largo: false) ?? "—", color: color, destacado: true)
            .accessibilityLabel("\(titulo), \(tiempo?.texto(largo: true) ?? "sin tiempo válido")")
    }
}
