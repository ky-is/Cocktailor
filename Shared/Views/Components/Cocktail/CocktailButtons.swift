import SwiftUI

struct CocktailButtonFavorite: View {
	let data: CocktailData
	@ObservedObject var entry: CocktailEntry

	@Environment(\.managedObjectContext) private var context

	init(data: CocktailData, entry: CocktailEntry?) {
		self.data = data
		self.entry = entry ?? CocktailEntry(id: data.id, insertInto: nil)
	}

	var body: some View {
		Button(action: toggleFavorite) {
			Image(systemName: entry.dateFavorited != nil ? "star.fill" : "star")
				.foregroundColor(.yellow)
		}
	}

	private func toggleFavorite() {
		context.performAndSave {
			self.context.insert(self.entry)
			self.entry.dateFavorited = self.entry.dateFavorited == nil ? Date() : nil
		}
	}
}

struct CocktailButtonMade: View {
	let data: CocktailData
	@ObservedObject var entry: CocktailEntry

	@Environment(\.managedObjectContext) private var context

	init(data: CocktailData, entry: CocktailEntry?) {
		self.data = data
		self.entry = entry ?? CocktailEntry(id: data.id, insertInto: nil)
	}

	var body: some View {
		let makings = self.entry.makings?.sortedArray(using: [NSSortDescriptor(keyPath: \CocktailMade.date, ascending: true)]) as? [CocktailMade]
		let date = makings?.first?.date
		return Button(action: toggleMade) {
			if date != nil {
				Text(date!.description)
			}
			Text("Made it!")
		}
	}

	private func toggleMade() {
		context.performAndSave {
			self.context.insert(self.entry)
			let made = CocktailMade(context: self.context)
			made.servings = 1 //TODO
			made.date = Date()
			made.cocktailEntry = self.entry
		}
	}
}

struct CocktailButtons_Previews: PreviewProvider {
	static let data = CocktailData.keyValues["bloodyMary"]!

	static var previews: some View {
		VStack {
			CocktailButtonFavorite(data: data, entry: nil)
			CocktailButtonMade(data: data, entry: nil)
		}
	}
}
