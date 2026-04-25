import TMDBKit

enum AppDependencies {
    static let movieClient = TMDBClient(
        configuration: TMDBConfiguration(
            authorization: .bearerToken("eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI5YmUyNmVmYzU2NTRiM2NkYmM3NmIzMTg5YmE2OTA3OSIsIm5iZiI6MTc3NzA3NzQ4Mi45NCwic3ViIjoiNjllYzBjZWEyMDVjMThmYzg0OTM1OWI1Iiwic2NvcGVzIjpbImFwaV9yZWFkIl0sInZlcnNpb24iOjF9.aZ29MtPvGG7uWehqZ9BVYmYzx7zLZsDonbd7EsQvoXE")
        )
    )
}
