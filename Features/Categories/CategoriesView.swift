import SwiftUI

struct CategoriesView: View {
    var body: some View {
        NavigationStack {
            List(ScriptCategory.allCases, id: \.self) { category in
                Text(category.displayName)
            }
            .navigationTitle("Categories")
        }
    }
}
