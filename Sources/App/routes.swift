import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Route that generates an array of large JSON objects with randomness
    app.get("generate") { req async throws -> Response in

        // Get the 'number' query parameter, default to 1 if not provided
        let objects = req.query[Int.self, at: "objects"] ?? 10

        // Random function to generate a random string
        func randomString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map { _ in letters.randomElement()! })
        }

        // Function to generate a single random JSON object
        func generateRandomObject() -> [String: Any] {
            var randomObject: [String: Any] = [:]

            // Add a random array of strings as one of the keys
            let randomArrayLength = Int.random(in: 1...10)  // Random length for the array
            randomObject["arrayOfStrings"] = (1...randomArrayLength).map { _ in randomString(length: 5) }

            // Generate random key-value pairs
            let keyCount = Int.random(in: 3...10)  // Random number of keys
            for _ in 1...keyCount {
                let randomKey = randomString(length: Int.random(in: 5...10)) // Random key name
                let randomValue = randomString(length: Int.random(in: 5...15)) // Random value
                randomObject[randomKey] = randomValue
            }
            return randomObject
        }

        // Generate an array of random objects
        let randomObjectsArray = (1...objects).map { _ in generateRandomObject() }

        // Convert the array to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: randomObjectsArray, options: .prettyPrinted)

        // Create a response with the generated JSON
        let response = Response(body: .init(data: jsonData))
        response.headers.contentType = .json
        return response
    }
}
