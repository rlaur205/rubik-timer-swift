import SwiftUI

struct RetroTiempos: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.retro) private var paleta
    @AppStorage(VistaHistorialTiempo.claveCuadricula) private var mostrarCuadricula = false
    @State private var seleccionado: Tiempo?
    @State private var mostrarOrden = false
    @State private var confirmarBorrado = false

    var body: some View {
        PantallaRetro {
            EncabezadoRetro(titulo: "Tiempos", contador: vm.tiemposRecorrer.count) {
                HStack(spacing: 6) {
                    IconoBotonRetro(
                        titulo: VistaHistorialTiempo.accion(muestraCuadricula: mostrarCuadricula),
                        icono: VistaHistorialTiempo.icono(muestraCuadricula: mostrarCuadricula),
                        relleno: paleta.amarillo
                    ) { mostrarCuadricula.toggle() }
                    IconoBotonRetro(titulo: "Ordenar tiempos", icono: "arrow.up.arrow.down", relleno: paleta.lavanda) { mostrarOrden = true }
                    IconoBotonRetro(titulo: "Eliminar tiempos", icono: "trash", relleno: paleta.coral) { confirmarBorrado = true }
                        .disabled(vm.tiemposRecorrer.isEmpty)
                }
            }

            if vm.tiemposRecorrer.isEmpty {
                VacioRetro(icono: "stopwatch", titulo: "Aún no hay tiempos", mensaje: "Tus resoluciones aparecerán aquí.")
            } else if mostrarCuadricula {
                CuadriculaTiempos(tiempos: vm.tiemposRecorrer, estiloRetro: true) { seleccionado = $0 }
            } else {
                ForEach(vm.tiemposRecorrer) { tiempo in
                    RetroFilaTiempo(tiempo: tiempo) { seleccionado = tiempo }
                }
            }
        }
        .sheet(item: $seleccionado) { tiempo in
            RetroDetalleTiempo(vm: vm, original: tiempo)
        }
        .sheet(isPresented: $mostrarOrden) {
            PanelRetro(titulo: "Ordenar tiempos") {
                ForEach(Orden.allCases, id: \.self) { orden in
                    Button {
                        vm.cambiarOrden(orden)
                        mostrarOrden = false
                    } label: {
                        HStack {
                            Text(orden.rawValue)
                            Spacer()
                            if orden == vm.ordenActual { Image(systemName: "checkmark") }
                        }
                    }
                    .buttonStyle(BotonRetro(relleno: orden == vm.ordenActual ? paleta.lima : nil))
                    .accessibilityAddTraits(orden == vm.ordenActual ? .isSelected : [])
                }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $confirmarBorrado) {
            ConfirmacionRetro(
                titulo: "Eliminar tiempos",
                mensaje: "Se eliminarán todos los tiempos de \(vm.sesionActual.nombre).",
                accionTitulo: "Eliminar", accion: vm.eliminarTodosTiempos
            )
        }
    }
}

struct RetroFilaTiempo: View {
    let tiempo: Tiempo
    let abrirDetalle: () -> Void
    @Environment(\.retro) private var paleta

    var body: some View {
        Button(action: abrirDetalle) {
            tarjeta
        }
        .buttonStyle(.plain)
        .accessibilityHint("Abre los detalles del tiempo")
    }

    private var tarjeta: some View {
        let colorTiempo = switch tiempo.penalizacion {
        case .ninguna: paleta.naranja
        case .masDos: paleta.amarillo
        case .dnf: paleta.coral
        }

        return VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(tiempo.texto(largo: true))
                    .font(.system(.title2, design: .monospaced, weight: .black))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundStyle(paleta.tinta)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .cajaRetro(colorTiempo, relieve: false, radio: 8)
                    .layoutPriority(1)
                Spacer(minLength: 0)
                Text(formatoFecha(tiempo.fecha))
                    .font(.system(.caption, design: .monospaced, weight: .medium))
                    .foregroundStyle(paleta.secundario)
                    .multilineTextAlignment(.trailing)
                Image(systemName: "arrow.up.right").font(.caption.weight(.bold)).accessibilityHidden(true)
            }
            Text(tiempo.scramble)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(paleta.secundario)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(11)
        .cajaRetro()
        .contentShape(Rectangle())
    }
}

