output "id" {
  value       = google_artifact_registry_repository.repo.id
  description = "ID of the created artifact registry with format `projects/{{project}}/locations/{{location}}/repositories/{{repository_id}}`."
}

output "name" {
  description = "Name of the created artifact registry, for example for example: `projects/p1/locations/us-central1/repositories/repo1`."
  value       = google_artifact_registry_repository.repo.name
}

output "url" {
  value       = format("%s-%s/%s/%s", google_artifact_registry_repository.repo.location, "docker.pkg.dev", google_artifact_registry_repository.repo.project, google_artifact_registry_repository.repo.name)
  description = "URL of the created artifact registry in the format `{{location}}-docker.pkg.dev/{{project}}/{{repository_name}}`"
}