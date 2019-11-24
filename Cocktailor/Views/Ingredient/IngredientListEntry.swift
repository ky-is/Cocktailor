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
					ButtonOwnedContent(data: data, selected: observededIngredients.selected!.contains(self.data.id), hasCocktail: hasCocktail)
				}
					.buttonStyle(BorderlessButtonStyle())
			} else {
				ButtonOwned(data: data, entry: $entry) {
					ButtonOwnedContent(data: self.data, selected: self.entry?.owned ?? false, hasCocktail: self.hasCocktail)
				}
					.buttonStyle(BorderlessButtonStyle())
			}
			Button(action: {
				self.showInfo.toggle()
			}) {
				Image(systemName: "info.circle")
					.foregroundColor(.secondary)
					.frame(width: 28)
			}
				.buttonStyle(BorderlessButtonStyle())
			Spacer()
			ButtonFavorite(data: data, entry: $entry)
				.buttonStyle(BorderlessButtonStyle())
				.frame(width: 28)
		}
			.sheet(isPresented: $showInfo) {
				IngredientDetail(data: self.data, entry: self.$entry)
			}
	}
}

struct IngredientListEntry_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			NavigationView {
				List {
					IngredientListEntry(data: IngredientData.keyValues["lemon"]!, entry: .constant(nil), observededIngredients: ObservableIngredients.inactive, hasCocktail: true)
						.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
				}
					.navigationBarTitle("My Bar")
			}
			NavigationView {
				List {
					IngredientListEntry(data: IngredientData.keyValues["lemon"]!, entry: .constant(nil), observededIngredients: ObservableIngredients.active, hasCocktail: true)
						.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
				}
					.navigationBarTitle("Build")
			}
		}
	}
}
