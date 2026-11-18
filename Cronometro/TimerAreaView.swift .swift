import SwiftUI

struct TimerAreaView: View {
    
    @Binding var stateTimer:TimerState
    @Environment(\.temaApp) private var temaApp
    
    let registrarNuevoTiempo: () -> Void
    let formatoTiempo: (TimeInterval) -> String
    
    var body: some View {
        
        ZStack{
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .frame(maxHeight: .infinity)
                .onAppear {
                    // Evitar que la pantalla se apague mientras la aplicación está en primer plano
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    // Reactivar el apagado automático de la pantalla
                    UIApplication.shared.isIdleTimerDisabled = false
                }
            VStack {
                
                TimelineView(.animation) { context in
                    
                    let tiempoParaMostrar = stateTimer.estaCorriendo ? Date().timeIntervalSince(stateTimer.tiempoInicio ?? Date()) : stateTimer.tiempoTranscurrido
                    
                    Text("\(formatoTiempo(tiempoParaMostrar).dropLast())")
                        .font(.system(size: stateTimer.estaCorriendo ? 104 : 96, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.45)
                        .padding(.horizontal, 24)
                        .foregroundStyle(stateTimer.estaTocando ? EstiloVisual.preparado : temaApp.texto)
                    
                }
            }
            
        }
        .contentShape(Rectangle())
        .gesture(
            LongPressGesture(minimumDuration: 0.5)
                .sequenced(before: DragGesture(minimumDistance: 0))
                .onChanged { value in
                    switch value {
                    case .first(true):
                        // Dedo presionado suficiente tiempo -> muestra el color de preparación
                        if !stateTimer.estaCorriendo {
                            stateTimer.estaTocando = true
                        }
                    default:
                        break
                    }
                }
                .onEnded { value in
                    // Inicia cronómetro cuando se suelta el dedo después del long press
                    if case .second(true, _) = value, !stateTimer.estaCorriendo {
                        stateTimer.estaCorriendo = true
                        stateTimer.tiempoInicio = Date()
                        stateTimer.tiempoTranscurrido = 0
                        stateTimer.visibilidadPromedios = false
                    }
                    stateTimer.estaTocando = false
                }
        )
        .simultaneousGesture(
            TapGesture()
                .onEnded {
                    if stateTimer.estaCorriendo {
                        stateTimer.estaCorriendo = false
                        registrarNuevoTiempo()
                        stateTimer.visibilidadPromedios = true
                    }
                }
        )
        
        
        
        
        
    }
}

#Preview {
    ContentView()
}
