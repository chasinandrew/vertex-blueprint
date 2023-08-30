moved {
  from = google_secret_manager_secret.secret-basic
  to   = google_secret_manager_secret.secret_basic
}

moved {
  from = google_secret_manager_secret_version.secret-version-basic
  to   = google_secret_manager_secret_version.secret_version_basic
}