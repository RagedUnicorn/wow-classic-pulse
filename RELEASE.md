# Release

> This document explains how a new release is created for Pulse

* Push all commits before proceeding
* Make sure `build-resources/release-notes.md` are up-to-date
* Make sure Metadata https://github.com/RagedUnicorn/wow-pulse-meta is up-to-date
* Create a GitHub deployment
  * mvn generate-resources -D generate.sources.overwrite=true -P release
  * mvn package -P deploy-github
* Create a CurseForge deployment
  * mvn generate-resources -D generate.sources.overwrite=true -P release
  * mvn package -P deploy-curseforge
* Update curseforge file id in `README.md`
  * [![](docs/curseforge.svg)](https://curseforge.overwolf.com/?addonId=[addon-id]&fileId=[file-id])
