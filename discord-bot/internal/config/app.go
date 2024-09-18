package config

import (
	"os"
)

func getAppEnv() string {
	return os.Getenv("APP_ENV")
}

func IsLocal() bool {
	return getAppEnv() == "local"
}

func IsDevelopment() bool {
	return getAppEnv() == "development"
}

func IsStaging() bool {
	return getAppEnv() == "staging"
}

func IsProduction() bool {
	return getAppEnv() == "production"
}

func GetProjectID() string {
	return os.Getenv("PROJECT_ID")
}
