import SwiftUI

struct CocktailDetail: View {
	let data: CocktailData

	@FetchRequest(entity: IngredientEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \IngredientEntry.favorite, ascending: false)], predicate: NSPredicate(format: "owned == TRUE")) private var ownedIngredientEntries: FetchedResults<IngredientEntry>
	@FetchRequest private var cocktailEntries: FetchedResults<CocktailEntry>

	init(data: CocktailData) {
		self.data = data
		self._cocktailEntries = FetchRequest(entity: CocktailEntry.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \CocktailEntry.id, ascending: false)], predicate: NSPredicate(format: "id == %@", data.id))
	}

	var body: some View {
		let ownedIngredientIDs = ownedIngredientEntries.map { $0.id }
		return CocktailDetailContent(data: data, ownedIngredientIDs: ownedIngredientIDs, cocktailEntry: .constant(cocktailEntries.first))
	}
}

struct CocktailDetailContent: View {
	let data: CocktailData
	let ownedIngredientIDs: [String]
	@Binding var cocktailEntry: CocktailEntry?

	@Environment(\.managedObjectContext) private var managedObjectContext
	@State private var selectedIngredient: IngredientData?
	@State private var scrollOffset: CGFloat = 0
	@State private var newNote = ""

	var body: some View {
		return GeometryReader { geometry in
			VStack {
				ScrollView {
					VStack {
						HStack {
							ForEach(self.data.nicknames, id: \.self) {
								Text($0)
							}
						}
						CocktailImage(data: self.data, size: geometry.size.width / 2)
						Text("Alcohol: \(NumberFormatter.localizedString(from: NSNumber(value: self.data.alcohol), number: .percent))")
						if self.data.region != nil {
							Text("Region: \(self.data.region!)")
						}
						VStack {
							VStack {
								ForEach(self.data.ingredients) { ingredientQuantity in
									CocktailDetailRow(selectedIngredient: self.$selectedIngredient, data: ingredientQuantity, ownedIngredientIDs: self.ownedIngredientIDs)
								}
							}
								.padding(.vertical)
							MultilineTextView(placeholder: "Save a note", text: self.$newNote) { text in
								DataModel.perform {
									let cocktailEntry = self.cocktailEntry ?? CocktailEntry(id: self.data.id)
									cocktailEntry.note = text
								}
							}
								.frame(minWidth: 256, minHeight: 80)
								.background(Color.secondarySystemBackground)
								.onAppear {
									if let note = self.cocktailEntry?.note {
										self.newNote = note
									}
								}
						}
							.frame(maxWidth: 360)
					}
						.offset(y: -self.scrollOffset)
						.padding(.horizontal)
				}
					.modifier(SoftwareKeyboardModifier(offset: self.$scrollOffset.animation()))
			}
		}
			.navigationBarTitle(data.name)
			.navigationBarItems(trailing:
				CocktailButtonFavorite(data: self.data, entry: .constant(cocktailEntry))
			)
			.sheet(item: $selectedIngredient) { selectedIngredient in
				IngredientEntryDetail(data: selectedIngredient)
					.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
					.accentColor(.primary)
			}
	}
}

private struct CocktailDetailRow: View {
	@Binding var selectedIngredient: IngredientData?
	let data: IngredientQuantity
	let ownedIngredientIDs: [String]

	var body: some View {
		let isOwned = data.ingredient.usableIn(available: ownedIngredientIDs) != nil
		let substitute = isOwned ? nil : data.ingredient.findSubstitute(available: ownedIngredientIDs)
		return Button(action: {
			self.selectedIngredient = substitute ?? self.data.ingredient
		}) {
			return HStack(spacing: 0) {
				IngredientListItem(data: data.ingredient, available: isOwned, substitute: substitute)
				Spacer()
				Text(data.quantity.value.description)
					.foregroundColor(.primary)
				+
				Text(" \(data.quantity.unit.rawValue) ")
					.foregroundColor(.secondary)
			}
		}
	}
}

struct CocktailDetail_Previews: PreviewProvider {
	static var previews: some View {
		let data = CocktailData.keyValues["bramble"]!
		return NavigationView {
			CocktailDetail(data: data)
				.environment(\.managedObjectContext, DataModel.persistentContainer.viewContext)
		}
	}
}
