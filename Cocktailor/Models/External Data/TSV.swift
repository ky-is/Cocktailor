import Foundation

struct TSV {
	static func cocktailData(_ name: String, process: ([String], [[String]]) -> Void) {
		guard let filepath = Bundle.main.path(forResource: "Cocktail Data - \(name)", ofType: "tsv") else {
			return print(#function, "TSV", name)
		}
		do {
			let contents = try String(contentsOfFile: filepath)
			var rows = contents.split(separator: "\r\n").map { $0.components(separatedBy: "\t") }
			let columns = rows.removeFirst()
			process(columns, rows)
		} catch {
			print(#function, name, error.localizedDescription)
		}
	}
}
