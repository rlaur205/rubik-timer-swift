import SwiftUI
import UIKit

struct CronometroView: View {
    
    @ObservedObject var vm: RubikViewModel
        
    var body: some View {

        VStack(spacing: 10) {
            
            //TITULO DEL CRONOMETRO
            if !vm.timerState.estaCorriendo{
                HStack{
                    
                    Image(systemName: "trash.fill")
                        .padding(8)
                        .background(Color(.red).opacity(0.4))
                        .cornerRadius(10)
                        .font(.system(size: 23))
                        .padding(.leading,-20)
                        .onTapGesture {
                            vm.borrarUltimoTiempo()
                        }
                    
                    Text(" \(vm.sesionActual.nombre) 🍀")
                        .multilineTextAlignment(.center)
                        .bold()
                        .foregroundColor(.primary)
                        .font(.custom("Avenir", size: 34))
                    
                    
                }
                .padding(.horizontal)
                
            }
            
            
            //SCRAMBLE
            if !vm.timerState.estaCorriendo {
                Text(vm.scrambleActual)
                    .font(.system(size: vm.sesionActual.categoria == "4x4" ? 20 :
                                    vm.sesionActual.categoria == "5x5" ? 18 :
                                    vm.sesionActual.categoria == "6x6" ? 13 :
                                    vm.sesionActual.categoria == "7x7" ? 12 :
                                    vm.sesionActual.categoria == "Megaminx" ? 11 :
                                    vm.sesionActual.categoria == "Square 1" ? 20 : 24))
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top,15)

                //DIAGRAMA 2D DEL SCRAMBLE
                if !vm.scrambleActual.isEmpty {
                    ImagenScrambleView(
                        scramble: vm.scrambleActual,
                        categoria: vm.sesionActual.categoria
                    )
                    .frame(height: 120)
                    .padding(.horizontal, 20)
                }
            }
            
            //CRONOMETRO
            TimerAreaView(
                stateTimer: $vm.timerState,
                registrarNuevoTiempo: { vm.registrarNuevoTiempo() },
                formatoTiempo: formatoTiempo)
            
            
            //ESTADISTICAS (EN LA PARTE INFERIOR)
            if !vm.timerState.estaCorriendo{
                EstadisticasCronometroView(vm: vm)
            }
        }
        
        .padding(.top,15)
        .padding(.bottom,5)
        .toolbar(vm.timerState.estaCorriendo ? .hidden : .visible, for: .tabBar)

    }

}

#Preview {
    ContentView()
}
