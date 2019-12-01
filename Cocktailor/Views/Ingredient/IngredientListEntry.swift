import SwiftUI

struct IngredientListEntry: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?
	@ObservedObject var observededIngredients: ObservableIngredients
	let hasCocktail: Bool

	@State private var showInfo = false

	@Environment(\.managedObjectContext) private var managedObjectContext

	var body: some View {
		HStack {
			if observededIngredients.selected != nil {
				Button(action: {
					if self.observededIngredients.selected!.contains(self.data.id) {
						self.observededIngredients.selected!.remove(self.data.id)
					} else {
						self.observededIngredients.selected!.insert(self.data.id)
					}
				}) {
					IngredientButtonOwnedContent(data: data, selected: observededIngredients.selected!.contains(self.data.id), hasCocktail: hasCocktail)
				}
					.buttonStyle(BorderlessButtonStyle())
			} else {
				IngredientButtonOwned(data: data, entry: $entry) {
					IngredientButtonOwnedContent(data: self.data, selected: self.entry?.owned ?? false, hasCocktail: self.hasCocktail)
				}
					.buttonStyle(BorderlessButtonStyle())
			}
			Button(action: {
				self.showInfo.toggle()
			}) {
				Image(systemName: "info.circle")
					.foregroundColor(.tertiary)
					.frame(width: 28)
			}
				.buttonStyle(BorderlessButtonStyle())
			Spacer()
			IngredientButtonFavorite(data: data, entry: $entry)
				.buttonStyle(BorderlessButtonStyle())
				.frame(width: 28)
		}
			.sheet(isPresented: $showInfo) {
				IngredientDetail(data: self.data, entry: self.$entry)
					.accentColor(.primary)
			}
	}
}

struct IngredientListEntry_Previews: PreviewProvider {
	static var previews: some View {
		let data = IngredientData.keyValues["mezcal"]!
		return Group {
			NavigationView {
				List {
					IngredientListEntry(data: data, entry: .constant(nil), observededIngredients: ObservableIngredients.inactive, hasCocktail: true)
						.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
				}
					.navigationBarTitle("My Bar")
			}
			NavigationView {
				List {
					IngredientListEntry(data: data, entry: .constant(nil), observededIngredients: ObservableIngredients.active, hasCocktail: true)
						.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
				}
					.navigationBarTitle("Build")
			}
		}
	}
}
