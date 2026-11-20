import SwiftUI

struct RetroAjustes: View {
    @Bindable var estado: AjustesEstado
    @Environment(\.retro) private var paleta
    @AppStorage("temaApp") private var temaElegido: TemaApp = .claro
    @AppStorage("temaDelSistema") private var temaDelSistema = true
    @AppStorage(AparienciaRetro.claveActivada) private var retroActivo = false
    @AppStorage(AparienciaRetro.claveOscura) private var retroOscuro = false
    @AppStorage(AjustesInicioCronometro.claveInspeccion) private var inspeccionActivada = AjustesInicioCronometro.inspeccionPredeterminada
    @AppStorage(AjustesInicioCronometro.claveOcultarTiempo) private var ocultarTiempo = AjustesInicioCronometro.ocultarTiempoPredeterminado
    @AppStorage(AjustesInicioCronometro.claveMantenerParaIniciar) private var mantener = AjustesInicioCronometro.mantenerPredeterminado
    @AppStorage(AjustesInicioCronometro.claveTiempoEspera) private var espera = AjustesInicioCronometro.esperaPredeterminada
    @AppStorage(AjustesInicioCronometro.claveColorListo) private var colorListo = AjustesInicioCronometro.colorPredeterminado
    @AppStorage(AjustesInicioCronometro.claveTamanoScramble) private var tamanoScramble = AjustesInicioCronometro.tamanoScramblePredeterminado
    @AppStorage(AjustesInicioCronometro.claveMostrarScramble) private var mostrarScramble = AjustesInicioCronometro.mostrarScramblePredeterminado
    @AppStorage(AjustesInicioCronometro.claveTamanoTimer) private var tamanoTimer = AjustesInicioCronometro.tamanoTimerPredeterminado
    @AppStorage(AjustesInicioCronometro.claveFuenteTimer) private var fuenteTimer = AjustesInicioCronometro.fuenteTimerPredeterminada
    @AppStorage(AjustesInicioCronometro.claveFuenteScramble) private var fuenteScramble = AjustesInicioCronometro.fuenteScramblePredeterminada
    @State private var panel: Panel?
    @State private var restablecer = false

    var body: some View {
        PantallaRetro {
            EncabezadoRetro(titulo: "Ajustes") { EmptyView() }
            apariencia
            texto
            temporizador
            datos
            acerca
        }
        .sheet(item: $panel, content: contenidoPanel)
        .sheet(isPresented: $restablecer) {
            ConfirmacionRetro(
                titulo: "Restablecer ajustes",
                mensaje: "Se restaurarán las preferencias de texto y temporizador. Tus tiempos y sesiones se conservan.",
                accionTitulo: "Restablecer",
                accion: restaurarValores
            )
        }
    }

