import SwiftUI

struct ButtonFavorite: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?

	@Environment(\.managedObjectContext) private var managedObjectContext

	private func toggleFavorite() {
		if let entry = entry {
			managedObjectContext.perform {
				entry.favorite.toggle()
				DataModel.saveContext()
			}
		} else {
			managedObjectContext.perform {
				let entry = IngredientEntry(context: self.managedObjectContext)
				entry.id = self.data.id
				entry.favorite = true
				DataModel.saveContext()
			}
		}
	}

	var body: some View {
		Button(action: toggleFavorite) {
			Image(systemName: entry?.favorite ?? false ? "star.fill" : "star")
				.foregroundColor(.yellow)
		}
	}
}

struct ButtonOwned<Content>: View where Content: View {
	let data: IngredientData
	@Binding var entry: IngredientEntry?
	let content: (() -> Content)?

	@Environment(\.managedObjectContext) private var managedObjectContext

	private func toggleOwned() {
		if let entry = entry {
			managedObjectContext.perform {
				entry.owned.toggle()
				try? self.managedObjectContext.save()
			}
		} else {
			managedObjectContext.perform {
				let entry = IngredientEntry(context: self.managedObjectContext)
				entry.id = self.data.id
				entry.owned = true
				try? self.managedObjectContext.save()
			}
		}
	}

	var body: some View {
		let owned = entry?.owned ?? false
		return Button(action: toggleOwned) {
			Image(systemName: owned ? "checkmark" : "circle")
				.foregroundColor(owned ? .blue : .secondary)
				.frame(width: 24)
			content?()
		}
	}
}

struct IngredientButtons_Previews: PreviewProvider {
	static var previews: some View {
		IngredientDetail(data: IngredientData(id: "test", name: "test"), entry: .constant(nil))
	}
}
