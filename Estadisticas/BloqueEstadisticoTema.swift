import SwiftUI
import Charts

// MARK: - Roles de los bloques

/// Los cuatro bloques de Estadísticas, con un acento propio por tema.
enum BloqueTema: Int, CaseIterable {
    case resumen
    case promedios
    case records
    case progreso
}

struct EstiloBloqueTema {
    let superficie: Color
    let acento: Color

    /// Lavado apenas perceptible sobre la superficie del bloque.
    var gradiente: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: superficie, location: 0),
                .init(color: superficie, location: 0.72),
                .init(color: acento.opacity(0.055), location: 1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var borde: Color {
        acento.opacity(0.22)
    }
}

// MARK: - Fondo del bloque

struct FondoBloqueEstadistico: View {
    let estilo: EstiloBloqueTema
    var radio: CGFloat = 16

    var body: some View {
        RoundedRectangle(cornerRadius: radio, style: .continuous)
            .fill(estilo.gradiente)
            .background(estilo.superficie, in: RoundedRectangle(cornerRadius: radio, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radio, style: .continuous)
                    .strokeBorder(estilo.borde, lineWidth: 1)
            }
    }
}

// MARK: - Encabezado del bloque

struct EncabezadoBloqueEstadistico: View {
    let titulo: String
    let sistema: String
    let estilo: EstiloBloqueTema

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: sistema)
                .font(.caption.weight(.semibold))
                .foregroundStyle(estilo.acento)
                .padding(5)
                .background(
                    estilo.acento.opacity(0.14),
                    in: RoundedRectangle(cornerRadius: 6, style: .continuous)
                )
                .accessibilityHidden(true)

            Text(titulo)
                .font(.headline.weight(.bold))
                .foregroundStyle(estilo.acento)
        }
        .textCase(nil)
        .accessibilityAddTraits(.isHeader)
    }
}

// MARK: - Gráfico de progreso

struct GraficoProgresoEstadistico: View {
    let actual: [Tiempo]
    let estilo: EstiloBloqueTema

    @Environment(\.temaApp) private var temaApp

    var body: some View {
        let items = grafica(tiempos: actual)
        let base = items.map(\.value).min() ?? 0

        Group {
            if items.isEmpty {
                Text("Sin tiempos válidos para mostrar")
                    .font(.subheadline)
                    .foregroundStyle(temaApp.texto.opacity(0.65))
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                Chart(items) { item in
                    AreaMark(
                        x: .value("Resolución", item.indice),
                        yStart: .value("Base", base),
                        yEnd: .value("Segundos", item.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [estilo.acento.opacity(0.12), estilo.acento.opacity(0.01)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Resolución", item.indice),
                        y: .value("Segundos", item.value)
                    )
                    .foregroundStyle(estilo.acento)

                    PointMark(
                        x: .value("Resolución", item.indice),
                        y: .value("Segundos", item.value)
                    )
                    .foregroundStyle(estilo.acento)
                    .symbolSize(12)
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 5)) { _ in
                        AxisGridLine().foregroundStyle(temaApp.linea.opacity(0.7))
                        AxisTick().foregroundStyle(temaApp.linea)
                        AxisValueLabel().foregroundStyle(temaApp.texto.opacity(0.65))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine().foregroundStyle(temaApp.linea.opacity(0.7))
                        AxisTick().foregroundStyle(temaApp.linea)
                        AxisValueLabel().foregroundStyle(temaApp.texto.opacity(0.65))
                    }
                }
                .chartXAxisLabel {
                    Text("Resolución")
                        .font(.caption)
                        .foregroundStyle(temaApp.texto.opacity(0.65))
                }
                .chartYAxisLabel {
                    Text("Segundos")
                        .font(.caption)
                        .foregroundStyle(temaApp.texto.opacity(0.65))
                }
                .frame(height: 200)
            }
        }
        .padding(.vertical, 12)
        .accessibilityLabel("Progreso de los tiempos de la sesión")
    }
}
