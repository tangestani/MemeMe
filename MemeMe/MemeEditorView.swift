//
//  MemeEditorView.swift
//  MemeMe
//
//  Created by Mohammed Tangestani on 5/20/20.
//  Copyright © 2020 Mohammed Tangestani. All rights reserved.
//

import SwiftUI

struct MemeEditorView: View {
    var body: some View {
        NavigationView {
            Text("Something something")
        }
        .navigationBarItems(
            leading: Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .imageScale(.large)
            },
            trailing: Button(action: {}) {
                Text("Cancel")
            }
        )
    }
}

struct MemeEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MemeEditorView()
        }
    }
}
