import SwiftUI

struct IngredientListEntry: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?
	@ObservedObject var observedIngredients: ObservableIngredients
	let hasCocktail: Bool

	@Environment(\.presentationMode) private var presentationMode
	@State private var showInfo = false

	var body: some View {
		HStack {
			if observedIngredients.selected != nil {
				Button(action: {
					if self.observedIngredients.selected!.contains(self.data.id) {
						self.observedIngredients.selected!.remove(self.data.id)
					} else {
						self.observedIngredients.selected!.insert(self.data.id)
					}
				}) {
					IngredientButtonOwnedContent(data: data, selected: observedIngredients.selected!.contains(self.data.id), hasCocktail: hasCocktail, withContent: true)
				}
					.buttonStyle(BorderlessButtonStyle())
			} else {
				IngredientButtonOwned(data: data, entry: $entry, hasCocktail: self.hasCocktail, withContent: true)
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
				IngredientDetail(data: self.data, entry: self.$entry, isModal: true)
					.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
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
					IngredientListEntry(data: data, entry: .constant(nil), observedIngredients: ObservableIngredients.inactive, hasCocktail: true)
						.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
				}
					.navigationBarTitle("My Bar")
			}
			NavigationView {
				List {
					IngredientListEntry(data: data, entry: .constant(nil), observedIngredients: ObservableIngredients.active, hasCocktail: true)
						.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
				}
					.navigationBarTitle("Build")
			}
		}
	}
}
