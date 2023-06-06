//
//  SwiftUIView.swift
//  HackathonFinal
//
//  Created by Ahmed Eslam on 16/05/2023.
//

import SwiftUI

enum Tab: String , CaseIterable{
    case house
    case chart = "chart.bar"

    case person
    
}
struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    private var fillImage : String {
        selectedTab.rawValue + ".fill"
    }
    private var tabColor : Color {
        switch selectedTab {
        case .house:
            return .blue
       
        case .chart:
            return .black
        case .person:
            return .indigo
        }
    }
    var body: some View {
        VStack{
            HStack{
                ForEach(Tab.allCases,id:\.rawValue){tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundColor(selectedTab == tab ? tabColor : .gray)
                        .font(.system(size: 22))
                        .onTapGesture{
                            
                            withAnimation(.easeIn(duration: 0.1)){
                                selectedTab = tab
                            }
                        }
                    Spacer()
                    
                }
                
            }
            .frame(width: 350,height: 70)
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding(.top)
        }
        
        
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(selectedTab: .constant(.house))
    }
}
