import SwiftUI

struct RetroCronometro: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.retro) private var paleta
    @Environment(\.dynamicTypeSize) private var tipoDinamico
    @ScaledMetric(relativeTo: .subheadline) private var alturaTiempoReciente = 18.0
    @AppStorage(AjustesInicioCronometro.claveMantenerParaIniciar) private var mantener = AjustesInicioCronometro.mantenerPredeterminado
    @AppStorage(AjustesInicioCronometro.claveTiempoEspera) private var espera = AjustesInicioCronometro.esperaPredeterminada
    @AppStorage(AjustesInicioCronometro.claveColorListo) private var colorListo = AjustesInicioCronometro.colorPredeterminado
    @AppStorage(AjustesInicioCronometro.claveTamanoScramble) private var tamanoScramble = AjustesInicioCronometro.tamanoScramblePredeterminado
    @AppStorage(AjustesInicioCronometro.claveMostrarScramble) private var mostrarScramble = AjustesInicioCronometro.mostrarScramblePredeterminado
    @AppStorage(AjustesInicioCronometro.claveTamanoTimer) private var tamanoTimer = AjustesInicioCronometro.tamanoTimerPredeterminado
    @AppStorage(AjustesInicioCronometro.claveFuenteTimer) private var fuenteTimer = AjustesInicioCronometro.fuenteTimerPredeterminada
    @AppStorage(AjustesInicioCronometro.claveFuenteScramble) private var fuenteScramble = AjustesInicioCronometro.fuenteScramblePredeterminada
    @State private var mostrarDiagrama = false
    @State private var mostrarPenalizacion = false
    @State private var tiempoPorEliminar: Tiempo?
    @State private var expandido = false

    private var tiempos: [Tiempo] { vm.sesionActual.tiempos }
    private var intentoActivo: Bool { vm.timerState.intentoActivo }

    var body: some View {
        GeometryReader { espacio in
            if tipoDinamico.isAccessibilitySize || espacio.size.height < 530 {
                ScrollView {
                    contenido.frame(minHeight: espacio.size.height)
                }
                .scrollDisabled(intentoActivo)
                .scrollBounceBehavior(.basedOnSize)
            } else {
                contenido
            }
        }
        .sheet(isPresented: $mostrarPenalizacion) {
            if let ultimo = tiempos.last {
                PanelRetro(titulo: "Último tiempo") {
                    Text(ultimo.texto(largo: true))
                        .font(.system(.largeTitle, design: .monospaced, weight: .black))
                    PenalizacionesRetro(seleccion: ultimo.penalizacion) { penalizacion in
                        vm.establecerPenalizacion(penalizacion, tiempoID: ultimo.id)
                        mostrarPenalizacion = false
                    }
                }
                .presentationDetents(tipoDinamico.isAccessibilitySize ? [.large] : [.height(235)])
            }
        }
        .sheet(item: $tiempoPorEliminar) { tiempo in
            ConfirmacionRetro(
                titulo: "¿Eliminar último tiempo?",
                mensaje: "Se eliminará el tiempo \(tiempo.texto(largo: true)) de esta sesión.",
                accionTitulo: "Eliminar"
            ) {
                vm.borrarUltimoTiempo(id: tiempo.id)
            }
        }
    }

    private var contenido: some View {
        VStack(spacing: 14) {
            if !intentoActivo {
                encabezado
                if mostrarScramble {
                    tarjetaScramble
                } else {
                    if !tiempos.isEmpty { recientes }
                    if !vm.scrambleListo { tarjetaScramble }
                }
            }
            instrumento
            if !intentoActivo {
                if mostrarScramble && !tiempos.isEmpty { recientes }
                resumen
            }
        }
        .padding(.horizontal, 17)
        .padding(.top, 2)
        .padding(.bottom, 10)
        .frame(maxHeight: .infinity)
    }

    private var encabezado: some View {
        HStack(spacing: 10) {
            Text("\(vm.sesionActual.categoria) · \(vm.sesionActual.nombre)".uppercased())
                .font(.system(.subheadline, design: .monospaced, weight: .heavy))
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(paleta.tinta)
                .cajaRetro(paleta.naranja, radio: 12)
                .rotationEffect(.degrees(-2))
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                if let ultimo = tiempos.last {
                    IconoBotonRetro(titulo: "Eliminar último tiempo", icono: "trash") { tiempoPorEliminar = ultimo }
                }
                IconoBotonRetro(
                    titulo: mostrarScramble ? "Ver diagrama" : "Ver scramble y diagrama",
                    icono: "cube.transparent", relleno: paleta.amarillo
                ) { mostrarDiagrama = true }
                .disabled(!vm.scrambleListo)
                .popover(isPresented: $mostrarDiagrama, arrowEdge: .top) {
                    VStack(spacing: 12) {
                        if !mostrarScramble { textoScramble }
                        ImagenScrambleView(scramble: vm.scrambleActual, categoria: vm.sesionActual.categoria)
                            .frame(width: 250, height: 173)
                    }
                    .padding(12)
                    .frame(idealWidth: mostrarScramble ? 278 : 340, maxWidth: 340)
                    .foregroundStyle(paleta.texto)
                    .presentationBackground(paleta.papel)
                    .presentationCompactAdaptation(.popover)
                }
            }
        }
    }

    private var tarjetaScramble: some View {
        Group {
            switch vm.estadoScramble {
            case .listo:
                textoScramble
            case .preparando:
                ProgressView("Preparando mezcla…").font(.subheadline)
            case .error:
                VStack(spacing: 8) {
                    Text("No se pudo generar el scramble.").font(.subheadline)
                    Button("Reintentar", action: vm.reintentarScramble)
                        .buttonStyle(BotonRetro(relleno: paleta.amarillo))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .cajaRetro()
    }

    private var textoScramble: some View {
        Text(vm.scrambleActual)
            .font(fuenteScramble.font(tamano: tamanoScramble.tamanoFuenteAjustado(para: vm.sesionActual.categoria), pesoPredeterminado: .bold))
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .textSelection(.enabled)
            .accessibilityIdentifier("retro-scramble")
    }

    private var instrumento: some View {
        SuperficieCronometro(
            vm: vm,
            mantenerParaIniciar: mantener,
            tiempoEspera: AjustesInicioCronometro.esperaValida(espera),
            abrirPenalizacion: vm.puedePenalizarUltimoTiempo ? { mostrarPenalizacion = true } : nil
        ) { valor, listo in
            Text(valor)
                .font(fuenteTimer == .predeterminado
                      ? .system(size: AjustesInicioCronometro.tamanoTimerValido(tamanoTimer), weight: .black, design: .monospaced)
                      : fuenteTimer.font(tamano: AjustesInicioCronometro.tamanoTimerValido(tamanoTimer), pesoPredeterminado: .black))
                .foregroundStyle(listo ? colorListo.color : paleta.texto)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.42)
                .padding(.horizontal, 10)
                .offset(y: -8)
                .accessibilityIdentifier("timer-digitos")
        }
        .frame(minHeight: tipoDinamico.isAccessibilitySize ? 240 : 152, maxHeight: .infinity)
        .cajaRetro(radio: 19)
        .layoutPriority(1)
    }

    private var recientes: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: tipoDinamico.isAccessibilitySize ? 2 : 5), spacing: 5) {
            ForEach(Array(tiempos.suffix(5).reversed())) { tiempo in
                let muestraMinutos = (tiempo.segundosValidos ?? 0) >= 60
                Text(tiempo.texto(largo: false))
                    .font(.system(muestraMinutos ? .footnote : .subheadline, design: .monospaced, weight: muestraMinutos ? .bold : .heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, minHeight: alturaTiempoReciente)
                    .padding(.vertical, 7)
                    .padding(.horizontal, muestraMinutos ? 6 : 3)
                    .foregroundStyle(tiempo.penalizacion == .ninguna ? paleta.texto : paleta.tinta)
                    .cajaRetro(tiempo.penalizacion == .dnf ? paleta.coral : tiempo.penalizacion == .masDos ? paleta.amarillo : nil, relieve: false, radio: 8)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityLabel("Últimos tiempos")
        .accessibilityIdentifier("retro-ultimos-tiempos")
    }

    private var resumen: some View {
        let metricas = [
            ("Solves", "\(tiempos.count)"),
            ("Media", EstiloVisual.promedio(mediaTotal(tiempos: tiempos))),
            ("Mejor", mejorTiempo(tiempos: tiempos)?.texto(largo: false) ?? "—"),
            ("Peor", peorTiempo(tiempos: tiempos)?.texto(largo: false) ?? "—")
        ]
        let promedios = [
            ("Mo3", EstiloVisual.promedio(mo3(tiempos: tiempos))),
            ("Ao5", EstiloVisual.promedio(avg(tiempos: tiempos, cantidad: 5))),
            ("Ao12", EstiloVisual.promedio(avg(tiempos: tiempos, cantidad: 12))),
            ("Ao50", EstiloVisual.promedio(avg(tiempos: tiempos, cantidad: 50)))
        ]

        return Button {
            expandido.toggle()
        } label: {
            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text("RESUMEN").font(.system(.caption2, design: .monospaced, weight: .heavy))
                    Spacer()
                    Image(systemName: expandido ? "minus" : "plus").font(.caption.weight(.heavy))
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: tipoDinamico.isAccessibilitySize ? 2 : 4), spacing: 7) {
                    ForEach(expandido ? metricas + promedios : metricas, id: \.0) { dato in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(dato.0).font(.caption2.weight(.semibold))
                            Text(dato.1).font(.system(.headline, design: .monospaced, weight: .black))
                                .lineLimit(1).minimumScaleFactor(0.6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityElement(children: .combine)
                    }
                }
            }
            .padding(11)
            .foregroundStyle(paleta.tinta)
            .cajaRetro(paleta.menta)
        }
        .buttonStyle(.plain)
        .accessibilityHint(expandido ? "Oculta los promedios" : "Muestra los promedios")
    }
}
