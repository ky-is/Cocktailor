import SwiftUI

struct IngredientListEntry: View {
	let data: IngredientData
	let entry: IngredientEntry?
	let observedIngredients: ObservableIngredients
	let hasCocktail: Bool

	@Environment(\.presentationMode) private var presentationMode
	@State private var showInfo = false

	var body: some View {
		HStack {
			IngredientButton(data: data, entry: entry, observedIngredients: observedIngredients, hasCocktail: hasCocktail)
			Spacer()
			Button(action: {
				self.showInfo.toggle()
			}) {
				Image(systemName: "info.circle")
					.foregroundColor(.tertiary)
					.frame(width: 28)
			}
				.buttonStyle(BorderlessButtonStyle())
			IngredientButtonFavorite(data: data, entry: entry)
				.buttonStyle(BorderlessButtonStyle())
				.frame(width: 28)
		}
			.sheet(isPresented: $showInfo) {
				IngredientDetail(data: self.data, entry: self.entry, isModal: true)
					.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
					.accentColor(.primary)
			}
	}
}

private struct IngredientButton: View {
	let data: IngredientData
	let entry: IngredientEntry?
	let observedIngredients: ObservableIngredients
	let hasCocktail: Bool

	var body: some View {
		Group {
			if observedIngredients.selected != nil {
				IngredientButtonSelected(data: data, observedIngredients: observedIngredients, hasCocktail: hasCocktail)
			} else {
				IngredientButtonOwned(data: data, entry: entry, hasCocktail: hasCocktail, withContent: true)
			}
		}
			.buttonStyle(BorderlessButtonStyle())
	}
}

private struct IngredientButtonSelected: View {
	let data: IngredientData
	@ObservedObject var observedIngredients: ObservableIngredients
	let hasCocktail: Bool

	var body: some View {
		let selected = observedIngredients.selected!.contains(self.data.id)
		return Button(action: {
			if selected {
				self.observedIngredients.selected!.remove(self.data.id)
			} else {
				self.observedIngredients.selected!.insert(self.data.id)
			}
		}) {
			IngredientButtonSelectedContent(data: data, selected: selected, hasCocktail: hasCocktail, withContent: true) //TODO refactor action param
		}
	}
}

struct IngredientListEntry_Previews: PreviewProvider {
	static let data = IngredientData.keyValues["mezcal"]!

	static var previews: some View {
		Group {
			NavigationView {
				List {
					IngredientListEntry(data: data, entry: nil, observedIngredients: ObservableIngredients.inactive, hasCocktail: true)
						.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
				}
					.navigationBarTitle("My Bar")
			}
			NavigationView {
				List {
					IngredientListEntry(data: data, entry: nil, observedIngredients: ObservableIngredients.active, hasCocktail: true)
						.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
				}
					.navigationBarTitle("Build")
			}
		}
	}
}
