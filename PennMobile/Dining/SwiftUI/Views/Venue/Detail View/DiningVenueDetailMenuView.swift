//
//  DiningVenueDetailMenuView.swift
//  PennMobile
//
//  Created by CHOI Jongmin on 23/6/2020.
//  Copyright © 2020 PennLabs. All rights reserved.
//

import SwiftUI

struct DiningVenueDetailMenuView: View {
    var menus: [DiningMenu]

    var body: some View {
        ForEach(menus, id: \.self) { menu in
            DiningMenuRow(for: menu)
                .transition(.opacity)
        }
    }
}

struct DiningVenueDetailMenuView_Previews: PreviewProvider {
    let diningVenues: DiningMenuAPIResponse = Bundle.main.decode("mock_menu.json")

    static var previews: some View {
        return NavigationView {
            ScrollView {
                VStack {
                    DiningVenueDetailMenuView(menus: [])
                    Spacer()
                }
            }.navigationTitle("Dining")
            .padding()
        }
    }
}
