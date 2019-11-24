import SwiftUI

final class ObservableIngredients: ObservableObject {
	static let active = ObservableIngredients(selected: Set<String>())
	static let inactive = ObservableIngredients(selected: nil)

	@Published var selected: Set<String>?

	init(selected: Set<String>?) {
		self.selected = selected
	}
}

struct Build: View {
	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.favorite, ascending: false), NSSortDescriptor(keyPath: \IngredientEntry.id, ascending: true)]) private var ingredientEntries: FetchedResults<IngredientEntry>
	@ObservedObject private var observedIngredients = ObservableIngredients.active

	var body: some View {
		let availableIngredientEntries = ingredientEntries.filter { $0.owned && IngredientData.keyValues[$0.id] != nil }
		let availableIDs = availableIngredientEntries.map { $0.id }
		var displayCocktails = CocktailData.keyValues.values.filter { cocktail in
			for iq in cocktail.ingredients {
				if !availableIDs.contains(iq.id) {
					return false
				}
			}
			return true
		}
		var possibleIngredients = Set<IngredientData>()
		if let selectedIngredients = observedIngredients.selected {
			displayCocktails = displayCocktails.filter { cocktail in
				var missingIngredients = Set(selectedIngredients)
				cocktail.ingredients.forEach { missingIngredients.remove($0.ingredient.id) }
				if missingIngredients.isEmpty {
					cocktail.ingredients.forEach { possibleIngredients.insert($0.ingredient) }
					return true
				}
				return false
			}
		}
		let hasFilteredCocktail = displayCocktails.count < CocktailData.keyValues.values.count
		return GeometryReader { geometry in
			if geometry.size.width > 1024 {
				BuildDouble(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, displayCocktails: displayCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: hasFilteredCocktail ? possibleIngredients : nil)
			} else if geometry.size.width > 640 {
				BuildDouble(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, displayCocktails: displayCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: hasFilteredCocktail ? possibleIngredients : nil)
					.navigationViewStyle(StackNavigationViewStyle())
			} else {
				BuildSingle(availableIngredientEntries: availableIngredientEntries, observedIngredients: self.observedIngredients, displayCocktails: displayCocktails, hasFilteredCocktail: hasFilteredCocktail, possibleIngredients: hasFilteredCocktail ? possibleIngredients : nil)
			}
		}
	}
}

private struct BuildDouble: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let displayCocktails: [CocktailData]
	let hasFilteredCocktail: Bool
	let possibleIngredients: Set<IngredientData>?

	@Environment(\.horizontalSizeClass) var horizontalSizeClass

	var body: some View {
		HStack(spacing: 0) {
			NavigationView {
				List {
					BuildIngredients(availableIngredientEntries: availableIngredientEntries, observedIngredients: observedIngredients, possibleIngredients: possibleIngredients)
				}
					.navigationBarTitle("Ingredients")
			}
				.frame(width: 321)
			NavigationView {
				List(displayCocktails) { cocktailData in
					NavigationLink(destination: CocktailDetail(data: cocktailData)) {
						Text(cocktailData.name)
					}
						.isDetailLink(true)
				}
					.navigationBarTitle("Cocktails")
				BuildCocktailPlaceholder()
			}
		}
	}
}

private struct BuildSingle: View {
	let availableIngredientEntries: [IngredientEntry]
	@ObservedObject var observedIngredients: ObservableIngredients
	let displayCocktails: [CocktailData]
	let hasFilteredCocktail: Bool
	let possibleIngredients: Set<IngredientData>?

	@State private var showCocktails = false

	var body: some View {
		return ZStack(alignment: .bottom) {
			NavigationView {
				Group {
					if !showCocktails {
						List {
							BuildIngredients(availableIngredientEntries: availableIngredientEntries, observedIngredients: observedIngredients, possibleIngredients: possibleIngredients)
							Text("")
						}
							.navigationBarTitle("Ingredients")
					} else {
						List {
							ForEach(displayCocktails) { cocktailData in
								NavigationLink(destination: CocktailDetail(data: cocktailData)) {
									Text(cocktailData.name)
								}
									.isDetailLink(true)
							}
							Text("")
						}
							.navigationBarTitle("Cocktails")
						BuildCocktailPlaceholder()
					}
				}
					.transition(.slide)
			}
			Picker("", selection: $showCocktails.animation()) {
				Text(observedIngredients.selected!.count > 0 ? "Ingredient".pluralize(observedIngredients.selected!.count) : "Any Ingredients")
					.tag(false)
				Text(hasFilteredCocktail ? "Cocktail".pluralize(displayCocktails.count) : "All Cocktails")
					.tag(true)
			}
				.padding(.horizontal)
				.frame(height: 48)
				.background(BlurView(style: .systemChromeMaterial))
				.labelsHidden()
				.pickerStyle(SegmentedPickerStyle())
		}
	}
}

private struct BuildCocktailPlaceholder: View {
	var body: some View {
		Text("Toggle ingredients or select a cocktail")
			.foregroundColor(.secondary)
	}
}

private struct BuildIngredients: View {
	let availableIngredientEntries: [IngredientEntry]
	let observedIngredients: ObservableIngredients
	let possibleIngredients: Set<IngredientData>?

	var body: some View {
		ForEach(availableIngredientEntries) { entry in
			IngredientListEntry(data: IngredientData.keyValues[entry.id]!, entry: .constant(entry), observededIngredients: self.observedIngredients, hasCocktail: self.possibleIngredients?.contains(IngredientData.keyValues[entry.id]!) ?? true) //TODO filter []! != nil
		}
	}
}

struct Build_Previews: PreviewProvider {
	static var previews: some View {
		Build()
			.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
	}
}