    private var apariencia: some View {
        SeccionRetro(titulo: "APARIENCIA", color: paleta.lima) {
            botonFila("Idioma", detalle: estado.idioma.nombre) { panel = .idioma }
            Toggle("Tema del sistema", isOn: $temaDelSistema)
                .accessibilityIdentifier("tema-del-sistema")
            SelectorDiseno(
                retroActivo: $retroActivo,
                esquemaClasico: temaDelSistema ? (paleta.oscura ? .dark : .light) : temaElegido.colorScheme,
                esquemaRetro: paleta.oscura ? .dark : .light,
                texto: paleta.texto,
                linea: paleta.linea,
                seleccion: paleta.oscura ? paleta.lima : paleta.tinta
            )
            Button {} label: {
                HStack {
                    Text("Tema de la app").font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: "lock").accessibilityHidden(true)
                }
                .frame(minHeight: 44)
                .foregroundStyle(paleta.secundario)
            }
            .buttonStyle(.plain)
            .disabled(true)
            .opacity(0.75)
            .accessibilityValue("Desactivado con Retro")
            .accessibilityIdentifier("abrir-selector-tema")

            if !temaDelSistema {
                opciones("Apariencia Retro", valores: [false, true], seleccion: $retroOscuro) {
                    $0 ? "Oscuro" : "Claro"
                }
            }
        }
        .toggleStyle(InterruptorRetro())
    }

    private var texto: some View {
        SeccionRetro(titulo: "TEXTO", color: paleta.lavanda) {
            Toggle("Mostrar scramble", isOn: $mostrarScramble)
                .toggleStyle(InterruptorRetro())
            botonFila("Fuente del scramble", detalle: fuenteScramble.nombre) { panel = .fuenteScramble }
            opciones("Tamaño del scramble", valores: TamanoScramble.allCases, seleccion: $tamanoScramble) { $0.nombre }
            Text("R U2 F’ D L2 B R’ U")
                .font(fuenteScramble.font(tamano: tamanoScramble.tamanoFuente, pesoPredeterminado: .bold))
                .frame(maxWidth: .infinity)
                .padding(9)
                .cajaRetro(relieve: false)
                .accessibilityLabel("Vista previa del scramble")
        }
    }

    private var temporizador: some View {
        SeccionRetro(titulo: "TEMPORIZADOR", color: paleta.amarillo) {
            controlNumerico("Tamaño del timer", valor: Binding(
                get: { AjustesInicioCronometro.tamanoTimerValido(tamanoTimer) },
                set: { tamanoTimer = $0 }
            ), rango: AjustesInicioCronometro.rangoTamanoTimer, paso: 1, texto: "\(Int(tamanoTimer)) pt")
            botonFila("Fuente del timer", detalle: fuenteTimer.nombre) { panel = .fuenteTimer }
            Text(AjustesInicioCronometro.ejemploTemporizador)
                .font(fuenteTimer == .predeterminado
                      ? .system(size: AjustesInicioCronometro.tamanoTimerValido(tamanoTimer), weight: .black, design: .monospaced)
                      : fuenteTimer.font(tamano: AjustesInicioCronometro.tamanoTimerValido(tamanoTimer), pesoPredeterminado: .black))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(8)
                .cajaRetro(relieve: false)
                .accessibilityLabel("Vista previa del temporizador")
            Toggle("Inspección de 15 s", isOn: $inspeccionActivada)
            Toggle("Ocultar tiempo en curso", isOn: $ocultarTiempo)
            Toggle("Mantener para iniciar", isOn: $mantener)
                .disabled(inspeccionActivada)
                .opacity(inspeccionActivada ? 0.45 : 1)
            controlNumerico("Tiempo de espera", valor: Binding(
                get: { AjustesInicioCronometro.esperaValida(espera) },
                set: { espera = $0 }
            ), rango: AjustesInicioCronometro.rangoEspera, paso: 0.1, texto: espera.formatted(.number.precision(.fractionLength(1))) + " s")
                .disabled(!inspeccionActivada && !mantener)
                .opacity(inspeccionActivada || mantener ? 1 : 0.5)
            coloresListo
        }
        .toggleStyle(InterruptorRetro())
    }

    private var coloresListo: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Color al estar listo").font(.subheadline.weight(.semibold))
            HStack(spacing: 5) {
                ForEach(ColorListoAjuste.allCases) { opcion in
                    Button {
                        colorListo = opcion
                    } label: {
                        Circle()
                            .fill(opcion.color)
                            .overlay {
                                if colorListo == opcion {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.heavy))
                                        .foregroundStyle(.white)
                                        .shadow(color: .black, radius: 1)
                                }
                            }
                            .frame(width: 22, height: 22)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .buttonStyle(BotonRetro(relleno: colorListo == opcion ? paleta.lima : nil))
                    .accessibilityLabel(opcion.nombre)
                    .accessibilityAddTraits(colorListo == opcion ? .isSelected : [])
                }
            }
        }
    }

    private var datos: some View {
        SeccionRetro(titulo: "DATOS", color: paleta.menta) {
            Toggle("Sincronizar con iCloud", isOn: Binding(
                get: { estado.sincronizarICloud },
                set: {
                    estado.sincronizarICloud = $0
                    if $0 { panel = .icloud }
                }
            ))
            .toggleStyle(InterruptorRetro())
            botonFila("Exportar tiempos", detalle: "JSON") { panel = .exportar }
            botonFila("Importar tiempos") { panel = .importar }
        }
    }

    private var acerca: some View {
        SeccionRetro(titulo: "ACERCA DE", color: paleta.coral) {
            HStack {
                Text("Versión")
                Spacer()
                Text(AjustesInformacionApp.version).monospacedDigit()
            }
            .font(.subheadline.weight(.semibold))
            botonFila("Licencias de terceros") { panel = .licencias }
            botonFila("Restablecer ajustes") { restablecer = true }
        }
    }

    @ViewBuilder
    private func contenidoPanel(_ panel: Panel) -> some View {
        switch panel {
        case .idioma:
            PanelRetro(titulo: "Idioma") {
                ForEach(IdiomaAjuste.allCases) { idioma in
                    botonFila(idioma.nombre, detalle: estado.idioma == idioma ? "✓" : nil) {
                        estado.idioma = idioma
                        self.panel = nil
                    }
                }
                Text("Esta preferencia se aplica a la vista de ajustes.")
                    .font(.footnote)
            }
        case .fuenteTimer:
            selectorFuente("Fuente del timer", ejemplo: AjustesInicioCronometro.ejemploTemporizador, seleccion: $fuenteTimer)
        case .fuenteScramble:
            selectorFuente("Fuente del scramble", ejemplo: "R U2 F’", seleccion: $fuenteScramble)
        case .licencias:
            PanelRetro(titulo: "Licencias de terceros") {
                Text("El listado de licencias estará disponible en una próxima versión.")
            }
            .presentationDetents([.medium, .large])
        case .icloud, .exportar, .importar:
            PanelRetro(titulo: panel.titulo) {
                Text("Función disponible próximamente.")
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func selectorFuente<Fuente: FuenteAjuste>(_ titulo: String, ejemplo: String, seleccion: Binding<Fuente>) -> some View {
        PanelRetro(titulo: titulo) {
            ForEach(Fuente.allCases) { opcion in
                Button {
                    seleccion.wrappedValue = opcion
                    panel = nil
                } label: {
                    HStack(spacing: 8) {
                        Text(opcion.nombre).font(opcion.fontLista(tamano: 16))
                        Spacer(minLength: 4)
                        Text(ejemplo).font(opcion.fontLista(tamano: 15)).lineLimit(1)
                    }
                }
                .buttonStyle(BotonRetro(relleno: seleccion.wrappedValue == opcion ? paleta.lima : nil))
                .accessibilityAddTraits(seleccion.wrappedValue == opcion ? .isSelected : [])
            }
        }
    }

    private func opciones<Valor: Hashable>(_ titulo: String, valores: [Valor], seleccion: Binding<Valor>, etiqueta: @escaping (Valor) -> String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo).font(.subheadline.weight(.semibold))
            HStack(spacing: 6) {
                ForEach(valores, id: \.self) { valor in
                    Button {
                        seleccion.wrappedValue = valor
                    } label: {
                        Text(etiqueta(valor))
                            .font(.system(.caption, design: .monospaced, weight: .bold))
                            .minimumScaleFactor(0.65)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BotonRetro(relleno: seleccion.wrappedValue == valor ? paleta.lima : nil))
                    .accessibilityAddTraits(seleccion.wrappedValue == valor ? .isSelected : [])
                }
            }
        }
    }

    private func controlNumerico(_ titulo: String, valor: Binding<Double>, rango: ClosedRange<Double>, paso: Double, texto: String) -> some View {
        VStack(spacing: 3) {
            HStack {
                Text(titulo).font(.subheadline.weight(.semibold))
                Spacer()
                Text(texto).font(.system(.caption, design: .monospaced, weight: .bold))
            }
            Slider(value: valor, in: rango, step: paso)
                .accessibilityLabel(titulo)
                .accessibilityValue(texto)
        }
    }

    private func botonFila(_ titulo: String, detalle: String? = nil, accion: @escaping () -> Void) -> some View {
        Button(action: accion) {
            HStack {
                Text(titulo)
                Spacer(minLength: 8)
                if let detalle { Text(detalle).foregroundStyle(paleta.secundario) }
                Image(systemName: "arrow.up.right").font(.caption.weight(.heavy))
            }
        }
        .buttonStyle(BotonRetro())
    }

    private func restaurarValores() {
        estado.restablecer()
        inspeccionActivada = AjustesInicioCronometro.inspeccionPredeterminada
        ocultarTiempo = AjustesInicioCronometro.ocultarTiempoPredeterminado
        mantener = AjustesInicioCronometro.mantenerPredeterminado
        espera = AjustesInicioCronometro.esperaPredeterminada
        colorListo = AjustesInicioCronometro.colorPredeterminado
        tamanoScramble = AjustesInicioCronometro.tamanoScramblePredeterminado
        mostrarScramble = AjustesInicioCronometro.mostrarScramblePredeterminado
        tamanoTimer = AjustesInicioCronometro.tamanoTimerPredeterminado
        fuenteTimer = AjustesInicioCronometro.fuenteTimerPredeterminada
        fuenteScramble = AjustesInicioCronometro.fuenteScramblePredeterminada
    }

    private enum Panel: String, Identifiable {
        case idioma, fuenteTimer, fuenteScramble, icloud, exportar, importar, licencias

        var id: Self { self }

        var titulo: String {
            switch self {
            case .icloud: "Sincronizar con iCloud"
            case .exportar: "Exportar tiempos"
            case .importar: "Importar tiempos"
            default: rawValue
            }
        }
    }
}

private struct InterruptorRetro: ToggleStyle {
    @Environment(\.retro) private var paleta

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 10) {
                configuration.label
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(paleta.texto)
                Spacer(minLength: 6)
                HStack(spacing: 0) {
                    if configuration.isOn { Spacer(minLength: 0) }
                    RoundedRectangle(cornerRadius: 6)
                        .fill(configuration.isOn ? paleta.tinta : paleta.texto)
                        .frame(width: 17, height: 16)
                    if !configuration.isOn { Spacer(minLength: 0) }
                }
                .padding(4)
                .frame(width: 48, height: 25)
                .cajaRetro(configuration.isOn ? paleta.lima : nil, relieve: false, radio: 12)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
                .toggleStyle(.switch)
        }
    }
}
