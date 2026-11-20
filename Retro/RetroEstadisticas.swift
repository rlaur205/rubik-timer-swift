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
            EncabezadoRetro(titulo: "Estadísticas", contexto: vm.sesionActual.nombre) {
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
            PanelRetro(titulo: ventana.titulo) {
                ForEach(Array(ventana.tiempos.reversed())) { tiempo in
                    HStack {
                        Text(tiempo.texto(largo: true))
                            .font(.system(.headline, design: .monospaced, weight: .black))
                        Spacer(minLength: 6)
                        Text(formatoFecha(tiempo.fecha))
                            .font(.system(.caption, design: .monospaced))
                            .multilineTextAlignment(.trailing)
                    }
                    .padding(11)
                    .cajaRetro(relieve: false)
                }
            }
        }
    }

    private var resumen: some View {
        SeccionRetro(titulo: "RESUMEN", color: paleta.lima) {
            cuadricula {
                metrica("Solves", valor: "\(tiempos.count)")
                metrica("Media", valor: EstiloVisual.promedio(mediaTotal(tiempos: tiempos)))
                metrica("Mejor tiempo", valor: mejorTiempo(tiempos: tiempos)?.texto(largo: false) ?? "—")
                metrica("Peor tiempo", valor: peorTiempo(tiempos: tiempos)?.texto(largo: false) ?? "—")
            }
        }
    }

    private var promedios: some View {
        SeccionRetro(titulo: "PROMEDIOS ACTUALES", color: paleta.amarillo) {
            cuadricula {
                metrica("Último", valor: tiempos.last?.texto(largo: false) ?? "—")
                ForEach(cantidades, id: \.self) { cantidad in
                    let resultado = cantidad == 3 ? mo3(tiempos: tiempos) : avg(tiempos: tiempos, cantidad: cantidad)
                    let ventana = tiempos.count >= cantidad ? Array(tiempos.suffix(cantidad)) : []
                    promedio(cantidad, resultado: resultado, resoluciones: ventana, esRecord: false)
                }
            }
        }
    }

    private var records: some View {
        SeccionRetro(titulo: "RÉCORDS PERSONALES", color: paleta.lavanda) {
            cuadricula {
                ForEach(cantidades, id: \.self) { cantidad in
                    let pb = cantidad == 3 ? PBmo3(tiempos: tiempos) : PBavg(tiempos: tiempos, cantidad: cantidad)
                    promedio(cantidad, resultado: pb.resultado, resoluciones: pb.tiempos, esRecord: true)
                }
                metrica("Desviación", valor: desviacion(tiempos: tiempos))
            }
        }
    }

    private var progreso: some View {
        SeccionRetro(titulo: "PROGRESO", color: paleta.menta) {
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

    private func promedio(_ cantidad: Int, resultado: ResultadoPromedio, resoluciones: [Tiempo], esRecord: Bool) -> some View {
        let titulo = cantidad == 3 ? "Mo3" : "Ao\(cantidad)"
        let valor = EstiloVisual.promedio(resultado)

        return Group {
            if resoluciones.isEmpty {
                metrica(titulo, valor: valor)
            } else {
                Button {
                    seleccionado = VentanaRetro(titulo: esRecord ? "Récord · \(titulo)" : "Tiempos · \(titulo)", tiempos: resoluciones)
                } label: {
                    metrica(titulo, valor: valor, detalle: true)
                }
                .buttonStyle(.plain)
                .accessibilityHint("Muestra los tiempos del promedio")
            }
        }
    }

    private func metrica(_ titulo: String, valor: String, detalle: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 3) {
                Text(titulo).font(.caption.weight(.semibold)).foregroundStyle(paleta.secundario)
                Spacer(minLength: 0)
                if detalle {
                    Image(systemName: "arrow.up.right").font(.caption2.weight(.bold)).accessibilityHidden(true)
                }
            }
            Text(valor)
                .font(.system(.title3, design: .monospaced, weight: .black))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 55, alignment: .leading)
        .cajaRetro(relieve: false, radio: 5)
        .accessibilityElement(children: .combine)
    }

    private struct VentanaRetro: Identifiable {
        var id: String { titulo }
        let titulo: String
        let tiempos: [Tiempo]
    }
}