struct RetroDetalleTiempo: View {
    @ObservedObject var vm: RubikViewModel
    @Environment(\.retro) private var paleta
    @Environment(\.dismiss) private var cerrar
    @State private var alturaContenido: CGFloat = 0
    @ScaledMetric(relativeTo: .footnote) private var tamanoScramble = 15.6
    let original: Tiempo
    var soloLectura = false

    private var tiempo: Tiempo {
        vm.sesionActual.tiempos.first { $0.id == original.id } ?? original
    }

    var body: some View {
        PanelRetro(titulo: nil, alturaContenido: $alturaContenido) {
            encabezado

            if !tiempo.scramble.isEmpty {
                SeccionRetro(titulo: "SCRAMBLE", color: paleta.lavanda) {
                    Text(tiempo.scramble)
                        .font(.system(size: tamanoScramble, design: .monospaced))
                        .fixedSize(horizontal: false, vertical: true)
                        .textSelection(.enabled)
                    ImagenScrambleView(scramble: tiempo.scramble, categoria: tiempo.categoria ?? vm.sesionActual.categoria)
                        .frame(height: 185)
                }
            }

            if !soloLectura {
                accionesTiempo
            }
        }
        .presentationDetents([alturaContenido > 0 ? .height(alturaContenido + 12) : .medium])
        .presentationDragIndicator(.visible)
        .accessibilityAction(.escape) { cerrar() }
    }

    private var accionesTiempo: some View {
        let anchoPapelera: CGFloat = 56
        let separacion: CGFloat = 10

        return VStack(alignment: .leading, spacing: 11) {
            SelloRetro(texto: "PENALIZACIÓN", color: paleta.menta)
                .accessibilityAddTraits(.isHeader)
            PenalizacionesRetro(seleccion: tiempo.penalizacion) {
                vm.establecerPenalizacion($0, tiempoID: original.id)
            }
            .disabled(tiempo.esDNFDeInspeccion)
            .padding(13)
            .cajaRetro()
            .padding(.trailing, anchoPapelera + separacion)
            .overlay(alignment: .trailing) {
                Button(role: .destructive) {
                    vm.eliminarTiempoSeleccionado(tiempo: original)
                    cerrar()
                } label: {
                    Image(systemName: "trash")
                        .scaleEffect(1.5)
                        .frame(width: anchoPapelera - 24)
                        .frame(maxHeight: .infinity)
                }
                .buttonStyle(BotonRetro(relleno: paleta.coral))
                .accessibilityLabel("Eliminar tiempo")
            }
        }
    }

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(tiempo.texto(largo: true))
                .font(.system(.largeTitle, design: .monospaced, weight: .black))
                .lineLimit(1).minimumScaleFactor(0.55)
            Text(formatoFecha(tiempo.fecha)).font(.system(.caption, design: .monospaced))
        }
        .foregroundStyle(paleta.tinta)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .cajaRetro(paleta.amarillo)
    }
}

struct PenalizacionesRetro: View {
    @Environment(\.retro) private var paleta
    let seleccion: PenalizacionTiempo
    let aplicar: (PenalizacionTiempo) -> Void

    var body: some View {
        HStack(spacing: 7) {
            ForEach(PenalizacionTiempo.allCases) { opcion in
                Button {
                    aplicar(opcion)
                } label: {
                    Group {
                        if opcion == .ninguna {
                            Image(systemName: "checkmark")
                        } else {
                            Text(opcion.titulo)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BotonRetro(relleno: seleccion == opcion ? paleta.lima : nil))
                .accessibilityLabel(opcion.titulo)
                .accessibilityAddTraits(seleccion == opcion ? .isSelected : [])
            }
        }
    }
}
